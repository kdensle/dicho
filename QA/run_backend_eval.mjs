import fs from "node:fs/promises";

const apiBaseURL = process.env.DICHO_API_BASE_URL || "http://127.0.0.1:8080";
const casesPath = new URL("./translation_eval_cases.json", import.meta.url);
const cases = JSON.parse(await fs.readFile(casesPath, "utf8"));

for (const testCase of cases) {
  const response = await fetch(`${apiBaseURL}/v1/translate`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Dicho-Client-Version": "dicho-eval/1"
    },
    body: JSON.stringify({
      message: testCase.message,
      country: testCase.country,
      countryDisplayName: testCase.country,
      clientID: `eval-${testCase.id}`
    })
  });

  const body = await response.json().catch(() => ({}));
  console.log(JSON.stringify({
    id: testCase.id,
    status: response.status,
    checks: testCase.checks,
    result: body
  }, null, 2));
}
