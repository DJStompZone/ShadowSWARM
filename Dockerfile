FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy specific files
COPY requirements.txt .
COPY banner.sh .
COPY app.py .
COPY bootstrap.sh .

# Install dependencies and make scripts executable
RUN chmod +x banner.sh bootstrap.sh && \
    bash banner.sh && \
    python3 -m pip install --no-cache-dir -r requirements.txt

# Default command
CMD ["python3", "app.py"]
