LOAD DATA
INFILE 'codigospostales1.txt'
APPEND
INTO TABLE "Codigos Postales 1"
FIELDS TERMINATED BY ';'
(CodigoPostal,Poblacion,Provincia)