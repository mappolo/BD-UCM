sqlldr userid= GIIC22@FBD/GIIC22 control=empleados.ctl	log=informe_empleados.txt
pause

sqlldr userid= GIIC22@FBD/GIIC22 control=CodigosPostales.ctl log=informe_CodigosPostales.txt
pause

sqlldr userid= GIIC22@FBD/GIIC22 control=Domicilios.ctl	log=informe_Domicilios.txt
pause

sqlldr userid= GIIC22@FBD/GIIC22 control=Telefonos.ctl log=informe_Telefonos.txt
pause