export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

sudo -E apt-get --purge remove apt-listchanges -y > /dev/null 2>&1
sudo -E apt-get update -y -qq > /dev/null 2>&1

sudo -E apt-get install linux-image-generic ${APT_OPTIONS} || true

sudo -E apt-get upgrade ${APT_OPTIONS} > /dev/null 2>&1
sudo -E apt-get dist-upgrade ${APT_OPTIONS} > /dev/null 2>&1

sudo -E apt-get autoremove -y > /dev/null 2>&1
sudo -E apt-get autoclean -y > /dev/null 2>&1
sudo -E apt-get clean > /dev/null 2>&1
