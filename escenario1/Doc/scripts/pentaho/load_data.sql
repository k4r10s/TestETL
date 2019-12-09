LOAD DATA LOCAL INFILE '/home/vink0s/loaded/*.txt' 
INTO TABLE visitas.estadisticas
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
email, jyv, badmail, Baja, Fecha, envio, FechaOpen, Opens, OpensVirales, FechaClick, Clicks, ClicksVirales, Links, IPs, Navegadores, Plataformas
)
