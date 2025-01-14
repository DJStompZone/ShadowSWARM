FROM nvidia/cuda:12.4.0-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip dos2unix \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
COPY banner.sh .
COPY app.py .
COPY bootstrap.sh .
COPY .env .

RUN dos2unix banner.sh bootstrap.sh && \
    chmod +x banner.sh bootstrap.sh

RUN bash banner.sh && \
    python3 -m pip install --no-cache-dir -r requirements.txt

CMD ["python3", "app.py"]
