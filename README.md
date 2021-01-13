# README - LXD Home Lab

Se crea un cluster LXD para practicar la creación de infraestructura en un
ámbito de laboratorio.

El lab se crea paso a paso.

Primero comenzamos con un solo nodo, usado de manera local para aprender los conceptos de LXC y LXD.

Más adelante agregamos un nodo cliente, que solicita a través de la red al cluster mononodo la creación de contenedores.

Luego agregamos otros nodos al cluster LXD, y verificamos cómo pasar contenedores de un nodo a otro.

En un contexto de cñuster multinodo, podemos usar Software Defined Networks para crear redes adicionales, y compartirlas
entre contenedores que corren en diferente nodo.

Por último, veremos cómo gestionar el almacenamiento de imágenes y contenedores mediante un cluster Ceph.

Cada uno de estos pasos se construye en un directorio de este repositorio.
