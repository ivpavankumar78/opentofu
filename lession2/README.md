Installing OpenTofu on .deb-based Linux (Debian, Ubuntu, etc.)
Thank you tofor sponsoring the OpenTofu package hosting.

You can install OpenTofu from our Debian repository by following the step-by-step instructions below.

Installing using the installer
You can use the OpenTofu installer script to run the installation.

Code Block

# Download the installer script:
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Give it execution permissions:
chmod +x install-opentofu.sh

# Please inspect the downloaded script

# Run the installer:
./install-opentofu.sh --install-method deb

# Remove the installer:
rm -f install-opentofu.sh
Step-by-step instructions
The following steps explain how to set up the OpenTofu Debian repositories. These instructions should work on most Debian-based Linux systems.

Installing tooling
In order to add the repositories, you will need to install some tooling. On most Debian-based operating systems, these tools will already be installed.

Code Block
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
Set up the OpenTofu repository
First, you need to make sure you have a copy of the OpenTofu GPG key. This verifies that your packages have indeed been created using the official pipeline and have not been tampered with.

Code Block

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://get.opentofu.org/opentofu.gpg | sudo tee /etc/apt/keyrings/opentofu.gpg >/dev/null
curl -fsSL https://packages.opentofu.org/opentofu/tofu/gpgkey | sudo gpg --no-tty --batch --dearmor -o /etc/apt/keyrings/opentofu-repo.gpg >/dev/null
sudo chmod a+r /etc/apt/keyrings/opentofu.gpg /etc/apt/keyrings/opentofu-repo.gpg
Now you have to create the OpenTofu source list.

Code Block

echo \
  "deb [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main
deb-src [signed-by=/etc/apt/keyrings/opentofu.gpg,/etc/apt/keyrings/opentofu-repo.gpg] https://packages.opentofu.org/opentofu/tofu/any/ any main" | \
  sudo tee /etc/apt/sources.list.d/opentofu.list > /dev/null
sudo chmod a+r /etc/apt/sources.list.d/opentofu.list
Installing OpenTofu
Finally, you can install OpenTofu:

Code Block
sudo apt-get update
sudo apt-get install -y tofu