export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '

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

  genera_preseed_nodo 2 > /vagrant/tmp/lxd2-init.preseed
  genera_preseed_nodo 3 > /vagrant/tmp/lxd3-init.preseed
else
  sudo lxd init --preseed < /vagrant/tmp/\$(hostname)-init.preseed
fi

NEWGROUP
