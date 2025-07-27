FROM alpine:3.20

LABEL maintainer="sec77 https://github.com/secure-77/Perlite"

# ------------------------------
# Install dependencies including Google Cloud SDK
# ------------------------------
RUN apk add --no-cache \
    nginx \
    php82 \
    php82-fpm \
    php82-pecl-yaml \
    php82-opcache \
    php82-mbstring \
    php82-session \
    php82-json \
    php82-iconv \
    php82-fileinfo \
    php82-curl \
    php82-dom \
    php82-tokenizer \
    php82-simplexml \
    supervisor \
    curl \
    bash \
    python3 \
    py3-pip \
    wget \
    tar

# Install Google Cloud SDK
RUN wget https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-456.0.0-linux-x86_64.tar.gz \
    -O /tmp/google-cloud-sdk.tar.gz && \
    mkdir -p /usr/local/gcloud && \
    tar -C /usr/local/gcloud -xvzf /tmp/google-cloud-sdk.tar.gz && \
    /usr/local/gcloud/google-cloud-sdk/install.sh --quiet && \
    rm /tmp/google-cloud-sdk.tar.gz

# Add gcloud and gsutil to PATH
ENV PATH="/usr/local/gcloud/google-cloud-sdk/bin:$PATH"

# Create virtual environment and install Google Cloud Storage Python SDK
RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --upgrade pip && \
    pip install google-cloud-storage

# Make virtual environment available globally
ENV PATH="/opt/venv/bin:$PATH"

# ------------------------------
# Set working directory
# ------------------------------
WORKDIR /var/www/perlite

# ------------------------------
# Copy Perlite PHP files
# ------------------------------
COPY ./index.php ./
COPY ./helper.php ./
COPY ./content.php ./
COPY ./settings.php ./
COPY ./*.svg ./
COPY ./*.ico ./
COPY ./.styles/ ./.styles/
COPY ./.js/ ./.js/
COPY ./.src/ ./.src/
COPY ./vendor/ ./vendor/

# ------------------------------
# Copy config files
# ------------------------------
COPY nginx.conf /etc/nginx/nginx.conf
COPY php-fpm.conf /etc/php82/php-fpm.conf
COPY supervisord.conf /etc/supervisord.conf

# ------------------------------
# Copy entrypoint script
# ------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ------------------------------
# Volume for Obsidian vault (used by GCS sync)
# ------------------------------
VOLUME /var/www/perlite/Demo

# ------------------------------
# Expose HTTP port
# ------------------------------
EXPOSE 80

# ------------------------------
# Set startup command to the entrypoint
# ------------------------------
ENTRYPOINT ["/entrypoint.sh"]

# ------------------------------
# Default command
# ------------------------------
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
