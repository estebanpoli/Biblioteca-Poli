FROM python:3.11-slim

WORKDIR /app

COPY app/ .                    
COPY app/test/ test/          
COPY requirements.txt .        
RUN pip install -r requirements.txt

CMD ["python", "app.py"]
