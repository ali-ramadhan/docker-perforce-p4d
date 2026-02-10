FROM ubuntu:24.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
# 'gnupg2' and 'lsb-release' are critical for adding the Perforce repo correctly
RUN apt-get update && \
    apt-get install -y apt-utils wget gnupg2 lsb-release curl && \
    rm -rf /var/lib/apt/lists/*

# Add Perforce Official Package Key & Repository
RUN wget -qO - https://package.perforce.com/perforce.pubkey | gpg --dearmor -o /usr/share/keyrings/perforce-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/perforce-archive-keyring.gpg] http://package.perforce.com/apt/ubuntu $(lsb_release -sc) release" > /etc/apt/sources.list.d/perforce.list

# Install Helix Core (p4d)
RUN apt-get update && \
    apt-get install -y helix-p4d && \
    rm -rf /var/lib/apt/lists/*

# Environment Variables
ENV P4ROOT=/opt/perforce/server
ENV P4PORT=1666

# Create server root and set ownership
RUN mkdir -p $P4ROOT && \
    chown -R perforce:perforce /opt/perforce

# Setup Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 1666
USER perforce
WORKDIR $P4ROOT

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
