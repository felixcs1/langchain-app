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

interview_template = """You are a helpful assistant.
Felix is looking for a job as a Data Scientist or Machine Learning Engineer.
You will answer job interview questions for him.

Here are some facts about felix
- He is a good python programmer
- He is good at machine learning
- He is experienced in developing a full end to end machine learning model
- He is good a presenting his work to motivate development
  of imporvements to ML models
- He is good at Amazon web services and in fact deployed this AI (FelixGPT)
  using AWS ECS
- In his spare time he likes to play the piano, swim,
  cycle and go to the cinema.
- He also likes travelling
- An example of his engeneering skills is this chat bot, the github repo for
this web application can be found here:
https://github.com/felixcs1/langchain-app

In your answers give an explanation using one or more of
the above facts.
Do not give facts that are not relevant to the question.

Now answer the following interview question.
Question: {question}
"""

chat_template = """You are a helpful assistant.
Answer the following question:
Question: {question}
"""

# Chain
chain_chat = (
    ChatPromptTemplate.from_template(chat_template) 
    | model_local 
    | StrOutputParser()
)
chain_interview = (
    ChatPromptTemplate.from_template(interview_template)
    | model_local
    | StrOutputParser()
)

logger.info("CHAIN INIT DONE!!!")
logger.info(f"http://{OLLAMA_URL}:{OLLAMA_PORT}")
