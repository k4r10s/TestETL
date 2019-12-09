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
