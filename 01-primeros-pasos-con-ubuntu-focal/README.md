# Primeros pasos: un solo nodo LXD

Se crea una VM con Vagrant, donde se instala de manera mínima LXD.

```bash
time vagrant up
time vagrant reload
```

Como instalé las herramientas para `zfs`, la inicialización
automática de LXD crea un storage basado en ZFS.

```text
vagrant@lxd1:~$ sudo du -kh  /var/snap/lxd/common/lxd/disks/default.img 
2.9M	/var/snap/lxd/common/lxd/disks/default.img

vagrant@lxd1:~$ sudo ls -lh  /var/snap/lxd/common/lxd/disks/default.img
-rw------- 1 root root 6.6G Jan 14 17:49 /var/snap/lxd/common/lxd/disks/default.img
```

* Creo un contenedor con Alpine y otro con Debian 10

```bash

time lxc launch images:alpine/3.12 alpi         # 11s incluye descarga de imagen

time lxc launch images:debian/10/cloud buster   # 32s incluye descarga de imagen

time lxc launch images:debian/11/cloud bullseye # 38s incluye descarga de imagen

```

Una vez descargadas las imágenes, tarda 2s en levantar un nuevo contenedor.


* Crear un usuario y conectarse con ese usuario


```bash
lxc exec buster -- useradd -m --shell /bin/bash pepe
lxc exec buster -- su - pepe



# para conectarnos por SSH, hace falta contraseña para pepe y el sshd en el contenedor:
lxc exec buster -- apt-get install openssh-server -y
lxc exec buster -- bash -c "echo 'pepe:p3rico' | chpasswd"

# buscamos la dirección IP y la agregamos a los hosts conocidos por SSH:
cnt_ip=$(lxc list  buster --format=json | jq -r ".[0].state.network.eth0.addresses[0].address")
ssh-keyscan "${cnt_ip}" >> ~/.ssh/known_hosts

sshpass -p p3rico ssh pepe@"${cnt_ip}"
```

Otros mandatos útiles en el caso de estudio de primeros pasos con Alpine.

