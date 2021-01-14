# README: LXD sobre Alpine Linux


```bash
time vagrant up

# El provisioning termina con un reboot forzado
# Ignore los mensajes de error y levante nuevamente la VM con:

time vagrant up

```
 
Ahora puede ingresar a la Vm con la cuenta `vagrant` y probar algunos mandatos `lxc`:

* ingresar mediante:

```bash
vagrant ssh
```

* algunos mandatos para ver el estado de la instalación LXD:

```text

# la configuración del cluster LXD:
lxc info

[... es muy largo para incluir aquí...]


# Los storages: (el tipo y tamaño depende de los defaults en la inicialización)

lxc storage list
+---------+-------------+--------+------------------------------------+---------+
|  NAME   | DESCRIPTION | DRIVER |               SOURCE               | USED BY |
+---------+-------------+--------+------------------------------------+---------+
| default |             | dir    | /var/lib/lxd/storage-pools/default | 1       |
+---------+-------------+--------+------------------------------------+---------+


# Las redes: (además de las físicas de la VM, las otras depende de los defaults en la inicialización)

lxc network list
+--------+----------+---------+----------------+---------------------------+-------------+---------+
|  NAME  |   TYPE   | MANAGED |      IPV4      |           IPV6            | DESCRIPTION | USED BY |
+--------+----------+---------+----------------+---------------------------+-------------+---------+
| eth0   | physical | NO      |                |                           |             | 0       |
+--------+----------+---------+----------------+---------------------------+-------------+---------+
| eth1   | physical | NO      |                |                           |             | 0       |
+--------+----------+---------+----------------+---------------------------+-------------+---------+
| lxdbr0 | bridge   | YES     | 10.39.151.1/24 | fd42:3eee:39e5:e11a::1/64 |             | 1       |
+--------+----------+---------+----------------+---------------------------+-------------+---------+

# Los contenedores:

lxc list
+------+-------+------+------+------+-----------+
| NAME | STATE | IPV4 | IPV6 | TYPE | SNAPSHOTS |
+------+-------+------+------+------+-----------+


# Las imágenes de los contenedores

lxc image list
+-------+-------------+--------+-------------+--------------+------+------+-------------+
| ALIAS | FINGERPRINT | PUBLIC | DESCRIPTION | ARCHITECTURE | TYPE | SIZE | UPLOAD DATE |
+-------+-------------+--------+-------------+--------------+------+------+-------------+

```


* El ciclo de vida de un contenedor:

```bash

# traer la imagen

lxc image list images:
lxc image list ubuntu:


lxc image list images: debian amd64
lxc image list images: debian amd64 cloud

lxc image list
lxc image copy images:alpine/3.12  local: --copy-aliases --auto-update

lxc image list
+----------------------+--------------+--------+------------------------------------+--------------+-----------+--------+------------------------------+
|        ALIAS         | FINGERPRINT  | PUBLIC |            DESCRIPTION             | ARCHITECTURE |   TYPE    |  SIZE  |         UPLOAD DATE          |
+----------------------+--------------+--------+------------------------------------+--------------+-----------+--------+------------------------------+
| alpine/3.12 (3 more) | d0f3a450c009 | no     | Alpine 3.12 amd64 (20210113_13:09) | x86_64       | CONTAINER | 2.40MB | Jan 14, 2021 at 2:04am (UTC) |
+----------------------+--------------+--------+------------------------------------+--------------+-----------+--------+------------------------------+


# lanzar un contenedor desde una imagen
i
time lxc launch local:alpine/3.12 alpi

Creating alpi
Starting alpi                             
                               
real	0m0.521s
user	0m0.015s
sys	0m0.016s


# ejecutar un mandato en e contenedor
lxc exec alpi -- cat /etc/alpine-release

# obtener un shell del contenedor
lxc exec alpi -- /bin/sh

# detener el contenedor
lxc stop alpi

# arrancarlo de nuevo
lxc start alpi

# destruir el contenedor, forzando la operación si el contenedor está encendido
lxc rm alpi --force



# crear un usuario y conectarse con ese usuario
lxc exec alpi -- adduser -D --home /home/pepe --shell /bin/ash pepe
lxc exec alpi -- su - pepe



# para conectarnos por SSH, hace falta contraseña para pepe y el sshd en el contenedor:
lxc exec alpi -- apk add openssh
lxc exec alpi -- rc-update add sshd
lxc exec alpi -- /etc/init.d/sshd start
lxc exec alpi -- ash -c "echo 'pepe:p3rico' | chpasswd"

# buscamos la dirección IP y la agregamos a los hosts conocidos por SSH:
cnt_ip=$(lxc list  alpi --format=json | jq -r ".[0].state.network.eth0.addresses[0].address")
ssh-keyscan "${cnt_ip}" >> ~/.ssh/known_hosts

sshpass -p p3rico ssh pepe@"${cnt_ip}"

```



