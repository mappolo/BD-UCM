LOAD DATA
INFILE 'Telefonos.txt'
APPEND
INTO TABLE Telefonos
FIELDS TERMINATED BY ';'
(dni,Telefono)