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

sudo apt-get install zfsutils-linux ${APT_OPTIONS} 
sudo apt-get install jq -y sshpass  ${APT_OPTIONS} # para las comprobaciones en el README
sudo snap install j2  # jinja2 templating for bash
sudo snap install yq  # yaml query for bash

sudo usermod --append --groups lxd vagrant

genera_preseed_nodo() {

  NODE_NUMBER=$1

  cat   <(printf  "server_name: lxd${NODE_NUMBER}\nserver_address: 192.168.33.1${NODE_NUMBER}:8443\ncluster_password: p3rico\n" ) \
	<(lxc info | sed -e "s/core\./core_/" -e "s/cluster\./cluster_/") \
    | j2 --format=yaml \
         $(cat /vagrant/provision/other-nodes-lxd-init.preseed.j2 |  { tf=$(mkdir -p ~/tmp ; mktemp -p ~/tmp); cat >"$tf"; echo "$tf"; } )

}

newgrp lxd << NEWGROUP
# debo escapar los $ para que no se ejecuten en el shell anterior al del newgrp

genera_preseed_nodo() {

  NODE_NUMBER=\$1

  cat   <(printf  "server_name: lxd\${NODE_NUMBER}\nserver_address: 192.168.33.1\${NODE_NUMBER}:8443\ncluster_password: p3rico\n" ) \
	<(lxc info | sed -e "s/core\./core_/" -e "s/cluster\./cluster_/") \
    | j2 --format=yaml \
         \$(cat /vagrant/provision/other-nodes-lxd-init.preseed.j2 |  { tf=\$(mkdir -p ~/tmp ; mktemp -p ~/tmp); cat >"\$tf"; echo "\$tf"; } )

}


if [ \$(hostname) == "lxd1" ]
then
  sudo lxd init --preseed < /vagrant/provision/first-node-lxd-init.preseed


  [ -d /vagrant/tmp/ ] || mkdir /vagrant/tmp/
  genera_preseed_nodo 2 > /vagrant/tmp/lxd2-init.preseed
  genera_preseed_nodo 3 > /vagrant/tmp/lxd3-init.preseed
else
  sudo lxd init --preseed < /vagrant/tmp/\$(hostname)-init.preseed
fi


if [ -n "${http_proxy}" ] || [ -n "${https_proxy}" ]
then
  # para que LXD pueda descargar las imagenes
  lxc config set core.proxy_http         "${http_proxy}"
  lxc config set core.proxy_https        "${https_proxy}"
  lxc config set core.proxy_ignore_hosts "${no_proxy}"

  # para que los contenedores del perfil default puedan acceder a internet
  lxc profile set default environment.http_proxy  "${http_proxy}"
  lxc profile set default environment.https_proxy "${https_proxy}"
  lxc profile set default environment.no_proxy    "${no_proxy}"
fi


NEWGROUP
