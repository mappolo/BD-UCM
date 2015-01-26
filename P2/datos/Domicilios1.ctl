LOAD DATA
INFILE 'Domicilios1.txt'
APPEND
INTO TABLE "Domicilios 1"
FIELDS TERMINATED BY ';'
(dni,Calle,CodigoPostal)