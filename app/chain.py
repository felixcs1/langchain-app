import os

from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough
from langchain_community.chat_models import ChatOllama
from langchain_core.prompts import ChatPromptTemplate


# Prompt
ollama_llm = "orca-mini:3b"
model_local = ChatOllama(model=ollama_llm, base_url="http://ollama:11434")

template = """Answer the question,
Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

# Chain
chain_simple = (
     prompt
    | model_local
    | StrOutputParser()
)

print("CHAIN INIT DONE!!!")