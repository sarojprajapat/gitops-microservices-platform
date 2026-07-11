# Base image — halka Python version, production ke liye "slim" use karte (poora OS nahi, kam size)
FROM python:3.12-slim

# Container ke andar working folder
WORKDIR /app

# Pehle sirf requirements copy karo (dependency install), code baad me — 
# isse Docker cache use hota, code badalne pe dependency dobara install nahi karni padti
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Ab poora app code copy karo
COPY . .

# Batao ye container kis port pe app serve karega
EXPOSE 8000

# Container start hote hi ye command chalegi
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]