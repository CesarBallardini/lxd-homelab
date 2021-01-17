export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

# sudo snap install lxd --channel=latest/stable # ya viene instalado por default
sudo snap refresh lxd --channel=latest/stable   # lo actualizo

sudo apt-get install zfsutils-linux ${APT_OPTIONS} 
sudo apt-get install jq -y sshpass  ${APT_OPTIONS} # para las comprobaciones en el README

sudo usermod --append --groups lxd vagrant

# https://lxd.readthedocs.io/en/latest/preseed/
# configuramos acceso a traves de la red

sudo lxd init --preseed < /vagrant/provision/lxd-init.preseed 




# Otra forma sería mediante un here-doc:

#  cat <<EOF | sudo lxd init --preseed
#config:
#  core.https_address: 192.168.1.1:9999
#  images.auto_update_interval: 15
#networks:
#- name: lxdbr0
#  type: bridge
#  config:
#    ipv4.address: auto
#    ipv6.address: none
#EOF


