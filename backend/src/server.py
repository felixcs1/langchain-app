import logging

import requests
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from langserve import add_routes
from requests.exceptions import ChunkedEncodingError
from src.chain import chain_chat, chain_interview
from src.config import OLLAMA_PORT, OLLAMA_URL
from starlette.background import BackgroundTasks

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

app = FastAPI()
# This is needed for calling the api from a brower application
# Set all CORS enabled origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)


# Try not using access point for EFS mount
def pull_model():
    logger.info("downloading model")
    response = requests.post(
        f"http://{OLLAMA_URL}:{OLLAMA_PORT}/api/pull",
        json={"model": "orca-mini:3b", "name": "orca-mini:3b"},
    )
    try:
        for data in response.iter_content(chunk_size=1024):
            logger.info(data)
    except ChunkedEncodingError as ex:
        logger.error(f"Invalid chunk encoding {str(ex)}")


@app.on_event("startup")
async def startup_event():
    background_tasks = BackgroundTasks()
    background_tasks.add_task(pull_model)
    await background_tasks()
    logger.info("background tasks done")


# http://domain/simple
add_routes(app, chain_chat, path="/chat")
add_routes(app, chain_interview, path="/interview")


@app.get("/")
async def redirect_root_to_docs():
    logger.info("Direct to docs")
    response = requests.get("http://www.google.com")
    logger.info(f"Pinged google, with status: {response.status_code}")
    return RedirectResponse("/docs")


@app.get("/healthz")
async def healthz():
    return "Healthy"


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)

    #  curl -X POST http://127.0.0.1:11434/api/pull
    # -d '{"model": "orca-mini:3b", "name": "orca-mini:3b"}'
