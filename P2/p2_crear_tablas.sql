/* Codigos Postales 1(/CodigoPostal: Char(5), Poblacion: Char(50), Provincia: Char(50))  */
CREATE TABLE "Codigos Postales 1"(
	CodigoPostal CHAR(5),
	Poblacion CHAR(50),
	Provincia CHAR(50)
);

/* Domicilios 1(/DNI: Char(9), /Calle: Char(50), /CodigoPostal: Char(5))  */
CREATE TABLE "Domicilios 1"(
	DNI CHAR(9),
	Calle CHAR(50),
	CodigoPostal CHAR(5)
);