/*
Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que 
realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que 
en los juegos de prueba demuestren la correcta aplicación de las validaciones. 
Las pruebas deben realizarse en un script separado, donde con comentarios se indique en 
cada caso el resultado esperado 

    BASE DE DATOS APLICADAS

Fecha de entrega: 23-05-2025
Comision: 5600
Numero de grupo: 03

-Lazarte Ulises 42838702
-Maximo Bertolin Graziano 46364320
-Jordi Marcelo Pairo Albarez 41247253
-Franco Agustin Grosso 46024348
*/

Use COM5600G03
go

--
/*** SP auxiliares ***/
create or alter procedure eliminar_y_restaurar_tabla @nombreDeTabla varchar(50)
as
begin
	declare @consulta varchar(max)
	set @consulta = 'delete from ' + @nombreDeTabla
	exec(@consulta)
	DBCC CHECKIDENT (@nombreDeTabla, RESEED, 0);
end
/*** Fin de SP auxiliares ***/
go

/*****	socios.insertar_rol(@nombre_rol varchar(20), @descripcion_rol varchar(50))	******/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.rol'
--Se espera que se inserten los siguientes registros

exec socios.insertar_rol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertar_rol 'Moderador', 'Encargado de moderar el sistema'
exec socios.insertar_rol '', ''
exec socios.insertar_rol NULL, NULL
exec socios.insertar_rol 'Administrador',  'Supervisar operaciones diarias'

-- No se podran insertar los siguientes mensajes, debera aparecer el mensaje correspondiente indicando el error
exec socios.insertar_rol 'Usuario', 'Un socio que quiere usar el sistema'
exec socios.insertar_rol '', 'Un invitado que quiere usar el sistema'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.rol'


/*****	socios.modificar_rol(@nombre_rol varchar(20), @nueva_descripcion_rol varchar(50))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertar_rol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertar_rol '', 'Rol vacio'

--Se espera que los registros anteriores vean su descripcion = 'modificado'
exec socios.modificar_rol 'Usuario', 'Rol de usuario'
exec socios.modificar_rol 'Administrador', 'Persona designada para revisar las operaciones'
exec socios.modificar_rol '', 'Rol fantasma'

--Se espera mensaje 'El rol que se quiere modificar, no existe segun su nombre.'
exec socios.modificar_rol 'Controlador', 'modificado'
exec socios.modificar_rol 'Deportista', 'modificado'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.rol'


/*****	socios.eliminar_rol(@nombre_rol varchar(20))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'Usuario', 'Rol de usuario'
exec socios.insertar_rol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertar_rol '', ''

--Se espera la eliminacion exitosa de los registro anteriores
exec socios.eliminar_rol 'Usuario'
exec socios.eliminar_rol 'Administrador'
exec socios.eliminar_rol ''

--Se espera mensaje 'El rol que se quiere eliminar, no existe segun su nombre.'
exec socios.eliminar_rol 'noExiste'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.rol'

/*****	socios.insertar_usuario
						@id_rol int,
						@contraseña varchar(40),
						@fecha_vigencia_contraseña date	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'a', 'a'
exec socios.insertar_rol 'b', 'b'
exec socios.insertar_rol 'c', 'c'

--Se espera la insercion exitosa de los sig usuarios con roles asignados validos
declare @fechaDePrueba date = GETDATE();
exec socios.insertar_usuario 1, 'contraseñaDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 2, 'contraseñaDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaDeUsuario3', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaDeUsuario4', @fechaDePrueba
--Se espera el mensaje 'No existe un rol con ese id.'
exec socios.insertar_usuario 4, 'contraseñaDeUsuario5', @fechaDePrueba

--Se espera el mensaje 'La fecha de vigencia no puede ser anterior a la actual.'
set @fechaDePrueba = DATEADD(DAY, -5, @fechaDePrueba)
exec socios.insertar_usuario 3, 'contraseñaDeUsuario5', @fechaDePrueba

--Se espera la insercion exitosa del sig registro
exec socios.insertar_usuario 3, 'contraseñaDeUsuario6', NULL

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'
go

/*****	socios.modificar_contraseña_usuario @id_usuario int, @contraseña varchar(40) *****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertar_rol 'Moderador', 'Encargado de moderar el sistema'
exec socios.insertar_rol 'Administrador', 'Supervisar operaciones diarias'

DECLARE @fechaDePrueba date = GETDATE();

exec socios.insertar_usuario 1, 'contraseñaOriginalDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 2, 'contraseñaOriginalDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaOriginalDeUsuario3', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaOriginalDeUsuario4', @fechaDePrueba

--Se espera la modificacion exitosa de la contraseña
exec socios.modificar_contraseña_usuario 1, 'contraseñaModificadaDeUsuario1'
exec socios.modificar_contraseña_usuario 2, 'contraseñaModificadaDeUsuario2'
exec socios.modificar_contraseña_usuario 3, 'contraseñaModificadaDeUsuario3'
exec socios.modificar_contraseña_usuario 4, 'contraseñaModificadaDeUsuario4'
exec socios.modificar_contraseña_usuario 4, ''
exec socios.modificar_contraseña_usuario 4, NULL

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.modificar_contraseña_usuario 5, 'contraseñaModificadaDeUsuario5'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'
go

/*****	socios.modificar_fecha_vigencia_usuario @id_usuario int, @fecha_vigencia_contraseña date *****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertar_rol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertar_rol 'Moderador', 'Modera usuarios'

declare @fechaDePrueba date = GETDATE();
declare @fechaDePruebaModificada date;

exec socios.insertar_usuario 1, 'contraseñaDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 2, 'contraseñaDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaDeUsuario3', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaDeUsuario4', @fechaDePrueba

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual' si fecha_vigencia_contraseña nueva es igual al original
exec socios.modificar_fecha_vigencia_usuario 1, @fechaDePrueba

--Se espera la modificacion exitosa de la fecha_vigencia_contraseña
set @fechaDePruebaModificada = DATEADD(DAY, 1, @fechaDePrueba)
exec socios.modificar_fecha_vigencia_usuario 1, @fechaDePruebaModificada
exec socios.modificar_fecha_vigencia_usuario 2, @fechaDePruebaModificada
exec socios.modificar_fecha_vigencia_usuario 3, @fechaDePruebaModificada
exec socios.modificar_fecha_vigencia_usuario 4, @fechaDePruebaModificada
exec socios.modificar_fecha_vigencia_usuario 4, @fechaDePruebaModificada

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.modificar_fecha_vigencia_usuario 5, @fechaDePrueba

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual'
set @fechaDePruebaModificada = DATEADD(DAY, -5, @fechaDePrueba)
exec socios.modificar_fecha_vigencia_usuario 1, @fechaDePruebaModificada

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'
go

/*****	socios.eliminar_usuario @id_usuario int *****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertar_rol 'Administrador', 'Supervisar operaciones diarias'
exec socios.insertar_rol 'Moderador', 'Modera usuarios'

declare @fechaDePrueba date = GETDATE();

exec socios.insertar_usuario 1, 'contraseñaDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 2, 'contraseñaDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaDeUsuario3', @fechaDePrueba
exec socios.insertar_usuario 3, 'contraseñaDeUsuario4', @fechaDePrueba

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.eliminar_usuario -1
exec socios.eliminar_usuario 0
exec socios.eliminar_usuario 5

--Se espera la eliminacion exitosa de los sig usuarios
exec socios.eliminar_usuario 1
exec socios.eliminar_usuario 2
exec socios.eliminar_usuario 3
exec socios.eliminar_usuario 4

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'

/*****	socios.insertar_obra_social @nombre_obra_social varchar(60), @telefono_obra_social int	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.obra_social'

--Se espera la insercion exitosa de los sig registros
exec socios.insertar_obra_social '', 0
exec socios.insertar_obra_social 'obraSocial1', 0
exec socios.insertar_obra_social 'obraSocial2', 0
exec socios.insertar_obra_social 'obraSocial3', 0
exec socios.insertar_obra_social NULL, NULL

--Se espera un mensaje 'El numero de telefono no puede ser negativo'
exec socios.insertar_obra_social 'obraSocial5', -1

--Se espera mensaje 'Ya existe una obra social con ese nombre.'
exec socios.insertar_obra_social '', 0
exec socios.insertar_obra_social 'obraSocial1', 11111111
exec socios.insertar_obra_social 'obraSocial2', 11111111
exec socios.insertar_obra_social 'obraSocial3', 11111111

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.obra_social'

/*****	socios.modificar_obra_social @nombre_obra_social varchar(60), @telefono_obra_social int	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.obra_social'

--Insertando registros para prueba
exec socios.insertar_obra_social 'obraSocial1', 11111111
exec socios.insertar_obra_social 'obraSocial2', 22222222
exec socios.insertar_obra_social 'obraSocial3', 33333333
exec socios.insertar_obra_social 'obraSocial4', 44444444

--Se espera la modificacion del @telefono_obra_social de los siguientes registros con exito
exec socios.modificar_obra_social 'obraSocial1', 0
exec socios.modificar_obra_social 'obraSocial2', 0
exec socios.modificar_obra_social 'obraSocial3', 0
exec socios.modificar_obra_social 'obraSocial4', 0

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.modificar_obra_social 'obraSocial6', 0
exec socios.modificar_obra_social 'obraSocial7', 0
exec socios.modificar_obra_social 'obraSocial8', 0

--Se espera mensaje 'El numero de telefono no puede ser negativo'
exec socios.modificar_obra_social 'obraSocial1', -1

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.obra_social'

/*****	socios.eliminar_obra_social @nombre_obra_social varchar(60)	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.obra_social'

--Insertando registros para prueba
exec socios.insertar_obra_social 'obraSocial1', 11111111
exec socios.insertar_obra_social 'obraSocial2', 22222222
exec socios.insertar_obra_social 'obraSocial3', 33333333
exec socios.insertar_obra_social 'obraSocial4', 44444444
--Se espera la eliminacion de los siguientes registros
exec socios.eliminar_obra_social 'obraSocial1'
exec socios.eliminar_obra_social 'obraSocial2'
exec socios.eliminar_obra_social 'obraSocial3'
exec socios.eliminar_obra_social 'obraSocial4'

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.eliminar_categoria 'obraSocial1'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.obra_social'

/*****	socios.insertar_categoria 
						@nombre_categoria varchar(16), @edad_minima int,
						@edad_maxima int, @costo_membresia decimal(9,3)	*****/

--Se espera la insercion exitosa de los siguientes registro
exec socios.insertar_categoria 'Menor', 1, 18, 9.69
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01
exec socios.insertar_categoria 'Mayor', 28, 35, 0

--Se espera mensaje 'Ya existe una categoría con ese nombre.'
exec socios.insertar_categoria 'Menor', 1, 18, 10.50

--Se espera mensaje 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
exec socios.insertar_categoria 'Veterano', 5, 5, 10.6
exec socios.insertar_categoria 'Sargento', 7, 5, 10.6

--Se espera mensaje 'El costo de la membresia no puede ser negativo.'
exec socios.insertar_categoria 'Veterano', 36, 45, -1.99

/*****	socios.modificar_costo_categoria @nombre_categoria varchar(16), @costo_membresia decimal(9,3) *****/

--Insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01
exec socios.insertar_categoria 'Mayor', 28, 35, 0

--Se espera la modificacion del valor de costo_membresía
exec socios.modificar_costo_categoria 'Menor', 10.99
exec socios.modificar_costo_categoria 'Cadete', 20.99

--Se espera mensaje 'El nuevo costo de la membresia no puede ser negativo.'
exec socios.modificar_costo_categoria 'Menor', -5.66

--Se espera mensaje 'No existe una categoría con ese nombre.'
exec socios.modificar_costo_categoria 'Sargento', 10.69

/******	socios.eliminar_categoria @nombre_categoria varchar(16)	*****/

--Insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01
exec socios.insertar_categoria 'Mayor', 28, 35, 0

--Se espera la eliminacion de los siguientes registros
exec socios.eliminar_categoria 'Menor'
exec socios.eliminar_categoria 'Cadete'
exec socios.eliminar_categoria 'Mayor'

--Se espera mensaje 'No existe una categoría con ese nombre.'
exec socios.eliminar_categoria 'Sargento'
go

/***** socios.insertar_socio 
					@dni int, @nombre varchar(40), 
					@apellido varchar(40), @email varchar(150), 
					@fecha_nacimiento date, @telefono_contacto int, 
					@telefono_emergencia int, @id_obra_social int, 
					@id_categoria int, @id_usuario int, 
					@id_medio_de_pago int	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'

--Insertanto registros para la prueba
declare @fechaDePrueba date = GETDATE();
exec socios.insertar_rol 'Cliente', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario3', @fechaDePrueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01
exec socios.insertar_categoria 'Mayor', 28, 35, 5
exec socios.insertar_obra_social 'Luis Pasteur', 1111111111
exec socios.insertar_obra_social 'OSECAC', 22222222
exec facturacion.insertar_medio_de_pago 'Visa', 1

--Se espera la insercion exitosa de los siguientes registros
exec socios.insertar_socio 41247252, 'Pepe', 'Grillo' , 'pGrillo@gmail.com', '1999-01-19', 11223344, 55667788, 1, 1, 1, 1

exec socios.insertar_socio 41247253, 'Armando', 'Paredes' , 'albañilParedes@gmail.com', '1990-01-19', 55667788, 11223344, 2, 2, 1, 1

--Se espera mensaje 'Ya existe un socio con ese dni.'
exec socios.insertar_socio 41247253, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 1, 3, 1, 1

--Se espera mensaje 'No existe una obra social con ese id.'
exec socios.insertar_socio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 4, 3, 1, 1

--Se espera mensaje 'No existe una categoria con ese id.'
exec socios.insertar_socio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 2, 4, 1, 1

--Se espera mensaje 'No existe un medio de pago con esa id.'
exec socios.insertar_socio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 2, 4, 2, 1

--Se espera mensaje 'No existe un usuario con esa id.'
exec socios.insertar_socio 41247254, 'Armando', 'Losas' , 'albañilLosas@gmail.com', '1990-01-19', 55667788, 11223344, 2, 3, 1, 1

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'

/*****	actividades.insertar_actividad(@nombreActividad varchar(36),@costoMensual decimal(9,3))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad'

--Se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_actividad 'Voley', 2.9
exec actividades.insertar_actividad 'Baile', 9999.5

--Se espera mensaje 'El costo de actividad no debe ser negativo'
exec actividades.insertar_actividad 'Futbol', -1.5

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad 'Baile', 1000
exec actividades.insertar_actividad 'Voley', 2.9

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad'

/*****	actividades.eliminar_actividad(@id_actividad int)	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad'

--Insertanto registros para la prueba
exec actividades.insertar_actividad 'Voley', 2.9
exec actividades.insertar_actividad 'Baile', 9999.5

--Se espera la eliminacion de los siguiente registros
exec actividades.eliminar_actividad 1
exec actividades.eliminar_actividad 2

--Se espera mensaje 'La actividad a eliminar no existe'
exec actividades.eliminar_actividad 1
exec actividades.eliminar_actividad 3

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad'

/*****	actividades.modificar_precio_actividad(@id_actividad int, @nuevoPrecio decimal(9,3))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad'

--Insertanto registros para la prueba
exec actividades.insertar_actividad 'Voley', 2.9
exec actividades.insertar_actividad 'Baile', 9999.5

--Se espera la modificacion del costo de actividad de los siguientes registros
exec actividades.modificar_precio_actividad 1, 5.3
exec actividades.modificar_precio_actividad 2, 3.3
--Se espera mensaje 'El nuevo costo de actividad no puede ser negativa'
exec actividades.modificar_precio_actividad 1, -5.3

--Se espera mensaje 'La actividad a modificar no existe'
exec actividades.modificar_precio_actividad 3, 99.5

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad'

/*****	actividades.insertar_actividad_extra(@nombreActividad varchar(36),@costo decimal(9,3))   *****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'

--Se espera la insercion exitosa de los siguiente registros
exec actividades.insertar_actividad_extra 'Pileta verano', 5.9 
exec actividades.insertar_actividad_extra 'Colonia de verano', 99.5

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad_extra 'Colonia de verano', 10.9

--Se espera mensaje 'El costo de la actividad no puede ser negativo'
exec actividades.insertar_actividad_extra 'Alquiler del SUM', -10.9

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'

/*****	actividades.eliminar_actividad_extra(@id_actividad_extra int)	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'

--Insertanto registros para la prueba
exec actividades.insertar_actividad_extra 'Pileta verano', 5.9 
exec actividades.insertar_actividad_extra 'Colonia de verano', 99.5

--Se espera la eliminacion de los siguientes registros
exec actividades.eliminar_actividad_extra 1
exec actividades.eliminar_actividad_extra 2

--Se espera mensaje 'La actividad extra a eliminar no existe'
exec actividades.eliminar_actividad_extra 1
exec actividades.eliminar_actividad_extra 3

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'

/*****	actividades.modificar_precio_actividad_extra(@id_actividad_extra int, @nuevoPrecio decimal(9,3))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'

--Insertanto registros para la prueba
exec actividades.insertar_actividad_extra 'Pileta vserano', 5.9 
exec actividades.insertar_actividad_extra 'Colonia de verano', 99.5

--Se espera la modificacion del costo de actividad_extra
exec actividades.modificar_precio_actividad_extra 1, 5.5
exec actividades.modificar_precio_actividad_extra 2, 6.5

--Se espera mensaje 'El nuevo costo de actividad extra no puede ser negativo'
exec actividades.modificar_precio_actividad_extra 1, -5.5

--Se espera mensaje 'La actividad extra a modificar no existe'
exec actividades.modificar_precio_actividad_extra 3, 5

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'

/****actividades.insertar_horario_actividad****/

--Preparando tablas para la prueba
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
go
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria'


--insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 10, 14, 20000
exec socios.insertar_categoria 'Cadete', 15, 18, 22000
exec actividades.insertar_actividad 'futbol', 10000
exec actividades.insertar_actividad 'voley', 10000
exec actividades.insertar_actividad 'tenis', 13000

--se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Martes', '19:00:00', '20:00:00', 2, 2
exec actividades.insertar_horario_actividad 'Jueves', '18:00:00', '19:30:00', 3, 2

--Se espera un mensaje de 'El dia no es correcto'
exec actividades.insertar_horario_actividad 'Noviembre', '18:00:00', '19:30:00', 3, 1

--Se espera un mensaje de 'no se encontro la actividad con ese id'
exec actividades.insertar_horario_actividad 'Sabado', '18:00:00', '19:30:00', 8, 2

--Se espera un mensaje de 'no se encontro la categoria con ese id'
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 10

--Eliminando registros restantes de la tabla de pruebas
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
go
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria'


/*****actividades.eliminar_horario_actividad(@id_horario int)****/
--Preparando tablas para la prueba
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
go
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria'


--insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 10, 14, 20000
exec socios.insertar_categoria 'Cadete', 15, 18, 22000
exec actividades.insertar_actividad 'futbol', 10000
exec actividades.insertar_actividad 'voley', 10000
exec actividades.insertar_actividad 'tenis', 13000

--se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Martes', '19:00:00', '20:00:00', 2, 2
exec actividades.insertar_horario_actividad 'Jueves', '18:00:00', '19:30:00', 3, 2

--Se espera la eliminacion exitosa de los siguientes registros
exec actividades.eliminar_horario_actividad 1
exec actividades.eliminar_horario_actividad 2
exec actividades.eliminar_horario_actividad 3

--Se espera un mensaje de 'No existe una actividad con ese id'
exec actividades.eliminar_horario_actividad 1
exec actividades.eliminar_horario_actividad 7

--Eliminando registros restantes de la tabla de pruebas
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
go
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria'

/*****actividades.modificar_horario_actividad*****/
--Preparando tablas para la prueba
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria'
go


--insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 10, 14, 20000
exec socios.insertar_categoria 'Cadete', 15, 18, 22000
exec actividades.insertar_actividad 'futbol', 10000
exec actividades.insertar_actividad 'voley', 10000
exec actividades.insertar_actividad 'tenis', 13000

--se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Martes', '19:00:00', '20:00:00', 2, 2
exec actividades.insertar_horario_actividad 'Jueves', '18:00:00', '19:30:00', 3, 2

--Se espera la modificacion exitosa de los siguientes registros
exec actividades.modificar_horario_actividad 1, 'Miercoles', '18:00:00', '19:30:00', 1, 1
exec actividades.modificar_horario_actividad 2, 'Martes', '18:30:00', '20:00:00', 2, 2
exec actividades.modificar_horario_actividad 3, 'Jueves', '18:00:00', '19:15:00', 3, 2

--Se espera un mensaje de 'El dia no es correcto'
exec actividades.modificar_horario_actividad 3, 'Enero', '18:00:00', '19:15:00', 3, 2

--Se espera un mensaje de 'No se encontro la categoria con ese id'
exec actividades.modificar_horario_actividad 1, 'Miercoles', '18:00:00', '19:30:00', 1, 10

--Se espera un mensaje de 'No se encontro la actividad con ese id'
exec actividades.modificar_horario_actividad 2, 'Miercoles', '18:00:00', '19:30:00', 19, 1

--Se espera un mensaje de 'No se encontro horario con ese id'
exec actividades.modificar_horario_actividad 9, 'Miercoles', '18:00:00', '19:30:00', 1, 1

/*****facturacion.crear_factura*****/

-- Limpieza y preparación de las tablas necesarias
exec eliminar_y_restaurar_tabla 'facturacion.factura'
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.rol'

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Adulto', 18, 65, 25000
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Tarjeta de crédito', 1
exec socios.insertar_obra_social 'OSDE', 1134225566

-- Se espera inserción exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', 1133445566, 1133445577, 1, 1, 1, 1

-- Se espera que se cree correctamente una nueva factura
exec facturacion.crear_factura 10000.000, 1

-- Se espera mensaje: 'Monto ingresado no es valido'
exec facturacion.crear_factura 0.000, 1

-- Se espera mensaje: 'Monto ingresado no es valido'
exec facturacion.crear_factura -500.000, 1

-- Se espera mensaje: 'No se encontro el socio para generar la factura'
exec facturacion.crear_factura 15000.000, 999

/*****facturacion.pago_factura*****/

-- Limpieza y preparación de las tablas necesarias
exec eliminar_y_restaurar_tabla 'facturacion.pago'
exec eliminar_y_restaurar_tabla 'facturacion.factura'
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.rol'

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Adulto', 18, 65, 25000
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Transferencia', 1
exec socios.insertar_obra_social 'OSDE', 1134225566

-- Se espera inserción exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', 1133445566, 1133445577, 1, 1, 1, 1

-- Se espera creación exitosa de una factura NO PAGADA
exec facturacion.crear_factura 10000.000, 1

-- Se espera que el pago se realice exitosamente y se actualice el estado de la factura
exec facturacion.pago_factura 1, 'PAGO', 1

-- Se espera mensaje: 'No se encontro factura con ese id o la factura ya fue abonada'
exec facturacion.pago_factura 1, 'PAGO', 1

-- Se espera mensaje: 'No se encontro el id de ese medio de pago'
exec facturacion.pago_factura 1, 'PAGO', 999