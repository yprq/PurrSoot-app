FROM python:3.9-slim

WORKDIR /app

# Flask kullanarak hızlıca bir API ayağa kaldıralım
RUN pip install flask

COPY . .

EXPOSE 5000

CMD ["python", "main.py"]
