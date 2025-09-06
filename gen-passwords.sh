#!/bin/bash

function generatePassword() {
    openssl rand -hex 16
}

function updateEnv() {
    local key=$1
    local password=$2
    
    if [ -f .env ]; then
        # Create backup
        cp .env .env.bak
        
        # Update or add the password
        if grep -q "^${key}=" .env; then
            # Replace existing entry
            sed -i.tmp "s/^${key}=.*/${key}=${password}/" .env
            rm -f .env.tmp
        else
            # Add new entry
            echo "${key}=${password}" >> .env
        fi
    else
        echo "Error: .env file not found!"
        exit 1
    fi
}

echo "Generating passwords for Jitsi Meet..."

# Generate passwords for all required services
JICOFO_COMPONENT_SECRET=$(generatePassword)
JICOFO_AUTH_PASSWORD=$(generatePassword)
JVB_AUTH_PASSWORD=$(generatePassword)
JIGASI_XMPP_PASSWORD=$(generatePassword)
JIBRI_RECORDER_PASSWORD=$(generatePassword)
JIBRI_XMPP_PASSWORD=$(generatePassword)

echo "Updating .env file..."

# Update .env file with generated passwords
updateEnv "JICOFO_COMPONENT_SECRET" "$JICOFO_COMPONENT_SECRET"
updateEnv "JICOFO_AUTH_PASSWORD" "$JICOFO_AUTH_PASSWORD"
updateEnv "JVB_AUTH_PASSWORD" "$JVB_AUTH_PASSWORD"
updateEnv "JIGASI_XMPP_PASSWORD" "$JIGASI_XMPP_PASSWORD"
updateEnv "JIBRI_RECORDER_PASSWORD" "$JIBRI_RECORDER_PASSWORD"
updateEnv "JIBRI_XMPP_PASSWORD" "$JIBRI_XMPP_PASSWORD"

echo "Strong passwords have been generated and saved to .env"
echo "A backup of your previous .env file has been saved as .env.bak"
echo ""
echo "Important: Make sure to update the following variables in .env:"
echo "  - PUBLIC_URL: Set to your actual domain (e.g., https://meet.yourdomain.com)"
echo "  - DOCKER_HOST_ADDRESS: Set to your server's public IP address"
echo ""
echo "Optional: Configure Let's Encrypt by uncommenting and setting:"
echo "  - ENABLE_LETSENCRYPT=1"
echo "  - LETSENCRYPT_DOMAIN=your.domain.com"
echo "  - LETSENCRYPT_EMAIL=your@email.com"