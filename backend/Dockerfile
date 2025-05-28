FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Create a startup script to handle PORT environment variable properly
RUN echo '#!/bin/bash\n\
PORT=${PORT:-8000}\n\
echo "Starting server on port: $PORT"\n\
exec uvicorn main:app --host 0.0.0.0 --port $PORT' > /app/start.sh \
    && chmod +x /app/start.sh

# Expose port (note: this is just documentation, Railway will still use its own PORT)
EXPOSE 8000

# Use the startup script
CMD ["/app/start.sh"]
