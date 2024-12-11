# Use the official Ubuntu image as the base image
FROM ubuntu:24.04

# Set environment variables to avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV DOCKERMODE=true

# Install necessary packages for Xvfb and pyvirtualdisplay
RUN apt-get update && \
    apt-get install -y \
        python3 \
        python3-pip \
        python3-venv \
        virtualenv \
        gnupg \
        ca-certificates \
        libx11-xcb1 \
        libxcomposite1 \
        libxdamage1 \
        libxrandr2 \
        libxss1 \
        libxtst6 \
        libnss3 \
        libatk-bridge2.0-0 \
        libgtk-3-0 \
        x11-apps \
        fonts-liberation \
        libappindicator3-1 \
        libu2f-udev \
        libvulkan1 \
        libdrm2 \
        xdg-utils \
        xvfb \
        wget \
        tinyproxy \
        supervisor \
        && rm -rf /var/lib/apt/lists/*

# Add Google Chrome repository and install Google Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable

# Install Python dependencies including pyvirtualdisplay

COPY docker/service/conf/supervisor-app.conf /etc/supervisor/conf.d/
COPY docker/service/conf/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf

# Set up a working directory
WORKDIR /app
RUN python3 -m venv /app/venv
ENV PATH=/app/venv/bin:$PATH
RUN pip3 install --upgrade pip
RUN pip3 install pyvirtualdisplay
# Copy application files
COPY . .

# Install Python dependencies
RUN pip3 install -r requirements.txt
RUN pip3 install -r server_requirements.txt

# Expose the port for remote debugging
EXPOSE 9222

# Expose the port for the FastAPI server
EXPOSE 8000

# Expose TinyProxy Server Port
EXPOSE 8888

# Default command
CMD ["supervisord", "-n"]
