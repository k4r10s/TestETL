# Proyecto ETL

### Introducción

Este proyecto realiza la carga de archivos de texto con cierto formato desde un SFTP a una base de datos MYSQL, llevando a cabo un proceso de validación de la información.

### Requerimientos

Para utilizar este proyecto es necesario tener las herramientas docker y docker-compose, ambas se pueden obtener de la página oficial de docker: https://docs.docker.com/install/

### Instalación

Este proyecto se puede correr de dos maneras, de manera gráfica a través de la GUI spoon.sh o sin interfaz gráfica mediante la herramienta: kitchen.sh

##### GUI
Para utilizar el ambiente gráfico es necesario cambiar el valor de las variables de entorno XAUTH y DISPLAY del archivo docker-compose.yml ubicado en la carpeta ``escenario1``. La sección de código es la siguiente:

```yaml
 environment:
            XAUTH: "5773c320f754bd10d40cfaa2da14740e"
            DISPLAY: ":0"
```
En este archivo tenemos que cambiar el valor ``5773c320f754bd10d40cfaa2da14740e`` de la variable *XAUTH* por el valor del comando:

```sh
xauth list | grep (uname -n) | cut -d " " -f5 | head -n 1
```
el valor de la variable *DISPLAY* debe cambiarse por el valor del comando:
```sh
env | grep DISPLAY | cut -d "=" -f2
```
para más información puede dirigirse al siguiente enlace: http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

##### Ejecución

Para ejecutar el proyecto, ingresamos a la carpeta ``escenario1`` en esta carpeta ejecutamos el siguiente comando:

```sh
docker-compose build
```

una vez que se construye la imágen ejecutamos el comando:

```sh
docker-compose up &
```

Este comando alzará tres contenedores, un sftp, una base de datos mysql y la herramienta de pentaho DI.

Una vez que el proyecto está arriba, contamos con una base de datos mysql con los siguientes parametros de conexión:
> IP: 8.8.8.2
> Usuario: examen
> Password: examen
> Base de datos: visitas

Así mismo tendremos un SFTP con los siguientes parametros de conexión:
> IP: 8.8.8.8
> Usuario: usuario
> Password: vink0s

Por último tendremos la herramienta Pentaho DI la cual podemos ejecutar de la siguiente manera:

Si tenemos la interfaz GUI configurada correctamente, podremos ejecutar el siguiente comando:

````sh
docker exec -it escenario1_pentaho_1 spoon.sh
````

Sin interfaz gráfica la forma de ejecutar el proyecto sería la siguiente:

````sh
docker exec -it escenario1_pentaho_1 kitchen.sh -file="/home/kettle/sample/logs/sample.ktr"
````
Antes de comenzar la ejecución del escenario es necesario agregar los archivos txt de la carpeta ``Examem/txt`` en la carpeta ``escenario1/archivos`` esto solo si la carpeta ``escenario1/archivos`` se encuentra vacía.

### Trabajos y transformaciones

Los trabajos y transformaciones los podemos encontrar en la ruta ``escenario1/Doc/jobs`` Las transformaciones las podemos ubicar en la ruta ``escenario1/Doc/transformations``. Los scripts que se ocuparon dentro de los procesos de los jobs y transformaciones se pueden encontrar en la ruta ``escenario1/Doc/scripts``

Para más información del escenario lease el documento Escenario.md