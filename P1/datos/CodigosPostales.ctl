LOAD DATA
INFILE 'CodigosPostales.txt'
APPEND
INTO TABLE CodigosPostales
FIELDS TERMINATED BY ';'
(CodigoPostal,Poblacion,Provincia)