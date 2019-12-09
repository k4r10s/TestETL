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
