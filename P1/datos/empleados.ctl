LOAD DATA
INFILE 'empleados.txt'
APPEND
INTO TABLE empleados
FIELDS TERMINATED BY ';'
(nombre,dni,sueldo)
