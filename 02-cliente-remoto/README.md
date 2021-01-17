# Primeros pasos: un solo nodo LXD + un nodo cliente

Se crea una VM con Vagrant, donde se instala de manera mínima LXD.

```bash
time vagrant up
```

* Ingreso al nodo cliente con:

```bash
vagrant ssh workstation
```


* Agrego el cluster remoto a los que puedo acceder desde esta workstation: (en [provision/instala-ws.sh](provision/instala-ws.sh))

```bash
lxc remote add my-cluster 192.168.33.11 --accept-certificate --password p3ric0

lxc cluster list  # muestra los clusters a los cuales tengo acceso

lxc remote switch my-cluster # selecciona el cluster por default

```

Todos los mandatos que haga usando `lxc` se ejecutan en el cluster por default.


* Creo un contenedor con Alpine desde el nodo cliente

```bash
time lxc launch local:alpine/3.12 alpine
time lxc launch images:debian/10/cloud buster

```


```text
vagrant@workstation:~$ lxc list
+--------+---------+-----------------------+------+-----------+-----------+----------+
|  NAME  |  STATE  |         IPV4          | IPV6 |   TYPE    | SNAPSHOTS | LOCATION |
+--------+---------+-----------------------+------+-----------+-----------+----------+
| alpine | RUNNING | 192.168.44.3 (eth0)   |      | CONTAINER | 0         | lxd1     |
+--------+---------+-----------------------+------+-----------+-----------+----------+
| buster | RUNNING | 192.168.44.90 (eth0)  |      | CONTAINER | 0         | lxd1     |
+--------+---------+-----------------------+------+-----------+-----------+----------+

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

Para conectarnos por SSH desde workstation, no podemos así como estamos, porque nuestra red es 192.168.33.0/24
y la red de los contenedores es 192.168.44.0/24

Podemos agregar una ruta en workstation que nos permita llegar a la red 192.168.44.0/24 a 
través de uno de los nodos del cluster, en nuestro caso actual es 192.168.33.11:

```bash
sudo ip route add 192.168.44.0/24 via 192.168.33.11
```

Y con eso ya podemos llegar con ping a buster, que tiene dirección 192.168.44.90.

Para que nos acepte la conexión por SSH usaremos una cuenta con contraseña:

```bash
lxc exec buster -- apt-get install openssh-server -y

lxc exec buster -- useradd -m --shell /bin/bash pepe
lxc exec buster -- bash -c "echo 'pepe:p3pito' | chpasswd"

cnt_ip=$(lxc list  buster --format=json | jq -r ".[0].state.network.eth0.addresses[0].address")
ssh-keyscan "${cnt_ip}" >> ~/.ssh/known_hosts
sshpass -p p3pito ssh pepe@"${cnt_ip}"

```

