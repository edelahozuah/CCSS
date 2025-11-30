FROM alpine:3.20

# Herramientas básicas + toolchain para compilar dependencias de Python
RUN apk add --no-cache \
      bash \
      curl \
      openssl \
      python3 \
      py3-pip \
      python3-dev \
      nano \
      bind-tools \
      build-base \
      gmp \
      gmp-dev \
      mpfr-dev \
      mpc1-dev

# Crear un entorno virtual para evitar el problema PEP 668
RUN python3 -m venv /opt/venv \
 && /opt/venv/bin/pip install --no-cache-dir badkeys pycryptodome

# Usar el venv por defecto en el PATH
ENV PATH="/opt/venv/bin:$PATH"

WORKDIR /lab

CMD ["sleep", "infinity"]
