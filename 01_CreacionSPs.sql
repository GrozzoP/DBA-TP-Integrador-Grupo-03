/*
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

/*
==========================================================================================================================
									CREACION DE STORED PROCEDURES
========================================================================================================================== */

-- ================================== ROL ==================================
-- Procedimiento para insertar un rol
create or alter procedure socios.insertar_rol(@nombre_rol varchar(20), @descripcion_rol varchar(50))
as
begin
	set nocount on

	if exists(select 1 from socios.rol 
			where nombre = @nombre_rol)
	begin
		print 'El rol que se quiere insertar ya existe en la tabla.'
	end
	else
	begin
		insert into socios.rol(nombre, descripcion) values (@nombre_rol, @descripcion_rol)
		print 'Se ha insertado el rol correctamente!'
	end
end
go

-- Procedimiento para modificar un rol
create or alter procedure socios.modificar_rol(@nombre_rol varchar(20), @nueva_descripcion_rol varchar(50))
as
begin
	set nocount on

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

		print 'Se ha modificado el rol correctamente!'
	end
end
go

-- Procedimiento para eliminar un rol de la tabla
create or alter procedure socios.eliminar_rol(@nombre_rol varchar(20))
as
begin
	set nocount on

	if not exists(select 1 from socios.rol 
				where nombre = @nombre_rol)
	begin
		print 'El rol que se quiere eliminar, no existe segun su nombre.'
	end
	else
	begin
		delete from socios.rol
		where nombre = @nombre_rol

		print 'Se ha eliminado el rol correctamente!'
	end
end
go

-- Procedimiento de carga aleatoria
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

-- ================================== SOCIO ==================================
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
        set @indice_random = (@valor_random % @maximo) + 1

		--  Concateno el caracter encontrado con la contraseña
        set @password += substring(@caracteres, @indice_random, 1)
        set @index  += 1
    end

    return @password
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
	set nocount on

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
		 select @id_categoria = id_categoria from socios.categoria
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
	set nocount on

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
		print 'Se ha habilitado al socio correctamente!'
	end
end
go

-- Procedimiento para eliminar un socio (mediante borrado logico)
create or alter procedure socios.eliminar_socio
	@id_socio int
as
begin
	set nocount on

	if not exists (select 1 from socios.socio 
					where id_socio = @id_socio)
	begin
		print 'No existe un socio con ese id.'
	end
	else
	begin
		-- Borrado logico
		update socios.socio 
		set habilitado = 'NO HABILITADO'
		where @id_socio = id_socio

		print 'Se ha eliminado al socio correctamente!'
	end
end
go

-- ================================== USUARIO ==================================
-- Procedimiento para insertar un usuario
create or alter procedure socios.insertar_usuario
	@id_rol int,
	@usuario varchar(40),
	@contraseña varchar(40),
	@fecha_vigencia_contraseña date
as
begin
	set nocount on

	if not exists (select 1 from socios.rol 
					where id_rol = @id_rol)
	begin
		print 'No existe un rol con ese id.'
	end
	else if (@contraseña is null or ltrim(rtrim(@contraseña)) = '')
	begin
		print 'La contraseña no puede ser nula o vacia.'
	end
	else if (@usuario is null or ltrim(rtrim(@usuario)) = '')
	begin
		print 'El usuario no puede ser nulo o vacio.'
	end
	else if (@fecha_vigencia_contraseña is null)
    begin
        print 'La fecha de vigencia no puede ser nula.'
    end
	else if (CONVERT(date, GETDATE()) > @fecha_vigencia_contraseña)
	begin
		print 'La fecha de vigencia no puede ser anterior a la actual.'
	end
	else
	begin
		insert into socios.usuario(id_rol, usuario, contraseña, fecha_vigencia_contraseña)
		values (@id_rol, @usuario, @contraseña, @fecha_vigencia_contraseña)

		print 'Se ha creado al usuario correctamente!'
	end
end
go

-- Procedimiento para modificar la contraseña del usuario
create or alter procedure socios.modificar_usuario
	@id_usuario int,
	@usuario varchar(40) = NULL,
	@contraseña varchar(40) = NULL,
	@fecha_vigencia_contraseña date = NULL
as
begin
    set nocount on

    if not exists (
        select 1 from socios.usuario
        where id_usuario = @id_usuario
    )
    begin
        print('No existe un usuario con ese id.')
        return
    end

    if @usuario is null
       and @contraseña is null
       and @fecha_vigencia_contraseña is null
    begin
        print('Debe proporcionar al menos un campo para actualizar.')
        return
    end

    if @contraseña is not null
       and LTRIM(RTRIM(@contraseña)) = ''
    begin
        print('La contraseña no puede estar vacia.')
        return
    end

	if @fecha_vigencia_contraseña is not null
        and @fecha_vigencia_contraseña < CAST(GETDATE() as date)
    begin
        print('La fecha de vigencia no puede ser menor a la fecha actual.')
        return
    end

    update socios.usuario
    set usuario = ISNULL(@usuario, usuario),
        contraseña = ISNULL(@contraseña, contraseña),
        fecha_vigencia_contraseña = ISNULL(@fecha_vigencia_contraseña, fecha_vigencia_contraseña)
    where id_usuario = @id_usuario

    if @@ROWCOUNT = 0
    begin
        print('No se realizaron cambios. Los valores enviados coinciden con los actuales.')
    end
    else
    begin
        print('Se ha modificado al usuario correctamente!')
    end
end
go

-- Procedimiento para eliminar usuarios
create or alter procedure socios.eliminar_usuario
	@id_usuario int
as
begin
	set nocount on

	if not exists (select 1 from socios.usuario 
					where id_usuario = @id_usuario)
	begin
		print 'No existe un usuario con ese id.'
	end
	else
	begin
		delete from socios.usuario
		where id_usuario = @id_usuario

		print 'Se ha eliminado al usuario correctamente!'
	end
end
go

-- ================================== OBRA SOCIAL ==================================
-- Procedimiento para insertar una obra social
create or alter procedure socios.insertar_obra_social
	@nombre_obra_social varchar(60),
	@telefono_obra_social char(18)
as
begin
	set nocount on

    if @nombre_obra_social is null or ltrim(rtrim(@nombre_obra_social)) = ''
    begin
        print 'El nombre de la obra social no puede ser nulo ni vacio.'
    end

    else if @telefono_obra_social is null or ltrim(rtrim(@telefono_obra_social)) = ''
    begin
        print 'El numero de teléfono no puede ser nulo ni vacio.'
    end

    else if exists (
        select 1 from socios.obra_social 
        where nombre_obra_social = @nombre_obra_social
    )
    begin
        print 'Ya existe una obra social con ese nombre!'
    end

    else
    begin
        insert into socios.obra_social(nombre_obra_social, telefono_obra_social)
        values (@nombre_obra_social, @telefono_obra_social)

		print 'Se ha insertado la obra social correctamente!'
    end
end
go

-- Procedimiento para modificar una obra social
create or alter procedure socios.modificar_obra_social
	@nombre_obra_social varchar(60),
	@telefono_obra_social char(18)
as
begin
	set nocount on

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

        print 'Se ha modificado la obra social correctamente!'
    end
end
go

-- Procedimiento para eliminar una obra social
create or alter procedure socios.eliminar_obra_social
	@nombre_obra_social varchar(60)
as
begin
	set nocount on

	if not exists (select 1 from socios.obra_social 
					where nombre_obra_social = @nombre_obra_social)
	begin
		print 'No existe una obra social con ese nombre.'
	end
	else
	begin
		delete from socios.obra_social
		where nombre_obra_social = @nombre_obra_social

		print 'Se ha eliminado la obra social correctamente!'
	end
end
go

-- ================================== CATEGORIA ==================================
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
		insert into socios.categoria(nombre_categoria, edad_minima, edad_maxima, costo_membresia)
		values (@nombre_categoria, @edad_minima, @edad_maxima, @costo_membresia)
			
		set @id_categoria_nueva = SCOPE_IDENTITY()
		
		-- Insertar el monto en los precios de las categorias
		insert into socios.categoria_precios(id_categoria, fecha_vigencia_desde, fecha_vigencia_hasta, costo_membresia)
		values (@id_categoria_nueva, GETDATE(),  @vigencia_hasta, @costo_membresia)

		print 'Se ha insertado la categoria correctamente!'
	end
end
go

-- Procedimiento para modificar el costo de una cateogira
create or alter procedure socios.modificar_costo_categoria
	@id_categoria int,
	@costo_membresia decimal(9, 3)
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
		declare @vigencia_hasta date

		-- Actualizar el precio actual en la tabla categoria
		update socios.categoria_precios
		set costo_membresia = @costo_membresia
		where id_categoria = @id_categoria

		-- Obtengo la fecha de vigencia hasta correspondiente a la categoria mas reciente
		select @vigencia_hasta = @vigencia_hasta
		from socios.categoria_precios
		where id_categoria = @id_categoria
		order by fecha_vigencia_hasta desc

		-- Agregarlo al historico de precios de la categoria
		insert into socios.categoria_precios(id_categoria, fecha_vigencia_desde, fecha_vigencia_hasta, costo_membresia)
		values (@id_categoria, GETDATE(),  @vigencia_hasta, @costo_membresia)

		print 'Se ha modificado el costo de la categoria correctamente!'
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

		print 'Se ha modificado la fecha de vigencia la categoria correctamente!'
	end
end
go

-- Procedimiento para eliminar una categoria
create or alter procedure socios.eliminar_categoria
	@id_categoria int
as
begin
	set nocount on

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

		print 'Se ha eliminado la categoria correctamente!'
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
    set nocount on
    
    select 
        @precio_actual = costo_membresia,
        @fecha_vigencia_desde = fecha_vigencia_desde,
        @fecha_vigencia_hasta = fecha_vigencia_hasta
    from socios.categoria_precios
    where id_categoria = @id_categoria
    order by fecha_vigencia_desde desc, id_precio desc;
    
    -- En el caso de no encontrar una coincidencia, selecciono valores por default
    if @precio_actual is null
    begin
        set @precio_actual = 0;
        set @fecha_vigencia_desde = null;
        set @fecha_vigencia_hasta = null;
    end
end
go

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

-- ================================== MEDIO DE PAGO ==================================
-- Crear un medio de pago
create or alter procedure facturacion.insertar_medio_de_pago
    @nombre_medio_pago varchar(40),
    @permite_debito_automatico bit
as
begin
	set nocount on

    if @nombre_medio_pago is null or ltrim(rtrim(@nombre_medio_pago)) = ''
    begin
        print 'El nombre del medio de pago no puede ser nulo ni vacio.'
    end
    else if exists (
        select 1 
        from facturacion.medio_de_pago 
        where nombre_medio_pago = @nombre_medio_pago
    )
    begin
        print 'Ya existe un medio de pago con ese nombre!'
    end
    else
    begin
        insert into facturacion.medio_de_pago(nombre_medio_pago, permite_debito_automatico)
        values (@nombre_medio_pago, @permite_debito_automatico)

		print 'Se ha insertado el medio de pago correctamente!'
    end
end
go

-- Modificar un medio de pago
create or alter procedure facturacion.modificar_medio_de_pago
    @id_medio_de_pago int,
    @nombre_medio_pago varchar(40),
    @permite_debito_automatico bit
as
begin
	set nocount on

    if not exists (
        select 1 
        from facturacion.medio_de_pago 
        where id_medio_de_pago = @id_medio_de_pago
    )
    begin
        print 'No existe un medio de pago con ese id.'
    end
    else if @nombre_medio_pago is null or ltrim(rtrim(@nombre_medio_pago)) = ''
    begin
        print 'El nombre del medio de pago no puede ser nulo ni vacio.'
    end
    else if exists (
        select 1 
        from facturacion.medio_de_pago 
        where nombre_medio_pago = @nombre_medio_pago
        and id_medio_de_pago <> @id_medio_de_pago
    )
    begin
        print 'Ya existe un medio de pago que usa ese nombre.'
    end
    else
    begin
        update facturacion.medio_de_pago
        set nombre_medio_pago = ISNULL(@nombre_medio_pago, nombre_medio_pago),
            permite_debito_automatico = ISNULL(@permite_debito_automatico, permite_debito_automatico)
        where id_medio_de_pago = @id_medio_de_pago

		print 'Se ha modificado el medio de pago correctamente!'
    end
end
go

-- Eliminar un medio de pago
create or alter procedure facturacion.eliminar_medio_de_pago
    @id_medio_de_pago int
as
begin
	set nocount on

    if not exists (
        select 1 
        from facturacion.medio_de_pago 
        where id_medio_de_pago = @id_medio_de_pago
    )
    begin
        print 'No existe un medio de pago con ese id'
    end
    else
    begin
        delete from facturacion.medio_de_pago
        where id_medio_de_pago = @id_medio_de_pago

		print 'Se ha eliminado el medio de pago correctamente!'
    end
end
go

-- ================================== GRUPO FAMILIAR ==================================
-- Insertar un grupo familiar
create or alter procedure socios.insertar_grupo_familiar
	@id_socio_menor int,
	@id_responsable int,
	@parentesco varchar(15) = 'Familiar'
as
begin
	set nocount on

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

			print 'Se ha creado el grupo familiar correctamente!'
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
	set nocount on

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

		print 'Se ha eliminado el grupo familiar correctamente!'
	end
	else
	begin
		print 'No existe una relación entre ese socio menor y ese responsable.'
	end
end
go

-- ================================== ACTIVIDAD ==================================
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
    order by vigencia_hasta desc, id_precio desc;

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
    @costo_mensual decimal(9, 3),
    @vigencia_hasta date = null
as
begin
	set nocount on

	if exists(
		select nombre_actividad from actividades.actividad
		where nombre_actividad = @nombreActividad
	)
	begin
		print 'El nombre de la actividad ya existe.'
	end
	else if(@costo_mensual < 0)
	begin
		print 'El costo de actividad no debe ser negativo.'
	end
	else
	 begin
		declare @id_actividad int

		insert into actividades.actividad(nombre_actividad, precio_mensual)
		values(@nombreActividad, @costo_mensual)

		set @id_actividad = scope_identity()

		insert into actividades.actividad_precios(id_actividad, costo_mensual, vigencia_desde, vigencia_hasta)
		values(@id_actividad, @costo_mensual, getdate(), @vigencia_hasta)

		print 'Se ha creado la actividad correctamente!'
	end
end
go

---Procedimiento para eliminar una actividad
create or alter procedure actividades.eliminar_actividad(@id_actividad int)
as
begin
	set nocount on

    if not exists (
        select 1 from actividades.actividad
        where id_actividad = @id_actividad
    )
    begin
        print 'La actividad a eliminar no existe'
        return
    end

    delete from actividades.actividad_precios
    where id_actividad = @id_actividad

    delete from actividades.actividad
    where id_actividad = @id_actividad

	print 'Se ha eliminado la actividad correctamente!'
end
go

--Procedimiento para modificar una actividad
create or alter procedure actividades.modificar_precio_actividad
    @id_actividad int,
    @nuevo_precio decimal(9,3) = NULL,
    @nueva_vigencia date = NULL
as
begin
	set nocount on

    if not exists (
        select 1 from actividades.actividad
        where id_actividad = @id_actividad
    )
    begin
        print 'La actividad a modificar no existe.'
        return
    end

    if @nuevo_precio <= 0
    begin
        print 'El nuevo costo de actividad no puede ser negativo o cero!'
        return
    end

	declare @fecha_vigencia date

	-- Actualizar el precio de la actividad
	update actividades.actividad
	set precio_mensual = ISNULL(@nuevo_precio, precio_mensual)
	where id_actividad = @id_actividad

	if(@nueva_vigencia = null)
	begin
		select @fecha_vigencia = vigencia_hasta
		from actividades.actividad_precios
		where id_actividad = @id_actividad
		order by vigencia_hasta desc
	end
	else
	begin
		set @fecha_vigencia = @nueva_vigencia
	end

	-- Insertar en el historia de los precios de la actividad
    insert into actividades.actividad_precios(id_actividad, costo_mensual, vigencia_desde, vigencia_hasta)
    values(@id_actividad, @nuevo_precio, getdate(), @fecha_vigencia)

	print 'Se ha modificado la actividad correctamente!'
end
go

-- Procedimiento para insertar una actividad extra
create or alter procedure actividades.insertar_actividad_extra(@nombreActividad varchar(36),@costo decimal(9,3))
as
begin
	set nocount on

	if exists(
		select nombre_actividad from actividades.actividad_extra
		where nombre_actividad = @nombreActividad
	)begin
		print 'El nombre de la actividad extra ya existe.'
	end
	else if @costo < 0
	begin
		print 'El costo de la actividad extra no puede ser negativa.'
	end
	else
	begin
		insert into actividades.actividad_extra(nombre_actividad, costo)
		values(@nombreActividad, @costo)

		print 'Se ha creado la actividad extra correctamente!'
	end
end
go

-- Procedimiento para eliminar una actividad extra
create or alter procedure actividades.eliminar_actividad_extra(@id_actividad_extra int)
as
begin
	set nocount on

	if exists(
		select id_actividad from actividades.actividad_extra
		where id_actividad = @id_actividad_extra
	)
	begin
		delete actividades.actividad_extra
		where id_actividad = @id_actividad_extra

		print 'Se ha eliminado la actividad extra correctamente!'
	end
	else
	begin
		print 'La actividad extra a eliminar no existe.'
	end
end
go

-- Procedimiento para modificar el precio a una actividad extra
create or alter procedure actividades.modificar_precio_actividad_extra(@id_actividad_extra int, @nuevoPrecio decimal(9,3))
as
begin
    set nocount on

    if not exists (
        select 1 
        from actividades.actividad_extra 
        where id_actividad = @id_actividad_extra
    )
    begin
        print('La actividad extra a modificar no existe.')
        return
    end

    if (@nuevoPrecio <= 0)
    begin
        print('El nuevo costo de actividad extra debe ser mayor a cero.')
        return
    end

    update actividades.actividad_extra
    set costo = @nuevoPrecio
    where id_actividad = @id_actividad_extra

	print 'Se ha modificado la actividad extra correctamente!'
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
    set nocount on

    if not exists (
        select 1 
        from actividades.actividad 
        where id_actividad = @id_actividad
    )
    begin
        print 'No se encontro la actividad con ese id'
        return
    end

    if not exists (
        select 1 
        from socios.categoria 
        where id_categoria = @id_categoria
    )
    begin
        print 'No se encontro la categoría con ese id'
        return
    end

    if @dia_semana not in ('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
    begin
        print 'El día no es correcto!'
        return
    end

    insert into actividades.horario_actividades (dia_semana, hora_inicio, hora_fin, id_actividad, id_categoria)
    values (@dia_semana, @hora_inicio, @hora_fin, @id_actividad, @id_categoria)

	print 'Se ha creado el horario de la actividad correctamente!'
end
go

-- Procedimiento para eliminar un horario
create or alter procedure actividades.eliminar_horario_actividad(@id_horario int)
as
begin
	set nocount on

	if exists(
		select id_horario from actividades.horario_actividades
		where id_horario = @id_horario
	)
	begin
			delete actividades.horario_actividades
			where id_horario = @id_horario

			print 'Se ha eliminado el horario de la actividad correctamente!'
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
		@dia_semana varchar(18) = NULL,
		@hora_inicio time = NULL,
		@hora_fin time = NULL,
		@id_actividad int = NULL,
		@id_categoria int = NULL
as
begin
    set nocount on

    if not exists (
        select 1 
        from actividades.horario_actividades 
        where id_horario = @id_horario
    )
    begin
        print 'No se encontro un horario con ese id'
        return
    end

    if @id_actividad is not null and not exists (
        select 1 
        from actividades.actividad 
        where id_actividad = @id_actividad
    )
    begin
        print 'No se encontro la actividad con ese id'
        return
    end

    if @id_categoria is not null and not exists (
        select 1 
        from socios.categoria 
        where id_categoria = @id_categoria
    )
    begin
        print 'No se encontro la categoría con ese id'
        return
    end

    if @dia_semana is not null and @dia_semana not in 
		('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
    begin
        print 'El dia ingresado no es correcto.'
        return
    end

    update actividades.horario_actividades
    set dia_semana = isnull(@dia_semana, dia_semana),
        hora_inicio = isnull(@hora_inicio, hora_inicio),
        hora_fin = isnull(@hora_fin, hora_fin),
        id_categoria = isnull(@id_categoria, id_categoria),
        id_actividad = isnull(@id_actividad, id_actividad)
    where id_horario = @id_horario

    print 'Se ha modificado el horario de la actividad correctamente!'
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


-- ================================== PROFESOR ==================================
--Procedimiento para insertar un profesor
create or alter procedure actividades.insertar_profesor
    @nombre_apellido varchar(45),
    @email varchar(50)
as
begin
    if exists (
        select 1 from actividades.profesor 
        where email = @email
    )
    begin
        print 'Ya existe un profesor con ese email'
    end
    else
    begin
        insert into actividades.profesor(nombre_apellido, email)
        values (@nombre_apellido, @email)

		print 'Se ha insertado el profesor correctamente!'
    end
end
go

--Procedimiento para modificar un profesor
create or alter procedure actividades.modificar_profesor
    @id_profesor int,
    @nombre_apellido varchar(45) = NULL,
    @email varchar(50) = NULL
as
begin
	set nocount on

    if not exists (
        select 1 from actividades.profesor
        where id_profesor = @id_profesor
    )
    begin
        print 'No existe un profesor con ese id.'
    end
    else
    begin
        update actividades.profesor
        set nombre_apellido = ISNULL(@nombre_apellido, nombre_apellido),
            email = ISNULL(@email, email)
        where id_profesor = @id_profesor

		print 'Se ha modificado el profesor correctamente!'
    end
end
go

--Procedimiento para eliminar un profesor
create or alter procedure actividades.eliminar_profesor
    @id_profesor int
as
begin
	set nocount on

    if not exists (
        select 1 from actividades.profesor 
        where id_profesor = @id_profesor
    )
    begin
        print 'No existe un profesor con ese id.'
    end
    else
    begin
        delete from actividades.profesor
        where id_profesor = @id_profesor
    end
end
go

create or alter procedure actividades.insertar_profesor_actividad
    @id_profesor int,
    @id_actividad int,
	@id_horario int
as
begin
	set nocount on

    if not exists (
        select 1 from actividades.profesor 
        where id_profesor = @id_profesor
    )
    begin
        raiserror('No existe profesor con ese id.', 16, 1)
        return
    end

    if not exists (
        select 1 
        from actividades.horario_actividades 
        where id_actividad = @id_actividad and id_horario = @id_horario
    )
    begin
        raiserror('No existe combinación de actividad y horario con esos ids.', 16, 1)
        return
    end

    update actividades.horario_actividades
    set id_profesor = @id_profesor
    where id_actividad = @id_actividad and id_horario = @id_horario

	print 'Se ha eliminado el profesor correctamente!'
end
go

-- ================================== FACTURA ==================================
--Procedimiento para generar una factura
create or alter procedure facturacion.crear_factura(@id_socio int, @periodo date)
as
begin
	set nocount on

	declare @cuota_categoria int,
			@edad int,
			@nombre_categoria varchar(50)

	if not exists(select 1 from socios.socio where id_socio = @id_socio)
	begin
		raiserror('El usuario con ese id no existe.', 16, 1)
		return
	end

	if exists (
		select 1
		from facturacion.factura
		where id_socio = @id_socio
		and periodo_desde = DATEFROMPARTS(YEAR(@periodo), MONTH(@periodo), 1)
		and estado = 'NO PAGADO'
	)
	begin
		raiserror('Ya existe una factura pendiente para ese socio en el período indicado.', 16, 1)
		return
	end

	select @edad =	DATEDIFF(YEAR, fecha_nacimiento, GETDATE()) -
						CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, fecha_nacimiento, GETDATE()), fecha_nacimiento) > GETDATE()
							THEN 1
							ELSE 0
						end
					from socios.socio
					where id_socio = @id_socio

	if(@edad < 18)
	begin
		raiserror('No se le puede hacer la factura a un menor de edad!', 16, 1)
		return
	end

	select @cuota_categoria = costo_membresia,
		   @nombre_categoria = nombre_categoria
	from socios.categoria
	where id_categoria = (select id_categoria from socios.socio where id_socio = @id_socio)

	if(@cuota_categoria IS NULL)
	begin
		raiserror('No se pudo definir el valor de la cuota correspondiente a la categoria del socio', 16, 1)
		return
	end

	begin transaction
		begin try
			declare @total_cuotas decimal(10, 2),
					@total_actividades decimal(10, 2),
					@total_actividades_menores decimal(10, 2),
					@descuento_actividad int = 0,
					@cuota_categoria_menor decimal(10, 2),
					@cuota_categoria_cadete decimal(10, 2),
					@cantidad_menores int,
					@cantidad_cadetes int,
					@cantidad_actividades int,
					@id_factura int,
					@fecha_emision date,
					@vencimiento_1 date,
					@vencimiento_2 date,
					@periodo_desde date,
					@periodo_hasta date,
					@razon_social varchar(80)

			set @fecha_emision = GETDATE()
			set @vencimiento_1 = DATEADD(DAY, 5, @fecha_emision)
			set @vencimiento_2 = DATEADD(DAY, 5, @vencimiento_1)

			select @razon_social = CONCAT(nombre, ' ', apellido)
			from socios.socio
			where id_socio = @id_socio

			set @periodo_desde = DATEFROMPARTS(YEAR(@periodo), MONTH(@periodo), 1)
			set @periodo_hasta = EOMONTH(@periodo)

			set @total_cuotas = @cuota_categoria

			if exists(select 1 from socios.grupo_familiar where id_responsable = @id_socio)
			begin
				select @cuota_categoria_menor = costo_membresia 
				from socios.categoria 
				where nombre_categoria = 'Menor'

				select @cuota_categoria_cadete = costo_membresia 
				from socios.categoria 
				where nombre_categoria = 'Cadete'

				select @cantidad_menores = SUM(case when sc.nombre_categoria = 'Menor'  then 1 else 0 end),
					   @cantidad_cadetes = SUM(case when sc.nombre_categoria = 'Cadete' then 1 else 0 end)
				from socios.grupo_familiar gf
				join socios.socio s on gf.id_socio_menor = s.id_socio
				join socios.categoria sc on s.id_categoria = sc.id_categoria
				where gf.id_responsable = @id_socio;

				if(@cantidad_menores > 0 AND @cuota_categoria_menor IS NULL)
				begin
					raiserror('No se pudo encontrar el valor de la cuota (MENOR) para los socios afiliados al grupo familiar que son menores de edad.', 16, 1)
					return
				end

				if(@cantidad_cadetes > 0 AND @cuota_categoria_cadete IS NULL)
				begin
					raiserror('No se pudo encontrar el valor de la cuota (CADETE) para los socios afiliados al grupo familiar que son menores de edad.', 16, 1)
					return
				end

				set @total_cuotas = @total_cuotas + 
									(@cantidad_menores * ISNULL(@cuota_categoria_menor, 0)) + 
									(@cantidad_cadetes * ISNULL(@cuota_categoria_cadete, 0))
			end

			select @total_actividades =	ISNULL(SUM(a.precio_mensual), 0),
				   @cantidad_actividades = COUNT(*)
			from actividades.inscripcion_actividades ia
			join actividades.actividad a on a.id_actividad = ia.id_actividad
			where ia.id_socio = @id_socio and (MONTH(ia.fecha_inscripcion) = MONTH(@periodo))
			and (YEAR(ia.fecha_inscripcion) = YEAR(@periodo))

			-- Pero si tengo un grupo familiar, seguramente ellos tambien realicen actividades...
			if exists (select 1 from socios.grupo_familiar where id_responsable = @id_socio)
			begin
				select @total_actividades_menores = ISNULL(SUM(a.precio_mensual), 0),
					   @cantidad_actividades = @cantidad_actividades + COUNT(*)
				from socios.grupo_familiar gf
				join actividades.inscripcion_actividades ia on gf.id_socio_menor = ia.id_socio
				join actividades.actividad a on a.id_actividad = ia.id_actividad
				where gf.id_responsable = @id_socio and (MONTH(ia.fecha_inscripcion) = MONTH(@periodo))
			    and (YEAR(ia.fecha_inscripcion) = YEAR(@periodo))

				-- Sumo las actividades de los menores y del socio mayor
				set @total_actividades = @total_actividades + @total_actividades_menores
			end

			-- Si se verifica esto, aplico el descuento
			if(@cantidad_actividades > 1)
			begin
				set @total_actividades = @total_actividades * 0.9
			end

			declare @dni int
			set @dni = (
			           select DNI from socios.socio
					   where id_socio = @id_socio
			)

			-- Ahora, puedo insertar en la factura
			insert into facturacion.factura(id_socio,dni ,fecha_emision, primer_vto, segundo_vto, estado, total, total_con_recargo,
			periodo_desde, periodo_hasta, razon_social)
			values (@id_socio,@dni,@fecha_emision, @vencimiento_1, @vencimiento_2, 'NO PAGADO', @total_actividades + @total_cuotas,
			(@total_actividades + @total_cuotas) * 1.1, @periodo_desde, @periodo_hasta, @razon_social)

			set @id_factura = SCOPE_IDENTITY()

			-- CUOTA DEL SOCIO RESPONSABLE / MAYOR DE EDAD
			insert into facturacion.detalle_factura (id_factura, servicio, precio_unitario, cantidad, subtotal)
			values (@id_factura, CONCAT('Cuota membresia ', @nombre_categoria), @cuota_categoria, 1, @cuota_categoria)

			-- CUOTA DEL SOCIO MENOR VINCULADOS CON EL SOCIO MAYOR
			if(@cantidad_menores > 0)
			begin
				insert into facturacion.detalle_factura (id_factura, servicio, precio_unitario, cantidad, subtotal)
				values (@id_factura, 'Cuota membresia Menor', @cuota_categoria_menor, @cantidad_menores,
						@cuota_categoria_menor * @cantidad_menores)
			end
			
			-- CUOTA DEL SOCIO CADETE VINCULADOS CON EL SOCIO MAYOR
			if(@cantidad_cadetes > 0)
			begin
				insert into facturacion.detalle_factura (id_factura, servicio, precio_unitario, cantidad, subtotal)
				values (@id_factura, 'Cuota membresia Cadete', @cuota_categoria_cadete, @cantidad_cadetes,
						@cuota_categoria_cadete * @cantidad_cadetes)
			end
			
			-- Ahora, inserto las actividades del socio titular
			insert into facturacion.detalle_factura(id_factura, servicio, precio_unitario, subtotal, cantidad)
			select @id_factura, 
				   a.nombre_actividad, 
				   a.precio_mensual, 
				   a.precio_mensual, 
				   1
			from actividades.inscripcion_actividades ia
			join actividades.actividad a
				on ia.id_actividad = a.id_actividad
			where ia.id_socio = @id_socio and (MONTH(ia.fecha_inscripcion) = MONTH(@periodo))
			and (YEAR(ia.fecha_inscripcion) = YEAR(@periodo))

			-- Ahora, inserto las actividades del socio menor
			if exists (select 1 from socios.grupo_familiar where id_responsable = @id_socio)
			begin
            insert into facturacion.detalle_factura(id_factura, servicio, precio_unitario, subtotal, cantidad)
            select @id_factura,
                   a.nombre_actividad,
                   a.precio_mensual,
                   a.precio_mensual,
                   1
            from socios.grupo_familiar gf
            join actividades.inscripcion_actividades ia
              on gf.id_socio_menor = ia.id_socio
            join actividades.actividad a
              on ia.id_actividad = a.id_actividad
			where gf.id_responsable = @id_socio and (MONTH(ia.fecha_inscripcion) = MONTH(@periodo))
			and (YEAR(ia.fecha_inscripcion) = YEAR(@periodo))
			end
            
			print CONCAT('La factura para el socio ', @id_socio, ' se genero corectamente!')
			commit transaction
		end try
	begin catch
		if @@TRANCOUNT > 0
			rollback transaction

		declare @msg nvarchar(4000) = ERROR_MESSAGE();
        throw 50000, @msg, 1
	end catch
end
go

-- Procedimiento para eliminar/anular factura
create or alter procedure facturacion.anular_factura(@id_factura int)
as
begin
	set nocount on

	if not exists(select 1
		from facturacion.factura
		where id_factura = @id_factura
		or estado = 'Anulada'
	)
	begin
		print 'La factura no ha sido creada o ya fue anulada!' 
	end

	update facturacion.factura
	set estado = 'Anulada'
	where id_factura = @id_factura

	print 'La factura con id ' + @id_factura + ' fue anulada correctamente!'
end
go

-- Procedimiento encargado de descontar el saldo del usuario en caso de que pague con saldo de su cuenta
create or alter procedure facturacion.descuento_saldo_usuario
(@id_socio int, @monto decimal(10, 2))
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

-- Procedimiento para pagar una factura
create or alter procedure facturacion.pago_factura(
		@id_factura int,
		@tipo_movimiento varchar(20),
		@id_medio_pago int
)
as
begin
    set nocount on

	-- Valido que exista el id de la factura
	if not exists(
		select 1
		from facturacion.factura
		where id_factura = @id_factura
	)
	begin
		raiserror('No existe factura con id %d.', 16, 1, @id_factura)
	end

	-- Validar medio de pago
    if not exists(
        select 1 
        from facturacion.medio_de_pago
        where id_medio_de_pago = @id_medio_pago
    )
    begin
        raiserror('Medio de pago con id% es invalido!', 16, 1, @id_medio_pago)
    end

    set transaction isolation level read committed
    begin transaction
    begin try
        declare @estado varchar(30),
				@primer_vto date,
				@segundo_vto date,
				@total decimal(10,2),
				@total_con_recargo decimal(10,2),
				@id_socio int

        select	@estado = estado,
				@primer_vto = primer_vto,
				@segundo_vto = segundo_vto,
				@total = total,
				@total_con_recargo = total_con_recargo,
				@id_socio = id_socio
        from facturacion.factura
        where id_factura = @id_factura

        if @estado <> 'NO PAGADO'
        begin
            raiserror('La factura %d ya fue abonada o no esta en estado "NO PAGADO".', 16, 1, @id_factura)
        end

		-- Calculo el monto segun la fecha de vencimiento
        declare @monto decimal(10,2),
                @hoy date = CAST(GETDATE() as date)

        if @hoy <= @primer_vto
            set @monto = @total
        else if @hoy <= @segundo_vto
            set @monto = @total_con_recargo
        else
		begin
			raiserror('La factura %d ya excedio el segundo vencimiento!', 16, 1, @id_factura)
		end

        -- Una vez validado todo, puedo asegurarme insertar el pago
        insert into facturacion.pago(id_factura, id_socio, fecha_pago, monto_total, tipo_movimiento, id_medio_pago)
        values(@id_factura, @id_socio, GETDATE(), @monto, @tipo_movimiento, @id_medio_pago)

		-- Ya puedo actualizar la factura, asegurando que se pago
        update facturacion.factura
        set estado = 'PAGADO'
        where id_factura = @id_factura

        commit transaction
    end try
    begin catch
        rollback transaction

        declare @err_msg nvarchar(4000) = ERROR_MESSAGE()
        raiserror('Error en pago_factura: %s', 16, 1, @err_msg)
    end catch
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
	set nocount on
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
					set @id_socio = (
					select id_socio from facturacion.factura 			  
					where id_factura = @id_factura				   
					)

					exec facturacion.descuento_saldo_usuario @id_socio , @monto
					--inserto los datos en la tabla de pago
					insert into facturacion.pago(id_factura,id_socio,fecha_pago,monto_total,tipo_movimiento,id_medio_pago)
					values(@id_factura, @id_socio,getdate(),@monto,'PAGO DEBITO',@id_medio_pago)
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
create or alter procedure facturacion.pago_a_cuenta(@id_socio int,@monto_reembolo decimal(9,3), @porcentaje float)
as
begin
	set nocount on

    declare @monto_final decimal(9,3)
    declare @id_user int

	begin try
		if not exists(select 1 from socios.socio where id_socio = @id_socio)
		begin
			raiserror('El usuario con ese id no existe.', 16, 1)
			return
		end

		set @monto_final = (@monto_reembolo*@porcentaje)

		set @id_user = (
			 select id_usuario from socios.socio
			 where id_socio = @id_socio
		)

		update socios.usuario
		set saldo = (saldo + @monto_final)
		where id_usuario = @id_user
	end try
	begin catch
		declare @err_msg nvarchar(4000) = ERROR_MESSAGE()
		raiserror('Error en pago_a_cuenta: %s', 16, 1, @err_msg)
	end catch
end
go

-- Procedimiento encargado de reembolsar algun pago indeseado
create or alter procedure facturacion.reembolsar_pago(@id_factura int)
as
begin
	set nocount on

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION
		if exists(
		select id_factura from facturacion.pago 
		where id_factura = @id_factura and tipo_movimiento like 'PAGO'
		)
		begin
				declare @monto_a_reembolsar decimal(10,2)

				set @monto_a_reembolsar = (

						select monto_total from facturacion.pago
						where id_factura = @id_factura     

				)
			
			declare @id_socio int
			set @id_socio = (
				select id_socio from facturacion.factura 
				where id_factura = @id_factura
			)

		
			update facturacion.pago
			set tipo_movimiento = 'REEMBOLSO'
			where id_factura = @id_factura

			-------Pago a cuenta en la tabla usuarios
			exec facturacion.pago_a_cuenta @id_socio, @monto_a_reembolsar,1
		end
		else
		begin
		print 'No es posible reembolsar esa factura'
		end
  
	COMMIT TRANSACTION
end
go

-- ================================== INSCRIPCION ACTIVIDAD ==================================
/* Procedimiento para inscribirse a una actividad...
		Para enviar los horarios, se hara mediante una cadena separada por comas que enviara
		los id de los horarios de la actividad determinada a la cual se desea inscribir.
			Por ejemplo: '5, 10, 15'
*/
create or alter procedure actividades.inscripcion_actividad
    @id_socio int,
    @id_actividad int,
	@lista_id_horarios varchar(200)
as
begin
    set nocount on
    set xact_abort on

    begin transaction
    begin try
        if not exists (select 1 from socios.socio where id_socio = @id_socio)
            throw 51000, 'No se encontro un socio con ese id.', 1

        if not exists (select 1 from actividades.actividad where id_actividad = @id_actividad)
            throw 51000, 'No se encontro una actividad con ese id.', 1

		if not exists (select 1 from actividades.horario_actividades where id_actividad = @id_actividad)
            throw 51000, 'No se encontro un horario para esa actividad.', 1

        declare @monto decimal(9,3),
				@id_inscripcion int,
				@dni int,
				@total_horarios_encontrados int,
				@total_horarios_ok int

        select top 1 @monto = costo_mensual
        from actividades.actividad_precios
        where id_actividad = @id_actividad
          and (vigencia_hasta is null or vigencia_hasta >= getdate())
        order by vigencia_hasta desc

        if @monto is null
            throw 51000, 'No hay un precio vigente para esta actividad!', 1

		if object_id('tempdb..#TEMP_ID_HORARIOS') is null 
			create table #TEMP_ID_HORARIOS (
				id_horario int
			)

		insert into #TEMP_ID_HORARIOS(id_horario)
		select TRY_CAST(value as int)
		from STRING_SPLIT(@lista_id_horarios, ',')
		where TRY_CAST(value as int) is not null

		select @total_horarios_encontrados = count(*) from #TEMP_ID_HORARIOS
		select @total_horarios_ok = (
			select count(*)
			from #TEMP_ID_HORARIOS h
			join actividades.horario_actividades ha
			on h.id_horario = ha.id_horario
			and ha.id_actividad = @id_actividad
		)

		if @total_horarios_encontrados != @total_horarios_ok
            throw 50000, 'Lo/s ID/s de los horarios insertados no se corresponden con la actividad!', 1

		-- Ya revisado todo, puedo insertar tranquilamente
		insert into actividades.inscripcion_actividades(id_socio, id_actividad)
		values (@id_socio, @id_actividad)

		set @id_inscripcion = SCOPE_IDENTITY()

		-- Insertar los horarios a los que se inscribio un socio
		insert into actividades.inscripcion_actividades_horarios(id_inscripcion, id_horario)
		select @id_inscripcion, h.id_horario
		from #TEMP_ID_HORARIOS h

        commit transaction
        print 'Inscripción generada correctamente!'
		drop table #TEMP_ID_HORARIOS
    end try
    begin catch
        rollback transaction

        declare @msg nvarchar(4000) = ERROR_MESSAGE()
        print @msg

    end catch
end;
go

-- Procedimiento para eliminar la inscripcion de un socio a una actividad
create or alter procedure actividades.eliminar_inscripcion_actividad
    @id_inscripcion int
as
begin
    set nocount on

    begin transaction

    begin try
        if not exists (
            select 1
            from actividades.inscripcion_actividades
            where id_inscripcion = @id_inscripcion
        )
        begin
            print 'La inscripcion a eliminar no existe!'
            rollback
            return
        end

        -- Elimino primero la tabla de los horarios inscriptos del socio
        delete from inscripcion_actividades_horarios
        where id_inscripcion = @id_inscripcion

        -- Una vez hecho eso, ya puedo eliminar la inscripcion en si
        delete from actividades.inscripcion_actividades
        where id_inscripcion = @id_inscripcion

        commit
        print 'Inscripcion eliminada correctamente!'
    end try
    begin catch
        rollback
        print ERROR_MESSAGE()
    end catch
end
go

-- ================================== INSCRIPCION ACTIVIDAD EXTRA ==================================
---Procedimiento para inscripcion a actividad extra
create or alter procedure actividades.inscripcion_actividad_extra
(@id_socio int, @id_actividad_extra int, @fecha date, @hora_inicio time, @hora_fin time, @cant_invitados int)
as
begin
    set nocount on

    if not exists(select 1 from socios.socio where id_socio = @id_socio)
    begin
        raiserror('No se encontro el socio con id %d.', 16, 1, @id_socio)
        return
    end

    if not exists(select 1 from actividades.actividad_extra where id_actividad = @id_actividad_extra)
    begin
        raiserror('No se encontro la actividad extra con id %d.', 16, 1, @id_actividad_extra)
        return
    end

    if (@cant_invitados < 0)
    begin
        raiserror('La cantidad de invitados (%d) no puede ser negativa.', 16, 1, @cant_invitados)
        return
    end

    if (@fecha < CAST(GETDATE() as date))
    begin
        raiserror('La fecha de reserva no puede ser anterior a hoy.', 16, 1)
        return
    end

    declare @nombre_actividad varchar(250),
            @monto decimal(9,3),
            @nombre_socio varchar(200),
            @dni_socio int,
			@id_factura int,
            @tipo varchar(20)

    select	@nombre_actividad = ae.nombre_actividad,
			@monto = ae.costo
    from actividades.actividad_extra ae
    where ae.id_actividad = @id_actividad_extra

    select	@nombre_socio = s.nombre + ' ' + s.apellido,
			@dni_socio = s.dni
    from socios.socio s
    where s.id_socio = @id_socio

    -- Determinar tipo y procesamiento de "Sum"
    begin transaction

    if(@nombre_actividad = 'Sum')
    begin
        if exists(select 1 from actividades.Sum_Reservas where fecha_reserva = @fecha)
        begin
            rollback transaction
            raiserror('Ya existe una reserva de Sum para la fecha.', 16, 1)
            return
        end

        insert into actividades.Sum_Reservas(monto, fecha_reserva, cant_invitados)
        values(@monto, @fecha, @cant_invitados)

        set @tipo = 'Reserva SUM'
    end
    else
    begin
        select @tipo = nombre_actividad from actividades.actividad_extra where id_actividad = @id_actividad_extra
    end

    -- Inscripción en actividad extra
    insert into actividades.inscripcion_act_extra(id_socio, id_actividad_extra, fecha, hora_inicio, hora_fin, cant_invitados) 
	values(@id_socio, @id_actividad_extra, @fecha, @hora_inicio, @hora_fin, @cant_invitados)

    -- Generar factura
    insert into facturacion.factura(id_socio, fecha_emision, primer_vto, segundo_vto, periodo_desde, periodo_hasta,
	total, total_con_recargo, estado, razon_social, dni) 
	values(@id_socio, GETDATE(), DATEADD(DAY, 5, GETDATE()), DATEADD(DAY, 10, GETDATE()), @fecha, @fecha, 
	@monto, @monto * 1.1, 'NO PAGADO', @nombre_socio, @dni_socio)

	set @id_factura = SCOPE_IDENTITY()

	insert into facturacion.detalle_factura(id_factura, servicio, precio_unitario, cantidad, subtotal)
	values (@id_factura, @tipo, @monto, 1, @monto)

    commit transaction

    raiserror('Inscripción a actividad extra realizada con éxito.', 0, 1)
end
go

create or alter procedure actividades.eliminar_inscripcion_act_extra
    @id_inscripcion_extra int
as
begin
    set nocount on

    if not exists(
        select 1
        from actividades.inscripcion_act_extra
        where id_inscripcion_extra = @id_inscripcion_extra
    )
    begin
        print('No existe inscripcion con ese id.')
        return
    end

    begin transaction

		delete from actividades.inscripcion_act_extra
		where id_inscripcion_extra = @id_inscripcion_extra

		if @@rowcount = 0
		begin
			rollback transaction
			print('Error al eliminar la inscripcion!')
			return
		end

    commit transaction

    print('Inscripcion eliminada correctamente!')
end
go

-- ================================== PILETA ==================================
-- Procedimiento para anotarse al uso de la pileta, ya sea un socio o un invitado del mismo
create or alter procedure actividades.inscribir_a_pileta
    @id_socio int,
    @es_invitado bit,
	@id_concepto int,
    @nombre_invitado varchar(40) = NULL,
    @apellido_invitado varchar(40) = NULL,
    @dni_invitado int = NULL,
    @edad_invitado int = NULL
as
begin
    set nocount on

	if not exists(select 1 from socios.socio where id_socio = @id_socio)
	begin
		raiserror('No existe un socio con id %d.', 16, 1, @id_socio)
		rollback transaction
		return
	end

    begin try
        begin transaction

		declare @id_invitado int = null,
				@id_tarifa int,
				@dni int,
				@id_factura int,
				@id_categoria_pileta int,
				@tarifa int,
				@edad int,
				@id_concepto_dia int,
				@nombre_categoria varchar(30),
				@descripcion varchar(35),
				@nombre_concepto varchar(35),
				@razon_social varchar(60),
				@fecha_emision date = CAST(GETDATE() as date),
				@primer_vencimiento date,
				@segundo_vencimiento date,
				@reembolso decimal(10, 2) = 0

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
			raiserror('Categoria de pileta no definida para edad %d.', 16, 1, @edad)
			rollback transaction
			return
		end
		else
		begin
			if @es_invitado = 1
			begin
				insert into actividades.invitado_pileta(id_socio, nombre, apellido, dni, edad)
				values(@id_socio, @nombre_invitado, @apellido_invitado, @dni_invitado, @edad_invitado)

				set @id_invitado = scope_identity()
				set @dni = @dni_invitado
			end
			else
			begin
				select @dni = DNI
				from socios.socio
				where id_socio = @id_socio
			end

			select top 1 @tarifa = (case when @es_invitado = 1 then precio_invitado else precio_socio end)
			from actividades.tarifa_pileta
			where id_categoria_pileta = @id_categoria_pileta
				and id_concepto = @id_concepto
				and (vigencia_hasta is NULL or vigencia_hasta >= GETDATE())
			order by vigencia_hasta

			if @tarifa is null
			begin
				raiserror('No hay tarifa vigente para categoria %s y concepto %d.', 16, 1, @nombre_categoria, @id_concepto)
				rollback transaction
				return
			end

			set @primer_vencimiento = DATEADD(DAY, 5, @fecha_emision)
			set @segundo_vencimiento = DATEADD(DAY, 5, @primer_vencimiento)
			set @descripcion = CONCAT('Acceso pileta - ', @nombre_categoria)

			select @id_concepto_dia = id_concepto
			from actividades.concepto_pileta
			where nombre = 'Valor del dia'

			if(@nombre_concepto = 'Valor del dia')
			begin
				if exists(
					select 1
					from facturacion.dias_lluviosos
					where fecha = CAST(GETDATE() as date)
					and lluvia = 1
				)
				begin
					declare @precio decimal(10, 2)

					select top 1 @precio = 
						case when @es_invitado = 1 then precio_invitado else precio_socio end
					from actividades.tarifa_pileta
					where id_concepto = @id_concepto_dia
					  and id_categoria_pileta = @id_categoria_pileta
					  and (vigencia_hasta is NULL or vigencia_hasta >= CAST(GETDATE() as date))
					order by vigencia_hasta

					set @reembolso = @precio * 0.6
				end
			end

			if(@es_invitado = 1)
			begin
				insert into facturacion.factura(id_socio, fecha_emision, primer_vto, segundo_vto, estado, total, total_con_recargo, 
				periodo_desde, periodo_hasta, razon_social, dni)
				values (@id_socio, @fecha_emision, @primer_vencimiento, @segundo_vencimiento, 'PAGADO', @tarifa, @tarifa * 1.1, @fecha_emision,
				@fecha_emision, CONCAT(@nombre_invitado, ' ', @apellido_invitado), @dni_invitado)

				set @id_factura = SCOPE_IDENTITY()

				insert into facturacion.detalle_factura(id_factura, servicio, precio_unitario, cantidad, subtotal)
				values (@id_factura, @descripcion, @tarifa - ISNULL(@reembolso, 0), 1, @tarifa - ISNULL(@reembolso, 0))
				
				insert into facturacion.pago(id_factura, id_socio, fecha_pago, monto_total, tipo_movimiento, id_medio_pago)
				values (@id_factura, @id_socio, GETDATE(), @tarifa, 'PAGO INMEDIATO',
						(select id_medio_de_pago from socios.socio where id_socio = @id_socio))
			end
			else
			begin
				select top 1 @id_factura = id_factura
				from facturacion.factura
				where id_socio = @id_socio and estado = 'NO PAGADO'
				order by fecha_emision desc

				if(@id_factura is NULL)
				begin
					select @razon_social = CONCAT(nombre, ' ', apellido)
					from socios.socio
					where id_socio = @id_socio

					insert into facturacion.factura (id_socio, fecha_emision, primer_vto, segundo_vto, estado, total, total_con_recargo,
					periodo_desde, periodo_hasta, razon_social, dni)
					values (@id_socio, @fecha_emision, @primer_vencimiento, @segundo_vencimiento, 'NO PAGADO', @tarifa, @tarifa * 1.1, 
					@fecha_emision, @fecha_emision, @razon_social, @dni);
					
					set @id_factura = SCOPE_IDENTITY()
				end

				insert into facturacion.detalle_factura (id_factura, servicio, precio_unitario, subtotal, cantidad)
				values (@id_factura, @descripcion, @tarifa, @tarifa, 1)

				if(@reembolso <> 0)
					exec facturacion.pago_a_cuenta @id_socio, @reembolso, 1
			end

			insert into actividades.acceso_pileta(fecha_inscripcion, id_socio, id_invitado, id_tarifa, id_factura)
			values(GETDATE(), @id_socio, @id_invitado, @id_tarifa, @id_factura)

			print 'Se ha generado la inscripcion a la pileta correctamente!'
		end

		commit transaction
		raiserror('InscripciOn a pileta realizada con éxito.', 0, 1)
    end try
    begin catch
        if @@trancount > 0
            rollback transaction
        print 'No se pudo realizar la inscripcion a la pileta!'
    end catch
end
go