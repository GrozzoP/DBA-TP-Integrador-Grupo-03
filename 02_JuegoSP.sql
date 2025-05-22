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

/*****	socios.insertarCategoria 
						@nombre_categoria varchar(16), @edad_minima int,
						@edad_maxima int, @costo_membresia decimal(9,3)	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.categoria'

--Se espera la insercion exitosa de los siguientes registro
exec socios.insertarCategoria 'Menor', 1, 18, 9.69
exec socios.insertarCategoria 'Cadete', 19, 27, 1.01
exec socios.insertarCategoria 'Mayor', 28, 35, 0

--Se espera mensaje 'Ya existe una categoría con ese nombre.'
exec socios.insertarCategoria 'Menor', 1, 18, 10.50

--Se espera mensaje 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
exec socios.insertarCategoria 'Veterano', 5, 5, 10.6
exec socios.insertarCategoria 'Sargento', 7, 5, 10.6

--Se espera mensaje 'El costo de la membresia no puede ser negativo.'
exec socios.insertarCategoria 'Veterano', 36, 45, -1.99

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.categoria'

/*****	socios.modificarCostoCategoria @nombre_categoria varchar(16), @costo_membresia decimal(9,3) *****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.categoria'

--Insertando registros para la prueba
exec socios.insertarCategoria 'Menor', 1, 18, 9.69
exec socios.insertarCategoria 'Cadete', 19, 27, 1.01
exec socios.insertarCategoria 'Mayor', 28, 35, 0

--Se espera la modificacion del valor de costo_membresía
exec socios.modificarCostoCategoria 'Menor', 10.99
exec socios.modificarCostoCategoria 'Cadete', 20.99

--Se espera mensaje 'El nuevo costo de la membresia no puede ser negativo.'
exec socios.modificarCostoCategoria 'Menor', -5.66

--Se espera mensaje 'No existe una categoría con ese nombre.'
exec socios.modificarCostoCategoria 'Sargento', 10.69

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.categoria'

/******	socios.eliminarCategoria @nombre_categoria varchar(16)	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.categoria'

--Insertando registros para la prueba
exec socios.insertarCategoria 'Menor', 1, 18, 9.69
exec socios.insertarCategoria 'Cadete', 19, 27, 1.01
exec socios.insertarCategoria 'Mayor', 28, 35, 0

--Se espera la eliminacion de los siguientes registros
exec socios.eliminarCategoria 'Menor'
exec socios.eliminarCategoria 'Cadete'
exec socios.eliminarCategoria 'Mayor'

--Se espera mensaje 'No existe una categoría con ese nombre.'
exec socios.eliminarCategoria 'Sargento'

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.categoria'

/***** socios.insertarSocio 
					@dni int, @nombre varchar(40), 
					@apellido varchar(40), @email varchar(150), 
					@fecha_nacimiento date, @telefono_contacto int, 
					@telefono_emergencia int, @id_obra_social int, 
					@id_categoria int, @id_usuario int, 
					@id_medio_de_pago int	*****/

--Preparando tabla para pruebas
exec eliminarYrestaurarTabla 'socios.socio'
exec eliminarYrestaurarTabla 'socios.obra_social'
exec eliminarYrestaurarTabla 'socios.categoria'
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'
exec eliminarYrestaurarTabla 'facturacion.medio_de_pago'

--Insertanto registros para la prueba
declare @fechaDePrueba date = GETDATE();
exec socios.insertarRol 'Cliente', @fechaDePrueba
exec socios.insertarUsuario 1, 'passwordDeUsuario1', @fechaDePrueba
exec socios.insertarUsuario 1, 'passwordDeUsuario2', @fechaDePrueba
exec socios.insertarUsuario 1, 'passwordDeUsuario3', @fechaDePrueba
exec socios.insertarCategoria 'Menor', 1, 18, 9.69
exec socios.insertarCategoria 'Cadete', 19, 27, 1.01
exec socios.insertarCategoria 'Mayor', 28, 35, 5
exec socios.insertarObraSocial 'Luis Pasteur', 1111111111
exec socios.insertarObraSocial 'OSECAC', 22222222
exec facturacion.crearMedioPago 'Visa', 1

--Se espera la insercion exitosa de los siguientes registros
exec socios.insertarSocio 41247252, 'Pepe', 'Grillo' , 'pGrillo@gmail.com', '1999-01-19', 11223344, 55667788, 1, 1, 1, 1
exec socios.insertarSocio 41247253, 'Armando', 'Paredes' , 'albañilParedes@gmail.com', '1990-01-19', 55667788, 11223344, 2, 2, 1, 1

--Se espera mensaje 'Ya existe un socio con ese dni.'
exec socios.insertarSocio 41247253, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 1, 3, 3, 1

--Se espera mensaje 'No existe una obra social con ese id.'
exec socios.insertarSocio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 4, 3, 3, 1

--Se espera mensaje 'No existe una categoria con ese id.'
exec socios.insertarSocio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 2, 4, 3, 1

--Se espera mensaje 'No existe un medio de pago con esa id.'
exec socios.insertarSocio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 2, 4, 3, 2

--Se espera mensaje 'No existe un usuario con esa id.'
exec socios.insertarSocio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 2, 3, 4, 1

--Eliminando registros restantes de la prueba en la tabla
exec eliminarYrestaurarTabla 'socios.socio'
exec eliminarYrestaurarTabla 'socios.obra_social'
exec eliminarYrestaurarTabla 'socios.categoria'
exec eliminarYrestaurarTabla 'socios.usuario'
exec eliminarYrestaurarTabla 'socios.rol'
exec eliminarYrestaurarTabla 'facturacion.medio_de_pago'

/*
use COM5600G03
go

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
 

 exec socios.insertarUsuario 1,'Usuario2', '24-06-2025'
 select*from socios.usuario
 select*from socios.socio
 exec socios.insertarSocio 42838703,'Roberto','Gimenez','rbGM@gmail.com','08-11-2004',1131119521,1132319592,1,1,2,1
 
 --se agregan actividades extra
 exec actividades.insertar_actividad_extra 'Piscina',300.50
 select*from actividades.actividad_extra

 --se inscribe a roberto en esa actividad
 exec actividades.inscripcion_actividad_extra 2,1,'23-05-2025','13:00','18:00',0

 select*from actividades.inscripcion_act_extra
 select*from facturacion.factura

 --se incribe a roberto en esa actividad pero con 1 invitado

 exec actividades.inscripcion_actividad_extra 2,1, '24-05-2025','10:00','18:00',1

 --se esperan 2 facturas no pagadas
 select*from actividades.inscripcion_act_extra
 select*from facturacion.factura

 exec facturacion.pago_factura 1,'PAGO',1 

 --se espera que la factura con id 3, este pagada 
 select*from actividades.inscripcion_act_extra
 select*from facturacion.factura

 --se espera que no te deje pagar una factura ya abonada
 exec facturacion.pago_factura 1,'PAGO',1 
 */