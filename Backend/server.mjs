import crypto from "node:crypto";
import fs from "node:fs/promises";
import http from "node:http";
import path from "node:path";

const config = {
  host: process.env.HOST || "0.0.0.0",
  port: Number(process.env.PORT || 8080),
  openAIAPIKey: process.env.OPENAI_API_KEY,
  openAIModel: process.env.OPENAI_MODEL || "gpt-5.4-mini",
  dataDir: process.env.DATA_DIR || path.join(process.cwd(), "data"),
  freeMonthlyLimit: Number(process.env.FREE_MONTHLY_LIMIT || 30),
  maxMessageChars: Number(process.env.MAX_MESSAGE_CHARS || 4000),
  maxRequestBytes: Number(process.env.MAX_REQUEST_BYTES || 65_536),
  rateLimitWindowMs: Number(process.env.RATE_LIMIT_WINDOW_MS || 60_000),
  rateLimitMaxRequests: Number(process.env.RATE_LIMIT_MAX_REQUESTS || 25),
  allowedOrigins: (process.env.ALLOWED_ORIGINS || "")
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean),
  bundleID: process.env.APPLE_BUNDLE_ID || "com.kyledensley.dicho",
  subscriptionProductID: process.env.SUBSCRIPTION_PRODUCT_ID || "dicho.pro.monthly",
  allowUnsignedStoreKitJWS: process.env.ALLOW_UNSIGNED_STOREKIT_JWS === "true"
};

const countries = {
  mexico: {
    displayName: "Mexico",
    promptGuidance: "Mexican Spanish. Prefer warm, clear phrasing. Use slang only when it genuinely fits the message."
  },
  spain: {
    displayName: "Spain",
    promptGuidance: "European Spanish from Spain. Use vosotros only when a native speaker would naturally use it."
  },
  colombia: {
    displayName: "Colombia",
    promptGuidance: "Colombian Spanish. Keep warmth and politeness in mind; avoid overdoing regional slang."
  },
  argentina: {
    displayName: "Argentina",
    promptGuidance: "Argentine Spanish. Use voseo naturally when appropriate, and avoid mixing it with Mexican or Caribbean wording."
  },
  chile: {
    displayName: "Chile",
    promptGuidance: "Chilean Spanish. Explain Chile-specific idioms when present; keep replies understandable and natural."
  },
  peru: {
    displayName: "Peru",
    promptGuidance: "Peruvian Spanish. Favor respectful, conversational phrasing; avoid forced slang."
  },
  puertoRico: {
    displayName: "Puerto Rico",
    promptGuidance: "Puerto Rican Spanish. Recognize Caribbean rhythm and idioms, but keep replies readable and context-sensitive."
  },
  unitedStates: {
    displayName: "U.S. Spanish",
    promptGuidance: "Spanish used by bilingual speakers in the United States. Allow natural code-switching only when the user asks for it or the context strongly suggests it."
  }
};

const instructions = `
You are Dicho, a bilingual Spanish-English translator for private messages.

Detect whether the user entered English or Spanish.
- If the input is primarily English, translate it into natural Spanish for the selected country.
- If the input is primarily Spanish, translate it into natural English.
- If the input is mixed English and Spanish, translate the dominant intent into the other language and preserve names, links, emojis, and formatting when useful.

Translate meaning, tone, and intent instead of word-for-word phrasing. When translating into Spanish, prioritize the selected country's natural wording. Do not force slang. Avoid stereotypes and say when a regional inference is uncertain.

Return only JSON that matches the schema.
`.trim();

const outputSchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "sourceLanguage",
    "targetLanguage",
    "directionLabel",
    "translation",
    "nuance",
    "countryNotes",
    "confidence"
  ],
  properties: {
    sourceLanguage: {
      type: "string",
      description: "The detected source language, such as English, Spanish, Mixed, or Unknown."
    },
    targetLanguage: {
      type: "string",
      description: "The language translated into, usually English or Spanish."
    },
    directionLabel: {
      type: "string",
      description: "A short label like English to Mexican Spanish or Spanish to English."
    },
    translation: {
      type: "string",
      description: "The primary translation to show and copy."
    },
    nuance: {
      type: "string",
      description: "A concise explanation of tone, idiom, or why the translation is natural."
    },
    countryNotes: {
      type: "array",
      items: { type: "string" },
      description: "Country-specific notes. Return an empty array when none are needed."
    },
    confidence: {
      type: "string",
      description: "A concise confidence label such as High, Medium, or Low with uncertainty if needed."
    }
  }
};

class UsageStore {
  constructor(filePath) {
    this.filePath = filePath;
    this.data = { periods: {} };
    this.writePromise = Promise.resolve();
  }

  async load() {
    await fs.mkdir(path.dirname(this.filePath), { recursive: true });

    try {
      const rawData = await fs.readFile(this.filePath, "utf8");
      this.data = JSON.parse(rawData);
      this.data.periods ||= {};
    } catch (error) {
      if (error.code !== "ENOENT") {
        throw error;
      }
    }
  }

  remaining(clientID, period, limit) {
    return Math.max(0, limit - this.count(clientID, period));
  }

  count(clientID, period) {
    return this.data.periods?.[period]?.[clientID]?.count || 0;
  }

  async consume(clientID, period) {
    this.data.periods[period] ||= {};
    this.data.periods[period][clientID] ||= { count: 0, updatedAt: null };
    this.data.periods[period][clientID].count += 1;
    this.data.periods[period][clientID].updatedAt = new Date().toISOString();
    await this.save();
    return this.data.periods[period][clientID];
  }

  async save() {
    this.writePromise = this.writePromise.then(async () => {
      const temporaryPath = `${this.filePath}.tmp`;
      await fs.writeFile(temporaryPath, `${JSON.stringify(this.data, null, 2)}\n`);
      await fs.rename(temporaryPath, this.filePath);
    });

    await this.writePromise;
  }
}

class SlidingWindowRateLimiter {
  constructor(windowMs, maxRequests) {
    this.windowMs = windowMs;
    this.maxRequests = maxRequests;
    this.buckets = new Map();
  }

  check(key) {
    const now = Date.now();
    const windowStart = now - this.windowMs;
    const timestamps = (this.buckets.get(key) || []).filter((timestamp) => timestamp > windowStart);
    const allowed = timestamps.length < this.maxRequests;

    if (allowed) {
      timestamps.push(now);
    }

    if (timestamps.length > 0) {
      this.buckets.set(key, timestamps);
    } else {
      this.buckets.delete(key);
    }

    return {
      allowed,
      remaining: Math.max(0, this.maxRequests - timestamps.length),
      resetAt: timestamps[0] ? timestamps[0] + this.windowMs : now + this.windowMs
    };
  }
}

const usageStore = new UsageStore(path.join(config.dataDir, "usage.json"));
const rateLimiter = new SlidingWindowRateLimiter(config.rateLimitWindowMs, config.rateLimitMaxRequests);

await usageStore.load();

const server = http.createServer(async (request, response) => {
  const requestID = crypto.randomUUID();
  response.setHeader("X-Dicho-Request-ID", requestID);

  try {
    if (request.method === "OPTIONS") {
      applyCORS(request, response);
      response.writeHead(204);
      response.end();
      return;
    }

    applyCORS(request, response);
    const url = new URL(request.url || "/", "http://localhost");

    if (request.method === "GET" && url.pathname === "/health") {
      sendJSON(response, 200, { ok: true, service: "dicho-backend" });
      return;
    }

    if (request.method === "GET" && url.pathname === "/ready") {
      sendJSON(response, config.openAIAPIKey ? 200 : 503, {
        ok: Boolean(config.openAIAPIKey),
        openAIConfigured: Boolean(config.openAIAPIKey),
        freeMonthlyLimit: config.freeMonthlyLimit
      });
      return;
    }

    if (!checkRateLimit(request, response, requestID)) {
      return;
    }

    if (request.method === "POST" && url.pathname === "/v1/translate") {
      await handleTranslate(request, response, requestID);
      return;
    }

    sendJSON(response, 404, { error: "not_found", message: "Not found." });
  } catch (error) {
    const statusCode = error.statusCode || (error instanceof SyntaxError ? 400 : 500);
    const message = statusCode === 400
      ? "Invalid JSON request body."
      : statusCode === 413
        ? "Request body is too large."
        : "Unexpected server error.";

    log("error", "request_error", {
      requestID,
      statusCode,
      error: error instanceof Error ? error.message : String(error)
    });

    sendJSON(response, statusCode, {
      error: statusCode === 400 ? "invalid_json" : statusCode === 413 ? "request_too_large" : "server_error",
      message
    });
  }
});

server.listen(config.port, config.host, () => {
  log("info", "server_started", {
    host: config.host,
    port: config.port,
    freeMonthlyLimit: config.freeMonthlyLimit,
    openAIConfigured: Boolean(config.openAIAPIKey)
  });
});

for (const signal of ["SIGINT", "SIGTERM"]) {
  process.on(signal, () => {
    log("info", "server_stopping", { signal });
    server.close(() => {
      log("info", "server_stopped", { signal });
      process.exit(0);
    });

    setTimeout(() => {
      log("error", "server_forced_shutdown", { signal });
      process.exit(1);
    }, 10_000).unref();
  });
}

async function handleTranslate(request, response, requestID) {
  if (!config.openAIAPIKey) {
    sendJSON(response, 503, {
      error: "openai_not_configured",
      message: "dicho is temporarily unavailable."
    });
    return;
  }

  const body = await readJSON(request, config.maxRequestBytes);
  const message = typeof body.message === "string" ? body.message.trim() : "";
  const countryKey = typeof body.country === "string" ? body.country : "mexico";
  const clientID = normalizeClientID(body.clientID, request);
  const country = countries[countryKey] || countries.mexico;
  const entitlement = await verifyEntitlement(body.entitlementJWS);
  const hasActiveSubscription = entitlement.active;

  if (!message) {
    sendJSON(response, 400, { error: "missing_message", message: "Enter a message to translate." });
    return;
  }

  if (message.length > config.maxMessageChars) {
    sendJSON(response, 413, {
      error: "message_too_long",
      message: `Messages can be up to ${config.maxMessageChars} characters.`
    });
    return;
  }

  const period = currentPeriodKey();
  const remainingBefore = hasActiveSubscription
    ? null
    : usageStore.remaining(clientID, period, config.freeMonthlyLimit);

  if (!hasActiveSubscription && remainingBefore <= 0) {
    response.setHeader("X-Dicho-Free-Remaining", "0");
    sendJSON(response, 402, {
      error: "free_limit_reached",
      message: "You used your free translations for this month. Upgrade to keep translating.",
      freeTranslationsRemaining: 0
    });
    return;
  }

  log("info", "translation_requested", {
    requestID,
    clientIDHash: hashValue(clientID),
    country: country.displayName,
    messageLength: message.length,
    subscribed: hasActiveSubscription
  });

  const openAIResponse = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${config.openAIAPIKey}`,
      "Content-Type": "application/json"
    },
    body: JSON.stringify({
      model: config.openAIModel,
      instructions,
      input: userInput(message, country),
      max_output_tokens: 700,
      text: {
        format: {
          type: "json_schema",
          name: "dicho_translation",
          strict: true,
          schema: outputSchema
        }
      }
    })
  });

  const responseBody = await openAIResponse.text();

  if (!openAIResponse.ok) {
    log("warn", "openai_error", {
      requestID,
      status: openAIResponse.status
    });
    sendJSON(response, openAIResponse.status, normalizeOpenAIError(responseBody));
    return;
  }

  const parsed = JSON.parse(responseBody);
  const outputText = extractOutputText(parsed);

  if (!outputText) {
    sendJSON(response, 502, {
      error: "missing_model_output",
      message: "The translation service did not return a result."
    });
    return;
  }

  const translation = JSON.parse(outputText);
  let remainingAfter = null;

  if (!hasActiveSubscription) {
    const usage = await usageStore.consume(clientID, period);
    remainingAfter = Math.max(0, config.freeMonthlyLimit - usage.count);
    response.setHeader("X-Dicho-Free-Remaining", String(remainingAfter));
  }

  log("info", "translation_completed", {
    requestID,
    clientIDHash: hashValue(clientID),
    subscribed: hasActiveSubscription,
    freeTranslationsRemaining: remainingAfter
  });

  sendJSON(response, 200, translation);
}

function applyCORS(request, response) {
  const origin = request.headers.origin;
  const allowOrigin = origin && config.allowedOrigins.includes(origin) ? origin : "";

  if (allowOrigin) {
    response.setHeader("Access-Control-Allow-Origin", allowOrigin);
    response.setHeader("Vary", "Origin");
  }

  response.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS");
  response.setHeader("Access-Control-Allow-Headers", "Content-Type,X-Dicho-Client-Version,X-Dicho-Install-ID");
}

function checkRateLimit(request, response, requestID) {
  const clientKey = request.headers["x-forwarded-for"]?.split(",")[0]?.trim()
    || request.socket.remoteAddress
    || "unknown";
  const result = rateLimiter.check(clientKey);

  response.setHeader("X-RateLimit-Limit", String(config.rateLimitMaxRequests));
  response.setHeader("X-RateLimit-Remaining", String(result.remaining));
  response.setHeader("X-RateLimit-Reset", String(Math.ceil(result.resetAt / 1000)));

  if (result.allowed) {
    return true;
  }

  log("warn", "rate_limited", { requestID, clientKeyHash: hashValue(clientKey) });
  sendJSON(response, 429, {
    error: "rate_limited",
    message: "Too many requests. Please wait a moment and try again."
  });
  return false;
}

function normalizeClientID(rawClientID, request) {
  if (typeof rawClientID === "string" && /^[A-Za-z0-9._:-]{16,128}$/.test(rawClientID)) {
    return rawClientID;
  }

  const fallback = request.socket.remoteAddress || "unknown";
  return `ip:${fallback}`;
}

async function verifyEntitlement(entitlementJWS) {
  if (typeof entitlementJWS !== "string" || !entitlementJWS) {
    return { active: false, reason: "missing" };
  }

  const decoded = decodeJWS(entitlementJWS);
  if (!decoded) {
    return { active: false, reason: "invalid_jws" };
  }

  if (!config.allowUnsignedStoreKitJWS && !verifyStoreKitJWSSignature(entitlementJWS, decoded.header)) {
    return { active: false, reason: "invalid_signature" };
  }

  const payload = decoded.payload;
  const expiresDate = Number(payload.expiresDate || 0);
  const productID = payload.productId || payload.productID;
  const bundleID = payload.bundleId || payload.bundleID;
  const isRevoked = Boolean(payload.revocationDate);
  const isExpired = expiresDate > 0 && expiresDate <= Date.now();

  if (productID !== config.subscriptionProductID) {
    return { active: false, reason: "wrong_product" };
  }

  if (bundleID && bundleID !== config.bundleID) {
    return { active: false, reason: "wrong_bundle" };
  }

  if (isRevoked || isExpired) {
    return { active: false, reason: isRevoked ? "revoked" : "expired" };
  }

  return { active: true, productID, expiresDate };
}

function decodeJWS(jws) {
  const parts = jws.split(".");
  if (parts.length !== 3) {
    return null;
  }

  try {
    return {
      header: JSON.parse(Buffer.from(parts[0], "base64url").toString("utf8")),
      payload: JSON.parse(Buffer.from(parts[1], "base64url").toString("utf8")),
      signature: parts[2],
      signingInput: `${parts[0]}.${parts[1]}`
    };
  } catch {
    return null;
  }
}

function verifyStoreKitJWSSignature(jws, header) {
  const parts = jws.split(".");
  const x5c = Array.isArray(header?.x5c) ? header.x5c : [];

  if (parts.length !== 3 || x5c.length === 0) {
    return false;
  }

  try {
    const leafCertificate = new crypto.X509Certificate(`-----BEGIN CERTIFICATE-----\n${x5c[0]}\n-----END CERTIFICATE-----`);
    const verifier = crypto.createVerify("sha256");
    verifier.update(`${parts[0]}.${parts[1]}`);
    verifier.end();
    return verifier.verify(leafCertificate.publicKey, Buffer.from(parts[2], "base64url"));
  } catch {
    return false;
  }
}

function userInput(message, country) {
  return `
Incoming message:
${message}

Target country for reply:
${country.displayName}

Country guidance:
${country.promptGuidance}
`.trim();
}

function extractOutputText(apiResponse) {
  return (apiResponse.output || [])
    .flatMap((item) => item.content || [])
    .map((content) => content.text || "")
    .join("");
}

function normalizeOpenAIError(responseBody) {
  try {
    const parsed = JSON.parse(responseBody);
    return {
      error: "translation_provider_error",
      message: parsed.error?.message || "Translation service request failed."
    };
  } catch {
    return {
      error: "translation_provider_error",
      message: "Translation service request failed."
    };
  }
}

async function readJSON(request, maxBytes) {
  const chunks = [];
  let size = 0;

  for await (const chunk of request) {
    size += chunk.length;

    if (size > maxBytes) {
      throw Object.assign(new Error("Request body is too large."), { statusCode: 413 });
    }

    chunks.push(chunk);
  }

  const rawBody = Buffer.concat(chunks).toString("utf8");
  return rawBody ? JSON.parse(rawBody) : {};
}

function sendJSON(response, status, body) {
  response.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store"
  });
  response.end(JSON.stringify(body));
}

function currentPeriodKey(date = new Date()) {
  return `${date.getUTCFullYear()}-${String(date.getUTCMonth() + 1).padStart(2, "0")}`;
}

function hashValue(value) {
  return crypto.createHash("sha256").update(value).digest("hex").slice(0, 16);
}

function log(level, event, fields = {}) {
  console.log(JSON.stringify({
    level,
    event,
    timestamp: new Date().toISOString(),
    ...fields
  }));
}
