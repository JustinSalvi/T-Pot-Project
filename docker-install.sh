#Update Package Index and Install Prerequisites
echo "Updating package index and installing prerequisites..."
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

#Add Docker’s Official GPG Key and Repository
echo "Adding Docker's official GPG key and setting up repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#Install Docker Engine & Docker Compose
echo "Installing Docker Engine..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#Add Current User to the Docker Group
echo "Adding current user to the Docker group..."

TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || true)}"
if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
  TARGET_USER="$(id -un)"
fi

sudo usermod -aG docker "$TARGET_USER"
echo "Added $TARGET_USER to the docker group."

#Verify Installation
echo "Verifying Docker installation..."
docker --version
echo "Verifying Docker Compose installation..."
docker compose version

#Final Message
echo "Testing Docker access (may require re-login)..."
if docker ps >/dev/null 2>&1; then
  echo "Docker works without sudo."
else
  echo "Docker requires a new login for group changes to apply."
  echo "Run: newgrp docker"
  echo "Or: log out and back in."
fi
