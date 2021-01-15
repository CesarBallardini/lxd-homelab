# Primeros pasos: un solo nodo LXD

Se crea una VM con Vagrant, donde se instala de manera mínima LXD.

```bash
time vagrant up
```

Como instalé las herramientas para `zfs`, la inicialización
automática de LXD crea un storage basado en ZFS.

Para trabajar con el LXD, ingresamos a la VM recién creada, como siempre, con:

```bash
vagrant ssh
```

* Creo un contenedor con Alpine y otros con Debian y Ubuntu (con el storage sobre ZFS sólo se utiliza lo que se diferencia de la imagen descargada)

```bash

time lxc launch images:alpine/3.12 alpine       # 10s incluye descarga de imagen - uso/pico RAM:     3/5 MB - uso disco 115 kB

time lxc launch images:debian/10/cloud buster   # 25s incluye descarga de imagen - uso/pico RAM:   12/70 MB - uso disco 3 MB

time lxc launch images:debian/11/cloud bullseye # 30s incluye descarga de imagen - uso/pico RAM:  12/105 MB - uso disco 45 MB

time lxc launch ubuntu:focal/amd64 focal        # 86s incluye descarga de imagen - uso/pico RAM: 168/229 MB - uso disco 9 MB

```

* Para ver datos de las imágenes anteriores:

```bash
lxc image list images:alpine/3.12/amd64     # download size:   3 MB
lxc image list images:debian/10/cloud/amd64 # download size:  92 MB
lxc image list images:debian/11/cloud/amd64 # download size: 108 MB
lxc image list ubuntu: focal amd64          # download size: 357 MB
```


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

