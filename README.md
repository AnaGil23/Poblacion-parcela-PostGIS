# Poblacion-parcela-PostGIS
Desagregación de los datos censales a escala de parcela
Este repositorio contiene el script SQL utilizado para calcular la población estimada y otros indicadores demográficos y sociales a escala de parcela catastral en los municipios de Catarroja y Massanassa (Valencia), como parte del Trabajo de Fin de Máster de Ana Gil (2025).

El objetivo es asignar datos censales (población total, edad, género, situación laboral, nivel educativo, etc.) a cada parcela, en función del número de viviendas, para construir un índice de vulnerabilidad social a escala inframunicipal.

# Contenido del repositorio
 - Intersección espacial de parcelas y secciones censales
  - Disolución por referencia catastral
  - Cálculo de población estimada por parcela
  - Estimación de las variables demográficas y socioeconómicas
  - Cálculo de variables sociales relevantes
  - Identificación de equipamientos sensibles (educativos, sanitarios, inclusivos)

# Autoría
Ana Gil  
Máster Universitario en Tecnologías de la Información Geográfica  
Universidad de Alcalá (2024–2025)

Este script forma parte del análisis espacial para el TFM titulado:
"Diagnóstico territorial y delimitación de áreas de vulnerabilidad social frente a inundaciones mediante análisis espacial y visualización interactiva en 3D: caso de Catarroja y Massanassa"
