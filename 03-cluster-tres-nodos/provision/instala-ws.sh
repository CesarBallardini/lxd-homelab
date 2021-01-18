export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

# sudo snap install lxd --channel=latest/stable # ya viene instalado por default
sudo snap refresh lxd --channel=latest/stable   # lo actualizo
sudo usermod --append --groups lxd vagrant

sudo apt-get install jq -y sshpass  ${APT_OPTIONS} # para las comprobaciones en el README

# desde workstation puedo acceder al cluster en forma remota
lxc remote add my-cluster 192.168.33.11 --password p3rico  --protocol=lxd --accept-certificate

#lxc remote list

# hago del cluster remoto el predeterminado
lxc remote switch my-cluster

# instalo fan networking para acceder a los contenedores de todos los hosts desde el cliente
sudo apt install ubuntu-fan ${APT_OPTIONS}
sudo fanatic enable-fan -u 192.168.33.10/24 -o 240.0.0.0/8

lxc cluster list
