# Escenario ETL

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

Al realizar el análisis del escenario propuesto se opto por usar Pentaho DI un software open source que cuenta con varias herramientas para poder extraer información, procesarla y cargarla a alguna fuente.

Dadas las necesidades del escenario el primero paso era lograr extraer la información desde el SFTP y depositarla en una carpeta en el sistema operativo que contenia el ETL, esto para posteriormente procesarla con Mysql y cargarla a una tabla.

Para realizar esta tarea se creo un JOB en pentaho DI, el cual consiste en 6 pasos.

El primera paso fue la extracción de la información desde el SFTP de la ruta ``/home/vinkOS/archivosVisitas``. Para extraer los archivos correctos, en el formato "repor_" + consecutivo" + ".txt" se utilizó una expresión regular la cual permite validar el formato de los archivos, la expresión es la siguiente: `` report_[0-9]+\.txt ``. Una vez que definimos la forma de extracción lo siguiente fue definir en dónde se depositarian los archivos, la ruta elegita fue: ``/home/etl/loaded``. Una vez que los archivos se extraen del SFTP se eliminan del mismo. El código de la entrada es la siguiente:

```` xml
<entry>
  <name>Get a file with SFTP</name>
  <description />
  <type>SFTP</type>
  <servername>8.8.8.8</servername>
  <serverport>22</serverport>
  <username>usuario</username>
  <password>Encrypted 2be98afc86aa7f2e4cb79b879d099ffc9</password>
  <sftpdirectory>home/vinkOS/archivosVisitas</sftpdirectory>
  <targetdirectory>/home/etl/loaded</targetdirectory>
  <wildcard>report_[0-9]+\.txt</wildcard>
  <remove>Y</remove>
  <isaddresult>Y</isaddresult>
  <createtargetfolder>Y</createtargetfolder>
  <copyprevious>N</copyprevious>
  <usekeyfilename>N</usekeyfilename>
  <keyfilename />
  <keyfilepass>Encrypted </keyfilepass>
  <compression>none</compression>
  <proxyType />
  <proxyHost />
  <proxyPort />
  <proxyUsername />
  <proxyPassword>Encrypted </proxyPassword>
  <parallel>N</parallel>
  <draw>Y</draw>
  <nr>0</nr>
  <xloc>160</xloc>
  <yloc>32</yloc>
</entry>
````
Una vez que se realizó este paso se continuo con la carga de información desde los archivos txt ubicados en la ruta ``/home/etl/loaded`` a la base de datos Mysql.

Para realizar este proceso se utilizó una transfoŕmación la cual barria los archivos en el directorio y mandaba la información a un script SQL, mediante el cual se cargaban los archivos a la base de datos.

Antes de poder realizar la carga se requirió realizar una configuración inicial para la base de datos.

Primero se establecio un parametro para realizar la carga con la sentencia ``LOAD DATA LOCAL INFILE``. El parametro es el siguiente:

````sql
SET GLOBAL local_infile = 1;
````

Posteriormente se realizó la creación de las tablas en dónde se iba a guardar la información de los archivos TXT, las tablas generadas son las siguientes:

````sql
CREATE TABLE IF NOT EXISTS estadisticas
(
    email VARCHAR(100),
    jyv VARCHAR(50),
    badmail VARCHAR(50),
    Baja VARCHAR(50),
    FechaEnvio VARCHAR(50),
    FechaOpen VARCHAR(50),
    Opens VARCHAR(50),
    OpensVirales VARCHAR(50),
    FechaClick VARCHAR(50),
    Clicks VARCHAR(50),
    ClicksVirales VARCHAR(50),
    Links VARCHAR(200),
    IPs VARCHAR(50),
    Navegadores VARCHAR(200),
    Plataformas VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS visitante
(
    email VARCHAR(100),
    fechaPrimeraVisita VARCHAR(50),
    fechaUltimaVisita VARCHAR(50),
    visitasTotales INT,
    visitasAnioActual INT,
    visitasMesActual INT,
    PRIMARY KEY (email)
);

CREATE TABLE IF NOT EXISTS error
(
    email VARCHAR(100),
    jyv VARCHAR(50),
    badmail VARCHAR(50),
    Baja VARCHAR(50),
    FechaEnvio VARCHAR(50),
    FechaOpen VARCHAR(50),
    Opens VARCHAR(50),
    OpensVirales VARCHAR(50),
    FechaClick VARCHAR(50),
    Clicks VARCHAR(50),
    ClicksVirales VARCHAR(50),
    Links VARCHAR(200),
    IPs VARCHAR(50),
    Navegadores VARCHAR(200),
    Plataformas VARCHAR(200)
);
````
Una vez que se tenia la configuración y las tablas se analizó el requerimiento de validar la información, identificando los errores en el formato de los datos en cuanto a fechas e emails. Así mismo surgio la necesidad de generar una inserción en la tabla visitante, la cual no podía repetir el email y debía llevar un conteo de visitas totales, al año y al mes.

Dadas estás restricción se opto por generar un trigger que contuviera está lógica, de esta manera podíamos ingresar los datos en la tabla estadísticas, que contendría todo el registro de datos cargados y posteriormente agregar la información validada a las tablas de error y visitante según fuera el caso.

El trigger generado fue el siguiente:
````sql
DROP TRIGGER IF EXISTS trValidData;

DELIMITER $$

CREATE TRIGGER trValidData AFTER INSERT ON visitas.estadisticas
FOR EACH ROW BEGIN

    DECLARE rowCount INT;

    SET rowCount = (SELECT COUNT(*) FROM visitante WHERE visitante.email = NEW.email);

    IF rowCount > 0 THEN
        UPDATE visitante SET fechaUltimaVisita = NEW.FechaOpen, visitasTotales = visitasTotales + 1, visitasAnioActual = visitasAnioActual + 1, visitasMesActual = visitasMesActual + 1 WHERE email = NEW.email;
    ELSE
        IF NEW.email REGEXP '^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
        AND NEW.FechaOpen REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
        AND NEW.FechaEnvio REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
        AND NEW.FechaClick REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
        THEN
            INSERT INTO visitante
                (email, fechaPrimeraVisita, fechaUltimaVisita, visitasTotales, visitasAnioActual, visitasMesActual)
            VALUES (NEW.email, NEW.FechaOpen, NEW.FechaOpen, 1, 1, 1);
        END IF;
    END IF;
END$$

DELIMITER ;⏎  
````

Este trigger valida los datos de email, FechaEnvio, FechaOpen y FechaClick a través de expresiones regulares, de esta manera podemos asegurar que los datos que se ingresan en la tabla visitante, son datos correctos, adicional a eso se implementa una lógica para aumentar el contador de visitas totales, visitas anuales y visitas al mes cada que se encuentre un registro duplicado.

Una vez que está instalado el trigger en la base de datos y las tablas existen, se continua con el paso dos del proceso ETL. ya que tenemos los archivos TXT del SFTP en la carpeta ``/home/etl/loaded`` procedemos a realizar un transformación. La cual obtiene los nombres de archivos de esa carpeta con base en una expresión regular `` report_[0-9]+\.txt `` y posteriormente ingresa la información a la tabla estadísticas. El código SQL que hace posible esta carga es el siguiente:

````sql
LOAD DATA LOCAL INFILE '/home/etl/loaded/?'
INTO TABLE visitas.estadisticas
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
email, jyv, badmail, Baja, FechaEnvio, FechaOpen, Opens, OpensVirales, FechaClick, Clicks, ClicksVirales, Links, IPs, Navegadores, Plataformas
)
````

el parametro ? va cambiando por cada nombre de archivo barrido en la carpeta ``/home/etl/loaded``. Como ya se tiene el trigger instalado, al hacer la carga de archivos en la tabla estadísticas, automáticamente se llena la tabla visitantes y se actualizan los contadores conforme a la lógica del trigger.

Como tercer paso se realiza la ejecución de un script sql para llenar la tabla de erroes, está tabla se alimenta de la tabla estadísticas y válida a través de expresiones regulares lo datos que no cumplen con las validaciones solicitadas. El script sql es el siguiente:

````sql
INSERT INTO error
SELECT
 *
FROM estadisticas
WHERE
  estadisticas.email NOT REGEXP '^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
  OR
    estadisticas.FechaEnvio NOT REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
  OR
    estadisticas.FechaOpen NOT REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
  OR
    estadisticas.FechaClick NOT REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
;
````

Este script asume que los datos de estadísticas contienen tanto registros válidos como inválidos, si se quisiera tener solo registros válidos en la tabla estadísticas se tendría que añadir al script anterior lo siguiente:

````sql
DELETE FROM estadisticas
WHERE
  estadisticas.email NOT REGEXP '^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
  OR
    estadisticas.FechaEnvio NOT REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
  OR
    estadisticas.FechaOpen NOT REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
  OR
    estadisticas.FechaClick NOT REGEXP '[0-9]{2}/[0-9]{2}/[0-9]{4} [0-9]{2}:[0-9]{2}'
;
````
De esta manera eliminariamos todos los registros erroneos de la tabla estadísticas, dejandola solo con registros válidos.

Como cuarto paso se realiza el movimiento de archivos de la carpeta ``/home/etl/loaded`` a la carpeta ``/home/etl/visitas/bckp/`` esto para posteriormente empaquetar los archivos TXT en un archivo ZIP.

Para realizar el movimiento de archivos se puede utilizar un entrada de pentaho con la opción de mover archivos o un script en bash para realizar el movimiento. Como ya se había válidado el formato de los archivos, opte por generar un script que moviera los archivos. Me parecio más optimo dejar esta tarea al sistema operativo. El script generado fue el siguiente:

````sh
mv /home/etl/loaded/report_*.txt /home/etl/visitas/bckp/
````

Posteriormente como quinto paso ejecute una entrada de zip de archivos a través de pentaho, en el cuál indique la ruta dónde se encontraban los archivos ``/home/etl/visitas/bckp`` y una expresión regular ``report_[0-9]+\.txt`` para elegir los archivos que se iban a comprimir, agregue al nombre del archivo comprimido, el día y la hora para tener un mejor control de los archivos cargados, adicional, agregue la opción de eliminar al comprimir, sin embargo a pesar de que comprimia no eliminaba los archivos por lo que fue necesario agregar un sexto paso para eliminar los archivos de la carpeta a través de la misma expresión regular.

Las entradas de estás operaciones son las siguientes:

````xml
<entry>
  <name>Zip file</name>
  <description />
  <type>ZIP_FILE</type>
  <zipfilename>/home/etl/visitas/bckp/visitas.zip</zipfilename>
  <compressionrate>2</compressionrate>
  <ifzipfileexists>2</ifzipfileexists>
  <wildcard>report_[0-9]+\.txt</wildcard>
  <wildcardexclude />
  <sourcedirectory>/home/etl/visitas/bckp</sourcedirectory>
  <movetodirectory />
  <afterzip>1</afterzip>
  <addfiletoresult>N</addfiletoresult>
  <isfromprevious>N</isfromprevious>
  <createparentfolder>N</createparentfolder>
  <adddate>Y</adddate>
  <addtime>Y</addtime>
  <SpecifyFormat>N</SpecifyFormat>
  <date_time_format />
  <createMoveToDirectory>N</createMoveToDirectory>
  <include_subfolders>Y</include_subfolders>
  <stored_source_path_depth />
  <parallel>N</parallel>
  <draw>Y</draw>
  <nr>0</nr>
  <xloc>528</xloc>
  <yloc>32</yloc>
</entry>

<entry>
  <name>Delete files</name>
  <description />
  <type>DELETE_FILES</type>
  <arg_from_previous>N</arg_from_previous>
  <include_subfolders>N</include_subfolders>
  <fields>
    <field>
      <name>/home/etl/visitas/bckp</name>
      <filemask>report_[0-9]+\.txt</filemask>
    </field>
  </fields>
  <parallel>N</parallel>
  <draw>Y</draw>
  <nr>0</nr>
  <xloc>608</xloc>
  <yloc>32</yloc>
</entry>
````

De esta manera se completaba el proceso ETL, realizando un backup de los archivos y se optimizaba el espacio al comprimirlos.

Para completar la tarea del ETL fueron necesarios dos trabajos más con una sola instrucción SQL. Estos para reiniciar los contadores al iniciar el mes o al iniciar el año.

Los archivos SQL contenidos en estos JOBS son los siguientes:

Para reinicio de los contadores por mes.

````sql
update visitante SET visitasMesActual = 0;
````

Para reinicio de los contadores por año.

````sql
update visitante SET visitasAnioActual = 0;
````

Los trabajos se pueden agregar a un crontab de la siguiente manera:

````sh
@annually /app/scripts/year.sh
@monthly /app/scripts/month.sh
@daily /app/scripts/daily.sh
````
Los archivos escritos en el crontab tendrían la siguiente información.

year.sh
````sh
#! /bin/bash
/data-integration/kitchen.sh file="/app/jobs/resetYear.kjb" >> /tmp/year.log
````

month.sh
````sh
#! /bin/bash
/data-integration/kitchen.sh file="/app/jobs/resetMonth.kjb" >> /tmp/month.log
````

daily.sh
````sh
#! /bin/bash
/data-integration/kitchen.sh file="/app/jobs/sftpjob.kjb" >> /tmp/daily.log
````

Una vez establecida la automatización a través de crontab se tendría el escenario completo de extracción, tratamiento de datos y carga en base de datos.

Está fue la solución generada para el escenario propuesto. Para ver la implementación consulte el archivo [README.md] (./README.md)

### HADOOP, HIVE e IMPALA

