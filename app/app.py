from flask import Flask
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests to the root endpoint."
)

@app.route("/")
def hello():
    REQUEST_COUNT.inc()
    return "Hello from Flask with Prometheus metrics!\n"

@app.route("/metrics")
def metrics():
    data = generate_latest()
    return data, 200, {"Content-Type": CONTENT_TYPE_LATEST}

if __name__ == "__main__":
    # Bind to 0.0.0.0 so container traffic works
    app.run(host="0.0.0.0", port=5000)
