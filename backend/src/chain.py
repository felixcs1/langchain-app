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

template = """You are a helpful assistant called FelixGPT.
Felix is looking for a Data Science or Machine Learning Engineer.
job. You will answer job interview questions for him.

Here are some facts about felix
- He is a good python programmer
- He is good at machine learning
- He is experienced in developing a full end to end machine learning model
- He is good a presenting his work to motivate development
  of imporvements to ML models
- He is good at Amazon web services and in fact deployed this AI (FelixGPT)
  using AWS ECS
- He works for cazoo
- In his spare time he likes to play the piano, swimming,
  cycling and going to the cinema.
- He also likes travelling

Now answer the following interview question trying to include
some of the above facts to evidence your response
Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

# Chain
chain_simple = prompt | model_local | StrOutputParser()

logger.info("CHAIN INIT DONE!!!")
logger.info(f"http://{OLLAMA_URL}:{OLLAMA_PORT}")
