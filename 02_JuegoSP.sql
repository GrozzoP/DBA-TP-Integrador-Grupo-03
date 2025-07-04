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

use COM5600G03
go


/*
==========================================================================================================================
												ROL
========================================================================================================================== */
/*****	socios.insertar_rol
		@nombre_rol varchar(20), 
		@descripcion_rol varchar(50))	******/

print '========================================ROL========================================'
--Se espera que se inserten los siguientes registros
exec socios.insertar_rol 'Usuario', 'Rol mas comun del sistema'
exec socios.insertar_rol 'Moderador', 'Encargado de moderar el sistema'
exec socios.insertar_rol 'Administrador',  'Supervisar operaciones diarias'

-- No se podra insertar el siguiente rol, debera aparecer 'El rol que se quiere insertar ya existe en la tabla'
exec socios.insertar_rol 'Usuario', 'Un socio que quiere usar el sistema'

-- La constraint de la tabla no permite ingresar un rol con el nombre ''
exec socios.insertar_rol '', ''

/*****	socios.modificar_rol
		@nombre_rol varchar(20), 
		@nueva_descripcion_rol varchar(50))	*****/

--Se espera que en los registros anteriores se modifique su descripcion
exec socios.modificar_rol 'Usuario', 'Rol de usuario'
exec socios.modificar_rol 'Administrador', 'Persona designada para revisar las operaciones'

--Se espera mensaje 'El rol que se quiere modificar, no existe segun su nombre'
exec socios.modificar_rol 'Controlador', 'modificado'
exec socios.modificar_rol 'Deportista', 'modificado'

/*****	socios.eliminar_rol(@nombre_rol varchar(20))	*****/

-- Se espera la eliminacion exitosa de los registro anteriores
exec socios.eliminar_rol 'Moderador'
exec socios.eliminar_rol 'Administrador'

-- Se espera el mensaje 'El rol que se quiere eliminar, no existe segun su nombre'
exec socios.eliminar_rol ''

print '========================================USUARIO========================================'
/*
==========================================================================================================================
												USUARIO
========================================================================================================================== */
/*****	socios.insertar_usuario
						@id_rol int,
						@contraseña varchar(40),
						@fecha_vigencia_contraseña date	*****/

declare @fechaDePrueba date = GETDATE()

-- Se espera la insercion exitosa de los sig usuarios con roles asignados validos
exec socios.insertar_usuario @id_rol = 1, @usuario = 'franco@hotmail.com', @contraseña = 'hola123', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'agustin@hotmail.com', @contraseña = 'francoGrosso123', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'francisco@hotmail.com', @contraseña = 'pileta1456', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'roberto@hotmail.com', @contraseña = 'contraseniaSecreta1!', @fecha_vigencia_contraseña = @fechaDePrueba

-- Se espera el mensaje 'La fecha de vigencia no puede ser anterior a la actual.'
set @fechaDePrueba = DATEADD(DAY, -5, @fechaDePrueba)
exec socios.insertar_usuario @id_rol = 1, @usuario = 'ruberto@hotmail.com', @contraseña = 'contraseñaDeUsuario5', @fecha_vigencia_contraseña = @fechaDePrueba

-- Se devuelve 'La fecha de vigencia no puede ser nula.'
exec socios.insertar_usuario @id_rol = 1, @usuario = 'equi-fernandez@hotmail.com', @contraseña = 'contraseñaDeUsuario6', @fecha_vigencia_contraseña =  NULL

-- Se devuelve 'El usuario no puede ser nulo o vacio.'
exec socios.insertar_usuario @id_rol = 1, @usuario = '', @contraseña = 'contraseñaDeUsuario6', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1 , @usuario =  NULL, @contraseña = 'contraseñaDeUsuario6', @fecha_vigencia_contraseña = @fechaDePrueba

/*****	create or alter procedure socios.modificar_usuario
		@id_usuario int,
		@usuario varchar(40) = NULL,
		@contraseña varchar(40) = NULL,
		@fecha_vigencia_contraseña date = NULL *****/

--Se espera la modificacion exitosa de la contraseña
exec socios.modificar_usuario @id_usuario = 1, @contraseña = 'naruto456!'
exec socios.modificar_usuario @id_usuario = 2, @contraseña = 'contraseña_super_secreta'
exec socios.modificar_usuario @id_usuario = 3, @contraseña = 'auricularTeclado46!'

-- Se espera mensaje 'La contraseña no puede estar vacia'
exec socios.modificar_usuario @id_usuario = 1, @contraseña = ''

-- Se espera mensaje 'Debe proporcionar al menos un campo para actualizar.'
exec socios.modificar_usuario @id_usuario = 4, @contraseña = NULL

-- Se espera mensaje 'No existe un usuario con ese id'
exec socios.modificar_usuario @id_usuario = 100, @contraseña = 'perroGatoMono55?'

declare @fechaDePruebaModificada date;

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual' si fecha_vigencia_contraseña nueva es igual al original
exec socios.modificar_usuario @id_usuario = 1, @fecha_vigencia_contraseña = @fechaDePrueba

--Se espera la modificacion exitosa de la fecha_vigencia_contraseña
set @fechaDePruebaModificada = DATEADD(DAY, 5, @fechaDePrueba)
exec socios.modificar_usuario @id_usuario = 1, @fecha_vigencia_contraseña = @fechaDePruebaModificada
exec socios.modificar_usuario @id_usuario = 2, @fecha_vigencia_contraseña = @fechaDePruebaModificada
exec socios.modificar_usuario @id_usuario = 3, @fecha_vigencia_contraseña = @fechaDePruebaModificada
exec socios.modificar_usuario @id_usuario = 4, @fecha_vigencia_contraseña = @fechaDePruebaModificada

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.modificar_usuario @id_usuario = 5, @fecha_vigencia_contraseña = @fechaDePrueba

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual'
set @fechaDePruebaModificada = DATEADD(DAY, -5, @fechaDePrueba)
exec socios.modificar_usuario @id_usuario = 1, @fecha_vigencia_contraseña = @fechaDePruebaModificada

/*****	socios.eliminar_usuario 
		@id_usuario int *****/

--Se espera mensaje 'No existe un usuario con ese id.'
exec socios.eliminar_usuario 55

--Se espera la eliminacion exitosa de los sig usuarios
exec socios.eliminar_usuario 1
exec socios.eliminar_usuario 2
exec socios.eliminar_usuario 3
exec socios.eliminar_usuario 4

print '========================================OBRA SOCIAL========================================'
/*
==========================================================================================================================
												OBRA SOCIAL
========================================================================================================================== */
/*****	socios.insertar_obra_social 
		@nombre_obra_social varchar(60), 
		@telefono_obra_social int	*****/


-- Se espera la insercion exitosa de los sig registros
exec socios.insertar_obra_social 'Swiss Medical', '4802-0022'
exec socios.insertar_obra_social 'OSMTT', '0800 8888 733'
exec socios.insertar_obra_social 'Hominis', '0810-888-3226'
exec socios.insertar_obra_social 'Plan de Salud Hospital Italiano', '011 4371-7717'

-- Se espera un mensaje 'El nombre de la obra social no puede ser nulo ni vacio.'
exec socios.insertar_obra_social NULL, NULL

-- Se espera mensaje 'Ya existe una obra social con ese nombre.'
exec socios.insertar_obra_social 'OSMTT', '11111111'

/*****	socios.modificar_obra_social 
		@nombre_obra_social varchar(60), 
		@telefono_obra_social int	*****/

--Se espera la modificacion del @telefono_obra_social
exec socios.modificar_obra_social 'OSMTT', '0800-268-3733'

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.modificar_obra_social 'OBRA-SOCIAL', '1120639622'

/*****	socios.eliminar_obra_social @nombre_obra_social varchar(60)	*****/

--Se espera la eliminacion de la siguiente obra social
exec socios.eliminar_obra_social 'Plan de Salud Hospital Italiano'

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.eliminar_obra_social 'OBRA-SOCIAL'

print '========================================CATEGORIA========================================'
/*
==========================================================================================================================
												CATEGORIA
========================================================================================================================== */
/*****	socios.insertar_categoria 
		@nombre_categoria varchar(16), 
		@edad_minima int,
		@edad_maxima int, 
		@costo_membresia decimal(9,3), 
		@vigencia_hasta date	*****/

--Se espera la insercion exitosa de los siguientes registros
exec socios.insertar_categoria 'Menor', 1, 12, 20000, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 13, 17, 30000, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 18, 99, 40000, '2025-08-30'
exec socios.insertar_categoria 'MayorAlCuadrado', 35, 45, 0, '2025-08-30'

--Se espera mensaje 'Ya existe una categoría con ese nombre.'
exec socios.insertar_categoria 'Menor', 1, 18, 10.50, '2025-12-31'

--Se espera mensaje 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
exec socios.insertar_categoria 'Veterano', 5, 5, 10.6, '2025-12-31'

--Se espera mensaje 'El costo de la membresia no puede ser negativo.'
exec socios.insertar_categoria 'Veterano', 36, 45, -1.99, '2025-12-31'

/*****	socios.modificar_costo_categoria @id_categoria int, @costo_membresia decimal(9,3) *****/

exec socios.modificar_costo_categoria 1, 10000.99
exec socios.modificar_costo_categoria 2, 20000.99

-- Se espera mensaje 'El nuevo costo de la membresia no puede ser negativo.'
exec socios.modificar_costo_categoria 1, -5.66

-- Se espera mensaje 'No existe una categoria con ese id.'
exec socios.modificar_costo_categoria 999, 10.69

/*****	socios.modificar_fecha_vigencia_categoria 
		@id_categoria int, 
		@costo_membresia decimal(9,3), 
		@vigencia_hasta date *****/

-- Se cambia de manera exitosa segun la nueva fecha de vigencia
exec socios.modificar_fecha_vigencia_categoria 1, 12.50, '2026-06-30'
exec socios.modificar_fecha_vigencia_categoria 2, 25.00, '2026-12-31'

-- Se espera mensaje 'La nueva fecha limite no puede ser menor a la actual'
exec socios.modificar_fecha_vigencia_categoria 1, 15.00, '2020-01-01'

-- Se espera mensaje 'El nuevo costo de la membresia no puede ser negativo'
exec socios.modificar_fecha_vigencia_categoria 1, -10.00, '2026-12-31'

-- Se espera mensaje 'No existe una categoría con ese id'
exec socios.modificar_fecha_vigencia_categoria 999, 20.00, '2026-12-31'

/******	socios.eliminar_categoria 
		@id_categoria int	*****/

--Se espera la eliminacion del siguiente registro
exec socios.eliminar_categoria 4

--Se espera mensaje 'No existe una categoría con ese id.'
exec socios.eliminar_categoria 999
go

-- Insertar datos para pruebas adicionales
exec socios.insertar_categoria 'TestCategoria', 18, 65, 50.00, '2025-12-31'

declare @precio decimal(9,3),
		@fecha_desde date, 
		@fecha_hasta date;

-- Esto se hace para obtener el precio mas vigente dentro del historico
exec socios.obtener_precio_actual
	@id_categoria = 5,
	@precio_actual = @precio output,
	@fecha_vigencia_desde = @fecha_desde output,
	@fecha_vigencia_hasta = @fecha_hasta output

-- select @precio as precio, @fecha_desde as fecha_desde, @fecha_hasta as fecha_hasta

print '========================================MEDIO DE PAGO========================================'
/*
==========================================================================================================================
												MEDIO DE PAGO
========================================================================================================================== */
/*****   facturacion.insertar_medio_de_pago
        @nombre_medio_pago varchar(40),
        @permite_debito_automatico bit  *****/

--Inserción exitosa de nuevos medios de pago
exec facturacion.insertar_medio_de_pago 'Tarjeta de Credito', 0
exec facturacion.insertar_medio_de_pago 'Banco Santander', 1
exec facturacion.insertar_medio_de_pago 'Cuenta DNI', 1
exec facturacion.insertar_medio_de_pago 'Medio de pago', 1

-- Se espera mensaje 'El nombre del medio de pago no puede ser nulo ni vacio.'
exec facturacion.insertar_medio_de_pago NULL, 0
exec facturacion.insertar_medio_de_pago '   ', 1

-- Medio de pago duplicado, se espera mensaje 'Ya existe un medio de pago con ese nombre!
exec facturacion.insertar_medio_de_pago 'Tarjeta de Credito', 1


/*****   facturacion.modificar_medio_de_pago
        @id_medio_de_pago int,
        @nombre_medio_pago varchar(40),
        @permite_debito_automatico bit  *****/

-- Se modifican los medios de pago de manera correcta
exec facturacion.modificar_medio_de_pago 1, 'Tarjeta Visa', 0
exec facturacion.modificar_medio_de_pago 2, 'Banco Galicia', 0

-- No existe el id, se espera mensaje 'No existe un medio de pago con ese id.'
exec facturacion.modificar_medio_de_pago 999, 'Otro Pago', 1

-- Se espera mensaje 'El nombre del medio de pago no puede ser nulo ni vacio.'
exec facturacion.modificar_medio_de_pago 1, NULL, 1
exec facturacion.modificar_medio_de_pago 2, '   ', 0

-- Medio de pago ya existente, se espera mensaje 'Ya existe un medio de pago con ese nombre!
exec facturacion.modificar_medio_de_pago 2, 'Tarjeta Visa', 1

/*****   facturacion.eliminar_medio_de_pago
        @id_medio_de_pago int  *****/

-- Error al eliminar, se espera mensaje 'No existe un medio de pago con ese id'
exec facturacion.eliminar_medio_de_pago 999

-- Se elimina el siguiente registro
exec facturacion.eliminar_medio_de_pago 4

print '========================================SOCIO========================================'
/*
==========================================================================================================================
												SOCIO
========================================================================================================================== */
/***** socios.insertar_socio 
						@dni int,
						@nombre varchar(40),
						@apellido varchar(40),
						@email varchar(150),
						@fecha_nacimiento date,
						@telefono_contacto char(18),
						@telefono_emergencia char(18),
						@id_obra_social int,
						@nro_socio_obra_social int,
						@id_medio_de_pago int,
						@id_rol int,
						@id_responsable_menor int = 0,
						@parentesco varchar(15) = ''	*****/


-- Insercion exitosa de un socio adulto, 'Se ha creado de manera automatica una cuenta para que disfrutes de los servicios de los socios!'
exec socios.insertar_socio
    @dni = 16054254,
    @nombre = 'Ana',
    @apellido = 'Perez',
    @email = 'ana.perez@mail.com',
    @fecha_nacimiento = '1990-05-10',
    @telefono_contacto = '0000000001',
    @telefono_emergencia = '0000000002',
    @id_obra_social = 1,
    @nro_socio_obra_social = 'a100',
    @id_medio_de_pago = 1,
    @id_rol = 1

exec socios.insertar_socio
    @dni = 52745821,
    @nombre = 'Martin',
    @apellido = 'Gutierrez',
    @email = 'martin.gutierrez@mail.com',
    @fecha_nacimiento = '1989-04-12',
    @telefono_contacto = '01112345678',
    @telefono_emergencia = '01187654321',
    @id_obra_social = 2,
    @nro_socio_obra_social = 'm350',
    @id_medio_de_pago = 2,
    @id_rol = 1

exec socios.insertar_socio
    @dni = 45896321,
    @nombre = 'Sofia',
    @apellido = 'Perez',
    @email = 'sofia.perez@mail.com',
    @fecha_nacimiento = '1995-08-20',
    @telefono_contacto = '01133445566',
    @telefono_emergencia = '01166554433',
    @id_obra_social = 2,
    @nro_socio_obra_social = 'sp220',
    @id_medio_de_pago = 2,
    @id_rol = 1

exec socios.insertar_socio
    @dni = 37894512,
    @nombre = 'María',
    @apellido = 'Gómez',
    @email = 'maria.gomez@mail.com',
    @fecha_nacimiento = '1985-02-14',  -- 40 años
    @telefono_contacto = '01166778899',
    @telefono_emergencia = '01199887766',
    @id_obra_social = 1,
    @nro_socio_obra_social = 'MG254',
    @id_medio_de_pago = 1,
    @id_rol = 1

-- Insercion fallida, 'Ya existe un socio con ese dni.'
exec socios.insertar_socio
    @dni = 16054254,
    @nombre = 'luis',
    @apellido = 'gomez',
    @email = 'luis.gomez@mail.com',
    @fecha_nacimiento = '1985-07-20',
    @telefono_contacto = '0000000003',
    @telefono_emergencia = '0000000004',
    @id_obra_social = 1,
    @nro_socio_obra_social = 'a101',
    @id_medio_de_pago = 2,
    @id_rol = 1

-- Insercion invalida, 'No existe una obra social con ese id.'
exec socios.insertar_socio
    @dni = 25365452,
    @nombre = 'maria',
    @apellido = 'lopez',
    @email = 'maria.lopez@mail.com',
    @fecha_nacimiento = '1988-03-15',
    @telefono_contacto = '0000000005',
    @telefono_emergencia = '0000000006',
    @id_obra_social = 99,
    @nro_socio_obra_social = 'b200',
    @id_medio_de_pago = 1,
    @id_rol = 1

-- No se pudo insertar un socio menor de edad, 'El socio al ser menor de edad, debe estar vinculado con un responsable ya registrado.'
exec socios.insertar_socio
    @dni = 14526523,
    @nombre = 'jose',
    @apellido = 'diaz',
    @email = 'jose.diaz@mail.com',
    @fecha_nacimiento = '2010-09-01',
    @telefono_contacto = '0000000007',
    @telefono_emergencia = '0000000008',
    @id_obra_social = 1,
    @nro_socio_obra_social = 'c300',
    @id_medio_de_pago = 1,
    @id_rol = 1

-- El menor se inserta con un responsable adulto, 'Se ha creado de manera automatica una cuenta para que disfrutes de los servicios de los socios!' 
exec socios.insertar_socio
    @dni = 60152458,
    @nombre = 'carlos',
    @apellido = 'martinez',
    @email = 'carlos.m@mail.com',
    @fecha_nacimiento = '2010-01-01',
    @telefono_contacto = '0000000009',
    @telefono_emergencia = '0000000010',
    @id_obra_social = 1,
    @nro_socio_obra_social = 'd400',
	@id_responsable_menor = 1,
    @id_medio_de_pago = 2,
    @id_rol = 1
go

/***** create or alter procedure socios.modificar_habilitar_socio
			@id_socio int *****/

-- Cambiar el campo de 'habilitado'
exec socios.modificar_habilitar_socio @id_socio = 1;

-- Lo vuelvo a cambiar al campo de 'habilitado'
exec socios.modificar_habilitar_socio @id_socio = 1;

-- El mensaje que me devuelve, es que el socio que se busca no existe
exec socios.modificar_habilitar_socio @id_socio = 999;
go

/***** create or alter procedure socios.eliminar_socio
			@DNI int *****/

-- Se elimina un socio mediante el ID
exec socios.eliminar_socio @id_socio = 3

-- Indica que 'No existe un socio con ese ID.'
exec socios.eliminar_socio @id_socio = 65
go

print '========================================GRUPO FAMILIAR========================================'
/*
==========================================================================================================================
												GRUPO FAMILIAR
========================================================================================================================== */
-- Insertar un grupo familiar
/*****	create or alter procedure socios.insertar_grupo_familiar
		@id_socio_menor int,
		@id_responsable int,
		@parentesco varchar(15) ******/

-- Se espera mensaje 'El socio responsable no puede ser menor de edad.'
exec socios.insertar_grupo_familiar @id_socio_menor = 2, @id_responsable = 3;

-- No existe el menor, 'No existe un socio menor con ese id.'
exec socios.insertar_grupo_familiar @id_socio_menor = 4, @id_responsable = 2;

-- El responsable no existe, 'No existe un socio responsable con ese id.'
exec socios.insertar_grupo_familiar @id_socio_menor = 2, @id_responsable = 888;

-- Relacion duplicada, 'Ya existe una relación entre este menor y este responsable.'
exec socios.insertar_grupo_familiar @id_socio_menor = 3, @id_responsable = 1

/***** pruebas de socios.eliminar_grupo_familiar *****/

-- Eliminar una relacion que no existe, 'No existe una relación entre ese socio menor y ese responsable.'
exec socios.eliminar_grupo_familiar @id_socio_menor = 5, @id_responsable = 3

-- Eliminar relacion de forma exitosa
exec socios.eliminar_grupo_familiar @id_socio_menor = 3, @id_responsable = 1

print '========================================ACTIVIDAD========================================'
/*
==========================================================================================================================
												ACTIVIDAD
========================================================================================================================== */
/*****	create or alter procedure actividades.insertar_actividad
		@nombreActividad varchar(36),
		@costoMensual decimal(9,3)	*****/

--Se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_actividad 'Voley', 3.9, '2025-07-27'
exec actividades.insertar_actividad 'Baile', 9999.5, '2025-08-29'
exec actividades.insertar_actividad 'Futbol', 1999.5, '2025-08-27'
exec actividades.insertar_actividad 'Basket', 2500, '2025-09-25'
exec actividades.insertar_actividad 'Handball', 4500, '2025-10-15'
exec actividades.insertar_actividad 'Futbol sala', 8200, '2025-12-1'

--Se espera mensaje 'El costo de actividad no debe ser negativo'
exec actividades.insertar_actividad 'Hockey', -1.5, '2026-06-19'

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad 'Baile', 1000, '2025-07-27'

/*****	actividades.eliminar_actividad(@id_actividad int)	*****/

--Se espera la eliminacion del siguiente registro
exec actividades.eliminar_actividad 6

--Se espera mensaje 'La actividad a eliminar no existe'
exec actividades.eliminar_actividad 999

/*****	actividades.modificar_precio_actividad(@id_actividad int, @nuevoPrecio decimal(9,3))	*****/

--Se espera la modificacion del costo de actividad de los siguientes registros
exec actividades.modificar_precio_actividad 3, 5.3, '2027-05-14'
exec actividades.modificar_precio_actividad 4, 3.3, '2026-06-19'

--Se espera mensaje 'El nuevo costo de actividad no puede ser negativa'
exec actividades.modificar_precio_actividad 3, -5.3, '2025-08-29'

--Se espera mensaje 'La actividad a modificar no existe'
exec actividades.modificar_precio_actividad 99, 99.5, '2026-06-19'

/*
==========================================================================================================================
												ACTIVIDAD EXTRA
========================================================================================================================== */

/*****	actividades.insertar_actividad_extra(@nombreActividad varchar(36),@costo decimal(9,3))   *****/

--Se espera la insercion exitosa de los siguiente registros
exec actividades.insertar_actividad_extra 'Pileta verano', 5.9 
exec actividades.insertar_actividad_extra 'Colonia de verano', 99.5
exec actividades.insertar_actividad_extra 'Competencia', 20
exec actividades.insertar_actividad_extra 'Atletismo', 25

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad_extra 'Colonia de verano', 10.9

--Se espera mensaje 'El costo de la actividad no puede ser negativo'
exec actividades.insertar_actividad_extra 'Alquiler del SUM', -10.9

/*****	actividades.eliminar_actividad_extra(@id_actividad_extra int)	*****/

--Se espera la eliminacion de los siguientes registros
exec actividades.eliminar_actividad_extra 1

--Se espera mensaje 'La actividad extra a eliminar no existe'
exec actividades.eliminar_actividad_extra 50

/*****	actividades.modificar_precio_actividad_extra(@id_actividad_extra int, @nuevoPrecio decimal(9,3))	*****/

-- Se espera la modificacion del costo de actividad_extra
exec actividades.modificar_precio_actividad_extra 2, 5.5

-- Se espera mensaje 'El nuevo costo de actividad extra debe ser mayor a cero.'
exec actividades.modificar_precio_actividad_extra 2, -5.5

-- Se espera mensaje 'La actividad extra a modificar no existe'
exec actividades.modificar_precio_actividad_extra 60, 5

-- Se deberian insertar con exito los siguientes registros
exec actividades.inscripcion_actividad_extra 2, 2, '2025-07-13', '16:00:00', '17:30:00', 10
exec actividades.inscripcion_actividad_extra 2, 3, '2025-08-14', '20:00:00', '21:00:00', 6

-- Se deberia mostrar el mensaje 'La cantidad de invitados no puede ser negativa.'
exec actividades.inscripcion_actividad_extra 1, 2, '2025-06-12', '14:00:00', '16:00:00', -2

-- Se deberia mostrar el mensaje 'La fecha de reserva no puede ser anterior a hoy.
exec actividades.inscripcion_actividad_extra 1, 2, '2025-06-12', '14:00:00', '16:00:00', 3

-- Se deberia mostrar el mensaje 'No se encontro una actividad con ese id'
exec actividades.inscripcion_actividad_extra 1, 7, '2025-06-12', '14:00:00', '16:00:00', 3

-- Se deberia mostrar el mensaje 'No se encontro el id del socio a inscribir a la actividad'
exec actividades.inscripcion_actividad_extra 25, 2, '2025-06-18', '14:00:00', '16:00:00', 3

/****  actividades.eliminar_inscripcion_act_extra
		@id_inscripcion int ****/

--Deberia eliminar con éxito los siguientes registros
exec actividades.eliminar_inscripcion_act_extra 1

--Se debería mostrar el mensaje 'La inscripcion extra a eliminar no existe'
exec actividades.eliminar_inscripcion_act_extra 15

print '========================================HORARIO ACTIVIDADES========================================'
/*
==========================================================================================================================
												HORARIO ACTIVIDADES
========================================================================================================================== */
/****actividades.insertar_horario_actividad****/

-- Se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Viernes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Martes', '19:00:00', '20:00:00', 2, 2
exec actividades.insertar_horario_actividad 'Miercoles', '19:00:00', '20:00:00', 2, 2
exec actividades.insertar_horario_actividad 'Jueves', '18:00:00', '19:30:00', 3, 2

--Se espera un mensaje de 'El dia no es correcto'
exec actividades.insertar_horario_actividad 'Noviembre', '18:00:00', '19:30:00', 3, 1

--Se espera un mensaje de 'No se encontro la actividad con ese id'
exec actividades.insertar_horario_actividad 'Sabado', '18:00:00', '19:30:00', 8, 2

--Se espera un mensaje de 'No se encontro la categoria con ese id'
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 10

/*****actividades.eliminar_horario_actividad(@id_horario int)****/

--Se espera la eliminacion exitosa de los siguientes registros
exec actividades.eliminar_horario_actividad 3

--Se espera un mensaje de 'No existe una actividad con ese id'
exec actividades.eliminar_horario_actividad 25

/*****actividades.modificar_horario_actividad*****/

--Se espera la modificacion exitosa del siguiente registro
exec actividades.modificar_horario_actividad 1, 'Miercoles', '18:00:00', '19:30:00', 1, 1

--Se espera un mensaje de 'El dia ingresado no es correcto.'
exec actividades.modificar_horario_actividad 3, 'Enero', '18:00:00', '19:15:00', 3, 2

--Se espera un mensaje de 'No se encontro la categoria con ese id'
exec actividades.modificar_horario_actividad 1, 'Miercoles', '18:00:00', '19:30:00', 1, 10

--Se espera un mensaje de 'No se encontro la actividad con ese id'
exec actividades.modificar_horario_actividad 2, 'Miercoles', '18:00:00', '19:30:00', 19, 1

--Se espera un mensaje de 'No se encontro horario con ese id'
exec actividades.modificar_horario_actividad 9, 'Miercoles', '18:00:00', '19:30:00', 1, 1

print '========================================INSCRIPCION ACTIVIDAD========================================'
/*
==========================================================================================================================
												INSCRIPCION ACTIVIDAD
========================================================================================================================== */
/********	actividades.inscripcion_actividad
			@id_socio int,
			@id_actividad int,
			@lista_id_horarios varchar(200)  ******/

--Insertanto registros para la prueba
declare @fechaDePrueba date = GETDATE()

select * from  actividades.horario_actividades

--Se deberían insertar con éxito los siguientes registros
exec actividades.inscripcion_actividad 1, 1, '1, 2'

--Se deberia generar un mensaje de 'No se encontro un horario para esa actividad'
exec actividades.inscripcion_actividad 1, 5, '1'

--Se deberia generar un mensaje de 'No se encontro una actividad con ese id'
exec actividades.inscripcion_actividad 1, 15, 9

--Se deberia generar un mensaje de 'No se encontro un socio con ese id'
exec actividades.inscripcion_actividad 15, 1, 1

/********  actividades.eliminar_inscripcion_actividad
			@id_inscripcion int  ***********/

--Deberían eliminarse correctamente los siguientes registros
exec actividades.eliminar_inscripcion_actividad 1

--Se debería generar un mensaje de 'La inscripcion a eliminar no existe'
exec actividades.eliminar_inscripcion_actividad 7

--Se espera que se ingresen mas inscripciones a actividades
exec actividades.inscripcion_actividad 2, 1, '1, 2'
exec actividades.inscripcion_actividad 3, 1, '1, 2'
exec actividades.inscripcion_actividad 2, 2, '4'
exec actividades.inscripcion_actividad 3, 2, '4'
exec actividades.inscripcion_actividad 3, 3, '5'
exec actividades.inscripcion_actividad 2, 3, '5'
exec actividades.inscripcion_actividad 1, 3, '5'

/*
==========================================================================================================================
												FACTURA
========================================================================================================================== */
/*****  facturacion.crear_factura  
		@total decimal(9,3),
		@dni int,
		@actividad varchar(250)  *****/

-- Se realizan inscripciones a las actividades
exec actividades.inscripcion_actividad 1, 1, '1'
exec actividades.inscripcion_actividad 4, 1, '1'

-- Se espera que no te deje crear la factura del socio menor 'No se le puede hacer la factura a un menor de edad!'
exec facturacion.crear_factura 5, '2025-07-02'

-- Se espera que te deje crear la factura del socio mayor, y agregue los gastos del menor 
exec facturacion.crear_factura 1,'2025-07-02'

--Si se ejecuta nuevamente, no te dejara crear mas facturas porque ya se ejecuto la factura del mes
exec facturacion.crear_factura 1, '2025-07-02'

--Luego se abona la factura creada
exec facturacion.pago_factura 1, 'PAGO', 1

--Se desea reembolsar la factura numero 1, que fue pagada anteriormente, 
--estos cambios se pueden visualizar en el saldo del usuario al que le pertenece la factura
exec facturacion.reembolsar_pago 1
--Si se ejecuta nuevamente no te deja realizar el reembolso
exec facturacion.reembolsar_pago 1
--Si la factura no se encuentra pagada no se puede realizar el reembolso
exec facturacion.reembolsar_pago 2
--Ahora se desea pagar la factura pero con saldo a favor del usuario
exec facturacion.pago_factura_debito 2,'PAGO',1

/*
==========================================================================================================================
												PILETA
========================================================================================================================== */
/***** actividades.inscribir_a_pileta
		@id_socio int,
		@es_invitado bit,
		@nombre_invitado varchar(40) = null,
		@apellido_invitado varchar(40) = null,
		@dni_invitado int = null,
		@edad_invitado int = null,
		@id_concepto int *****/

-- Se espera el mensaje de 'No existe una categoria creada para la edad de la persona que quiere ir a la pileta!'
exec actividades.inscribir_a_pileta 
	@id_socio = 1, 
	@es_invitado = 0, 
	@dni_invitado = NULL, 
	@edad_invitado = 10, 
	@id_concepto = 1

-- Inserto categorias y tambien el concepto
exec actividades.insertar_categoria_pileta @nombre = 'Menores de 12 años';
exec actividades.insertar_categoria_pileta @nombre = 'Adultos';
exec actividades.insertar_concepto_pileta @nombre = 'Temporada'

-- Se espera el mensaje 'No hay tarifa vigente para esta categoria y concepto'
exec actividades.inscribir_a_pileta 
	@id_socio = 1, 
	@es_invitado = 0, 
	@dni_invitado = NULL, 
	@edad_invitado = 8, 
	@id_concepto = 1

-- Insertar una tarifa valida para la pileta
declare @fecha date
set @fecha = DATEADD(MONTH, 1, GETDATE())

exec actividades.insertar_tarifa_pileta
	@id_concepto = 1,
	@id_categoria_pileta = 2,
	@precio_socio = 1000,
	@precio_invitado = 1500,
	@vigencia_hasta = @fecha

-- Se inscribe de manera exitosa
exec actividades.inscribir_a_pileta 
	@id_socio = 1,
	@es_invitado = 0,
	@id_concepto = 1

-- Inserto tarifa de menores
exec actividades.insertar_tarifa_pileta
	@id_concepto = 1,
	@id_categoria_pileta = 1, 
	@precio_socio = 2000,
	@precio_invitado = 2500,
	@vigencia_hasta = @fecha

-- Insercion exitosa para socio menor de edad
exec actividades.inscribir_a_pileta 
	@id_socio = 5,
	@es_invitado = 0,
	@id_concepto = 1

-- Inscripcion para un invitado
exec actividades.inscribir_a_pileta 
	@id_socio = 1,
	@es_invitado = 1,
	@id_concepto = 1,
	@nombre_invitado = 'Carlos',
	@apellido_invitado = 'Perez',
	@dni_invitado = 30456789,
	@edad_invitado = 35

/*
==========================================================================================================================
												ELIMINAR REGISTROS
========================================================================================================================== 
*/
/*
EXEC sp_MSForEachTable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
GO

DELETE FROM actividades.presentismo
DELETE FROM actividades.Sum_Reservas
DELETE FROM actividades.acceso_pileta
DELETE FROM actividades.invitado_pileta
DELETE FROM actividades.inscripcion_act_extra
DELETE FROM actividades.inscripcion_actividades_horarios
DELETE FROM actividades.inscripcion_actividades
DELETE FROM actividades.horario_actividades
DELETE FROM actividades.profesor
DELETE FROM actividades.actividad_extra
DELETE FROM actividades.actividad_precios
DELETE FROM actividades.actividad
DELETE FROM actividades.tarifa_pileta
DELETE FROM actividades.categoria_pileta
DELETE FROM actividades.concepto_pileta

DELETE FROM facturacion.pago
DELETE FROM facturacion.detalle_factura
DELETE FROM facturacion.factura
DELETE FROM facturacion.dias_lluviosos
DELETE FROM facturacion.medio_de_pago

DELETE FROM socios.pago_cuotas_historico
DELETE FROM socios.grupo_familiar
DELETE FROM socios.socio
DELETE FROM socios.categoria_precios
DELETE FROM socios.categoria
DELETE FROM socios.obra_social
DELETE FROM socios.usuario
DELETE FROM socios.rol
GO

DBCC CHECKIDENT ('actividades.presentismo', RESEED, 0);
DBCC CHECKIDENT ('actividades.Sum_Reservas', RESEED, 0);
DBCC CHECKIDENT ('actividades.acceso_pileta', RESEED, 0);
DBCC CHECKIDENT ('actividades.invitado_pileta', RESEED, 0);
DBCC CHECKIDENT ('actividades.inscripcion_act_extra', RESEED, 0);
DBCC CHECKIDENT ('actividades.inscripcion_actividades', RESEED, 0);
DBCC CHECKIDENT ('actividades.horario_actividades', RESEED, 0);
DBCC CHECKIDENT ('actividades.profesor', RESEED, 0);
DBCC CHECKIDENT ('actividades.actividad_extra', RESEED, 0);
DBCC CHECKIDENT ('actividades.actividad_precios', RESEED, 0)
DBCC CHECKIDENT ('actividades.actividad', RESEED, 0)
DBCC CHECKIDENT ('actividades.tarifa_pileta', RESEED, 0)
DBCC CHECKIDENT ('actividades.categoria_pileta', RESEED, 0)
DBCC CHECKIDENT ('actividades.concepto_pileta', RESEED, 0)
DBCC CHECKIDENT ('facturacion.pago', RESEED, 0)
DBCC CHECKIDENT ('facturacion.detalle_factura', RESEED, 0)
DBCC CHECKIDENT ('facturacion.factura', RESEED, 0)
DBCC CHECKIDENT ('facturacion.medio_de_pago', RESEED, 0)
DBCC CHECKIDENT ('socios.socio', RESEED, 0)
DBCC CHECKIDENT ('socios.categoria_precios', RESEED, 0)
DBCC CHECKIDENT ('socios.categoria', RESEED, 0)
DBCC CHECKIDENT ('socios.obra_social', RESEED, 0)
DBCC CHECKIDENT ('socios.usuario', RESEED, 0)
DBCC CHECKIDENT ('socios.rol', RESEED, 0)
GO

EXEC sp_MSForEachTable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
GO
*/