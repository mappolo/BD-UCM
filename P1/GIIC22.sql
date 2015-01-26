/* 
CONECTAR A FBD:
GIIC22
GIIC22
*/
/*
CREATE TABLESPACE EMPRESAGIIC22 DATAFILE 'D:\oracle\EMPRESAGIIC22' 
SIZE 5M AUTOEXTEND OFF;

CREATE USER GIIC22 IDENTIFIED BY GIIC22 DEFAULT TABLESPACE 
EMPRESAGIIC22 TEMPORARY TABLESPACE TEMP QUOTA UNLIMITED ON 
EMPRESAGIIC22;

GRANT CREATE SESSION, CREATE TABLE, DELETE ANY TABLE, SELECT ANY 
DICTIONARY, CREATE ANY SEQUENCE TO GIIC22; 
*/

/* 
 * Apartado 1: Crear y ejecutar el script crea_tablas.sql
 * 
 */

/* BORRADO DE TABLAS*/
DROP TABLE Empleados CASCADE CONSTRAINTS;
DROP TABLE Domicilios CASCADE CONSTRAINTS;
DROP TABLE Telefonos CASCADE CONSTRAINTS;
DROP TABLE CodigosPostales CASCADE CONSTRAINTS;

/* Empleados(Nombre: Char(50), /DNI: Char(9), Sueldo*: Number(6,2))  */
CREATE TABLE Empleados(
  Nombre CHAR(50) NOT NULL,
  DNI CHAR(9),
  Sueldo NUMBER(6,2),
  CONSTRAINTS emp_PK PRIMARY KEY (DNI)
);

/* Domicilios(/DNI: Char(9), /Calle: Char(50), /CodigoPostal: Char(5))  */
CREATE TABLE Domicilios(
	DNI CHAR(9),
	Calle CHAR(50),
	CodigoPostal CHAR(5),
	CONSTRAINTS dom_PK PRIMARY KEY (DNI, Calle, CodigoPostal)
);

/* Telefonos(/DNI: Char(9), /Telefono: Char(9))  */
CREATE TABLE Telefonos(
	DNI CHAR(9),
	Telefono CHAR(9),
	CONSTRAINTS tf_PK PRIMARY KEY (DNI, Telefono)
);

/* CodigosPostales(/CodigoPostal: Char(5), Poblacion: Char(50), Provincia: Char(50))  */
CREATE TABLE CodigosPostales(
	CodigoPostal CHAR(5) NOT NULL,
	Poblacion CHAR(50) NOT NULL,
	Provincia CHAR(50) NOT NULL,
	CONSTRAINTS codPos_PK PRIMARY KEY (CodigoPostal) /*ON DELETE RESTRICT -> por defecto*/
);

/* Ampliamos las tablas*/
ALTER TABLE Empleados ADD CONSTRAINTS emp_sueldo CHECK (Sueldo >= 0 AND Sueldo <= 5000);
ALTER TABLE Domicilios ADD CONSTRAINTS dom_FK_dni FOREIGN KEY (DNI) REFERENCES Empleados (DNI) ON DELETE CASCADE;
ALTER TABLE Domicilios ADD CONSTRAINTS dom_FK_cp FOREIGN KEY (CodigoPostal) REFERENCES CodigosPostales (CodigoPostal); /* ON DELETE CASCADE; */
ALTER TABLE Telefonos ADD CONSTRAINTS tf_FK FOREIGN KEY (DNI) REFERENCES Empleados (DNI) ON DELETE CASCADE;

/*
 * Apartado 2: Carga de datos con INSERT
 */

 /* Insertamos una línea de datos en cada tabla */
INSERT INTO Empleados VALUES ('Nombre1','12345678A','1000');
INSERT INTO Telefonos VALUES ('12345678A','912345678');
INSERT INTO CodigosPostales VALUES ('28000','Getafe','Madrid');
INSERT INTO Domicilios VALUES ('12345678A','C/Madrid s/n','28000');

/* ERRORES */
/* Se intenta insertar una fila con clave primaria duplicada */
INSERT INTO Empleados VALUES ('Nombre2','12345678A','2000');
 
/* Se intenta una inserción que no incluye todas las columnas no nulables */
INSERT INTO Empleados (DNI,Sueldo) VALUES ('00000000B','3000');

/* Se intenta una inserción que no verifica las restricciones de dominio (CHECK) */
INSERT INTO Empleados VALUES ('Nombre3','11111111A','5001');

/* Se intenta una inserción que no respeta una regla de integridad referencial */
INSERT INTO Telefonos VALUES ('22222222C','4000');

/* Documenta que pasa si se intenta un borrado en una tabla padre con filas dependientes donde la
	FK tiene una regla de borrado ON DELETE RESTRICT (el defecto)*/
TRUNCATE TABLE CodigosPostales;
DELETE CodigosPostales;
DELETE FROM CodigosPostales WHERE CodigoPostal = '28000';

/* Documenta que pasa si se intenta un borrado en una tabla padre con filas dependientes donde la
	FK tiene una regla de borrado ON DELETE CASCADE. Por ejemplo, borrar un empleado y
	documentar que pasa con sus teléfonos y direcciones */
TRUNCATE TABLE Empleados;
DELETE Empleados;

/*
 * Apartado 3: Carga de datos con SQL Loader
 */
 
/*Borrar todas las filas de todas las tablas*/
DELETE Telefonos;
DELETE Domicilios;
DELETE CodigosPostales;
DELETE Empleados;

/* ejecutar cargar.bat de la carpeta Datos
sqlldr userid= ucm@xe/ucm control=empleados.ctl 
log=informe_empleados.txt

sqlldr userid= ucm@xe/ucm control=CodigosPostales.ctl 
log=informe_CodigosPostales.txt

sqlldr userid= ucm@xe/ucm control=Domicilios.ctl 
log=informe_Domicilios.txt

sqlldr userid= ucm@xe/ucm control=Telefonos.ctl 
log=informe_Telefonos.txt
*/
 
/*
 * Apartado 4: Consultas SQL en el archivo consultas.sql
 */
 
/* 1) Listado de empleados que muestre Nombre, Calle y Código postal
	ordenados por Código postal y Nombre */
SELECT NOMBRE, CALLE, CODIGOPOSTAL
FROM EMPLEADOS E, DOMICILIOS D
WHERE E.DNI=D.DNI
ORDER BY D.CODIGOPOSTAL ASC,E.NOMBRE ASC;


/* 2) Listado de los empleados ordenados por nombre que muestre Nombre, DNI, Calle, Código 
	postal y teléfono, obteniendo sólo los empleados que tengan teléfono. */
SELECT E.NOMBRE,E.DNI,D.CALLE,D.CODIGOPOSTAL,T.TELEFONO
FROM EMPLEADOS E
LEFT JOIN DOMICILIOS D ON D.DNI=E.DNI
INNER JOIN TELEFONOS T ON T.DNI=E.DNI
ORDER BY E.NOMBRE ASC;

/* 3) Listado de los empleados ordenados por nombre que muestre Nombre, DNI, Calle, Código
	postal y teléfono, obteniendo tanto los empleados que tengan teléfono como los que no. */
SELECT E.NOMBRE,E.DNI,D.CALLE,D.CODIGOPOSTAL,T.TELEFONO
FROM EMPLEADOS E
LEFT JOIN DOMICILIOS D ON D.DNI=E.DNI
LEFT JOIN TELEFONOS T ON T.DNI=E.DNI
ORDER BY E.NOMBRE ASC;

/* 4) Listado del número total de empleados, el sueldo máximo, el mínimo y el medio. */
SELECT COUNT(*) EMPLEADOS, MIN (E.SUELDO) "MÍNIMO", MAX(E.SUELDO) "MÁXIMA", AVG(E.SUELDO) MEDIA
FROM EMPLEADOS E;

/* 5) Listado de sueldo medio y número de empleados por población ordenado por población. */
SELECT AVG(E.SUELDO) MEDIO, COUNT(*) AS EMPLEADOS, C.POBLACION
FROM (EMPLEADOS E LEFT JOIN DOMICILIOS D ON E.DNI=D.DNI)
LEFT JOIN CODIGOSPOSTALES C ON D.CODIGOPOSTAL = C.CODIGOPOSTAL
GROUP BY C.POBLACION
ORDER BY POBLACION;

/* 6) Listado de provincias con códigos postales ordenado por población. En la cabecera de las 
	columnas deben aparecer las provincias y en cada columna los códigos postales de las 
	localidades de cada provincia. */
SELECT C.POBLACION, C.CODIGOPOSTAL AS "BARCELONA", NULL AS "CORDOBA", NULL AS "MADRID", NULL AS "ZARAGOZA"
FROM CODIGOSPOSTALES C
WHERE PROVINCIA = 'BARCELONA'
UNION
SELECT C.POBLACION, NULL AS "BARCELONA", C.CODIGOPOSTAL AS "CORDOBA", NULL AS "MADRID", NULL AS "ZARAGOZA"
FROM CODIGOSPOSTALES C
WHERE PROVINCIA = 'CÓRDOBA'
UNION
SELECT C.POBLACION,NULL AS "BARCELONA", NULL AS "CORDOBA", C.CODIGOPOSTAL AS "MADRID", NULL AS "ZARAGOZA"
FROM CODIGOSPOSTALES C
WHERE PROVINCIA = 'MADRID'
UNION
SELECT C.POBLACION,NULL AS "BARCELONA", NULL AS "CORDOBA", NULL AS "MADRID", C.CODIGOPOSTAL AS "ZARAGOZA"
FROM CODIGOSPOSTALES C
WHERE PROVINCIA = 'ZARAGOZA'


/* 7) Obtener el nombre y DNI de cada empleado con su número de teléfonos, que puede ser cero. */
SELECT E.NOMBRE, E.DNI, COUNT(T.DNI) TELEFONO
FROM EMPLEADOS E
LEFT JOIN TELEFONOS T ON E.DNI=T.DNI
GROUP BY E.NOMBRE, E.DNI;

/* 8) Obtener los empleados que tengan más de un teléfono, indicando Nombre y DNI ordenados por
	su nombre. */
SELECT E.NOMBRE, E.DNI, COUNT(T.DNI) TELEFONO
FROM EMPLEADOS E
LEFT JOIN TELEFONOS T ON E.DNI=T.DNI
WHERE TELEFONO !=0
GROUP BY E.NOMBRE, E.DNI
ORDER BY NOMBRE;

/* 9) Obtener los empleados que ganan más que la media de salarios de su código postal. */
SELECT T2.NOMBRE
FROM(SELECT D.CODIGOPOSTAL, AVG(E.SUELDO) MEDIA
FROM DOMICILIOS D
LEFT JOIN EMPLEADOS E ON D.DNI=E.DNI
GROUP BY D.CODIGOPOSTAL) T1,(SELECT E.NOMBRE, E.SUELDO, D.CODIGOPOSTAL
FROM EMPLEADOS E, DOMICILIOS D
WHERE E.DNI=D.DNI) T2
WHERE T1.CODIGOPOSTAL= T2.CODIGOPOSTAL AND T2.SUELDO>T1.MEDIA;

/* 10) Incrementar en un 10% el sueldo de todos los empleados, de forma que el sueldo aumentado no 
	supere en ningún caso 1.900 . */
UPDATE EMPLEADOS SET SUELDO = SUELDO*1.1
WHERE SUELDO*1.1 <= 1900;


/*----------------------------FIN----------------------------*/
