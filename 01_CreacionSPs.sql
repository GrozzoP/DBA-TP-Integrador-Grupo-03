﻿/*
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, 
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla. 
Los nombres de los store procedures NO deben comenzar con “SP”.  
Algunas operaciones implicarán store procedures que involucran varias tablas, uso de 
transacciones, etc. Puede que incluso realicen ciertas operaciones mediante varios SPs. 
Asegúrense de que los comentarios que acompañen al código lo expliquen. 
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto 
en la creación de objetos. NO use el esquema “dbo”.  

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

-- ROL
-- Procedimiento para insertar un rol
create or alter procedure socios.insertar_rol(@nombre_rol varchar(20), @descripcion_rol varchar(50))
as
begin
	if exists(select 1 from socios.rol 
			where nombre = @nombre_rol)
	begin
		print 'El rol que se quiere insertar ya existe en la tabla.'
	end
	else
	begin
		insert into socios.rol(nombre, descripcion) values (@nombre_rol, @descripcion_rol)
	end
end
go

-- Procedimiento para modificar un rol
create or alter procedure socios.modificar_rol(@nombre_rol varchar(20), @nueva_descripcion_rol varchar(50))
as
begin
	if not exists(select 1 from socios.rol 
				where nombre = @nombre_rol)
	begin
		print 'El rol que se quiere modificar, no existe segun su nombre.'
	end
	else
	begin
		update socios.rol
		set descripcion = @nueva_descripcion_rol
		where nombre = @nombre_rol
	end
end
go

-- Procedimiento para eliminar un rol de la tabla
create or alter procedure socios.eliminar_rol(@nombre_rol varchar(20))
as
begin
	if not exists(select 1 from socios.rol 
				where nombre = @nombre_rol)
	begin
		print 'El rol que se quiere eliminar, no existe segun su nombre.'
	end
	else
	begin
		delete from socios.rol
		where nombre = @nombre_rol
	end
end
go

-- MEDIO DE PAGO
-- Procedimiento para insertar un medio de pago
create or alter procedure facturacion.insertar_medio_de_pago(@nombre_medio_de_pago varchar(40), @permite_debito_automatico BIT)
as
begin
	if exists(select 1 from facturacion.medio_de_pago
				where nombre_medio_pago = @nombre_medio_de_pago)
	begin
		print 'El medio de pago que se quiere agregar, ya existe.'
	end
	else
	begin
		insert into facturacion.medio_de_pago(nombre_medio_pago, permite_debito_automatico)
		values (@nombre_medio_de_pago, @permite_debito_automatico)
	end
end
go

-- Procedimiento para modificar un medio de pago
create or alter procedure facturacion.modificar_medio_de_pago(@nombre_medio_de_pago varchar(40))
as
begin
	if not exists(select 1 from facturacion.medio_de_pago
				where nombre_medio_pago = @nombre_medio_de_pago)
	begin
		print 'El medio de pago que se quiere modificar, no existe.'
	end
	else
	begin
		/* Como tenemos un campo de 'bit' y solo tiene dos valores posibles, si lo quiero modificar, simplemente
		   niego el bit actual vinculado con el habilitar */
		update facturacion.medio_de_pago
		set permite_debito_automatico = ~permite_debito_automatico
		where nombre_medio_pago = @nombre_medio_de_pago
	end
end
go

-- Procedimiento para eliminar un medio de pago en la tabla
create or alter procedure facturacion.eliminar_medio_de_pago(@nombre_medio_de_pago varchar(40))
as
begin
	if not exists(select 1 from facturacion.medio_de_pago
				where nombre_medio_pago = @nombre_medio_de_pago)
	begin
		print 'El rol que se quiere eliminar, no existe segun su nombre.'
	end
	else
	begin
		delete from facturacion.medio_de_pago
		where nombre_medio_pago = @nombre_medio_de_pago
	end
end
go

-- SOCIO
-- Funcion para crear una contraseña aleatoria para la cuenta del socio

-- Creo esta vista para poseer un valor aleatorio que me sea util para generar la contraseña
create or alter view vRandom
as
select valor_aleatorio = CRYPT_GEN_RANDOM(1000)
go

-- Crear funcion para generar contraseña de manera aleatoria
create or alter function socios.generar_contraseña_aleatoria(
	@longitud int
)
returns varchar(1000) as
begin
    declare @caracteres varchar(100),
			@index int,
			@password varchar(8000),
			@indice_random int,
			@maximo int,
			@valor_random tinyint,
			@bytes varbinary(1000)

	-- Almaceno en una varaible todos los caracteres que me interesan para conformar la contraseña
    set @caracteres = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
					+ 'abcdefghijklmnopqrstuvwxyz'
                    + '0123456789'
                    + '!@#$%?'

	-- Seteo el valor de la contraseña en una cadena vacia
    set @password = '';

	-- Que el indice empiece en 0
	set @index = 0

	-- Me marca hasta donde puedo acceder en la cadena @caracteres
	set @maximo = len(@caracteres)

	-- Elegir el valor aleatorio que retorno el CRYPT_GEN_RANDOM
	select @bytes = valor_aleatorio from vRandom

	-- Bucle para generar la contraseña de manera aleatoria
    while @index < @longitud
    begin
		-- Como no se puede usar NEWID() en una funcion, genero un numero aleatorio en base a crypt_gen_random
		set @valor_random = cast(substring(@bytes, @index, 1) as tinyint)

		-- Elijo un indice que este entre los caracteres de la variable @caracteres
        set @indice_random = (@valor_random % @maximo) + 1;

		--  Concateno el caracter encontrado con la contraseña
        set @password += substring(@caracteres, @indice_random, 1);
        set @index  += 1;
    end

    return @password;
end
go

-- Procedimiento para insertar un socio
create or alter procedure socios.insertar_socio
	@dni int,
	@nombre varchar(40),
	@apellido varchar(40),
	@email varchar(150),
	@fecha_nacimiento date,
	@telefono_contacto char(18),
	@telefono_emergencia char(18),
	@id_obra_social int,
	@nro_socio_obra_social varchar(40),
	@id_medio_de_pago int,
	@id_rol int,
	@id_responsable_menor int = 0,
	@parentesco varchar(15) = ''
as
begin
	set nocount on;

	declare @edad int = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE());

	if (DATEADD(YEAR, @edad, @fecha_nacimiento) > GETDATE())
	begin
        SET @edad = @edad - 1
	end

	if exists (select 1 from socios.socio 
			   where dni = @dni)
	begin
		print 'Ya existe un socio con ese dni.'
	end

	-- Buscar si existe id_obra_social
	else if not exists (select 1 from socios.obra_social 
					where id_obra_social = @id_obra_social)
	begin
		print 'No existe una obra social con ese id.'
	end

	-- Buscar si existe id_rol
	else if not exists (select 1 from socios.rol 
					where id_rol = @id_rol)
	begin
		print 'No existe un rol con ese id.'
	end

	-- Buscar si existe id_medio_de_pago
	else if not exists (select 1 from facturacion.medio_de_pago 
					where id_medio_de_pago = @id_medio_de_pago)
	begin
		print 'No existe un medio de pago con esa id.'
	end

	else if (@edad < 18 AND NOT EXISTS (
			select 1 from socios.socio
			where id_socio = @id_responsable_menor))
	begin
		print 'El socio al ser menor de edad, debe estar vinculado con un responsable ya registrado.'
	end

	else
	begin
		declare @usuario varchar(83),
				@contraseña varchar(16),
				@id_usuario int,
				@responsable_menor int,
				@id_categoria int,
				@nuevo_id_socio int

		-- Generar un usuario y una contraseña de manera automatica
		 set @usuario = @nombre + '_' + @apellido + CAST(RIGHT(@dni, 2) as varchar)
		 select @contraseña = socios.generar_contraseña_aleatoria(16)

		 -- Enviar al mail esta informacion (usuario, contraseña)
		 insert into socios.usuario (usuario, contraseña, fecha_vigencia_contraseña, id_rol)
		 values (@usuario, @contraseña,  DATEADD(DAY, 7, GETDATE()), @id_rol)

		 -- Insertar el socio teniendo en cuenta la creacion del usuario
		 select @id_usuario = id_usuario from socios.usuario where usuario = @usuario

		 -- Elegimos la categoria segun la edad del socio
		 select @id_categoria = @id_categoria from socios.categoria
		 where @edad BETWEEN edad_minima AND edad_maxima

		 insert into socios.socio
		 (dni, nombre, apellido, email, fecha_nacimiento, telefono_contacto, telefono_emergencia, habilitado,
		 id_obra_social, nro_socio_obra_social, id_categoria, id_usuario, id_medio_de_pago)
		 values (@dni, @nombre, @apellido, @email, @fecha_nacimiento, @telefono_contacto, @telefono_emergencia, 'HABILITADO',
		 @id_obra_social, @nro_socio_obra_social, @id_categoria, @id_usuario, @id_medio_de_pago)

		 set @nuevo_id_socio = SCOPE_IDENTITY();

		 if(@edad < 18)
		 begin
			insert into socios.grupo_familiar (id_responsable, id_socio_menor, parentesco)
			values (@id_responsable_menor, 
					@nuevo_id_socio, 
					@parentesco)
		 end

		 print 'Se ha creado de manera automatica una cuenta para que disfrutes de los servicios de los socios!'
	end
end
go

-- Procedimiento para modificar el estado de un socio
create or alter procedure socios.modificar_habilitar_socio
	@id_socio int
as
begin
	if not exists (select 1 from socios.socio 
					where id_socio = @id_socio)
	begin
		print 'No existe un socio con ese id.'
	end
	else
	begin
		update socios.socio
		set habilitado =
			case
				when habilitado = 'HABILITADO' THEN 'NO HABILITADO'
				else 'HABILITADO'
			end
		where id_socio = @id_socio
	end
end
go

-- Procedimiento para eliminar un socio (mediante borrado logico)
create or alter procedure socios.eliminar_socio
	@DNI int
as
begin
	set nocount on

	if not exists (select 1 from socios.socio 
					where DNI = @DNI)
	begin
		print 'No existe un socio con ese dni.'
	end
	else
	begin
		-- Borrado logico
		update socios.socio 
		set habilitado = 'NO HABILITADO'
		where DNI = @DNI
	end
end
go

-- USUARIO
-- Procedimiento para insertar un usuario
create or alter procedure socios.insertar_usuario
	@id_rol int,
	@contraseña varchar(40),
	@fecha_vigencia_contraseña date
as
begin
	
	if not exists (select 1 from socios.rol 
					where id_rol = @id_rol)
	begin
		print 'No existe un rol con ese id.'
	end
	else if(@contraseña is null)
	begin
		print 'La contraseña no puede ser nula o vacia'
	end
	else if (CONVERT(date, GETDATE()) > @fecha_vigencia_contraseña)
	begin
		print 'La fecha de vigencia no puede ser anterior a la actual.'
	end
	else
	begin
		insert into socios.usuario(id_rol, contraseña, fecha_vigencia_contraseña)
		values (@id_rol, @contraseña, @fecha_vigencia_contraseña)
	end
end
go

-- Procedimiento para modificar la contraseña del usuario
create or alter procedure socios.modificar_contraseña_usuario
	@id_usuario int,
	@contraseña varchar(40)
as
begin
	if not exists (select 1 from socios.usuario 
					where id_usuario = @id_usuario)
	begin
		print 'No existe un usuario con ese id.'
	end
	else if(@contraseña is null)
	begin
		print 'La contraseña no puede ser nula o vacia'
	end
	else
	begin
		update socios.usuario
		set contraseña = @contraseña
		where id_usuario = @id_usuario
	end
end
go

-- Procedimiento para modificar la fecha de vigencia de la contraseña
create or alter procedure socios.modificar_fecha_vigencia_usuario
	@id_usuario int,
	@fecha_vigencia_contraseña date
as
begin
	if not exists (select 1 from socios.usuario 
					where id_usuario = @id_usuario)
	begin
		print 'No existe un usuario con ese id.'
	end
	else
	begin
		if (CONVERT(date, GETDATE()) < @fecha_vigencia_contraseña)
		begin
			update socios.usuario
			set fecha_vigencia_contraseña = @fecha_vigencia_contraseña
			where id_usuario = @id_usuario
		end
		else
		begin
			print 'La fecha de vigencia no puede ser anterior a la actual.'
		end
	end
end
go

-- Procedimiento para eliminar usuarios
create or alter procedure socios.eliminar_usuario
	@id_usuario int
as
begin
	if not exists (select 1 from socios.usuario 
					where id_usuario = @id_usuario)
	begin
		print 'No existe un usuario con ese id.'
	end
	else
	begin
		delete from socios.usuario
		where id_usuario = @id_usuario
	end
end
go

-- OBRA SOCIAL
-- Procedimiento para insertar una obra social
create or alter procedure socios.insertar_obra_social
	@nombre_obra_social varchar(60),
	@telefono_obra_social char(18)
as
begin
	if exists (select 1 from socios.obra_social 
				where nombre_obra_social = @nombre_obra_social)
	begin
		print 'Ya existe una obra social con ese nombre.'
	end
	else
	begin
		insert into socios.obra_social(nombre_obra_social, telefono_obra_social)
		values (@nombre_obra_social, @telefono_obra_social)
	end
end
go

-- Procedimiento para modificar una obra social
create or alter procedure socios.modificar_obra_social
	@nombre_obra_social varchar(60),
	@telefono_obra_social char(18)
as
begin
    if (@nombre_obra_social is null)
    begin
        print 'El nombre de la obra social no puede ser nulo o vacío.'
    end

    -- Si el telefono es nulo
    else if (@telefono_obra_social is null or ltrim(rtrim(@telefono_obra_social)) = '')
    begin
        print 'El numero de telefono no puede ser nulo o vacio.'
    end

    -- Verificar si existe el nombre de la obra social
    else if not exists (
        select 1 from socios.obra_social
        where nombre_obra_social = @nombre_obra_social
    )
    begin
        print 'No existe una obra social con ese nombre.'
    end

    -- Que el numero tenga una longitud minima
    else if (len(replace(@telefono_obra_social, ' ', '')) < 8)
    begin
        print 'El numero de telefono es muy corto.'
    end

    -- Si se llego hasta aca, se actualiza
    else
    begin
        update socios.obra_social
        set telefono_obra_social = @telefono_obra_social
        where nombre_obra_social = @nombre_obra_social

        print 'La obra social fue actualizada correctamente.'
    end
end
go

-- Procedimiento para eliminar una obra social
create or alter procedure socios.eliminar_obra_social
	@nombre_obra_social varchar(60)
as
begin
	if not exists (select 1 from socios.obra_social 
					where nombre_obra_social = @nombre_obra_social)
	begin
		print 'No existe una obra social con ese nombre.'
	end
	else
	begin
		delete from socios.obra_social
		where nombre_obra_social = @nombre_obra_social
	end
end
go

-- CATEGORIA
-- Procedimiento para crear una categoria
create or alter procedure socios.insertar_categoria
	@nombre_categoria varchar(16),
	@edad_minima int,
	@edad_maxima int,
	@costo_membresia decimal(9,3),
	@vigencia_hasta date
as
begin
	set nocount on

	if exists (select 1 from socios.categoria 
				where nombre_categoria = @nombre_categoria)
	begin
		print 'Ya existe una categoría con ese nombre.'
	end

	else if (@edad_minima >= @edad_maxima)
	begin
		print 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
	end

	else if (@costo_membresia < 0)
	begin
		print 'El costo de la membresia no puede ser negativo.'
	end

	else
	begin
		declare @id_categoria_nueva int

		-- Insertar la categoria
		insert into socios.categoria(nombre_categoria, edad_minima, edad_maxima)
		values (@nombre_categoria, @edad_minima, @edad_maxima)
			
		set @id_categoria_nueva = SCOPE_IDENTITY()
			
		-- Insertar el monto en los precios de las categorias
		insert into socios.categoria_precios(id_categoria, fecha_vigencia_desde, fecha_vigencia_hasta, costo_membresia)
		values (@id_categoria_nueva, GETDATE(),  @vigencia_hasta, @costo_membresia)
	end
end
go

-- Procedimiento para modificar el costo de una cateogira
create or alter procedure socios.modificar_costo_categoria
	@id_categoria int,
	@costo_membresia decimal(9,3)
as
begin
	set nocount on

	if not exists (select 1 from socios.categoria where id_categoria = @id_categoria)
	begin
		print 'No existe una categoría con ese id.'
	end
	else if @costo_membresia < 0
	begin
		print 'El nuevo costo de la membresia no puede ser negativo.'
	end
	else
	begin
		update socios.categoria_precios
		set costo_membresia = @costo_membresia
		where id_categoria = @id_categoria
	end
end
go

-- Procedimiento para modificar la fecha de vigencia de una cateogira
create or alter procedure socios.modificar_fecha_vigencia_categoria
	@id_categoria int,
	@costo_membresia decimal(9,3),
	@vigencia_hasta date
as
begin
	set nocount on

	if not exists (select 1 from socios.categoria where id_categoria = @id_categoria)
	begin
		print 'No existe una categoría con ese id.'
	end
	else if @costo_membresia < 0
	begin
		print 'El nuevo costo de la membresia no puede ser negativo.'
	end
	else if(@vigencia_hasta < GETDATE())
	begin
		print 'La nueva fecha limite no puede ser menor a la actual'
	end
	else
	begin
		update socios.categoria_precios
		set fecha_vigencia_hasta = @vigencia_hasta,
			costo_membresia = @costo_membresia
		where id_categoria = @id_categoria
	end
end
go

-- Procedimiento para eliminar una categoria
create or alter procedure socios.eliminar_categoria
	@id_categoria int
as
begin
	if not exists (select 1 from socios.categoria 
					where id_categoria = @id_categoria)
	begin
		print 'No existe una categoría con ese nombre.'
	end
	else
	begin
		delete from socios.categoria_precios
		where id_categoria = @id_categoria

		delete from socios.categoria
		where id_categoria = @id_categoria
	end
end
go

-- Obtener el precio actual de la cuota de un socio dada una id
create or alter procedure socios.obtener_precio_actual
    @id_categoria int,
    @precio_actual decimal(9,3) output,
    @fecha_vigencia_desde date output,
    @fecha_vigencia_hasta date output
as
begin
    set nocount on;
    
    select 
        @precio_actual = costo_membresia,
        @fecha_vigencia_desde = fecha_vigencia_desde,
        @fecha_vigencia_hasta = fecha_vigencia_hasta
    from socios.categoria_precios
    where id_categoria = @id_categoria
	/*
      and fecha_vigencia_desde <= getdate()
      and (fecha_vigencia_hasta is null or fecha_vigencia_hasta >= getdate())*/
    order by fecha_vigencia_desde desc;
    
    -- En el caso de no encontrar una coincidencia, selecciono valores por default
    if @precio_actual is null
    begin
        set @precio_actual = 0;
        set @fecha_vigencia_desde = null;
        set @fecha_vigencia_hasta = null;
    end
end
go

-- GRUPO FAMILIAR
-- Insertar un grupo familiar
create or alter procedure socios.insertar_grupo_familiar
	@id_socio_menor int,
	@id_responsable int,
	@parentesco varchar(15) = 'Familiar'
as
begin
	set nocount on;

	if exists(select 1 from socios.socio
			  where id_socio = @id_responsable)
	begin
		declare @fecha_nacimiento_responsable date,
				@fecha_nacimiento_menor date,
				@edad_responsable int,
				@edad_menor int;

		-- Obtener fecha nacimiento responsable
		select @fecha_nacimiento_responsable = fecha_nacimiento
		from socios.socio where id_socio = @id_responsable;

		set @edad_responsable = DATEDIFF(YEAR, @fecha_nacimiento_responsable, GETDATE());

		if (DATEADD(YEAR, @edad_responsable, @fecha_nacimiento_responsable) > GETDATE())
		begin
			set @edad_responsable = @edad_responsable - 1;
		end

		if @edad_responsable < 18
		begin
			print 'El socio responsable no puede ser menor de edad.';
			return;
		end
		else
		begin
			-- Verificar existencia del menor
			if not exists (select 1 from socios.socio where id_socio = @id_socio_menor)
			begin
				print 'No existe un socio menor con ese id.';
				return;
			end

			-- Obtener fecha nacimiento menor
			select @fecha_nacimiento_menor = fecha_nacimiento
			from socios.socio where id_socio = @id_socio_menor

			set @edad_menor = DATEDIFF(YEAR, @fecha_nacimiento_menor, GETDATE());

			if (DATEADD(YEAR, @edad_menor, @fecha_nacimiento_menor) > GETDATE())
			begin
				set @edad_menor = @edad_menor - 1
			end

			if @edad_menor >= 18
			begin
				print 'El socio menor no es menor de edad.'
				return
			end

			-- Verificar si ya existe la relación
			if exists (
				select 1 
				from socios.grupo_familiar 
				where id_socio_menor = @id_socio_menor 
				  and id_responsable = @id_responsable
			)
			begin
				print 'Ya existe una relación entre este menor y este responsable.'
				return
			end

			-- Insertar relación
			insert into socios.grupo_familiar (id_socio_menor, id_responsable, parentesco)
			values (@id_socio_menor, @id_responsable, @parentesco)

			print 'Grupo familiar insertado correctamente.'
		end
	end
	else
	begin
		print 'No existe un socio responsable con ese id.'
	end
end
go

-- Eliminar un grupo familiar
create or alter procedure socios.eliminar_grupo_familiar
	@id_socio_menor int,
	@id_responsable int
as
begin
	if exists (
		select 1 
		from socios.grupo_familiar
		where id_socio_menor = @id_socio_menor 
		  and id_responsable = @id_responsable
	)
	begin
		delete from socios.grupo_familiar
		where id_socio_menor = @id_socio_menor 
		and id_responsable = @id_responsable
	end
	else
	begin
		print 'No existe una relación entre ese socio menor y ese responsable.'
	end
end
go

-- PROCEDIMIENTO DE CREACION ALEATORIA 
-- ROL
create or alter procedure socios.carga_aleatoria_rol
	@cantidad int
as
begin
	-- Para no llenar la consola de mensajes debido a las inserciones
	set nocount on

	-- Indice para el while
	declare @index int,
			@random int,
			@nombre_rol varchar(8),
			@descripcion_rol varchar(50);
	set @index = 1;

	-- Creo una tabla que posea descripciones para roles
	declare @Descripcion table (descripcion varchar(50));
	insert into @Descripcion (descripcion)
	values ('Usuario mas comun del sistema'),
        ('Moderador de la aplicacion'),
        ('Moderador de usuarios'), 
        ('Supervisor de seguridad'),
        ('Administrador de la aplicacion'),
        ('Operador de soporte técnico'),
		('Invitado de uno o mas socios');

	while @index <= @cantidad
	begin
		begin try
			-- Elegir de manera aleatoria el nombre del rol: Rol_####
			set @random = ABS(CHECKSUM(NEWID())) % 10000;
			set @nombre_rol = 'Rol_' + CAST(@random as varchar)

			-- Verificar que el nombre generado de forma aleatoria, no existe dentro de la tabla
			if not exists(
				select 1 from socios.rol where nombre = @nombre_rol
			)
			begin

				-- Seleccionar una descripcion aleatoria insertada en la tabla temporal creada
				select top 1 @descripcion_rol = descripcion from @Descripcion order by NEWID();

				-- Una vez seleccionados los dos valores, se insertan en la tabla
				insert into socios.rol(nombre, descripcion)
				values (@nombre_rol, @descripcion_rol)

				-- Aumentar el indice del while, solo se aumenta si se encontro un nombre de rol nuevo
				set @index = @index + 1
			end
		end try
		begin catch
			print 'Error en la carga de datos aleatorios: ' + ERROR_MESSAGE()
		end catch
	end

	print 'Se han generado los roles de manera aleatoria!'
end
go

-- CATEGORIA
create or alter procedure socios.carga_aleatoria_categoria
	@cantidad int
as
begin
	set nocount on

	declare @index int = 1,
			@random int,
			@nombre_categoria varchar(16),
			@edad_minima int,
			@edad_maxima int,
			@costo_membresia decimal(9,3),
			@id_categoria_nueva int

	while @index <= @cantidad
	begin
		begin try
			-- Generar un nombre de categoria aleatorio
			set @random = ABS(CHECKSUM(NEWID()));
			set @nombre_categoria = 'Categoria_' + CAST(@random % 10000 as varchar)

			if not exists(select 1 from socios.categoria
								where nombre_categoria = @nombre_categoria)
				begin
				-- Edad minima aleatoria entre 4 y 12 años
				set @edad_minima = (@random % (12 - 4 + 1)) + 4;

				-- Edad maxima aleatoria entre 80 y 13 años
				set @edad_maxima = (@random % (80 - 13 + 1)) + 13;

				-- Establecer el costo de la categoria
				set @costo_membresia = ROUND(RAND(@random) * (10000), 2)

				-- Una vez creados los valores, se insertan en la tabla
				insert into socios.categoria(nombre_categoria, edad_minima, edad_maxima)
				values (@nombre_categoria, @edad_minima, @edad_maxima)

				set @id_categoria_nueva = SCOPE_IDENTITY()

				insert into socios.categoria_precios(id_categoria, fecha_vigencia_desde, fecha_vigencia_hasta, costo_membresia)
				values (@id_categoria_nueva, GETDATE(), 
						dateadd(day, abs(checksum(newid())) % 30, getdate()), @costo_membresia)

				-- Aumentar indice solo si el nombre de categoria no existe en la tabla
				set @index = @index + 1
			end
		end try
		begin catch
			print 'Error en la carga de datos aleatorios: ' + ERROR_MESSAGE()
		end catch
	end
	print 'Se han generado las categorias de manera aleatoria!'
end
go

-- ACTIVIDAD
-- Obtener el precio actual de una actividad dada una id
create or alter procedure actividades.obtener_precio_actividad
    @id_actividad int,
    @costo_mensual decimal(9,3) output,
    @vigencia_hasta date output
as
begin
    set nocount on;

    -- Buscar la tarifa vigente actual
    select top 1
        @costo_mensual = costo_mensual,
        @vigencia_hasta = vigencia_hasta
    from actividades.actividad_precios
    where id_actividad = @id_actividad
      and (vigencia_hasta is null or vigencia_hasta >= getdate())
    order by vigencia_hasta desc;

    -- Si no encontró un precio valido, se asignan valores por defecto
    if @costo_mensual is null
    begin
        set @costo_mensual = 0;
        set @vigencia_hasta = null;
    end
end
go

--- Procedimiento para insertar una actividad
create or alter procedure actividades.insertar_actividad
    @nombreActividad varchar(36),
    @costoMensual decimal(9, 3),
    @vigencia_hasta date = null
as
begin
  
   if exists(
      select nombre_actividad from actividades.actividad
	  where nombre_actividad = @nombreActividad
   )begin
       print 'El nombre de la actividad ya existe'
    end
	else if(@costoMensual < 0)
	begin
		print 'El costo de actividad no debe ser negativo'
	end
	else
	 begin
		declare @id_actividad int;

		insert into actividades.actividad(nombre_actividad)
		values(@nombreActividad);

		set @id_actividad = scope_identity();

		insert into actividades.actividad_precios(id_actividad, costo_mensual, vigencia_desde, vigencia_hasta)
		values(@id_actividad, @costoMensual, getdate(), @vigencia_hasta);
	 end

end
go

---Procedimiento para eliminar una actividad
create or alter procedure actividades.eliminar_actividad(@id_actividad int)
as
begin
    if not exists (
        select 1 from actividades.actividad
        where id_actividad = @id_actividad
    )
    begin
        print 'La actividad a eliminar no existe'
        return
    end

    delete from actividades.actividad_precios
    where id_actividad = @id_actividad;

    delete from actividades.actividad
    where id_actividad = @id_actividad;
end
go

--Procedimiento para modificar una actividad
create or alter procedure actividades.modificar_precio_actividad
    @id_actividad int,
    @nuevoPrecio decimal(9,3),
    @nueva_vigencia date = null
as
begin
    if not exists (
        select 1 from actividades.actividad
        where id_actividad = @id_actividad
    )
    begin
        print 'La actividad a modificar no existe'
        return
    end

    if @nuevoPrecio <= 0
    begin
        print 'El nuevo costo de actividad no puede ser negativo o cero!'
        return
    end

    insert into actividades.actividad_precios(id_actividad, costo_mensual, vigencia_desde, vigencia_hasta)
    values(@id_actividad, @nuevoPrecio, getdate(), @nueva_vigencia);
end
go

-- Procedimiento para insertar una actividad extra
create or alter procedure actividades.insertar_actividad_extra(@nombreActividad varchar(36),@costo decimal(9,3))
as
begin
  
   if exists(
      select nombre_actividad from actividades.actividad_extra
	  where nombre_actividad = @nombreActividad
   )begin
       print 'El nombre de la actividad extra ya existe'
    end
	else if @costo < 0
	begin
		print 'El costo de la actividad extra no puede ser negativa'
	end
	else
	 begin
	    insert into actividades.actividad_extra(nombre_actividad, costo)values(@nombreActividad, @costo)
	 end

end
go

-- Procedimiento para eliminar una actividad extra
create or alter procedure actividades.eliminar_actividad_extra(@id_actividad_extra int)
as
begin
  
   if exists(
      select id_actividad from actividades.actividad_extra
	  where id_actividad = @id_actividad_extra
   )begin
       delete actividades.actividad_extra
	   where id_actividad = @id_actividad_extra
    end
	else
	 begin
	    print 'La actividad extra a eliminar no existe'
	 end

end
go

-- Procedimiento para modificar el precio a una actividad extra
create or alter procedure actividades.modificar_precio_actividad_extra(@id_actividad_extra int, @nuevoPrecio decimal(9,3))
as
begin

   if exists(
      select id_actividad from actividades.actividad_extra
	  where id_actividad = @id_actividad_extra
   )begin
	if @nuevoPrecio > 0
	begin
       update actividades.actividad_extra
	   set costo = @nuevoPrecio
	   where id_actividad = @id_actividad_extra
	end
	else
	begin
		print 'El nuevo costo de actividad extra no puede ser negativo'
	end
    end
	else
	 begin
	    print 'La actividad extra a modificar no existe'
	 end
end
go

-- Procedimiento para insertar un horario
create or alter procedure actividades.insertar_horario_actividad 
		@dia_semana varchar(18),
		@hora_inicio time,
		@hora_fin time,
		@id_actividad int,
		@id_categoria int
as
begin
       if exists(
	     select id_actividad from actividades.actividad
	     where id_actividad = @id_actividad
	   )begin
	       if exists(
		        select id_categoria from socios.categoria
				where id_categoria = @id_categoria
		   )begin
		       if(
			       @dia_semana like 'Lunes' or
				        @dia_semana like 'Martes' or
						     @dia_semana like'Miercoles' or 
								 @dia_semana like'Jueves' or 
									  @dia_semana like'Viernes' or 
										    @dia_semana like'Sabado' or
											    @dia_semana like  'Domingo')
			    begin
			      insert into actividades.horario_actividades(dia_semana,hora_inicio,hora_fin,id_actividad,id_categoria)
				  values (@dia_semana,@hora_inicio,@hora_fin,@id_actividad,@id_categoria)
			    end
				else
				begin
				   print 'El dia no es correcto'
				end
		       
		    end
			else
			begin
			   print 'No se encontro la categoria con ese id'
			end
	    end
		else
		begin
		  print 'No se encontro la actividad con ese id'
		end
end
go

-- Procedimiento para eliminar un horario
create or alter procedure actividades.eliminar_horario_actividad(@id_horario int)
as
begin
   if exists(
      select id_horario from actividades.horario_actividades
	  where id_horario = @id_horario
   )begin
         delete actividades.horario_actividades
		 where id_horario = @id_horario
    end
	else
	begin
	     print 'No existe una actividad con ese id'
	end
end
go

-- Procedimiento para modificar un horario
create or alter procedure actividades.modificar_horario_actividad 
        @id_horario int,
		@dia_semana varchar(18),
		@hora_inicio time,
		@hora_fin time,
		@id_actividad int,
		@id_categoria int
as
begin
   if exists(
      select id_horario from actividades.horario_actividades
	  where id_horario = @id_horario
   )
   begin 
       if exists(
	     select id_actividad from actividades.actividad
	     where id_actividad = @id_actividad
	   )begin
	       if exists(
		        select id_categoria from socios.categoria
				where id_categoria = @id_categoria
		   )begin
		       if(
			       @dia_semana like 'Lunes' or
				        @dia_semana like 'Martes' or
						     @dia_semana like'Miercoles' or 
								 @dia_semana like'Jueves' or 
									  @dia_semana like'Viernes' or 
										    @dia_semana like'Sabado' or
											    @dia_semana like  'Domingo')
			    begin
			      update actividades.horario_actividades
				  set dia_semana = @dia_semana,
				      hora_inicio = @hora_inicio,
					  hora_fin = @hora_fin,
					  id_categoria = @id_categoria,
					  id_actividad = @id_actividad
					  where id_horario = @id_horario
			    end
				else
				begin
				   print 'El dia no es correcto'
				end
		       
		    end
			else
			begin
			   print 'No se encontro la categoria con ese id'
			end
	    end
		else
		begin
		  print 'No se encontro la actividad con ese id'
		end
	end
	else
	begin
	  print 'No se encontro horario con ese id'
	end
end
go

-- Funcion para validar CUIT
create or alter function facturacion.validar_CUIT (@cuit varchar(13))
returns bit
as
begin
	declare @verificador int
	declare @resultado int = 0
	declare @cuit_nro varchar(11)
	declare @validacion bit
	declare @codes varchar(10) = '6789456789'

	declare @x int = 0

	while @x < 10
	begin
		declare @digitoValidador int = convert(int, substring(@codes, @x + 1, 1))
		declare @digito int = convert(int, substring(@cuit_nro, @x + 1, 1))
		declare @digitoValidacion int = @digitoValidador * @digito

		set @resultado = @resultado + @digitoValidacion
		set @x = @x + 1
	end

	set @resultado = @resultado % 11

	if @resultado = @verificador
	begin
		set @validacion = 1
	end
	else
	begin
		set @validacion = 0
	end

	return @validacion
end
go

-- Obtener el cuit en base al dni
create or alter function facturacion.obtener_dni_del_cuit
	(@cuit varchar(11))
returns int
as
begin
	if(len(@cuit) <> 11 or @cuit like '%[^0-9]%')
		return null
	
	return cast(substring(@cuit, 3, 8) as int)
end
go

--Procedimiento para generar una factura
create or alter procedure facturacion.crear_factura(@total decimal(9,3), @dni int, @actividad varchar(250))
as
begin

    if(@total <= 0)
    begin
        print 'El total a facturar no puede ser menor o igual a 0!'
        return
    end

    declare @nombre varchar(40),
            @apellido varchar(40)

    -- Busco el nombre y apellido de un socio con ese dni
    select @nombre = nombre,
           @apellido = apellido
    from socios.socio
    where dni = @dni;

	-- En caso de no existir un socio con ese dni, busco en invitados
    if @nombre is null or @apellido is null
    begin
        select @nombre = nombre,
               @apellido = apellido
        from actividades.invitado_pileta
        where dni = @dni;
    end

    -- Si no se pudo encontrar el nombre y apellido ni en socios ni en invitados, se dice que el DNI es invalido
    if @nombre is null or @apellido is null
    begin
        print 'No existe ningun individuo que posea ese DNI en el sistema'
        return
    end

    -- Insertar la factura con los datos brindados, ya sea de un socio o un invitado
    insert into facturacion.factura(fecha_emision, primer_vto, segundo_vto, total, total_con_recargo,
                                    estado, dni, nombre, apellido, servicio)
    values(getdate(), dateadd(day, 5, getdate()), dateadd(day, 10, getdate()), @total,
           @total + (@total * 0.1), 'NO PAGADO', @dni, @nombre, @apellido, @actividad);
end
go

-- Procedimiento encargado de descontar el saldo del usuario en caso de que pague con saldo de su cuenta
create or alter procedure facturacion.descuento_saldo_usuario
(@id_socio int, @monto decimal(9,3))
as
begin
    declare @monto_total int = 0
    declare @id_usuario int
	set @id_usuario = (
	   select id_usuario from socios.socio
	   where id_socio = @id_socio
	)
	declare @saldo_usuario decimal(9,3)
	set @saldo_usuario = (
	    select saldo from socios.usuario
		where id_usuario = @id_usuario
	)
	if(@saldo_usuario > 0)
	begin
	   set @monto_total = @monto - @saldo_usuario
	   if(@monto_total > 0)
	   begin
	       update socios.usuario
		   set saldo = 0
		   where id_usuario = @id_usuario
	   end
	   else
	   begin
	       set @monto_total = @saldo_usuario - @monto

		   update socios.usuario
		   set saldo = @monto_total
		   where id_usuario = @id_usuario
	   end    
	end
end
go

-- Procedimiento que realiza el descuento del 10% si el socio ya participa en alguna actividad
create or alter procedure facturacion.descuento_actividad(@id_socio int, @monto_actividad decimal(9,3) OUTPUT)
as
begin
   SET NOCOUNT ON

   declare @cantidad int 
   set @cantidad = (
    select COUNT(id_socio) from actividades.inscripcion_actividades
    group by id_socio
    having id_socio = @id_socio
   )
   if(@cantidad > 1)
   begin
       set @monto_actividad = @monto_actividad - (@monto_actividad*0.1)
	   return @monto_actividad
   end
   else
   begin
       return @monto_actividad
   end
end
go

-- Procedimiento para inscribirse a una actividad
create or alter procedure actividades.inscripcion_actividad(@id_socio int, @id_horario int, @id_actividad int)
as
begin
    if exists(
		select id_horario from actividades.horario_actividades
		where id_horario = @id_horario
	)
	begin
		if exists(
			    select id_actividad from actividades.horario_actividades
				where id_actividad = @id_actividad
		)
		begin
			    if exists(
				    select 1 from actividades.horario_actividades
					where id_actividad = @id_actividad and id_horario = @id_horario
				)
				begin
					if exists(
							  select 1 from socios.socio
							  where id_socio = @id_socio
					)
						begin
						declare @DNI int = (select DNI
						from socios.socio
						where id_socio = @id_socio)

						-- Generacion del monto
						declare @monto decimal(9,3)

						select top 1 @monto = costo_mensual
						from actividades.actividad_precios
						where id_actividad = @id_actividad
							and (vigencia_hasta is null or vigencia_hasta >= getdate())
						order by vigencia_hasta desc;

						if @monto is null
						begin
							print 'No hay un precio vigente para esta actividad'
							return
						end

						-- Inscripcion
						insert into actividades.inscripcion_actividades(id_socio,id_horario,id_actividad)
						values(@id_socio,@id_horario,@id_actividad)
					   
						declare @actividadInsertar varchar(250)
						set @actividadInsertar = (
							select nombre_actividad from actividades.actividad
							where id_actividad = @id_actividad
						)
					   
						-- Generacion del descuento
						exec facturacion.descuento_actividad @id_socio, @monto OUTPUT
						-- Generacion de factura
						exec facturacion.crear_factura @monto, @DNI, @actividadInsertar
					end
					else
					begin
						print 'No se encontro un socio con ese id'
					end
				end
				else
				begin
				    print 'No se encontro un horario para esa actividad'
				end
		end
		else
		begin
			print 'No se encontro una actividad con ese id'
		end
	end
	else
	begin
		print 'No se encontro un horario con ese id'
	end
end
go

-- Procedimiento para eliminar la inscripcion de un socio a una actividad
create or alter procedure actividades.eliminar_inscripcion_actividad(@id_inscripcion int)
as
begin
	if exists(
		select id_inscripcion from actividades.inscripcion_actividades
		where id_inscripcion = @id_inscripcion
	)begin
	   delete actividades.inscripcion_actividades
	   where id_inscripcion = @id_inscripcion
    end
	else
	begin
		print 'La inscripcion a eliminar no existe'
	end
end
go

---Procedimiento para inscripcion a actividad extra
create or alter procedure actividades.inscripcion_actividad_extra
(@id_socio int, @id_actividad_extra int, @fecha date, @hora_inicio time, @hora_fin time, @cant_invitados int)
as
begin
   if exists(
        select id_socio from socios.socio
		where id_socio = @id_socio
   )begin
		    if exists(
			      select id_actividad from actividades.actividad_extra
				  where id_actividad = @id_actividad_extra
			)
			begin
			      if (@cant_invitados<0)
				  begin
				     print 'Error en la cantidad de invitados'
				  end
				  else
				  begin	
				        -- Obengo la actividad
				        declare @actividadInsertar varchar(250)
						set @actividadInsertar = (
						    select nombre_actividad from actividades.actividad_extra
							where id_actividad = @id_actividad_extra
						)
						-- Generacion de calculos
						declare @monto decimal(9,3)
						set @monto = (select costo from actividades.actividad_extra
										 where id_actividad = @id_actividad_extra)

						declare @dni int = (
							   select DNI from socios.socio
							   where id_socio = @id_socio
						)

						if(@actividadInsertar = 'Sum')
						begin
						   if exists(
						      select * from actividades.Sum_Reservas
							  where fecha_reserva = @fecha
						   )begin
						       print 'Ya hay reservas del Sum para esa fecha'
						    end
							else
							begin
								insert into actividades.Sum_Reservas(monto,fecha_reserva)
								values(@monto,@fecha)

								--inscribir
								insert into actividades.inscripcion_act_extra
								(id_socio,fecha,hora_inicio,hora_fin,cant_invitados,id_actividad_extra)
								values(@id_socio,@fecha,@hora_inicio,@hora_fin,@cant_invitados,@id_actividad_extra)

								exec facturacion.crear_factura @monto, @dni, @actividadInsertar --se llama al sp crear factura para crear la factura
				       


							end
						end
						else
						begin
												
							--inscribir
							insert into actividades.inscripcion_act_extra
							(id_socio,fecha,hora_inicio,hora_fin,cant_invitados,id_actividad_extra)
							values(@id_socio,@fecha,@hora_inicio,@hora_fin,@cant_invitados,@id_actividad_extra)

							exec facturacion.crear_factura @monto, @dni, @actividadInsertar --se llama al sp crear factura para crear la factura
				       
					   end
				 end
			end
			else
			begin
			   print 'No se encontro una actividad con ese id'
			end
    end
	else
	begin
	  print 'No se encontro el id del socio a inscribir a la actividad'
	end
end
go

-- Procedimiento para eliminar la inscripcion a una actividad extra
create or alter procedure actividades.eliminar_inscripcion_act_extra(@id_inscripcion int)
as
begin
	if exists(
		select id_inscripcion_extra from actividades.inscripcion_act_extra
		where id_inscripcion_extra = @id_inscripcion
	)begin
	   delete actividades.inscripcion_act_extra
	   where id_inscripcion_extra = @id_inscripcion
    end
	else
	begin
		print 'La inscripcion extra a eliminar no existe'
	end
end
go	

-- Procedimiento para pagar una factura
create or alter procedure facturacion.pago_factura(
		@id_factura int,
		@tipo_movimiento varchar(20),
		@id_medio_pago int
)
as
begin
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED
  BEGIN TRANSACTION

    declare @monto decimal(9,3)

    if exists(
	   select id_factura from facturacion.factura
	   where id_factura = @id_factura and estado like 'NO PAGADO'
	)
	begin
	    if exists(
		  select id_medio_de_pago from facturacion.medio_de_pago
		  where id_medio_de_pago = @id_medio_pago
		)
		begin
			 if exists(
			   select primer_vto from facturacion.factura
			   where primer_vto >= GETDATE()
			 ) 
			 begin
			      set @monto = (
								 select total from facturacion.factura
								 where id_factura = @id_factura
			                    )
			 end
			 else
			 begin
			    if exists(
				   select segundo_vto from facturacion.factura
				   where segundo_vto >= GETDATE()
				)
				  begin
				  set @monto = (
								 select total_con_recargo from facturacion.factura
								 where id_factura = @id_factura
			                    )
				  end
				  else
				  begin
				      set @monto = -1
				  end
			 end

			 if(@monto = -1)
			 begin
			     print 'La factura ya excedio la fecha de pago'
			 end
			 else
			 begin
			     declare @id_socio int
				 
				 declare @servicioInsertar varchar(250)
				 set @servicioInsertar = (
				     select servicio from facturacion.factura
					 where id_factura = @id_factura
				 )

				 set @id_socio  = (
				     select s.id_socio from facturacion.factura f
					 join socios.socio s
					 on s.DNI = f.dni
					 where id_factura = @id_factura				 
				 )

			     -- Inserto los datos en la tabla de pago
				 insert into facturacion.pago(id_factura,id_socio,fecha_pago,monto_total,tipo_movimiento,id_medio_pago,servicio)
				 values(@id_factura, @id_socio, getdate(), @monto, 'PAGO', @id_medio_pago, @servicioInsertar)
				 -- Modifico el estado de la factura

				 update facturacion.factura
				 set estado = 'PAGADO'
				 where id_factura = @id_factura
			 end		 
		end
		else
		begin
		   print 'No se encontro el id de ese medio de pago'
		end
	end
	else
	begin
	   print 'No se encontro factura con ese id o la factura ya fue abonada'
	end

  COMMIT TRANSACTION

end
go

-- Procedimiento que paga la factura pero teniendo en cuenta el saldo del usuario
create or alter procedure facturacion.pago_factura_debito(
		@id_factura int,
		@tipo_movimiento varchar(20),
		@id_medio_pago int
)
as
begin
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED
  BEGIN TRANSACTION

    declare @monto decimal(9,3)

    if exists(
	   select id_factura from facturacion.factura
	   where id_factura = @id_factura and estado like 'NO PAGADO'
	)
	begin
	    if exists(
		  select id_medio_de_pago from facturacion.medio_de_pago
		  where id_medio_de_pago = @id_medio_pago
		)
		begin
			 if exists(
			   select primer_vto from facturacion.factura
			   where primer_vto >= GETDATE()
			 ) 
			 begin
			      set @monto = (
								 select total from facturacion.factura
								 where id_factura = @id_factura
			                    )
			 end
			 else
			 begin
			    if exists(
				   select segundo_vto from facturacion.factura
				   where segundo_vto >= GETDATE()
				)
				  begin
				  set @monto = (
								 select total_con_recargo from facturacion.factura
								 where id_factura = @id_factura
			                    )
				  end
				  else
				  begin
				      set @monto = -1
				  end
			 end

			 if(@monto = -1)
			 begin
			     print 'La factura ya excedio la fecha de pago'
			 end
			 else
			 begin
			    
				 declare @servicioInsertar varchar(250)

				 set @servicioInsertar = (
				     select servicio from facturacion.factura
					 where id_factura = @id_factura
				 )

				 declare @id_socio int
				 set @id_socio = (
				   select id_socio from facturacion.factura f
				   join socios.socio s
				   on s.DNI = f.dni
				   where f.id_factura = @id_factura				   
				 )

				 exec facturacion.descuento_saldo_usuario @id_socio , @monto
			     --inserto los datos en la tabla de pago
				 insert into facturacion.pago(id_factura,id_socio,fecha_pago,monto_total,tipo_movimiento,id_medio_pago,servicio)
				 values(@id_factura, @id_socio,getdate(),@monto,'PAGO DEBITO',@id_medio_pago,@servicioInsertar)
				 --modifico el estado de la factura

				 update facturacion.factura
				 set estado = 'PAGADO'
				 where id_factura = @id_factura
			 end		 
		end
		else
		begin
		   print 'No se encontro el id de ese medio de pago'
		end
	end
	else
	begin
	   print 'No se encontro factura con ese id o la factura ya fue abonada'
	end

  COMMIT TRANSACTION
end
go

-- Procedimiento encargado de sumar el saldo en caso de algun reembolso o pago a cuenta
-- Se hace uso del float para establecer porcentajes 0.1, 0.05, 0.2, 0.5
create or alter procedure facturacion.pago_a_cuenta(@id_socio int,@monto_reembolo decimal(9,3),@porcentaje float)
as
begin
    declare @monto_final decimal(9,3)
    declare @id_user int


	set @monto_final = (@monto_reembolo*@porcentaje)

	set @id_user = (
	     select id_usuario from socios.socio
		 where id_socio = @id_socio
	)

	update socios.usuario
	set saldo = (saldo + @monto_final)
	where id_usuario = @id_user

end
go
-- Procedimiento encargado de reembolsar algun pago indeseado
create or alter procedure facturacion.reembolsar_pago(@id_factura int)
as
begin
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED
  BEGIN TRANSACTION
     if exists(
	    select id_factura from facturacion.pago 
		where id_factura = @id_factura and tipo_movimiento like 'PAGO'
	 )
	 begin
			 declare @monto_a_reembolsar decimal(9,3)
			 declare @id_socio_reembolso int
			 set @monto_a_reembolsar = (

					 select monto_total from facturacion.pago
					 where id_factura = @id_factura     

			 )
			 set @id_socio_reembolso = (

					 select id_socio from facturacion.pago
					 where id_factura = @id_factura     

			 )

			declare @id_socio int
			set @id_socio = (
			   select id_socio from facturacion.factura f
			   join socios.socio s
			   on s.DNI = f.dni
			   where id_factura = @id_factura
			)

		
			update facturacion.pago
			set tipo_movimiento = 'REEMBOLSO'
			where id_factura = @id_factura

			-------Pago a cuenta en la tabla usuarios
			exec facturacion.pago_a_cuenta @id_socio_reembolso, @monto_a_reembolsar,1
	 end
	 else
	 begin
	    print 'No es posible reembolsar esa factura'
	 end
  
  COMMIT TRANSACTION
end
go

-- PILETA
-- Procedimiento para anotarse al uso de la pileta, ya sea un socio o un invitado del mismo
create or alter procedure actividades.inscribir_a_pileta
    @id_socio int,
    @es_invitado bit,
    @nombre_invitado varchar(40) = null,
    @apellido_invitado varchar(40) = null,
    @dni_invitado int = null,
    @edad_invitado int = null,
	@id_concepto int
as
begin
    set nocount on;

    declare @id_invitado int = null,
			@id_tarifa int,
			@dni int,
			@id_factura int,
			@id_categoria_pileta int,
			@tarifa int,
			@edad int,
			@nombre_categoria varchar(30)

    begin try
        begin tran

		if @es_invitado = 1
			set @edad = @edad_invitado;
		else
		begin
			select @edad = datediff(year, fecha_nacimiento, getdate())
			from socios.socio
			where id_socio = @id_socio;
		end

		if @edad < 12
			set @nombre_categoria = 'Menores de 12 años'
		else
			set @nombre_categoria = 'Adultos'

		select @id_categoria_pileta = id_categoria_pileta
		from actividades.categoria_pileta
		where nombre = @nombre_categoria

		if @id_categoria_pileta is null
		begin
			print 'No existe una categoria creada para la edad de la persona que quiere ir a la pileta!'
			rollback tran
			return
		end
		else
		begin
		    -- Si es invitado, se inserta primero en 'invitado pileta'
			if @es_invitado = 1
			begin
				insert into actividades.invitado_pileta(id_socio, nombre, apellido, dni, edad)
				values(@id_socio, @nombre_invitado, @apellido_invitado, @dni_invitado, @edad_invitado)

				set @id_invitado = scope_identity()
				set @dni = @dni_invitado

				select top 1 @id_tarifa = id_tarifa,
							 @tarifa = precio_invitado
				from actividades.tarifa_pileta
				where id_categoria_pileta = @id_categoria_pileta
				  and id_concepto = @id_concepto
				  and (vigencia_hasta is null or vigencia_hasta >= getdate())
				order by vigencia_hasta
			end
			else
			begin
				select @dni = DNI from socios.socio where id_socio = @id_socio

				select top 1 @id_tarifa = id_tarifa,
							 @tarifa = precio_socio
				from actividades.tarifa_pileta
				where id_categoria_pileta = @id_categoria_pileta
				  and id_concepto = @id_concepto
				  and (vigencia_hasta is null or vigencia_hasta >= getdate())
				order by vigencia_hasta
			end

			-- Validar si la tarifa no fue encontrada
			if @id_tarifa is null or @tarifa is null
			begin
				print 'No se encontro una tarifa vigente para esta categoria y concepto'
				rollback tran
				return
			end

			-- Creo la factura en base a la tarifa correspondiente a la pileta
			exec facturacion.crear_factura @tarifa, @dni, 'Pileta'

			-- Obtengo el id de la factura recien insertada
			select top 1 @id_factura = id_factura
			from facturacion.factura
			where dni = @dni
			  and servicio = 'Pileta'
			  and total = @tarifa
			order by fecha_emision desc;

			-- Guardo los datos en el acceso a pileta, por ahora la factura la dejo NULL porque hay que modificar cosas
			insert into actividades.acceso_pileta(fecha_inscripcion, id_socio, id_invitado, id_tarifa, id_factura)
			values(getdate(), @id_socio, @id_invitado, @id_tarifa, @id_factura);

			commit tran;
			end
    end try
    begin catch
        if @@trancount > 0
            rollback tran;
        print 'No se pudo realizar la inscripcion a la pileta!';
        throw;
    end catch
end
go

create or alter procedure facturacion.descuento_pileta_lluvia(@fecha date)
as
begin
    update socios.usuario 
	set saldo = saldo + (f.total*0.6)
	from socios.usuario u
	join socios.socio s
	on u.id_usuario = s.id_usuario
	join facturacion.factura f
	on f.dni = s.DNI
	where s.DNI in (
	   select dni from facturacion.factura f
	   join facturacion.dias_lluviosos d
	   on d.fecha = f.fecha_emision
	   where d.lluvia = 1 and f.estado = 'PAGADO' and f.fecha_emision = @fecha
    ) and f.fecha_emision = @fecha

end
go
