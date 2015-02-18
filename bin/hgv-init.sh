#!/bin/bash
echo "

 -------------------------  -----------------
|   _    _                ||  __      __     |
|  | |  | |               ||  \ \    / /     |
|  | |__| |  __           ||   \ \  / /      |
|  |  __  |/ _\` \         ||    \ \/ /       |
|  | |  | | (_| |         ||     \  /        |
|  |_|  |_|\__, |         ||      \/         |
|           __/ |___  __  ||        ___ ____ |
|          |___/( _ )/  \ ||       |_  )__ / |
|               / _ \ () |||        / / |_ \ |
|               \___/\__/ ||       /___|___/ |
 -------------------------  -----------------

"

LSB=`lsb_release -r | awk {'print $2'}`

echo "Updating APT sources."

apt-get autoclean -y
apt-get clean -y
add-apt-repository -y ppa:ansible/ansible
apt-get update -y
apt-get update -yq --fix-missing

echo "Installing packages for Ansible."

# Force installation of latest configurations to avoid
# grub from interactively prompting during upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" dist-upgrade -y

apt-get install software-properties-common -y
apt-get install ansible -y
ansible_version=`dpkg -s ansible 2>&1 | grep Version | cut -f2 -d' '`
echo "Ansible installed ($ansible_version)"

ANS_BIN=`which ansible-playbook`

if [[ -z $ANS_BIN ]]
    then
    echo "Whoops, can't find Ansible anywhere. Aborting run."
    exit
fi

echo "Setting Ansible hostfile permissions."
chmod 644 /vagrant/provisioning/hosts

# More continuous scroll of the ansible standard output buffer
export PYTHONUNBUFFERED=1

# $ANS_BIN /vagrant/provisioning/playbook.yml -i /vagrant/provisioning/hosts
$ANS_BIN /vagrant/provisioning/playbook.yml -i'127.0.0.1,'

echo "Provision successfully completed."
