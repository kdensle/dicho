import http from "node:http";

const host = process.env.HEALTHCHECK_HOST || "127.0.0.1";
const port = Number(process.env.PORT || 8080);

const request = http.request({
  host,
  port,
  path: "/health",
  method: "GET",
  timeout: 3000
}, (response) => {
  response.resume();

  if (response.statusCode && response.statusCode >= 200 && response.statusCode < 300) {
    process.exit(0);
  }

  console.error(`Healthcheck failed with status ${response.statusCode}.`);
  process.exit(1);
});

request.on("timeout", () => {
  request.destroy(new Error("Healthcheck timed out."));
});

request.on("error", (error) => {
  console.error(error.message);
  process.exit(1);
});

request.end();
