# Primeros pasos: 3 nodos LXD + un nodo cliente

Se crea una VM con Vagrant, donde se instala de manera mínima LXD.

```bash
# levanta el cluster LXD
time vagrant up
```

* Ingreso al nodo cliente con:

```bash
# levanta el cliente
vagrant up workstation
vagrant ssh workstation
```

Todos los mandatos que haga usando `lxc` se ejecutan en el cluster por default.


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
lxc exec alpine -- sh
lxc exec buster -- bash
```

* Crear un usuario y conectarse con ese usuario

También se puede crear una cuenta de usuario no privilegiada y usarla para conectarnos al contenedor:

```bash
lxc exec alpine -- adduser -D --home /home/pepe --shell /bin/ash pepe
lxc exec alpine -- su - pepe
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
