# Step 1: Base image - lightweight Python runtime
FROM python:3.11-slim

# Step 2: Set working directory inside the container
WORKDIR /app

# Step 3: Prevent Python from writing .pyc files & enable unbuffered stdout for Docker logs
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Step 4: Copy dependency definition first (takes advantage of Docker layer caching)
COPY requirements.txt .

# Step 5: Install dependencies without storing pip cache (keeps image size tiny)
RUN pip install --no-cache-dir -r requirements.txt

# Step 6: Copy application code into container
COPY . .

# Step 7: Create a non-root system user for security hardening
RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

# Step 8: Document port exposed by the container
EXPOSE 8000

# Step 9: Production WSGI server (Gunicorn) with 2 workers
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--timeout", "60", "app:app"]
