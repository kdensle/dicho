const strict = process.argv.includes("--strict");

const checks = [
  {
    key: "OPENAI_API_KEY",
    required: true,
    validate: (value) => value.startsWith("sk-"),
    message: "Set this as a secret on the backend host. Never ship it in the app."
  },
  {
    key: "OPENAI_MODEL",
    required: false,
    defaultValue: "gpt-5.4-mini"
  },
  {
    key: "HOST",
    required: false,
    defaultValue: "0.0.0.0"
  },
  {
    key: "PORT",
    required: false,
    defaultValue: "8080",
    validate: (value) => Number.isInteger(Number(value)) && Number(value) > 0
  },
  {
    key: "DATA_DIR",
    required: false,
    defaultValue: "./data"
  },
  {
    key: "FREE_MONTHLY_LIMIT",
    required: false,
    defaultValue: "30",
    validate: (value) => Number.isInteger(Number(value)) && Number(value) >= 0
  },
  {
    key: "MAX_MESSAGE_CHARS",
    required: false,
    defaultValue: "4000",
    validate: (value) => Number.isInteger(Number(value)) && Number(value) > 0
  },
  {
    key: "MAX_REQUEST_BYTES",
    required: false,
    defaultValue: "65536",
    validate: (value) => Number.isInteger(Number(value)) && Number(value) >= 8192
  },
  {
    key: "RATE_LIMIT_WINDOW_MS",
    required: false,
    defaultValue: "60000",
    validate: (value) => Number.isInteger(Number(value)) && Number(value) > 0
  },
  {
    key: "RATE_LIMIT_MAX_REQUESTS",
    required: false,
    defaultValue: "25",
    validate: (value) => Number.isInteger(Number(value)) && Number(value) > 0
  },
  {
    key: "APPLE_BUNDLE_ID",
    required: true,
    validate: (value) => /^[A-Za-z0-9.-]+$/.test(value)
  },
  {
    key: "SUBSCRIPTION_PRODUCT_ID",
    required: true,
    validate: (value) => /^[A-Za-z0-9._-]+$/.test(value)
  },
  {
    key: "ALLOW_UNSIGNED_STOREKIT_JWS",
    required: false,
    defaultValue: "false",
    validate: (value) => value === "true" || value === "false",
    message: "Keep false in production."
  },
  {
    key: "ALLOWED_ORIGINS",
    required: false,
    defaultValue: ""
  }
];

let failures = 0;

for (const check of checks) {
  const value = process.env[check.key] ?? check.defaultValue ?? "";
  const missing = check.required && !process.env[check.key];
  const invalid = value && check.validate ? !check.validate(value) : false;

  if (missing || invalid) {
    failures += 1;
  }

  const status = missing ? "missing" : invalid ? "invalid" : process.env[check.key] ? "set" : "default";
  const shownValue = check.key.includes("KEY") && value ? "[redacted]" : value || "(empty)";
  console.log(`${status.padEnd(8)} ${check.key}=${shownValue}`);

  if (check.message) {
    console.log(`         ${check.message}`);
  }
}

if (failures > 0) {
  console.error(`\n${failures} production environment check(s) need attention.`);
  process.exit(strict ? 1 : 0);
}

console.log("\nBackend environment looks launch-ready.");
