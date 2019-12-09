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
END$$

DELIMITER ;