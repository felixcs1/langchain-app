import os

from langchain_community.vectorstores import Chroma
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableLambda, RunnablePassthrough
from langchain_nomic import NomicEmbeddings
from langchain_nomic.embeddings import NomicEmbeddings

from langchain_community.document_loaders import WebBaseLoader

from langchain_community.chat_models import ChatOllama
from langchain_core.prompts import ChatPromptTemplate
from langchain_openai import ChatOpenAI
from langchain.text_splitter import CharacterTextSplitter
import tiktoken

urls = [
    # "https://ellipsedata.com/careers/",
    "https://www.cazoo.co.uk/car-details/b5b97b16-5345-5cc1-8744-403ce3bbdeaf/",
    "https://www.cazoo.co.uk/car-details/e0461d99-7dde-58db-a66b-bcfe5c2532da/"
]

docs = [WebBaseLoader(url).load() for url in urls]
docs_list = [item for sublist in docs for item in sublist]



text_splitter = CharacterTextSplitter.from_tiktoken_encoder(
    chunk_size=7500, chunk_overlap=1
)
doc_splits = text_splitter.split_documents(docs_list)



encoding = tiktoken.get_encoding("cl100k_base")
encoding = tiktoken.encoding_for_model("gpt-3.5-turbo")
for d in doc_splits:
    print("The document is %s tokens" % len(encoding.encode(d.page_content)))


# Add to vectorDB
vectorstore = Chroma.from_documents(
    documents=doc_splits,
    collection_name="rag-chroma",
    embedding=NomicEmbeddings(model="nomic-embed-text-v1"),
)
retriever = vectorstore.as_retriever()


# Prompt
template = """Answer the question based only on the following context:
{context}

Question: {question}
"""
prompt = ChatPromptTemplate.from_template(template)

# LLM API
model = ChatOpenAI(temperature=0, max_tokens=2, model="gpt-4-1106-preview")

# Local LLM
# ollama_llm = "mistral:instruct"
ollama_llm = "orca-mini:3b"
model_local = ChatOllama(model=ollama_llm)

# Chain
chain = (
    {"context": retriever, "question": RunnablePassthrough()}
    | prompt
    | model_local
    | StrOutputParser()
)