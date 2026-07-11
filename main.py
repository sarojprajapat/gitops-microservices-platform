from fastapi import FastAPI
from prometheus_fastapi_instrumentator import Instrumentator
import socket

app = FastAPI()

# Ye line automatically ek "/metrics" endpoint bana degi jaha
# request-count, response-time, status-codes jaisa data expose hoga —
# Prometheus wahan se scrape (collect) karega
Instrumentator().instrument(app).expose(app)

@app.get("/")
def read_root():
    return {
        "message": "Hello from GitOps Microservices Platform!",
        "hostname": socket.gethostname()   # ye pod ka naam dikhayega k8s me — proof ki load balancing ho rahi
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}