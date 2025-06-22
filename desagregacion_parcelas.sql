1)
CREATE TABLE parcelas_disueltas AS
SELECT
    "REFCAT",
    SUM(num_viv) AS num_viv,
    MAX("CUSEC") AS cusec,
    MAX("Total") AS total_poblacion,
    ST_Union(geom) AS geom
FROM
    poblacion_parcela2
GROUP BY
    "REFCAT";





2)
CREATE TABLE viviendas_por_seccion AS
SELECT
    cusec,
    SUM(num_viv) AS total_viviendas_seccion
FROM
    parcelas_disueltas
GROUP BY
    cusec;


3)
ALTER TABLE parcelas_disueltas
ADD COLUMN total_viviendas_seccion INTEGER;

UPDATE parcelas_disueltas p
SET total_viviendas_seccion = v.total_viviendas_seccion
FROM viviendas_por_seccion v
WHERE p.cusec = v.cusec;


4)
ALTER TABLE parcelas_disueltas
ADD COLUMN poblacion_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET poblacion_estim_parcela = 
    (total_poblacion::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


5)pop menor 5
ALTER TABLE parcelas_disueltas
ADD COLUMN pob_menor5_total INTEGER;

UPDATE parcelas_disueltas p
SET pob_menor5_total = e.menor_5
FROM edad_poblacionn e
WHERE p.cusec = e.cusec;

ALTER TABLE parcelas_disueltas
ADD COLUMN pob_menor5_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET pob_menor5_estim_parcela = 
    (pob_menor5_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


6)pop mayor 65
ALTER TABLE parcelas_disueltas
ADD COLUMN pob_mayor65_total INTEGER;

UPDATE parcelas_disueltas p
SET pob_mayor65_total = e.mayor_65
FROM edad_poblacionn e
WHERE p.cusec = e.cusec;

ALTER TABLE parcelas_disueltas
ADD COLUMN pob_mayor65_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET pob_mayor65_estim_parcela = 
    (pob_mayor65_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


7)extranjeros (grupo vulnerable)
ALTER TABLE extranjeros
ADD COLUMN extran_vulner_total INTEGER;

UPDATE extranjeros
SET extran_vulner_total = 
    COALESCE(ext_marrue, 0) +
    COALESCE(ext_bolivi, 0) +
    COALESCE(ext_colomb, 0) +
    COALESCE(ext_ecuado, 0) +
    COALESCE(ext_venezu, 0) +
    COALESCE(ext_repabl, 0) +
    COALESCE(ext_ruman_, 0) +
    COALESCE(ext_ucrani, 0) +
    COALESCE(ext_apetri, 0) +
    COALESCE("ext_pera,n", 0);  

ALTER TABLE parcelas_disueltas
ADD COLUMN extran_vulner_total INTEGER;

UPDATE parcelas_disueltas p
SET extran_vulner_total = e.extran_vulner_total
FROM edad_poblacionn e
WHERE p.cusec = e.cusec;

ALTER TABLE parcelas_disueltas
ADD COLUMN extran_vulner_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET extran_vulner_estim_parcela = 
    (extran_vulner_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


8) mujeres
ALTER TABLE parcelas_disueltas
ADD COLUMN mujeres_total INTEGER;

UPDATE parcelas_disueltas p
SET mujeres_total = s."Mujeres"
FROM poblacion_sexo s
WHERE p.cusec = s.cusec;

ALTER TABLE parcelas_disueltas
ADD COLUMN mujeres_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET mujeres_estim_parcela = 
    (mujeres_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


9)Ocupacion
ALTER TABLE parcelas_disueltas
ADD COLUMN ocup_elementales_total INTEGER;

UPDATE parcelas_disueltas p
SET ocup_elementales_total = (o."Ocupaciones_elementales_total")::INTEGER
FROM ocupacion_agregad o
WHERE p.cusec = o."CUSEC";

ALTER TABLE parcelas_disueltas
ADD COLUMN ocup_elementales_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET ocup_elementales_estim_parcela = 
    (ocup_elementales_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


10)situacion profesional
ALTER TABLE parcelas_disueltas
ADD COLUMN cuenta_propia_total INTEGER;

UPDATE parcelas_disueltas p
SET cuenta_propia_total = (s."Trabajador por cuenta propia")::INTEGER
FROM situacion_profesional s
WHERE p.cusec = s.cusec;

ALTER TABLE parcelas_disueltas
ADD COLUMN cuenta_propia_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET cuenta_propia_estim_parcela = 
    (cuenta_propia_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;

11)tasa paro
ALTER TABLE parcelas_disueltas
ADD COLUMN total_parados NUMERIC;

UPDATE parcelas_disueltas p
SET total_parados = t.tasaparo
FROM tasa_paro t
WHERE p.cusec = t."CUSEC";

ALTER TABLE parcelas_disueltas
ADD COLUMN parados_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET parados_estim_parcela = 
    (total_parados / NULLIF(total_viviendas_seccion, 0)) * num_viv;


12) nivel estudios
ALTER TABLE parcelas_disueltas
ADD COLUMN estudios_primaria_total INTEGER;

UPDATE parcelas_disueltas p
SET estudios_primaria_total = (n."educacionprimaria_inferior ")::INTEGER
FROM nivel_estudios n
WHERE p.cusec = n.cusec;

ALTER TABLE parcelas_disueltas
ADD COLUMN estudios_primaria_estim_parcela NUMERIC;

UPDATE parcelas_disueltas
SET estudios_primaria_estim_parcela = 
    (estudios_primaria_total::NUMERIC / NULLIF(total_viviendas_seccion, 0)) * num_viv;


13)antiguedad
ALTER TABLE parcelas_disueltas
ADD COLUMN antiguedad INTEGER;

UPDATE parcelas_disueltas p
SET antiguedad = c."ANTIGUEDAD"
FROM catastro_todo c
WHERE p."REFCAT" = c."REFCAT";


14)elementos sensibles
ALTER TABLE parcelas_disueltas
ADD COLUMN elemento_sensible INTEGER DEFAULT 0;

UPDATE parcelas_disueltas p
SET elemento_sensible = 1
WHERE EXISTS (
    SELECT 1
    FROM elementos e
    WHERE ST_Intersects(p.geom, e.geom)
);


15)
ALTER TABLE parcelas_disueltas
ADD COLUMN centro_educativo INTEGER DEFAULT 0;

UPDATE parcelas_disueltas p
SET centro_educativo = 1
WHERE EXISTS (
    SELECT 1
    FROM centros_educativos ce
    WHERE ST_Intersects(p.geom, ce.geom)
);


16)
ALTER TABLE parcelas_disueltas
ADD COLUMN centro_inclusivo INTEGER DEFAULT 0;

UPDATE parcelas_disueltas p
SET centro_inclusivo = 1
WHERE EXISTS (
    SELECT 1
    FROM centros_inclusivos ce
    WHERE ST_Intersects(p.geom, ce.geom)
);


17)
ALTER TABLE parcelas_disueltas
ADD COLUMN centro_salud INTEGER DEFAULT 0;

UPDATE parcelas_disueltas p
SET centro_salud = 1
WHERE EXISTS (
    SELECT 1
    FROM centros_salud ce
    WHERE ST_Intersects(p.geom, ce.geom)
);