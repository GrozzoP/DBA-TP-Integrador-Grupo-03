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
-- Este SP sirve para eliminar y restaurar el incremento de los id de las tablas,
create or alter procedure eliminar_y_restaurar_tabla @tabla nvarchar(512)
as
begin
    declare @schema sysname = parsename(@tabla, 2),
            @name sysname = parsename(@tabla, 1),
            @sql nvarchar(max);

	-- Si el esquema es nulo, entonces usar por default el dbo
    if @schema is null 
		set @schema = 'dbo';

    -- Eliminar los registros relativos a la tabla
    set @sql = 'delete from ' + quotename(@schema) + '.' + quotename(@name);
    exec sp_executesql @sql;

    -- resetear identidad si existe columna identity
    if exists (
        select 1 from sys.identity_columns ic
        where ic.object_id = object_id(@schema + '.' + @name)
    )
    begin
        -- reseed a 0 para que próximo valor sea 1
        set @sql = 'dbcc checkident(''' + @schema + '.' + @name + ''', reseed, 0)';
        exec sp_executesql @sql;
    end
end;
go


/*** Fin de SP auxiliares ***/
/*
Limpiar si hace falta
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades';
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_act_extra';
exec eliminar_y_restaurar_tabla 'actividades.presentismo';
exec eliminar_y_restaurar_tabla 'actividades.acceso_pileta';
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades';
exec eliminar_y_restaurar_tabla 'facturacion.pago';
exec eliminar_y_restaurar_tabla 'actividades.tarifa_pileta';
exec eliminar_y_restaurar_tabla 'actividades.invitado_pileta';
exec eliminar_y_restaurar_tabla 'facturacion.factura';
exec eliminar_y_restaurar_tabla 'facturacion.dias_lluviosos';
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar';
exec eliminar_y_restaurar_tabla 'socios.socio';
exec eliminar_y_restaurar_tabla 'socios.usuario';
exec eliminar_y_restaurar_tabla 'socios.categoria_precios';
exec eliminar_y_restaurar_tabla 'socios.categoria';
exec eliminar_y_restaurar_tabla 'socios.obra_social';
exec eliminar_y_restaurar_tabla 'socios.rol';
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago';
exec eliminar_y_restaurar_tabla 'actividades.Sum_Reservas';
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios';
exec eliminar_y_restaurar_tabla 'actividades.actividad';
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra';
exec eliminar_y_restaurar_tabla 'actividades.concepto_pileta';
exec eliminar_y_restaurar_tabla 'actividades.categoria_pileta';
*/
go


-- /////////////// ROLES ///////////////
/*****	socios.insertar_rol
		@nombre_rol varchar(20), 
		@descripcion_rol varchar(50))	******/

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


/*****	socios.modificar_rol
		@nombre_rol varchar(20), 
		@nueva_descripcion_rol varchar(50))	*****/

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

-- /////////////// USUARIO ///////////////
/*****	socios.insertar_usuario
						@id_rol int,
						@contraseña varchar(40),
						@fecha_vigencia_contraseña date	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'

--Insertando registros para prueba
exec socios.insertar_rol 'Usuario', 'Persona que utiliza la aplicacion'
exec socios.insertar_rol 'Moderador', 'Encargado de moderar'
exec socios.insertar_rol 'Ayudante', 'Encargado de brindar ayuda a los socios'

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

/*****	socios.modificar_contraseña_usuario 
		@id_usuario int,
		@contraseña varchar(40) *****/

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

/*****	socios.modificar_fecha_vigencia_usuario 
		@id_usuario int, 
		@fecha_vigencia_contraseña date *****/

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

/*****	socios.eliminar_usuario 
		@id_usuario int *****/

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

-- /////////////// OBRA SOCIAL ///////////////
/*****	socios.insertar_obra_social 
		@nombre_obra_social varchar(60), 
		@telefono_obra_social int	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.obra_social'

--Se espera la insercion exitosa de los sig registros
exec socios.insertar_obra_social '', 0
exec socios.insertar_obra_social 'obraSocial1', '0'
exec socios.insertar_obra_social 'obraSocial2', '0'
exec socios.insertar_obra_social 'obraSocial3', '0'
exec socios.insertar_obra_social NULL, NULL

--Se espera un mensaje 'El numero de telefono no puede ser negativo'
exec socios.insertar_obra_social 'obraSocial5', -1

--Se espera mensaje 'Ya existe una obra social con ese nombre.'
exec socios.insertar_obra_social '', 0
exec socios.insertar_obra_social 'obraSocial1', '11111111'
exec socios.insertar_obra_social 'obraSocial2', '11111111'
exec socios.insertar_obra_social 'obraSocial3', '11111111'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.obra_social'

/*****	socios.modificar_obra_social 
		@nombre_obra_social varchar(60), 
		@telefono_obra_social int	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.obra_social'

--Insertando registros para prueba
exec socios.insertar_obra_social 'obraSocial1', '11111111'
exec socios.insertar_obra_social 'obraSocial2', '22222222'
exec socios.insertar_obra_social 'obraSocial3', '33333333'
exec socios.insertar_obra_social 'obraSocial4', '44444444'

--Se espera la modificacion del @telefono_obra_social de los siguientes registros con exito
exec socios.modificar_obra_social 'obraSocial1', '0'
exec socios.modificar_obra_social 'obraSocial2', '0'
exec socios.modificar_obra_social 'obraSocial3', '0'
exec socios.modificar_obra_social 'obraSocial4', '0'

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.modificar_obra_social 'obraSocial6', '0'
exec socios.modificar_obra_social 'obraSocial7', '0'
exec socios.modificar_obra_social 'obraSocial8', '0'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'socios.obra_social'

/*****	socios.eliminar_obra_social @nombre_obra_social varchar(60)	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.obra_social'

--Insertando registros para prueba
exec socios.insertar_obra_social 'obraSocial1', '11111111'
exec socios.insertar_obra_social 'obraSocial2', '22222222'
exec socios.insertar_obra_social 'obraSocial3', '33333333'
exec socios.insertar_obra_social 'obraSocial4', '44444444'
--Se espera la eliminacion de los siguientes registros
exec socios.eliminar_obra_social 'obraSocial1'
exec socios.eliminar_obra_social 'obraSocial2'
exec socios.eliminar_obra_social 'obraSocial3'
exec socios.eliminar_obra_social 'obraSocial4'

--Se espera mensaje 'No existe una obra social con ese nombre.'
exec socios.eliminar_obra_social 'obraSocial1'


-- Limpiar datos de pruebas anteriores
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
go

-- /////////////// CATEGORIA ///////////////
/*****	socios.insertar_categoria 
		@nombre_categoria varchar(16), 
		@edad_minima int,
		@edad_maxima int, 
		@costo_membresia decimal(9,3), 
		@vigencia_hasta date	*****/

--Se espera la insercion exitosa de los siguientes registros
exec socios.insertar_categoria 'Menor', 1, 18, 9.69, '2025-12-31'
exec socios.insertar_categoria 'Cadete', 19, 27, 1.01, '2026-01-15'  
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'

/*
select c.id_categoria, c.nombre_categoria, c.edad_minima, c.edad_maxima,
       p.costo_membresia, p.fecha_vigencia_desde, p.fecha_vigencia_hasta
from socios.categoria c
inner join socios.categoria_precios p on c.id_categoria = p.id_categoria
order by c.id_categoria */

--Se espera mensaje 'Ya existe una categoría con ese nombre.'
exec socios.insertar_categoria 'Menor', 1, 18, 10.50, '2025-12-31'

--Se espera mensaje 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
exec socios.insertar_categoria 'Veterano', 5, 5, 10.6, '2025-12-31'
exec socios.insertar_categoria 'Sargento', 7, 5, 10.6, '2025-12-31'

--Se espera mensaje 'El costo de la membresia no puede ser negativo.'
exec socios.insertar_categoria 'Veterano', 36, 45, -1.99, '2025-12-31'

--Se espera mensaje sobre fecha de vigencia invalida
exec socios.insertar_categoria 'Veterano', 36, 45, 15.99, '2020-01-01'
go

/*****	socios.modificar_costo_categoria @id_categoria int, @costo_membresia decimal(9,3) *****/

exec socios.modificar_costo_categoria 1, 10.99  -- ID de 'Menor'
exec socios.modificar_costo_categoria 2, 20.99  -- ID de 'Cadete'

/*
select c.id_categoria, c.nombre_categoria, p.costo_membresia
from socios.categoria c
inner join socios.categoria_precios p on c.id_categoria = p.id_categoria
order by c.id_categoria*/

-- Se espera mensaje 'El nuevo costo de la membresia no puede ser negativo.'
exec socios.modificar_costo_categoria 1, -5.66

-- Se espera mensaje 'No existe una categoria con ese id.'
exec socios.modificar_costo_categoria 999, 10.69

go

/*****	socios.modificar_fecha_vigencia_categoria 
		@id_categoria int, @costo_membresia decimal(9,3), @vigencia_hasta date *****/

-- Se cambia de manera exitosa segun la nueva fecha de vigencia
exec socios.modificar_fecha_vigencia_categoria 1, 12.50, '2026-06-30'
exec socios.modificar_fecha_vigencia_categoria 2, 25.00, '2026-12-31'

/*
select c.id_categoria, c.nombre_categoria, p.costo_membresia, 
       p.fecha_vigencia_desde, p.fecha_vigencia_hasta
from socios.categoria c
inner join socios.categoria_precios p on c.id_categoria = p.id_categoria
order by c.id_categoria*/

-- Se espera mensaje 'La nueva fecha limite no puede ser menor a la actual'
exec socios.modificar_fecha_vigencia_categoria 1, 15.00, '2020-01-01'

-- Se espera mensaje 'El nuevo costo de la membresia no puede ser negativo'
exec socios.modificar_fecha_vigencia_categoria 1, -10.00, '2026-12-31'

-- Se espera mensaje 'No existe una categoría con ese id'
exec socios.modificar_fecha_vigencia_categoria 999, 20.00, '2026-12-31'
go

/******	socios.eliminar_categoria 
		@id_categoria int	*****/

--Se espera la eliminacion de los siguientes registros
exec socios.eliminar_categoria 1
exec socios.eliminar_categoria 2   
exec socios.eliminar_categoria 3

--Se espera mensaje 'No existe una categoría con ese id.'
exec socios.eliminar_categoria 999
go

-- Insertar datos para pruebas adicionales
exec socios.insertar_categoria 'TestCategoria', 18, 65, 50.00, '2025-12-31'

declare @precio decimal(9,3),
		@fecha_desde date, 
		@fecha_hasta date;

exec socios.obtener_precio_actual
	@id_categoria = 5,
	@precio_actual = @precio output,
	@fecha_vigencia_desde = @fecha_desde output,
	@fecha_vigencia_hasta = @fecha_hasta output

-- select @precio as precio, @fecha_desde as fecha_desde, @fecha_hasta as fecha_hasta

-- /////////////// SOCIO ///////////////
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

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'facturacion.pago'
exec eliminar_y_restaurar_tabla 'facturacion.factura'
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar'
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'socios.rol'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'

-- Crear los roles
insert into socios.rol (nombre, descripcion) values ('Usuario', 'Rol comun'), ('Admin', 'Administracion')

-- Creo los medios de pago
insert into facturacion.medio_de_pago (nombre_medio_pago) values ('Mercadopago'), ('Tarjeta')

-- Crear las obras sociales
insert into socios.obra_social (nombre_obra_social) values ('OSDE'), ('GALENO')

-- Crear las categorias por edad
insert into socios.categoria (edad_minima, edad_maxima, nombre_categoria) values (1, 17, 'menor'), (18, 64, 'adulto'), (65, 85, 'mayor')
go

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


-- /////////////// GRUPO FAMILIAR ///////////////
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
exec socios.insertar_grupo_familiar @id_socio_menor = 3, @id_responsable = 1;
go

/***** pruebas de socios.eliminar_grupo_familiar *****/

-- Eliminar una relacion que no existe, 'No existe una relación entre ese socio menor y ese responsable.'
exec socios.eliminar_grupo_familiar @id_socio_menor = 5, @id_responsable = 3;

-- Eliminar relacion de forma exitosa
exec socios.eliminar_grupo_familiar @id_socio_menor = 3, @id_responsable = 1;
go

-- /////////////// ACTIVIDAD ///////////////
/*****	actividades.insertar_actividad(@nombreActividad varchar(36),@costoMensual decimal(9,3))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar'
exec eliminar_y_restaurar_tabla 'actividades.actividad'

--Se espera la insercion exitosa de los siguientes registros
exec actividades.insertar_actividad 'Voley', 2.9, '2025-07-27'
exec actividades.insertar_actividad 'Baile', 9999.5, '2025-08-29'

--Se espera mensaje 'El costo de actividad no debe ser negativo'
exec actividades.insertar_actividad 'Futbol', -1.5, '2026-06-19'

--Se espera mensaje 'El nombre de la actividad extra ya existe'
exec actividades.insertar_actividad 'Baile', 1000, '2025-07-27'
exec actividades.insertar_actividad 'Voley', 2.9, '2025-08-29'

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'

/*****	actividades.eliminar_actividad(@id_actividad int)	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'

--Insertanto registros para la prueba
exec actividades.insertar_actividad 'Voley', 2.9, '2025-08-29'
exec actividades.insertar_actividad 'Baile', 9999.5, '2026-06-19'

--Se espera la eliminacion de los siguiente registros
exec actividades.eliminar_actividad 1
exec actividades.eliminar_actividad 2

--Se espera mensaje 'La actividad a eliminar no existe'
exec actividades.eliminar_actividad 1
exec actividades.eliminar_actividad 3

--Eliminando registros restantes de la prueba en la tabla
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'

/*****	actividades.modificar_precio_actividad(@id_actividad int, @nuevoPrecio decimal(9,3))	*****/

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'

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

--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
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

-- /////////////// HORARIO ACTIVIDADES ///////////////
/****actividades.insertar_horario_actividad****/

--Preparando tablas para la prueba
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria'


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

--Eliminando registros restantes de la tabla de pruebas
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
exec eliminar_y_restaurar_tabla 'socios.categoria'


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
--Preparando tablas para la prueba
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
exec eliminar_y_restaurar_tabla 'socios.categoria'
go

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


-- /////////////// INSCRIPCION ACTIVIDAD ///////////////
/********	actividades.inscripcion_actividad
			@id_socio int,
			@id_horario int,
			@id_actividad int)  ******/
--Preparando tabla para pruebas
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades'
exec eliminar_y_restaurar_tabla 'facturacion.factura'
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.rol'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'

--Insertanto registros para la prueba
declare @fechaDePrueba date = GETDATE();
exec socios.insertar_rol 'Cliente', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario3', @fechaDePrueba
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
exec actividades.insertar_horario_actividad 'Jueves', '18:00:00', '19:30:00', 3, 2
exec actividades.insertar_horario_actividad 'Martes', '19:00:00', '20:00:00', 2, 2

--Se deberían insertar con éxito los siguientes registros
exec actividades.inscripcion_actividad 1, 1, 1
exec actividades.inscripcion_actividad 1, 3, 2

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

--Eliminando registros restantes de la tabla de pruebas
exec eliminar_y_restaurar_tabla 'facturacion.pago'
exec eliminar_y_restaurar_tabla 'facturacion.factura'
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades'
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_act_extra'
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra'
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.rol'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'
go

-- /////////////// ACTIVIDAD EXTRA ///////////////
/****	actividades.inscripcion_actividad_extra
		@id_socio int,
		@id_actividad_extra int,
		@fecha date,
		@hora_inicio time,
		@hora_fin time,
		@cant_invitados int)  *****/

--Insertanto registros para la prueba
declare @fechaDePrueba date = GETDATE();
exec socios.insertar_rol 'Cliente', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario1', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario2', @fechaDePrueba
exec socios.insertar_usuario 1, 'passwordDeUsuario3', @fechaDePrueba
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

-- /////////////// FACTURA ///////////////
/*****  facturacion.crear_factura  
		@total decimal(9,3),
		@dni int,
		@actividad varchar(250)  *****/

-- Limpieza y preparación de las tablas necesarias
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_act_extra'
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades'
exec eliminar_y_restaurar_tabla 'facturacion.factura'
exec eliminar_y_restaurar_tabla 'socios.socio'
exec eliminar_y_restaurar_tabla 'socios.usuario'
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago'
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades'
exec eliminar_y_restaurar_tabla 'socios.categoria_precios'
exec eliminar_y_restaurar_tabla 'socios.categoria'
exec eliminar_y_restaurar_tabla 'socios.obra_social'
exec eliminar_y_restaurar_tabla 'socios.rol'

-- Inserción de datos requeridos para relaciones
exec socios.insertar_categoria 'Mayor', 28, 35, 0, '2025-08-30'
exec socios.insertar_rol 'Socio', 'Rol para socios comunes'
exec facturacion.insertar_medio_de_pago 'Tarjeta de crédito', 1
exec socios.insertar_obra_social 'OSDE', '1134225566'

-- Se espera inserción exitosa del socio
exec socios.insertar_socio 42838702, 'Juan', 'Roman', 'riquelme@mail.com', '2000-06-01', '1133445566', '1133445577', 1, 12, 1, 1, 1

-- Se espera que se cree correctamente una nueva factura
exec facturacion.crear_factura 10000.000, 42838702, 1

-- Se espera mensaje: 'El total a facturar no puede ser menor o igual a 0!'
exec facturacion.crear_factura 0.000, 42838702, 1

-- Se espera mensaje: 'El total a facturar no puede ser menor o igual a 0!'
exec facturacion.crear_factura -500.000, 42838702, 1

-- Se espera mensaje: 'No existe ningun individuo que posea ese DNI en el sistema'
exec facturacion.crear_factura 15000.000, 4521515, 999

/*****  facturacion.pago_factura 
		@id_factura int,
		@tipo_movimiento varchar(20),
		@id_medio_pago int  *****/

-- Limpieza y preparación de las tablas necesarias
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades';
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_act_extra';
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades';
exec eliminar_y_restaurar_tabla 'actividades.acceso_pileta';
exec eliminar_y_restaurar_tabla 'facturacion.pago';
exec eliminar_y_restaurar_tabla 'facturacion.factura';
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar';
exec eliminar_y_restaurar_tabla 'socios.socio';
exec eliminar_y_restaurar_tabla 'socios.usuario';
exec eliminar_y_restaurar_tabla 'socios.categoria_precios';
exec eliminar_y_restaurar_tabla 'socios.categoria';
exec eliminar_y_restaurar_tabla 'socios.obra_social';
exec eliminar_y_restaurar_tabla 'socios.rol';
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago';
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad';
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra';

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

-- Limpieza y preparación de las tablas necesarias
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades';
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_act_extra';
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades';
exec eliminar_y_restaurar_tabla 'actividades.acceso_pileta';
exec eliminar_y_restaurar_tabla 'facturacion.pago';
exec eliminar_y_restaurar_tabla 'facturacion.factura';
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar';
exec eliminar_y_restaurar_tabla 'socios.socio';
exec eliminar_y_restaurar_tabla 'socios.usuario';
exec eliminar_y_restaurar_tabla 'socios.categoria_precios';
exec eliminar_y_restaurar_tabla 'socios.categoria';
exec eliminar_y_restaurar_tabla 'socios.obra_social';
exec eliminar_y_restaurar_tabla 'socios.rol';
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago';
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad';

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

-- Limpieza y preparación de las tablas necesarias
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_actividades';
exec eliminar_y_restaurar_tabla 'actividades.inscripcion_act_extra';
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades';
exec eliminar_y_restaurar_tabla 'actividades.acceso_pileta';
exec eliminar_y_restaurar_tabla 'facturacion.pago';
exec eliminar_y_restaurar_tabla 'facturacion.factura';
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar';
exec eliminar_y_restaurar_tabla 'socios.socio';
exec eliminar_y_restaurar_tabla 'socios.usuario';
exec eliminar_y_restaurar_tabla 'socios.categoria_precios';
exec eliminar_y_restaurar_tabla 'socios.categoria';
exec eliminar_y_restaurar_tabla 'socios.obra_social';
exec eliminar_y_restaurar_tabla 'socios.rol';
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago';
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad';

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
exec actividades.inscripcion_actividad_extra 1,2,'2025-06-28','19:00:00','20:00:00',0
-- Se espera que no pueda inscribirse y reservar la actividad Sum porque ya esta reservada para ese dia
exec actividades.inscripcion_actividad_extra 1,2,'2025-06-28','19:00:00','20:00:00',0

-- PRUEBAS PARA LA PILETA
/***** actividades.inscribir_a_pileta
		@id_socio int,
		@es_invitado bit,
		@nombre_invitado varchar(40) = null,
		@apellido_invitado varchar(40) = null,
		@dni_invitado int = null,
		@edad_invitado int = null,
		@id_concepto int *****/

-- Limpieza de las tablas usadas por el SP
exec eliminar_y_restaurar_tabla 'actividades.horario_actividades';
exec eliminar_y_restaurar_tabla 'actividades.acceso_pileta';
exec eliminar_y_restaurar_tabla 'facturacion.pago';
exec eliminar_y_restaurar_tabla 'facturacion.factura';
exec eliminar_y_restaurar_tabla 'socios.grupo_familiar';
exec eliminar_y_restaurar_tabla 'socios.socio';
exec eliminar_y_restaurar_tabla 'socios.usuario';
exec eliminar_y_restaurar_tabla 'socios.categoria_precios';
exec eliminar_y_restaurar_tabla 'socios.categoria';
exec eliminar_y_restaurar_tabla 'socios.obra_social';
exec eliminar_y_restaurar_tabla 'socios.rol';
exec eliminar_y_restaurar_tabla 'facturacion.medio_de_pago';
exec eliminar_y_restaurar_tabla 'actividades.actividad_precios'
exec eliminar_y_restaurar_tabla 'actividades.actividad';
exec eliminar_y_restaurar_tabla 'actividades.actividad_extra';

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

--Se inserta una facturacion en un dia en el que llovio manualmente '2025-01-01',previamente se inserto el archivo de meteorologia 2025
insert into facturacion.factura (dni,fecha_emision,total,estado,nombre,apellido,servicio)
values(42838702,'2025-01-01',5000,'PAGADO','Juan','Roman','Pileta')
--Se espera que realice el reembolso de una factura pagada, en esa fecha, si llovio y si el dni es de socio
exec facturacion.descuento_pileta_lluvia '2025-01-01'


