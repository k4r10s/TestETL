LOAD DATA LOCAL INFILE '/home/etl/loaded/?'
INTO TABLE visitas.estadisticas
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
email, jyv, badmail, Baja, FechaEnvio, FechaOpen, Opens, OpensVirales, FechaClick, Clicks, ClicksVirales, Links, IPs, Navegadores, Plataformas
)
