from langchain_community.chat_models import ChatOllama
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate

from app.config import OLLAMA_PORT, OLLAMA_URL

# Prompt
ollama_llm = "orca-mini:3b"
model_local = ChatOllama(
    model=ollama_llm, base_url=f"http://{OLLAMA_URL}:{OLLAMA_PORT}"
)

template = """Answer the question,
Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

# Chain
chain_simple = prompt | model_local | StrOutputParser()

print("CHAIN INIT DONE!!!")
