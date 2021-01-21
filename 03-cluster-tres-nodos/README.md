# Primeros pasos: 3 nodos LXD + un nodo cliente

Se crea una VM con Vagrant, donde se instala de manera mínima LXD.

```bash
# levanta el cluster LXD
no_proxy=192.168.33.11,192.168.33.12,192.168.33.13,${no_proxy} time vagrant up
```

* Ingreso al nodo cliente con:

```bash
# levanta el cliente
no_proxy=192.168.33.11,192.168.33.12,192.168.33.13,${no_proxy} vagrant up workstation
vagrant ssh workstation
```

La variable `no_proxy` se asigna con la lista de las direcciones IP o nombres de
los nodos del cluster.  Esto es así cuando el ambiente donde corre el cluster LXD requiere
utilizar un servicio de proxy para acceder a la internet.  Si usted no tiene definidas las 
variables `http_proxy` ni `https_proxy` en su entorno de trabajo, puede correr los mandatos
anteriores sin la asignación de `no_proxy`


Los accesos a internet se necesitan para acceder a:
* los repositorios de paquetes de la distrbución usada en los nodos y los contenedores
* los repositorios de Snap
* los repositorios de imágenes de contenedores para LXD

Todos los mandatos `lxc` se ejecutan en el cluster por default.


* Creo un contenedor con Alpine desde el nodo cliente

```bash
time lxc launch images:alpine/3.12 alpi1
time lxc launch images:alpine/3.12 alpi2
time lxc launch images:alpine/3.12 alpi3
time lxc launch images:alpine/3.12 alpi4

time lxc launch images:debian/10/cloud buster

```


```text
vagrant@workstation:~$ lxc list
+--------+---------+---------------------+------+-----------+-----------+----------+
|  NAME  |  STATE  |        IPV4         | IPV6 |   TYPE    | SNAPSHOTS | LOCATION |
+--------+---------+---------------------+------+-----------+-----------+----------+
| alpi1  | RUNNING | 240.11.0.93 (eth0)  |      | CONTAINER | 0         | lxd1     |
+--------+---------+---------------------+------+-----------+-----------+----------+
| alpi2  | RUNNING | 240.12.0.20 (eth0)  |      | CONTAINER | 0         | lxd2     |
+--------+---------+---------------------+------+-----------+-----------+----------+
| alpi3  | RUNNING | 240.13.0.60 (eth0)  |      | CONTAINER | 0         | lxd3     |
+--------+---------+---------------------+------+-----------+-----------+----------+
| alpi4  | RUNNING | 240.11.0.104 (eth0) |      | CONTAINER | 0         | lxd1     |
+--------+---------+---------------------+------+-----------+-----------+----------+
| buster | RUNNING | 240.12.0.52 (eth0)  |      | CONTAINER | 0         | lxd2     |
+--------+---------+---------------------+------+-----------+-----------+----------+

```


Desde cualquier nodo del cluster, y desde workstation, puedo conectarme como root a cualquier contenedor mediante:

```bash
lxc exec alpi1 -- sh
lxc exec buster -- bash
```

* Crear un usuario y conectarse con ese usuario

También se puede crear una cuenta de usuario no privilegiada y usarla para conectarnos al contenedor:

```bash
lxc exec alpi1 -- adduser -D --home /home/pepe --shell /bin/ash pepe
lxc exec alpi1 -- su - pepe
```

En este caso usamos la red FAN de Ubuntu para que el espacio de direcciones de los contenedores sea el mismo 
en todos los nodos del cluster, y sea accesible a la estación de trabajo cliente.

Para que nos acepte la conexión por SSH usaremos una cuenta con contraseña:

```bash
lxc exec buster -- apt-get install openssh-server -y

lxc exec buster -- useradd -m --shell /bin/bash pepe
lxc exec buster -- bash -c "echo 'pepe:p3pito' | chpasswd"

cnt_ip=$(lxc list  buster --format=json | jq -r ".[0].state.network.eth0.addresses[0].address")
ssh-keyscan "${cnt_ip}" >> ~/.ssh/known_hosts
sshpass -p p3pito ssh pepe@"${cnt_ip}"

```


# Referencias

* https://discuss.linuxcontainers.org/t/lxd-cluster-on-raspberry-pi-4/9076 LXD cluster on Raspberry Pi 4
* https://ubuntu.com/blog/lxd-clusters-a-primer
