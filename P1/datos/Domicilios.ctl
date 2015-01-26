LOAD DATA
INFILE 'Domicilios.txt'
APPEND
INTO TABLE Domicilios
FIELDS TERMINATED BY ';'
(dni,Calle,CodigoPostal)