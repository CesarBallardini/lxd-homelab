export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

if [ -n "${http_proxy}" ] || [ -n "${https_proxy}" ]
then
  # https://snapcraft.io/docs/system-options#heading--proxy
  sudo snap set system proxy.http="${http_proxy}"
  sudo snap set system proxy.https="${https_proxy}"
fi

# sudo snap install lxd --channel=latest/stable # ya viene instalado por default
sudo snap refresh lxd --channel=latest/stable   # lo actualizo
sudo usermod --append --groups lxd vagrant

sudo apt-get install jq -y sshpass  ${APT_OPTIONS} # para las comprobaciones en el README

newgrp lxd << NEWGROUP

# desde workstation puedo acceder al cluster en forma remota, pero debo eliminar del proxy la conexion a la API del server

# Con unas pocas direciones de IP para excluir puedo usar la variable de entorno NO_PROXY
# pero cuando esa cantidad crece, va a convenir instalar un tinyproxy en la workstation y
# configurar allí el proxy aguas arriba, y las excepciones necesarias
echo "export NO_PROXY=192.168.33.11" | tee ~/.bash_aliases
source ~/.bash_aliases

lxc remote add my-cluster 192.168.33.11 --accept-certificate --password p3rico

# hago del cluster remoto el predeterminado
lxc remote switch my-cluster
lxc remote list

# agrega una ruta para llegar a los contenedores desde el workstation
sudo ip route add 192.168.44.0/24 via 192.168.33.11

# Con mas de un nodo en el cluster, la estratagema de las rutas no servirá
# Usaremos Ubuntu FAN Network

NEWGROUP

