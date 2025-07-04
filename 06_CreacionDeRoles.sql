/*
Parte 7

Asigne los roles correspondientes para poder cumplir con este requisito, según el área a la
cual pertenece
Tesorería	Jefe de tesorería
Tesorería	Administrativo de Cobranza
Tesorería	Administrativo de Facturacion
Tesorería	Administrativo de Morosos
Socios		Administrativo Socios
Socios		Socio Web
Autoridades	Presidente
Autoridades	Vicepresidente
Autoridades	Secretario
Autoridades	Vocales

    BASE DE DATOS APLICADAS

Fecha de entrega: 19-06-2025
Comision: 5600
Numero de grupo: 03

-Lazarte Ulises 42838702
-Maximo Bertolin Graziano 46364320
-Jordi Marcelo Pairo Albarez 41247253
-Franco Agustin Grosso 46024348
*/

Use COM5600G03
go

--Creacion del rol tesoreria_administrativo_morosos
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'tesoreria_administrativo_morosos')
BEGIN
	CREATE ROLE tesoreria_administrativo_morosos AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de tesoreria_administrativo_morosos ya existe'
END
Go

--Creacion del rol tesoreria_administrativo_cobranza
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'tesoreria_administrativo_cobranza')
BEGIN
	CREATE ROLE tesoreria_administrativo_cobranza AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de tesoreria_administrativo_cobranza ya existe'
END
Go

--Creacion del rol tesoreria_administrativo_facturacion
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'tesoreria_administrativo_facturacion')
BEGIN
	CREATE ROLE tesoreria_administrativo_facturacion AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de tesoreria_administrativo_facturacion ya existe'
END
Go

--Creacion del rol tesoreria_jefe_tesoreria
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'tesoreria_jefe_tesoreria')
BEGIN
	CREATE ROLE tesoreria_jefe_tesoreria AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de tesoreria_jefe_tesoreria ya existe'
END
Go

--Creacion del rol socios_socio
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'socios_socio')
BEGIN
	CREATE ROLE socios_socio AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de socios_socio ya existe'
END
Go

--Creacion del rol socios_administrativo_socio
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'socios_administrativo_socio')
BEGIN
	CREATE ROLE socios_administrativo_socio AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de socios_administrativo_socio ya existe'
END
Go

--Creacion del rol autoridades_presidente
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'autoridades_presidente')
BEGIN
	CREATE ROLE autoridades_presidente AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de autoridades_presidente ya existe'
END
Go

--Creacion del rol autoridades_vicepresidente
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'autoridades_vicepresidente')
BEGIN
	CREATE ROLE autoridades_vicepresidente AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de autoridades_vicepresidente ya existe'
END
Go

--Creacion del rol autoridades_secretario
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'autoridades_secretario')
BEGIN
	CREATE ROLE autoridades_secretario AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de autoridades_secretario ya existe'
END
Go

--Creacion del rol autoridades_vocal
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'autoridades_vocal')
BEGIN
	CREATE ROLE autoridades_vocal AUTHORIZATION dbo
END
ELSE
BEGIN
	print 'El rol de autoridades_vocal ya existe'
END
Go

--Asignacion de permisos para el rol administrativo_morosos
GRANT EXEC ON	socios.eliminar_grupo_familiar TO tesoreria_administrativo_morosos
GRANT EXEC ON	socios.eliminar_socio TO tesoreria_administrativo_morosos
GRANT EXEC ON	facturacion.morosos_recurrentes TO tesoreria_administrativo_morosos
GO

-- Asignacion de permisos para el rol administrativo_cobranza
GRANT EXEC ON	facturacion.insertar_medio_de_pago TO tesoreria_administrativo_cobranza
GRANT EXEC ON	facturacion.modificar_medio_de_pago TO tesoreria_administrativo_cobranza
GRANT EXEC ON	facturacion.eliminar_medio_de_pago TO tesoreria_administrativo_cobranza
GRANT EXEC ON	facturacion.pago_factura TO tesoreria_administrativo_cobranza
GRANT EXEC ON	facturacion.pago_a_cuenta TO tesoreria_administrativo_cobranza
GRANT EXEC ON	facturacion.reembolsar_pago TO tesoreria_administrativo_cobranza
GRANT SELECT ON	facturacion.pago TO tesoreria_administrativo_facturacion
GO

-- Asignacion de permisos para el rol administrativo_facturacion
GRANT EXEC ON	facturacion.crear_factura TO tesoreria_administrativo_facturacion
GRANT SELECT ON	facturacion.factura TO tesoreria_administrativo_facturacion
GRANT SELECT ON	facturacion.detalle_factura TO tesoreria_administrativo_facturacion
GO

-- Asignacion de permisos para el rol jefe_de_tesoreria
GRANT EXEC ON	socios.eliminar_grupo_familiar TO tesoreria_jefe_tesoreria
GRANT EXEC ON	socios.eliminar_grupo_familiar TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.morosos_recurrentes TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.reporte_ingresos_por_actividad TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.insertar_medio_de_pago TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.modificar_medio_de_pago TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.eliminar_medio_de_pago TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.pago_a_cuenta TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.reembolsar_pago TO tesoreria_jefe_tesoreria
GRANT EXEC ON	facturacion.crear_factura TO tesoreria_jefe_tesoreria
GRANT SELECT ON	facturacion.pago TO tesoreria_administrativo_facturacion
GRANT SELECT ON	facturacion.factura TO tesoreria_administrativo_facturacion
GRANT SELECT ON	facturacion.detalle_factura TO tesoreria_administrativo_facturacion
GO

-- Asignacion de permisos para el rol de administrativo_socio
GRANT EXEC ON	socios.insertar_grupo_familiar TO socios_administrativo_socio
GRANT EXEC ON	socios.eliminar_grupo_familiar TO socios_administrativo_socio
GRANT EXEC ON	socios.insertar_socio TO socios_administrativo_socio
GRANT EXEC ON	socios.modificar_habilitar_socio TO socios_administrativo_socio
GRANT EXEC ON	socios.eliminar_socio TO socios_administrativo_socio
GRANT EXEC ON	socios.socios_sin_presentismo_por_actividad TO socios_administrativo_socio
GRANT EXEC ON	socios.cant_inasitencia_por_cat_act TO socios_administrativo_socio
GRANT SELECT ON socios.socio TO socios_administrativo_socio
GO

--Asignacion de permisos para el rol de socio
GRANT EXEC ON 	socios.eliminar_socio TO socios_socio
GRANT EXEC ON 	socios.eliminar_grupo_familiar TO socios_socio
GRANT EXEC ON 	socios.obtener_precio_actual TO socios_socio
GRANT EXEC ON 	actividades.inscripcion_actividad_extra TO socios_socio
GRANT EXEC ON 	actividades.inscripcion_actividad TO socios_socio
GRANT EXEC ON 	actividades.eliminar_inscripcion_actividad TO socios_socio
GRANT EXEC ON 	facturacion.pago_factura TO socios_socio
GRANT SELECT ON socios.socio TO socios_socio
GO


--Asignacion de permisos para el rol del presidente
GRANT EXEC ON socios.insertar_categoria TO autoridades_presidente
GRANT EXEC ON socios.modificar_costo_categoria TO autoridades_presidente
GRANT EXEC ON socios.modificar_fecha_vigencia_categoria TO autoridades_presidente
GRANT EXEC ON socios.eliminar_categoria TO autoridades_presidente
GRANT EXEC ON socios.insertar_rol TO autoridades_presidente
GRANT EXEC ON socios.modificar_rol TO autoridades_presidente
GRANT EXEC ON socios.eliminar_rol TO autoridades_presidente

GRANT EXEC ON actividades.insertar_actividad TO autoridades_presidente
GRANT EXEC ON actividades.eliminar_actividad TO autoridades_presidente
GRANT EXEC ON actividades.modificar_precio_actividad TO autoridades_presidente
GRANT EXEC ON actividades.insertar_actividad_extra TO autoridades_presidente
GRANT EXEC ON actividades.eliminar_actividad_extra TO autoridades_presidente
GRANT EXEC ON actividades.modificar_precio_actividad_extra TO autoridades_presidente

GRANT EXEC ON facturacion.reporte_ingresos_por_actividad TO autoridades_presidente

GRANT EXEC ON empleados.insertar_posicion TO autoridades_presidente
GRANT EXEC ON empleados.actualizar_posicion_por_id TO autoridades_presidente
GRANT EXEC ON empleados.eliminar_posicion_por_id TO autoridades_presidente
GRANT EXEC ON empleados.insertar_posicion_asignada TO autoridades_presidente
GRANT EXEC ON empleados.anular_posicion_asignada TO autoridades_presidente
GRANT EXEC ON empleados.insertar_empleado TO autoridades_presidente
GRANT EXEC ON empleados.actualizar_sueldo TO autoridades_presidente
GRANT EXEC ON empleados.actualizar_empleado_fecha_fin TO autoridades_presidente
Go

--Asignacion de permisos al rol del vicepresidente
GRANT EXEC ON socios.modificar_costo_categoria TO autoridades_vicepresidente
GRANT EXEC ON socios.modificar_fecha_vigencia_categoria TO autoridades_vicepresidente
GRANT EXEC ON socios.insertar_rol TO autoridades_vicepresidente
GRANT EXEC ON socios.modificar_rol TO autoridades_vicepresidente
GRANT EXEC ON socios.eliminar_rol TO autoridades_vicepresidente

GRANT EXEC ON actividades.insertar_actividad TO autoridades_vicepresidente
GRANT EXEC ON actividades.eliminar_actividad TO autoridades_vicepresidente
GRANT EXEC ON actividades.modificar_precio_actividad TO autoridades_vicepresidente
GRANT EXEC ON actividades.insertar_actividad_extra TO autoridades_vicepresidente
GRANT EXEC ON actividades.eliminar_actividad_extra TO autoridades_vicepresidente
GRANT EXEC ON actividades.modificar_precio_actividad_extra TO autoridades_vicepresidente

GRANT EXEC ON facturacion.reporte_ingresos_por_actividad TO autoridades_vicepresidente

GRANT EXEC ON empleados.insertar_empleado TO autoridades_vicepresidente
GRANT EXEC ON empleados.actualizar_sueldo TO autoridades_vicepresidente
GRANT EXEC ON empleados.insertar_posicion TO autoridades_vicepresidente
GRANT EXEC ON empleados.actualizar_posicion_por_id TO autoridades_vicepresidente
GRANT EXEC ON empleados.insertar_posicion_asignada TO autoridades_vicepresidente
GRANT EXEC ON empleados.anular_posicion_asignada TO autoridades_vicepresidente
Go

--Asignacion de permisos al secretario
GRANT EXEC ON socios.modificar_costo_categoria TO autoridades_secretario
GRANT EXEC ON socios.modificar_fecha_vigencia_categoria TO autoridades_secretario

GRANT EXEC ON actividades.insertar_actividad TO autoridades_secretario
GRANT EXEC ON actividades.eliminar_actividad TO autoridades_secretario
GRANT EXEC ON actividades.modificar_precio_actividad TO autoridades_secretario
GRANT EXEC ON actividades.insertar_actividad_extra TO autoridades_secretario
GRANT EXEC ON actividades.eliminar_actividad_extra TO autoridades_secretario
GRANT EXEC ON actividades.modificar_precio_actividad_extra TO autoridades_secretario
GRANT EXEC ON actividades.insertar_horario_actividad TO autoridades_secretario
GRANT EXEC ON actividades.eliminar_horario_actividad TO autoridades_secretario
GRANT EXEC ON actividades.modificar_horario_actividad TO autoridades_secretario

GRANT EXEC ON empleados.insertar_empleado TO autoridades_secretario
GRANT EXEC ON empleados.actualizar_correo_empleado TO autoridades_secretario
GRANT EXEC ON empleados.actualizar_domicilio TO autoridades_secretario
GRANT EXEC ON empleados.actualizar_telefono TO autoridades_secretario
GRANT EXEC ON empleados.actualizar_nro_cuil TO autoridades_secretario
	
GRANT EXEC ON facturacion.reporte_ingresos_por_actividad TO autoridades_secretario
Go
	
--Asignacion de permisos a los vocales
GRANT EXEC ON actividades.insertar_actividad TO autoridades_vocal
GRANT EXEC ON actividades.eliminar_actividad TO autoridades_vocal
GRANT EXEC ON actividades.modificar_precio_actividad TO autoridades_vocal
GRANT EXEC ON actividades.insertar_actividad_extra TO autoridades_vocal
GRANT EXEC ON actividades.eliminar_actividad_extra TO autoridades_vocal
GRANT EXEC ON actividades.modificar_precio_actividad_extra TO autoridades_vocal
GRANT EXEC ON actividades.insertar_horario_actividad TO autoridades_vocal
GRANT EXEC ON actividades.eliminar_horario_actividad TO autoridades_vocal
GRANT EXEC ON actividades.modificar_horario_actividad TO autoridades_vocal

GRANT EXEC ON facturacion.reporte_ingresos_por_actividad TO autoridades_vocal
GRANT EXEC ON facturacion.morosos_recurrentes TO autoridades_vocal
Go

-------------------------------Prueba de roles con creacion de usuarios y Login------------------------------------
/*
--	Ejemplo con Rol de presidente
USE COM5600G03
CREATE LOGIN Lionel_messi WITH PASSWORD = 'contraseña'
Go
CREATE USER Lionel_messi FOR LOGIN lionel_messi
Go
ALTER ROLE autoridades_presidente ADD MEMBER lionel_messi
Go

--	Las siguientes sentencias deberían ejecutarse con normalidad
exec facturacion.reporte_ingresos_por_actividad
exec actividades.insertar_actividad 'Hockey sobre Césped', 20000

--	No se debería permitir la ejecucion de las siguientes sentencias debido a que el permiso de ejecucion está negado
exec socios.socios_sin_presentismo_por_actividad
exec facturacion.morosos_recurrentes '2025-01-01', '2025-07-01', 2

--	Ejemplo con Rol de socio

CREATE LOGIN Juan_Perez WITH PASSWORD = 'otraContra'
Go
CREATE USER Juan_Perez FOR LOGIN Juan_Perez
Go
ALTER ROLE socios_socio ADD MEMBER Juan_Perez
Go

--	Las siguientes sentencias deberían ejecutarse sin problemas
SELECT 1 FROM socios.socio

--	No se debería permitir la ejecucion de las siguientes sentencias debido a que el permiso de ejecucion está negado
exec facturacion.crear_factura 2, '2025-06-01'
exec facturacion.reporte_ingresos_por_actividad*/
