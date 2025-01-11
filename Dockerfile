FROM nvidia/cuda:12.1.1-base-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/root/.local/bin:$PATH"

RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN python3 -m pip install --no-cache-dir -r requirements.txt

WORKDIR /app
COPY . /app

CMD ["bash", "banner.sh"]
CMD ["python3", "app.py"]
