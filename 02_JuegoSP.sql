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

/*****	socios.modificar_contraseña_usuario 
		@id_usuario int,
		@contraseña varchar(40) *****/

--Se espera la modificacion exitosa de la contraseña
exec socios.modificar_usuario @id_usuario = 1, @contraseña = 'naruto456!'
exec socios.modificar_usuario @id_usuario = 2, @contraseña = 'contraseña_super_secreta'
exec socios.modificar_usuario @id_usuario = 3, @contraseña = 'auricularTeclado46!'

-- Se espera mensaje 'La contraseña no puede estar vacia'
exec socios.modificar_usuario @id_usuario = 1, @contraseña = ''

-- Se espera mensaje 'La contraseña no puede ser nula'
exec socios.modificar_usuario @id_usuario = 4, @contraseña = NULL

-- Se espera mensaje 'No existe un usuario con ese id'
exec socios.modificar_usuario @id_usuario = 100, @contraseña = 'perroGatoMono55?'

declare @fechaDePruebaModificada date;

--Se espera mensaje 'La fecha de vigencia no puede ser anterior a la actual' si fecha_vigencia_contraseña nueva es igual al original
exec socios.modificar_usuario @id_usuario = 1, @fecha_vigencia_contraseña = @fechaDePrueba

--Se espera la modificacion exitosa de la fecha_vigencia_contraseña
set @fechaDePruebaModificada = DATEADD(DAY, 1, @fechaDePrueba)
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
exec socios.eliminar_obra_social 'Swiss Medical'

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
exec socios.insertar_categoria 'Menor', 1, 12, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 13, 17, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 18, 35, 0, '2025-08-30'
exec socios.insertar_categoria 'MayorAlCuadrado', 35, 45, 0, '2025-08-30'

--Se espera mensaje 'Ya existe una categoría con ese nombre.'
exec socios.insertar_categoria 'Menor', 1, 18, 10.50, '2025-12-31'

--Se espera mensaje 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
exec socios.insertar_categoria 'Veterano', 5, 5, 10.6, '2025-12-31'

--Se espera mensaje 'El costo de la membresia no puede ser negativo.'
exec socios.insertar_categoria 'Veterano', 36, 45, -1.99, '2025-12-31'

/*****	socios.modificar_costo_categoria @id_categoria int, @costo_membresia decimal(9,3) *****/

exec socios.modificar_costo_categoria 1, 10.99  -- ID de 'Menor'
exec socios.modificar_costo_categoria 2, 20.99  -- ID de 'Cadete'

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

-- Esto se hacep ara obtener el precio mas vigente dentro del historico
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
exec facturacion.eliminar_medio_de_pago 1

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
    @nombre = 'ana',
    @apellido = 'perez',
    @email = 'ana.perez@mail.com',
    @fecha_nacimiento = '1990-05-10',
    @telefono_contacto = '0000000001',
    @telefono_emergencia = '0000000002',
    @id_obra_social = 1,
    @nro_socio_obra_social = 'a100',
    @id_medio_de_pago = 1,
    @id_rol = 1;

exec socios.insertar_socio
    @dni = 52745821,
    @nombre = 'martin',
    @apellido = 'gutierrez',
    @email = 'martin.gutierrez@mail.com',
    @fecha_nacimiento = '1989-04-12',
    @telefono_contacto = '01112345678',
    @telefono_emergencia = '01187654321',
    @id_obra_social = 2,
    @nro_socio_obra_social = 'm350',
    @id_medio_de_pago = 2,
    @id_rol = 1;

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
    @id_rol = 1;

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
    @id_rol = 1;

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
    @id_rol = 1;

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
    @id_rol = 1;
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

-- Se elimina un socio mediante el DNI
exec socios.eliminar_socio @dni = 52745821;

-- Indica que 'No existe un socio con ese dni.'
exec socios.eliminar_socio @dni = 88888;
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

-- Responsable menor de edad
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

--Se espera mensaje 'El costo de actividad no debe ser negativo'
exec actividades.insertar_actividad 'Futbol', -1.5, '2026-06-19'

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad 'Baile', 1000, '2025-07-27'
exec actividades.insertar_actividad 'Voley', 2.9, '2025-08-29'

/*****	actividades.eliminar_actividad(@id_actividad int)	*****/

--Insertanto registros para la prueba
exec actividades.insertar_actividad 'Voley', 2.9, '2025-08-29'
exec actividades.insertar_actividad 'Baile', 9999.5, '2026-06-19'

--Se espera la eliminacion de los siguiente registros
exec actividades.eliminar_actividad 1
exec actividades.eliminar_actividad 2

--Se espera mensaje 'La actividad a eliminar no existe'
exec actividades.eliminar_actividad 1
exec actividades.eliminar_actividad 3

/*****	actividades.modificar_precio_actividad(@id_actividad int, @nuevoPrecio decimal(9,3))	*****/

--Insertanto registros para la prueba
exec actividades.insertar_actividad 'Voley', 2.9, '2026-06-19'
exec actividades.insertar_actividad 'Baile', 9999.5, '2027-05-14'

--Se espera la modificacion del costo de actividad de los siguientes registros
exec actividades.modificar_precio_actividad 1, 5.3, '2027-05-14'
exec actividades.modificar_precio_actividad 2, 3.3, '2026-06-19'
--Se espera mensaje 'El nuevo costo de actividad no puede ser negativa'
exec actividades.modificar_precio_actividad 1, -5.3, '2025-08-29'

--Se espera mensaje 'La actividad a modificar no existe'
exec actividades.modificar_precio_actividad 3, 99.5, '2026-06-19'

/*****	actividades.insertar_actividad_extra(@nombreActividad varchar(36),@costo decimal(9,3))   *****/

--Se espera la insercion exitosa de los siguiente registros
exec actividades.insertar_actividad_extra 'Pileta verano', 5.9 
exec actividades.insertar_actividad_extra 'Colonia de verano', 99.5

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad_extra 'Colonia de verano', 10.9

--Se espera mensaje 'El costo de la actividad no puede ser negativo'
exec actividades.insertar_actividad_extra 'Alquiler del SUM', -10.9

/*****	actividades.eliminar_actividad_extra(@id_actividad_extra int)	*****/

--Insertanto registros para la prueba
exec actividades.insertar_actividad_extra 'Pileta verano', 5.9 
exec actividades.insertar_actividad_extra 'Colonia de verano', 99.5

--Se espera la eliminacion de los siguientes registros
exec actividades.eliminar_actividad_extra 1
exec actividades.eliminar_actividad_extra 2

--Se espera mensaje 'La actividad extra a eliminar no existe'
exec actividades.eliminar_actividad_extra 1
exec actividades.eliminar_actividad_extra 3

/*****	actividades.modificar_precio_actividad_extra(@id_actividad_extra int, @nuevoPrecio decimal(9,3))	*****/

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

print '========================================HORARIO ACTIVIDADES========================================'
/*
==========================================================================================================================
												HORARIO ACTIVIDADES
========================================================================================================================== */
/****actividades.insertar_horario_actividad****/

--insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec actividades.insertar_actividad 'futbol', 10000, '2026-06-19'
exec actividades.insertar_actividad 'voley', 10000, '2025-08-25'
exec actividades.insertar_actividad 'tenis', 13000, '2026-06-19'

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

/*****actividades.eliminar_horario_actividad(@id_horario int)****/

--insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec actividades.insertar_actividad 'futbol', 10000, '2025-12-31'
exec actividades.insertar_actividad 'voley', 10000, '2026-12-31'
exec actividades.insertar_actividad 'tenis', 13000, '2027-12-31'

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

/*****actividades.modificar_horario_actividad*****/

--insertando registros para la prueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec actividades.insertar_actividad 'futbol', 10000, '2026-08-25'
exec actividades.insertar_actividad 'voley', 10000, '2026-08-25'
exec actividades.insertar_actividad 'tenis', 13000, '2026-08-25'

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
declare @fechaDePrueba date = GETDATE();
exec socios.insertar_rol 'Cliente', @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'grosso@gmail.com', @contraseña = 'passwordDeUsuario1', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'lautaro@gmail.com', @contraseña = 'passwordDeUsuario2', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'federico@gmail.com', @contraseña = 'passwordDeUsuario3', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_obra_social 'Luis Pasteur', '1111111111'
exec socios.insertar_obra_social'OSECAC', '22222222'
exec facturacion.insertar_medio_de_pago'Visa', 1

--insercion de socios
exec socios.insertar_socio 41247252, 'Pepe', 'Grillo' , 'pGrillo@gmail.com', '1999-01-19', '11223344', '55667788', 1, 41, 1, 1, 1
exec socios.insertar_socio 41247253, 'Armando', 'Paredes' , 'albañilParedes@gmail.com', '1990-01-19', '55667788', '11223344', 2, 45, 1, 1, 1

--Insercion de actividades
exec actividades.insertar_actividad 'futbol', 10000, '2029-02-15'
exec actividades.insertar_actividad 'voley', 10000, '2026-08-25'
exec actividades.insertar_actividad 'tenis', 13000, '2025-09-20'

--Insercion de horarios
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Martes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Jueves', '18:00:00', '19:30:00', 3, 2
exec actividades.insertar_horario_actividad 'Martes', '19:00:00', '20:00:00', 2, 2

select * from  actividades.horario_actividades

--Se deberían insertar con éxito los siguientes registros
exec actividades.inscripcion_actividad 1, 1, '1,4'
exec actividades.inscripcion_actividad 1, 3, '2'

--Se deberia generar un mensaje de 'No se encontro un horario para esa actividad'
exec actividades.inscripcion_actividad 1, 3, 1

--Se deberia generar un mensaje de 'No se encontro una actividad con ese id'
exec actividades.inscripcion_actividad 1, 1, 9

--Se deberia generar un mensaje de 'No se encontro un horario con ese id'
exec actividades.inscripcion_actividad 1, 5, 1

--Se deberia generar un mensaje de 'No se encontro el id del socio a inscribir a la actividad'
exec actividades.inscripcion_actividad 15, 1, 1

/********  actividades.eliminar_inscripcion_actividad
			@id_inscripcion int  ***********/

--Deberían eliminarse correctamente los siguientes registros
exec actividades.eliminar_inscripcion_actividad 1
exec actividades.eliminar_inscripcion_actividad 2

--Se debería generar un mensaje de 'La inscripcion a eliminar no existe'
exec actividades.eliminar_inscripcion_actividad 1
exec actividades.eliminar_inscripcion_actividad 7

print '========================================ACTIVIDAD EXTRA========================================'
/*
==========================================================================================================================
												ACTIVIDAD EXTRA
========================================================================================================================== */
/****	actividades.inscripcion_actividad_extra
		@id_socio int,
		@id_actividad_extra int,
		@fecha date,
		@hora_inicio time,
		@hora_fin time,
		@cant_invitados int)  *****/

--Insertanto registros para la prueba
exec socios.insertar_rol 'Cliente', @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'damian@gmail.com', @contraseña = 'passwordDeUsuario1', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'nicolas@gmail.com', @contraseña = 'passwordDeUsuario2', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_usuario @id_rol = 1, @usuario = 'rivero@gmail.com', @contraseña = 'passwordDeUsuario3', @fecha_vigencia_contraseña = @fechaDePrueba
exec socios.insertar_categoria 'Menor', 1, 18, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_obra_social 'Luis Pasteur', '1111111111'
exec socios.insertar_obra_social 'OSECAC', '22222222'
exec facturacion.insertar_medio_de_pago 'Visa', 1

--insercion de socios
exec socios.insertar_socio 41247252, 'Pepe', 'Grillo' , 'pGrillo@gmail.com', '1999-01-19', '11223344', '55667788', 1, 21, 1, 1, 1
exec socios.insertar_socio 41247253, 'Armando', 'Paredes' , 'albañilParedes@gmail.com', '1990-01-19', '55667788', '11223344', 2, 35, 1, 1, 1

--Insercion de actividades extra
exec actividades.insertar_actividad_extra 'pileta', 10000
exec actividades.insertar_actividad_extra 'SUM', 25000
exec actividades.insertar_actividad_extra 'Colonia', 40000

/* Lo dejo comentado para hacer las modificaciones...
--Se deberIan insertar con Exito los siguientes registros
exec actividades.inscripcion_actividad_extra 1, 1, '2025-06-12', '14:00:00', '16:00:00', 3
exec actividades.inscripcion_actividad_extra 2, 2, '2025-06-13', '16:00:00', '17:30:00', 10
exec actividades.inscripcion_actividad_extra 2, 3, '2025-06-14', '20:00:00', '21:00:00', 6

--Se deberia mostrar el mensaje 'Error en la cantidad de invitados'
exec actividades.inscripcion_actividad_extra 1, 2, '2025-06-12', '14:00:00', '16:00:00', -2

--Se deberia mostrar el mensaje 'No se encontro una actividad con ese id'
exec actividades.inscripcion_actividad_extra 1, 7, '2025-06-12', '14:00:00', '16:00:00', 3

--Se deberia mostrar el mensaje 'No se encontro el id del socio a inscribir a la actividad'
exec actividades.inscripcion_actividad_extra 4, 1, '2025-06-18', '14:00:00', '16:00:00', 3

/****  actividades.eliminar_inscripcion_act_extra
		@id_inscripcion int ****/

--Deberia eliminar con éxito los siguientes registros
exec actividades.eliminar_inscripcion_act_extra 1
exec actividades.eliminar_inscripcion_act_extra 2

--Se debería mostrar el mensaje 'La inscripcion extra a eliminar no existe'
exec actividades.eliminar_inscripcion_act_extra 1
exec actividades.eliminar_inscripcion_act_extra 7



==========================================================================================================================
												FACTURA
========================================================================================================================== */
/*****  facturacion.crear_factura  
		@total decimal(9,3),
		@dni int,
		@actividad varchar(250)  *****/

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Mayor', 18, 99, 200, '2025-08-30'
exec socios.insertar_categoria 'Menor', 1, 17, 50, '2025-08-30'
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Tarjeta de crédito', 1
exec socios.insertar_obra_social 'OSDE', '1134225566'

exec actividades.insertar_actividad 'Ajedrez', 15003, '2029-02-15'
exec actividades.insertar_actividad 'Arte', 900000, '2026-08-25'

exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad 'Martes', '18:00:00', '19:30:00', 1, 1
exec actividades.insertar_horario_actividad  'Jueves', '18:00:00', '19:30:00', 2, 2

-- Se espera inserción exitosa del socio Roman, Messi es padre de Liomeñ
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', '1133445566', '1133445577', 1, 12, 1, 1, 1
exec socios.insertar_socio  41288888, 'Messi', 'Messi', 'messi@gmail.com', '1990-06-01', '1121555566', '1333445577', 1, 12, 1, 1, 1
exec socios.insertar_socio  51283188,'Liomeñ', 'Messi', 'lion@gmail.com', '2015-06-01', '1123445566', '1333445577', 1, 12, 1, 1, 2,'PADRE'
exec socios.insertar_socio  337834783,'Marcos', 'Roto', 'mrquitos@gmail.com', '1990-06-01', '1123445566', '1333445577', 1, 12, 1, 1

--Inscribimos a Lionel y al Hijo de lionel a actividades
exec actividades.inscripcion_actividad 1, 1, '1'
exec actividades.inscripcion_actividad 3, 2, '3'
exec actividades.inscripcion_actividad 4, 1, '1'

--Se espera que se encuentre en detalles de factura, ambas inscripciones
select*from facturacion.detalle_factura
--Una vez inscriptos, se cargaran mas actividades de esos socios en el club
--Y a fin de mes, se realiza la creacion de la factura del socio mayor
--En caso de que sea menor, no te deja crear la factura

--Se espera que no te deje crear la factura del socio menor
exec facturacion.crear_factura 3,'2025-07-02'
--Se espera que te deje crear la factura del socio mayor, y agregue los gastos del menor 
--Tambien a la factura
exec facturacion.crear_factura 4,'2025-07-02'
select*from facturacion.factura
--Si se ejecuta nuevamente, no te dejara crear mas facturas porque ya se ejecuto la factura del mes
exec facturacion.crear_factura 2,'2025-07-02'
--Tambien en detalle factura, aparece la factura a la cual pertenecen las actividades
select*from facturacion.detalle_factura
--Luego se abona la factura creada
exec facturacion.pago_factura 1,'PAGO', 1

exec facturacion.crear_factura 1,'2025-07-02'

select * from actividades.horario_actividades
select * from actividades.actividad
select * from facturacion.detalle_factura
select * from socios.socio
select * from socios.obra_social
select * from facturacion.factura
select * from facturacion.pago
select * from actividades.inscripcion_actividades
select * from socios.grupo_familiar

--Se agregan nuevamente actividades
--================================================
/*
/*****  facturacion.pago_factura 
		@id_factura int,
		@tipo_movimiento varchar(20),
		@id_medio_pago int  *****/

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Transferencia', 1
exec socios.insertar_obra_social 'OSDE', '1134225566'

-- Se espera inserción exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', '1133445566', '1133445577', 1, 22, 1, 1, 1

-- Se espera creación exitosa de una factura NO PAGADA
exec facturacion.crear_factura 10000.000, 42838702, 1
exec facturacion.crear_factura 250000.000, 42838702, 1

-- Se espera que el pago se realice exitosamente y se actualice el estado de la factura
exec facturacion.pago_factura 1, 'PAGO', 1

-- Se espera mensaje: 'No se encontro factura con ese id o la factura ya fue abonada'
exec facturacion.pago_factura 1, 'PAGO', 1

-- Se espera mensaje: 'No se encontro el id de ese medio de pago'
exec facturacion.pago_factura 2, 'PAGO', 999

/*****  facturacion.reembolsar_pago
		@id_factura int  *****/

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Transferencia', 1
exec socios.insertar_obra_social 'OSDE', 1134225566
exec actividades.insertar_actividad 'Futbol', 200.5, '2025-09-20'
exec actividades.insertar_horario_actividad 'Lunes','20:00:00','21:00:00', 1, 1
go

-- Se espera insercion exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', 1133445566, 1133445577, 1, 1, 1, 1

-- Se espera la inscripcion exitosa del socio a futbol y generacion de factura
exec actividades.inscripcion_actividad 1, 1, 1

-- Se espera que la factura no haga un reembolso porque ese id factura no fue pagada
exec facturacion.reembolsar_pago 1

-- Se espera que el pago se realice exitosamente y se actualice el estado de la factura
exec facturacion.pago_factura 1, 'PAGO', 1

-- Se espera que la factura no haga un reembolso porque ese id factura no existe
exec facturacion.reembolsar_pago 2

-- Se espera que la factura haga un reembolso exitosamente,
-- Se cambie el tipo de movimiento en la tabla facturacion.pago
-- El saldo en usuario aumente porque es un reembolso, en este caso el 100%
exec facturacion.reembolsar_pago 1

-- Se espera que se debite de la cuenta del usuario al realizar el pago con saldo
-- Ademas se espera un descuento en el precio del 10% porque el socio ya esta inscripto en una actividad deportiva
exec actividades.inscripcion_actividad 1, 1, 1

--Prueba de Inscripcion y Reserva de Sum

exec actividades.insertar_actividad_extra 'Sum', 9000
exec actividades.inscripcion_actividad_extra 1, 2, '2025-06-28', '19:00:00', '20:00:00', 0

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Transferencia', 1
exec socios.insertar_obra_social 'OSDE', 1134225566
exec actividades.insertar_actividad 'Futbol', 200.5, '2025-09-20'
exec actividades.insertar_horario_actividad 'Lunes','20:00:00','21:00:00',1,1
go

-- Se espera inserción exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', 1133445566, 1133445577, 1, 1, 1, 1

-- Se espera que inserte la actividad extra Sum
exec actividades.insertar_actividad_extra 'Sum',9000

-- Se espera que inscriba al socio en la actividad y reserve el Sum, se genere la factura 
exec actividades.inscripcion_actividad_extra 1, 1, '2025-06-28','19:00:00','20:00:00', 0

-- Se espera que no pueda inscribirse y reservar la actividad Sum porque ya esta reservada para ese dia
exec actividades.inscripcion_actividad_extra 1, 1, '2025-06-28','19:00:00','20:00:00', 0
*/
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

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Transferencia', 1
exec socios.insertar_obra_social 'OSDE', 1134225566
exec actividades.insertar_actividad 'Futbol', 200.5, '2025-09-20'
exec actividades.insertar_horario_actividad 'Lunes','20:00:00','21:00:00', 1, 1
go

-- Se espera insercion exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', 1133445566, 1133445577, 1, 1, 1, 1

-- Se espera el mensaje de 'No existe una categoria creada para la edad de la persona que quiere ir a la pileta!'
exec actividades.inscribir_a_pileta 
     @id_socio = 1, 
     @es_invitado = 0, 
     @dni_invitado = null, 
     @edad_invitado = 10, 
     @id_concepto = 1

-- Inserto categorias y tambien el concepto
insert into actividades.categoria_pileta(nombre) values('Menores de 12 años'), ('Adultos');
insert into actividades.concepto_pileta(nombre) values('Temporada');

-- Se espera el mensaje 'No se encontro una tarifa vigente para esta categoria y concepto'
exec actividades.inscribir_a_pileta 
     @id_socio = 1, 
     @es_invitado = 0, 
     @dni_invitado = null, 
     @edad_invitado = 8, 
     @id_concepto = 1

-- Insertar una tarifa valida para la pileta
insert into actividades.tarifa_pileta(id_concepto, id_categoria_pileta, precio_socio, precio_invitado, vigencia_hasta)
values(1, 2, 1000, 1500, dateadd(month, 1, getdate()));

-- Se inscribe de manera exitosa
exec actividades.inscribir_a_pileta 
     @id_socio = 1,
     @es_invitado = 0,
     @edad_invitado = 8,
     @id_concepto = 1;

-- Inserto tarifa de adultos
insert into actividades.tarifa_pileta(id_concepto, id_categoria_pileta, precio_socio, precio_invitado, vigencia_hasta)
values(1, 2, 2000, 2500, dateadd(month, 1, getdate()));

-- Insercion exitosa para un invitado
exec actividades.inscribir_a_pileta 
     @id_socio = 1,
     @es_invitado = 1,
     @nombre_invitado = 'María',
     @apellido_invitado ='Gómez',
     @dni_invitado = 87654321,
     @edad_invitado = 30,
     @id_concepto = 1;

/*Prueba descuento por dia de lluvia*/

-- Se inserta una facturacion en un dia en el que llovio manualmente '2025-01-01',previamente se inserto el archivo de meteorologia 2025
insert into facturacion.factura (dni,fecha_emision,total,estado,nombre,apellido,servicio)
values(42838702,'2025-01-01',5000,'PAGADO','Juan','Roman','Pileta')

-- Se espera que realice el reembolso de una factura pagada, en esa fecha, si llovio y si el dni es de socio
exec facturacion.descuento_pileta_lluvia '2025-01-01'
*/

/*
==========================================================================================================================
												TEST GENERAL
========================================================================================================================== 
*/
/*
use COM5600G03
go
*/
--       Inserción de datos requeridos para relaciones   --

--Se insertan las distintas categorias con las que se va a contar
exec socios.insertar_categoria 'Menor', 1, 18, 1300, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1600, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 101, 3600, '2025-08-30'

	select*from socios.categoria
--Se inserta un rol general para socios
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'

	select*from socios.rol

--Se inserta un medio de pago con el que vamos a contar para esta prueba
exec facturacion.insertar_medio_de_pago 'Tarjeta de crédito', 1

--Se inserta una obra social con la que vamos a contar para esta prueba
exec socios.insertar_obra_social 'OSDE', '1134225566'

--       Generacion de socios y grupo familiar           --
--Una vez terminado la insercion de datos necesarios, se insertan nuevas actividades
exec actividades.insertar_actividad 'Handball', 2300, '2029-02-15'
exec actividades.insertar_actividad 'Polo', 11200, '2026-08-25'
exec actividades.insertar_actividad 'Arte', 3200, '2026-08-25'

	select*from actividades.actividad

--Se agregan horarios para esas actividades
exec actividades.insertar_horario_actividad 'Lunes', '18:00:00', '19:30:00', 1, 2
exec actividades.insertar_horario_actividad 'Martes', '18:00:00', '19:30:00', 2, 2
--En este caso se genera una actividad para menores de edad
exec actividades.insertar_horario_actividad  'Jueves', '18:00:00', '19:30:00', 1, 1
--En este caso se inserta la actividad Arte los viernes
exec actividades.insertar_horario_actividad 'Viernes', '13:00:00', '16:30:00', 3, 2


	select*from actividades.horario_actividades
--//////GENERAR INSERCION DE PROFESORES
-- Se espera inserción exitosa del socio Roman
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', '1133445566', '1133445577', 1, 10, 1, 1, 1

--En este caso se genera el socio Lionel Messi, pero Lionel es padre de Mateo Messi,
--por lo tanto en la inscripcion se genera directamente el grupo familiar
exec socios.insertar_socio  41288888, 'Lionel', 'Messi', 'messi@gmail.com', '1990-06-01', '1123445566', '113222577', 1, 10, 1, 1, 1
exec socios.insertar_socio  51283188,'Mateo', 'Messi', 'mate@gmail.com', '2015-06-01', '1177445567', '1123445566', 1, 112, 1, 1, 2,'PADRE'
--Se inserta al socio Marcos Rojo
exec socios.insertar_socio  33783478,'Marcos', 'Rojo', 'mrquitos@gmail.com', '1994-06-01', '1183485568', '116245877', 1, 3412, 1, 1

	select*from socios.socio
	select*from socios.grupo_familiar
	select*from socios.usuario

--Inscribimos a Lionel y Mateo en actividades, hay que tener en cuenta que son familiares
--En este caso se inscribe a Lionel en (HandBall), en el horario ('Lunes', '18:00:00', '19:30:00')
exec actividades.inscripcion_actividad 2, 1, '1'
--En este caso se inscribe a Mateo en (Handball), en el horario ('Jueves', '18:00:00', '19:30:00') para Menores
exec actividades.inscripcion_actividad 3, 1, '3'

    select*from actividades.inscripcion_actividades
   
--Se puede visualizar que Lionel y Mateo son familiares por lo tanto no deberia de poder generarse una factura para Mateo
exec facturacion.crear_factura 3,'2025-07-01'
--Por lo tanto se debe de generar la factura para Messi, agregando los gastos que tuvo Mateo,
--generando los descuentos correspondientes y membresia
exec facturacion.crear_factura 2,'2025-07-01'

    select*from facturacion.factura
    select*from facturacion.detalle_factura

--Ahora se inscribe a Roman en alguna actividad
exec actividades.inscripcion_actividad 1, 1, '1'

	select*from actividades.inscripcion_actividades

--Se le crea la factura correspondiente
exec facturacion.crear_factura 1,'2025-07-01'

	select*from facturacion.factura
    select*from facturacion.detalle_factura

--Ahora se va a realizar el pago de la factura de Lionel(Socio 2)
--Se espera que en la factura el estado pase a (PAGADO), y se confirme el pago en la tabla facturacion.pago
exec facturacion.pago_factura  1,'PAGO', 1

	select*from facturacion.factura
	select*from facturacion.pago

--Una vez pagada la factura se necesita realizar el reembolso de una factura
--En este caso se va a reembolsar la factura 1
--Cuando se reembolsa la factura, en la tabla facturacion.pago, puede visualizar como figura (REEMBOLSO) 
--y en la cuenta del socio puede visualizarse un saldo a favor del total de la factura
exec facturacion.reembolsar_pago 1

	select*from facturacion.factura
	select*from facturacion.pago
	select*from socios.usuario
	
--Ahora que el socio tiene saldo a favor quiere inscribirse a la Actividad Arte, los viernes por la tarde
--En este caso se genera manualmente la inscripcion, para testear el procedimiento de pago con saldo a favor
--Ya que no se puede generar una factura del mes, dos veces el mismo mes
--Entonces creamos una factura de una fecha pasada
INSERT INTO actividades.inscripcion_actividades(id_socio,id_actividad,fecha_inscripcion)
values(2,3,'2025-11-03')

     select*from actividades.inscripcion_actividades

exec facturacion.crear_factura 2,'2025-11-03'

	select*from facturacion.factura
	select*from facturacion.detalle_factura
	select*from facturacion.pago
	select*from socios.usuario
--Se cuenta con una factura no paga del socio 2, por lo tanto vamos a pagarla con saldo a favor del socio
exec facturacion.pago_factura_debito 3,'PAGO',1


--Se espera que no te deje crear la factura del socio menor
exec facturacion.crear_factura 3,'2025-07-02'
--Se espera que te deje crear la factura del socio mayor, y agregue los gastos del menor 
--Tambien a la factura
exec facturacion.crear_factura 4,'2025-07-02'
select*from facturacion.factura
--Si se ejecuta nuevamente, no te dejara crear mas facturas porque ya se ejecuto la factura del mes
exec facturacion.crear_factura 2,'2025-07-02'
--Tambien en detalle factura, aparece la factura a la cual pertenecen las actividades
select*from facturacion.detalle_factura
--Luego se abona la factura creada
exec facturacion.pago_factura 1,'PAGO', 1

exec facturacion.crear_factura 1,'2025-07-02'


