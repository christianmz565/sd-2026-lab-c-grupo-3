FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    openmpi-bin \
    libopenmpi-dev \
    build-essential \
    openssh-server \
    wget \
    dnsutils \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN wget https://github.com/sharkdp/hyperfine/releases/download/v1.16.1/hyperfine_1.16.1_amd64.deb \
    && dpkg -i hyperfine_1.16.1_amd64.deb \
    && rm hyperfine_1.16.1_amd64.deb

RUN mkdir -p /var/run/sshd
RUN echo 'root:mpi' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

RUN ssh-keygen -t rsa -f /root/.ssh/id_rsa -N "" \
    && cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys \
    && chmod 600 /root/.ssh/authorized_keys \
    && echo "Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile=/dev/null" > /root/.ssh/config

WORKDIR /app

COPY pyproject.toml .
COPY uv.lock .

RUN uv pip install --system mpi4py pandas scikit-learn joblib

COPY . .

ENV PYTHONPATH=/app/src
ENV PYTHONUNBUFFERED=1

CMD ["/usr/sbin/sshd", "-D"]
