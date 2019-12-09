# Escenario ETL

#### Escenario propuesto como solución de comunicación entre un SFTP y una base de datos MYSQL.

### Introducción
Se solicito generar el proceso de un ETL para el consumo de archivos TXT con un formato definido desde un servidor SFTP a una base de datos MYSQL.

Los datos proporcionados para el escenario fueron los siguientes:
* La ip del servidor SFTP es 8.8.8.8
* La ruta dónde se encuentran los archivos en el SFTP es: /home/vinkOS/archivosVisitas
* Los archivos contienen la extensión txt y tienen el siguiente formato "repor_" + consecutivo" + ".txt"
* Se debe hacer la busqueda de archivos todos los días
* Se debe válidar el formato de cada archivo
* Se debe válidar la información que se carga (Email y formato de fechas dd/mm/yyyy HH:mm)
* Se debe cargar la información en 3 tablas de MYSQL.
    * Visitante [email, fechaPrimeraVisita, fechaUltimaVisita, visitasTotales, visitasAnioActual, visitasMesActual]
    * estádistica [email,jyv,Badmail,Baja,Fecha envío,Fecha open,Opens,Opens virales,Fecha click,Clicks,Clicks virales,Links,IPs,Navegadores,Plataformas]
    * errores [registros con error]
* Los archivos se deben de borrar del origen SFTP una vez que se realiza la carga.
* Realizar un backup de los archivos cargados en formato zip en el ruta: /home/etl/visitas/bckp
* No se debe cargar un archivo más de una vez
* El proceso es responsable de la administración de los archivos (borrado en origen y backup en destino)
* El servidor donde se ejecuta el proceso ETL se utilizará como storage del backup
* En la tabla visitante, solo hay un registro por email, si no existe se agrega, si existe se actualizan los valores de fechaUltimaVisita, visitasTotales, visitasAnioActual, visitasMesActual

Adicional a los requerimientos anteriores se solucito el mismo escenario pero con un entorno de big data, utilizando las técnologias de HADOOP y HIVE O IMPALA.

### Solución propuesta


