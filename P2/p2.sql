/* APARTADO 0
	SET SERVEROUTPUT ON SIZE 100000; 
*/

/* APARTADO 1 */

/*
4)	Escribir un bloque que permita la detección de valores nulos en la tabla "Códigos postales I" y que emita un
	error por pantalla que identifique el problema (usar para ello la instrucción RAISE). 
*/


DECLARE
/*CREATE OR REPLACE PROCEDURE DetectarNulos AS*/
	x_Nulos EXCEPTION;
	v_codigopostal "Codigos Postales 1".codigopostal%TYPE;
	v_poblacion "Codigos Postales 1".poblacion%TYPE;
	v_provincia "Codigos Postales 1".provincia%TYPE;
	CURSOR cursorNulos IS
    SELECT *
    FROM "Codigos Postales 1" 
    WHERE (codigopostal IS NULL) OR (poblacion IS NULL) OR (provincia IS NULL);
BEGIN
	OPEN cursorNulos;
	LOOP
		FETCH cursorNulos INTO v_codigopostal, v_poblacion, v_provincia;
		EXIT WHEN cursorNulos%NOTFOUND;
		RAISE x_Nulos;
	END LOOP;

	CLOSE cursorNulos;
	
	EXCEPTION 
	WHEN x_Nulos THEN
	DBMS_OUTPUT.PUT_LINE('Se han detectado valores nulos en la tabla "Codigos postales 1"');
END;

/*
5)	Crear un bloque que permita detectar la violación de clave primaria en la tabla la tabla "Códigos postales I" y
	que emita por pantalla un error que identifique el problema.
*/
DECLARE
/*CREATE OR REPLACE PROCEDURE Detect_vi_PK AS*/
	x_Viola_Primaria EXCEPTION;
	v_codigopostal "Codigos Postales 1".codigopostal%TYPE;	
	CURSOR cursorViola_Primaria IS
	SELECT c.codigopostal
	FROM "Codigos Postales 1" c
	GROUP BY codigopostal
	HAVING COUNT(*) > 1;
BEGIN
	OPEN cursorViola_Primaria;
	LOOP
		FETCH cursorViola_Primaria INTO v_codigopostal;
		EXIT WHEN cursorViola_Primaria%NOTFOUND;
		RAISE x_Viola_Primaria;
	END LOOP;

	CLOSE cursorViola_Primaria;
	
	EXCEPTION 
	WHEN x_Viola_Primaria THEN
	DBMS_OUTPUT.PUT_LINE('Se ha detectado violación de clave primaria en la tabla "Codigos postales 1"');
END;

/*
6)	Crear un bloque que permita detectar la violación de dependencia funcional en la tabla "Códigos postales I" (a
	una población siempre le corresponde una misma provincia) y que emita por pantalla un error que identifique
	el problema.
*/
DECLARE
/*CREATE OR REPLACE PROCEDURE Detect_vi_FD AS*/
	x_Viola_DF EXCEPTION;
	v_poblacion "Codigos Postales 1".poblacion%TYPE;
	CURSOR cursorViola_DF IS
	SELECT c.poblacion
	FROM "Codigos Postales 1" c
	GROUP BY c.poblacion
	HAVING COUNT(DISTINCT c.provincia) > 1;
BEGIN
	OPEN cursorViola_DF;
	LOOP
		FETCH cursorViola_DF INTO v_poblacion;
		EXIT WHEN cursorViola_DF%NOTFOUND;
		RAISE x_Viola_DF;
	END LOOP;

	CLOSE cursorViola_DF;
	
	EXCEPTION 
	WHEN x_Viola_DF THEN
	DBMS_OUTPUT.PUT_LINE('Se ha detectado violación de dependencia funcional en la tabla "Codigos postales 1"');
END;

/*
7)	Crear un bloque que permita detectar la violación de integridad referencial en la tabla Domicilios I y que
	emita un error por pantalla que identifique el problema.
*/
DECLARE
/*CREATE OR REPLACE PROCEDURE Detect_vi_IR AS*/
	x_Viola_IR EXCEPTION;
	v_codigopostal "Codigos Postales 1".codigopostal%TYPE;
	CURSOR cursorViola_IR IS
	SELECT d.codigopostal
	FROM "Domicilios 1" d
	LEFT JOIN "Codigos Postales 1" c
	ON d.codigopostal=c.codigopostal
	where c.codigopostal IS NULL;
BEGIN
	OPEN cursorViola_IR;
	LOOP
		FETCH cursorViola_IR INTO v_codigopostal;
		EXIT WHEN cursorViola_IR%NOTFOUND;
		RAISE x_Viola_IR;
	END LOOP;

	CLOSE cursorViola_IR;
	
	EXCEPTION 
	WHEN x_Viola_IR THEN
	DBMS_OUTPUT.PUT_LINE('Se ha detectado violación de integridad referencial en la tabla "Domicilios 1"');
END;

/*
8)	Opcional: Crear procedimientos almacenados a partir del bloque definido en el paso 4 añadiendo la siguiente
	funcionalidad: 
		a) Procesamiento por lotes de todas las comprobaciones (en lugar de parar en cada error se deben procesar
			todas las comprobaciones). El tipo de procesamiento se debe poder elegir mediante un parámetro. 
			Nota:
				Para poder probar el procedimiento añadimos dos tuplas con valores nulos a la tabla "Códigos postales I": 
				INSERT INTO "Codigos Postales 1" VALUES (NULL,'Toledo',NULL); 
				INSERT INTO "Codigos Postales 1" VALUES (NULL,'Segovia',NULL);
*/
CREATE OR REPLACE procedure errores(V VARCHAR2) as
  v_nulos number;
  v_PK number;
  v_FD number;
  v_IR number;
  cursor c_error is
  SELECT
    INSTR(V,'n') nulos,
    INSTR(V,'k') PK,
    INSTR(V,'f') FD,
    INSTR(V,'i') IR
FROM DUAL;
BEGIN 
  open c_error;
  FETCH c_error INTO v_nulos, v_PK ,v_FD, v_IR;
   if(v_nulos<>0) then
    DetectarNulos_C;
   end if;
   if(v_PK<>0) then
    Detect_vi_PK_c;
   end if;
   if(v_FD<>0) then
    Detect_vi_FD_c;
   end if;
   if(v_IR<>0) then
    Detect_vi_IR_c;
   end if;
  close c_error;
END;

/*
 EXECUTE ERRORES('valores');
 valores deben ir entre las comillas simples segun se muestra en el ejemplo. Pueden ser n, k, f y/o i por ejemplo: 
 EXECUTE ERRORES('n'); Muestra los nulos
 EXECUTE ERRORES('nk'); Muestra los nulos y violaciones de Primary Key
 EXECUTE ERRORES('nkf'); Muestra los nulos y violaciones de Primary Key y de dependencia funcional.


*/




/* Valores nulos */
DECLARE
/*CREATE OR REPLACE PROCEDURE DetectarNulos_C AS*/
	CURSOR cursorNulos IS
    SELECT *
    FROM "Codigos Postales 1" 
    WHERE (codigopostal IS NULL) OR (poblacion IS NULL) OR (provincia IS NULL);
BEGIN
  DBMS_OUTPUT.PUT_LINE('Valores nulos encontrados en la tabla "Codigos postales 1":');
	FOR cn IN cursorNulos LOOP
    if(cn.codigopostal is null) then
      cn.codigopostal := 'NULL';
    end if;
    if (cn.poblacion is null) then
      cn.poblacion := 'NULL';
    end if;
    if (cn.provincia is null) then
      cn.provincia := 'NULL';
    end if;
    DBMS_OUTPUT.PUT_LINE(cn.codigopostal || ' | '|| cn.poblacion || ' | '|| cn.provincia);
  END LOOP;
END;

/* violación de clave */
DECLARE
/*CREATE OR REPLACE PROCEDURE Detect_vi_PK_c AS*/
	CURSOR cursorViola_Primaria IS
	SELECT c.codigopostal
	FROM "Codigos Postales 1" c
	GROUP BY codigopostal
	HAVING COUNT(*) > 1;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Claves primarias violadas en la tabla "Codigos postales 1":');
	FOR cn IN cursorViola_Primaria LOOP
    if(cn.codigopostal is null) then
      cn.codigopostal := 'NULL';
    end if;
    DBMS_OUTPUT.PUT_LINE(cn.codigopostal);
  END LOOP;
END;

/* violación dependencia funcional */
DECLARE
/*CREATE OR REPLACE PROCEDURE Detect_vi_FD_c AS*/
	CURSOR cursorViola_DF IS
	SELECT c.poblacion
	FROM "Codigos Postales 1" c
	GROUP BY c.poblacion
	HAVING COUNT(DISTINCT c.provincia) > 1;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Dependencias funcionales violadas en la tabla "Codigos postales 1":');
	FOR cn IN cursorViola_DF LOOP
    if (cn.poblacion is null) then
      cn.poblacion := 'NULL';
    end if;
    DBMS_OUTPUT.PUT_LINE(cn.poblacion);
  END LOOP;
END;

/* violación integridad referencial */
DECLARE
/*CREATE OR REPLACE PROCEDURE Detect_vi_IR_c AS*/
	CURSOR cursorViola_IR IS
	SELECT d.codigopostal
	FROM "Domicilios 1" d
	LEFT JOIN "Codigos Postales 1" c
	ON d.codigopostal=c.codigopostal
	where c.codigopostal IS NULL;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Integridades referenciales violadas en la tabla "Domicilios 1":');
	FOR cn IN cursorViola_IR LOOP
    if (cn.codigopostal is null) then
      cn.codigopostal := 'NULL';
    end if;
    DBMS_OUTPUT.PUT_LINE(cn.codigopostal);
  END LOOP;
END;
