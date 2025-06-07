FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y default-mysql-client && rm -rf /var/lib/apt/lists/*

COPY ./backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./backend/ .

RUN chmod +x wait-for-it.sh

ENV DB_HOST=db
ENV DB_USER=root
ENV DB_PASSWORD=Test123456
ENV DB_NAME=grocery_store

EXPOSE 5000

CMD ["python", "server.py"]
