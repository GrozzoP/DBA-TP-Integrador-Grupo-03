/*
Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que 
realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que 
en los juegos de prueba demuestren la correcta aplicación de las validaciones. 
Las pruebas deben realizarse en un script separado, donde con comentarios se indique en 
cada caso el resultado esperado 
*/

Use COM5600G03
go

--
/*** SP auxiliares ***/
create or alter procedure eliminarYrestaurarTabla @nombreDeTabla varchar(50)
as
begin
	declare @consulta varchar(max)
	set @consulta = 'delete from ' + @nombreDeTabla
	exec(@consulta)
	DBCC CHECKIDENT (@nombreDeTabla, RESEED, 0);
end
/*** Fin de SP auxiliares ***/
go

/*****	socios.insertarRol(@nombre_rol varchar(20), @descripcion_rol varchar(50))	******/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.rol'
--Se espera que se inserten los siguientes registros

exec socios.insertarRol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertarRol 'Moderador', 'Encargado de moderar el sistema'
exec socios.insertarRol '', ''
exec socios.insertarRol NULL, NULL
exec socios.insertarRol 'Administrador',  'Supervisar operaciones diarias'

-- No se podran insertar los siguientes mensajes, debera aparecer el mensaje correspondiente indicando el error
exec socios.insertarRol 'Usuario', 'Un socio que quiere usar el sistema'
exec socios.insertarRol '', 'Un invitado que quiere usar el sistema'

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.rol'


/*****	socios.modificarRol(@nombre_rol varchar(20), @nueva_descripcion_rol varchar(50))	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertarRol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertarRol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertarRol '', 'Rol vacio'

--Se espera que los registros anteriores vean su descripcion = 'modificado'
exec socios.modificarRol 'Usuario', 'Rol de usuario'
exec socios.modificarRol 'Administrador', 'Persona designada para revisar las operaciones'
exec socios.modificarRol '', 'Rol fantasma'

--Se espera mensaje 'El rol que se quiere modificar, no existe segun su nombre.'
exec socios.modificarRol 'Controlador', 'modificado'
exec socios.modificarRol 'Deportista', 'modificado'

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.rol'


/*****	socios.eliminarRol(@nombre_rol varchar(20))	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertarRol 'Usuario', 'Rol de usuario'
exec socios.insertarRol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertarRol '', ''

--Se espera la eliminacion exitosa de los registro anteriores
exec socios.eliminarRol 'Usuario'
exec socios.eliminarRol 'Administrador'
exec socios.eliminarRol ''

--Se espera mensaje 'El rol que se quiere eliminar, no existe segun su nombre.'
exec socios.eliminarRol 'noExiste'

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.rol'

/*****	socios.insertarUsuario
						@id_rol int,
						@contraseña varchar(40),
						@fecha_vigencia_contraseña date	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertarRol 'a', 'a'
exec socios.insertarRol 'b', 'b'
exec socios.insertarRol 'c', 'c'

--Se espera la insercion exitosa de los sig usuarios con roles asignados validos
declare @fechaDePrueba date = GETDATE();
exec socios.insertarUsuario 1, 'contraseñaDeUsuario1', @fechaDePrueba
exec socios.insertarUsuario 2, 'contraseñaDeUsuario2', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaDeUsuario3', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaDeUsuario4', @fechaDePrueba
--Se espera el mensaje 'No existe un rol con ese id.'
exec socios.insertarUsuario 4, 'contraseñaDeUsuario5', @fechaDePrueba

--Se espera el mensaje 'La fecha de vigencia no puede ser anterior a la actual.'
set @fechaDePrueba = DATEADD(DAY, -5, @fechaDePrueba)
exec socios.insertarUsuario 3, 'contraseñaDeUsuario5', @fechaDePrueba

--Se espera la insercion exitosa del sig registro
exec socios.insertarUsuario 3, 'contraseñaDeUsuario6', NULL

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'
go

/*****	socios.modificarContraseñaUsuario @id_usuario int, @contraseña varchar(40) *****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertarRol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertarRol 'Moderador', 'Encargado de moderar el sistema'
exec socios.insertarRol 'Administrador', 'Supervisar operaciones diarias'

DECLARE @fechaDePrueba date = GETDATE();

exec socios.insertarUsuario 1, 'contraseñaOriginalDeUsuario1', @fechaDePrueba
exec socios.insertarUsuario 2, 'contraseñaOriginalDeUsuario2', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaOriginalDeUsuario3', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaOriginalDeUsuario4', @fechaDePrueba

--Se espera la modificacion exitosa de la contraseña
exec socios.modificarContraseñaUsuario 1, 'contraseñaModificadaDeUsuario1'
exec socios.modificarContraseñaUsuario 2, 'contraseñaModificadaDeUsuario2'
exec socios.modificarContraseñaUsuario 3, 'contraseñaModificadaDeUsuario3'
exec socios.modificarContraseñaUsuario 4, 'contraseñaModificadaDeUsuario4'
exec socios.modificarContraseñaUsuario 4, ''
exec socios.modificarContraseñaUsuario 4, NULL

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.modificarContraseñaUsuario 5, 'contraseñaModificadaDeUsuario5'

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'
go

/*****	socios.modificarFechaVigenciaUsuario @id_usuario int, @fecha_vigencia_contraseña date *****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertarRol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertarRol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertarRol 'Moderador', 'Modera usuarios'

declare @fechaDePrueba date = GETDATE();
declare @fechaDePruebaModificada date;

exec socios.insertarUsuario 1, 'contraseñaDeUsuario1', @fechaDePrueba
exec socios.insertarUsuario 2, 'contraseñaDeUsuario2', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaDeUsuario3', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaDeUsuario4', @fechaDePrueba

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual' si fecha_vigencia_contraseña nueva es igual al original
exec socios.modificarFechaVigenciaUsuario 1, @fechaDePrueba

--Se espera la modificacion exitosa de la fecha_vigencia_contraseña
set @fechaDePruebaModificada = DATEADD(DAY, 1, @fechaDePrueba)
exec socios.modificarFechaVigenciaUsuario 1, @fechaDePruebaModificada
exec socios.modificarFechaVigenciaUsuario 2, @fechaDePruebaModificada
exec socios.modificarFechaVigenciaUsuario 3, @fechaDePruebaModificada
exec socios.modificarFechaVigenciaUsuario 4, @fechaDePruebaModificada
exec socios.modificarFechaVigenciaUsuario 4, @fechaDePruebaModificada

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.modificarFechaVigenciaUsuario 5, @fechaDePrueba

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual'
set @fechaDePruebaModificada = DATEADD(DAY, -5, @fechaDePrueba)
exec socios.modificarFechaVigenciaUsuario 1, @fechaDePruebaModificada

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'
go

/*****	socios.eliminarUsuario @id_usuario int *****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertarRol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertarRol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertarRol 'Moderador', 'Modera usuarios'

declare @fechaDePrueba date = GETDATE();

exec socios.insertarUsuario 1, 'contraseñaDeUsuario1', @fechaDePrueba
exec socios.insertarUsuario 2, 'contraseñaDeUsuario2', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaDeUsuario3', @fechaDePrueba
exec socios.insertarUsuario 3, 'contraseñaDeUsuario4', @fechaDePrueba

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.eliminarUsuario -1
exec socios.eliminarUsuario 0
exec socios.eliminarUsuario 5

--Se espera la eliminacion exitosa de los sig usuarios
exec socios.eliminarUsuario 1
exec socios.eliminarUsuario 2
exec socios.eliminarUsuario 3
exec socios.eliminarUsuario 4

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'

/*****	socios.insertarObraSocial @nombre_obra_social varchar(60), @telefono_obra_social int	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.obra_social'

--Se espera la insercion exitosa de los sig registros
exec socios.insertarObraSocial '', 0
exec socios.insertarObraSocial 'obraSocial1', 0
exec socios.insertarObraSocial 'obraSocial2', 0
exec socios.insertarObraSocial 'obraSocial3', 0
exec socios.insertarObraSocial NULL, NULL
--Se espera un error por que el valor de telefono supera el valor MAX 2147483647

exec socios.insertarObraSocial 'obraSocial4', 2147483648
--Se espera un mensaje 'El numero de telefono no puede ser negativo'

exec socios.insertarObraSocial 'obraSocial5', -1
--Se espera mensaje 'Ya existe una obra social con ese nombre.'

exec socios.insertarObraSocial '', 0
exec socios.insertarObraSocial 'obraSocial1', 11111111
exec socios.insertarObraSocial 'obraSocial2', 11111111
exec socios.insertarObraSocial 'obraSocial3', 11111111

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.obra_social'

/*****	socios.modificarObraSocial @nombre_obra_social varchar(60), @telefono_obra_social int	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.obra_social'

--Insertando registros para prueba
exec socios.insertarObraSocial 'obraSocial1', 11111111
exec socios.insertarObraSocial 'obraSocial2', 22222222
exec socios.insertarObraSocial 'obraSocial3', 33333333
exec socios.insertarObraSocial 'obraSocial4', 44444444

--Se espera la modificacion del @telefono_obra_social de los siguientes registros con exito
exec socios.modificarObraSocial 'obraSocial1', 0
exec socios.modificarObraSocial 'obraSocial2', 0
exec socios.modificarObraSocial 'obraSocial3', 0
exec socios.modificarObraSocial 'obraSocial4', 0

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.modificarObraSocial 'obraSocial6', 0
exec socios.modificarObraSocial 'obraSocial7', 0
exec socios.modificarObraSocial 'obraSocial8', 0

--Se espera mensaje 'El numero de telefono no puede ser negativo'
exec socios.modificarObraSocial 'obraSocial1', -1

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.obra_social'

/*****	socios.eliminarObraSocial @nombre_obra_social varchar(60)	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.obra_social'

--Insertando registros para prueba
exec socios.insertarObraSocial 'obraSocial1', 11111111
exec socios.insertarObraSocial 'obraSocial2', 22222222
exec socios.insertarObraSocial 'obraSocial3', 33333333
exec socios.insertarObraSocial 'obraSocial4', 44444444
--Se espera la eliminacion de los siguientes registros
exec socios.eliminarObraSocial 'obraSocial1'
exec socios.eliminarObraSocial 'obraSocial2'
exec socios.eliminarObraSocial 'obraSocial3'
exec socios.eliminarObraSocial 'obraSocial4'

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.eliminarCategoria 'obraSocial1'

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.obra_social'


use COM5600G03
go

/*
--dropear la base de datos y generar sps y tablas nuevamente, antes de realizar este test, pintar cada exec paso a paso
select*from socios.rol
select*from facturacion.medio_de_pago
select*from socios.usuario
select*from socios.obra_social
select*from socios.categoria
select*from socios.socio
select*from socios.responsable_menor
select*from actividades.actividad
select*from actividades.actividad_extra
select*from actividades.horario_actividades
select*from actividades.inscripcion_actividades
select*from actividades.inscripcion_act_extra
select*from facturacion.factura
select*from facturacion.pago
--medio pago
 exec facturacion.crearMedioPago 'Mercadolibre',1
--rol
 exec socios.insertarRol 'Usuario','Anda re loco por la vida'
 --usuario
 exec socios.insertarUsuario 1,'Oracle puto', '24-05-2025'
 --obra social
 exec socios.insertarObraSocial 'ObraSocialPOLO',1133589593
 --categoria
 exec socios.insertarCategoria 'Adulto',18,70,400.50
 --insertar socio
 exec socios.insertarSocio 42838702,'Ulises','Lazarte','ulazarte22@gmail.com','28-10-2000',1133589591,1133589592,1,1,1,1
 --insertar actividad
 exec actividades.insertar_actividad 'Futbol',900.50
 --insertar horario
 exec actividades.insertar_horario_actividad 'Jueves', '21:00','22:00',1,1
 --realizar inscripcion del socio a la actividad de futbol los jueves de 21 a 22 hs
 exec actividades.inscripcion_actividad 1,1,1
 --se realizo la inscripcion y debe de generarse una factura en la tabla factura y la inscripcion en la tabla inscripcion
 select*from actividades.inscripcion_actividades
 select*from facturacion.factura
 -- se debe de realizar el pago de la inscripcion y cambiar el estado de NO PAGADO a PAGADO
 exec facturacion.pago_factura 1,'PAGO',1
 select*from actividades.inscripcion_actividades
 select*from facturacion.pago
 select*from facturacion.factura
 */
