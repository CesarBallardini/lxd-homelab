export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

# sudo snap install lxd --channel=latest/stable # ya viene instalado por default
sudo snap refresh lxd --channel=latest/stable   # lo actualizo
sudo usermod --append --groups lxd vagrant

sudo apt-get install jq -y sshpass  ${APT_OPTIONS} # para las comprobaciones en el README

# desde workstation puedo acceder al cluster en forma remota
lxc remote add my-cluster 192.168.33.11 --accept-certificate --password p3rico

#lxc remote list

# hago del cluster remoto el predeterminado
lxc remote switch my-cluster

# agrega una ruta para llegar a los contenedores desde el workstation
sudo ip route add 192.168.44.0/24 via 192.168.33.11

