from fastapi import FastAPI
from fastapi.responses import RedirectResponse
from langserve import add_routes


from app.chain import chain_simple

app = FastAPI()


# http://127.0.0.1:8000/nomic-rag/playground/
add_routes(app, chain_simple, path="/simple")

@app.get("/")
async def redirect_root_to_docs():
    print("HELLO WORLD!!!")
    return RedirectResponse("/docs")


# Edit this to add the chain you want to add
# add_routes(app, NotImplemented)

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
