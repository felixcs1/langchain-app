import logging

from langchain_community.chat_models import ChatOllama
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate
from src.config import OLLAMA_PORT, OLLAMA_URL

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger(__name__)

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

logger.info("CHAIN INIT DONE!!!")
logger.info(f"http://{OLLAMA_URL}:{OLLAMA_PORT}")
