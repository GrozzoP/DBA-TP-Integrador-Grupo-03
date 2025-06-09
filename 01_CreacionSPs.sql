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
	@telefono_contacto int,
	@telefono_emergencia int,
	@id_obra_social int,
	@id_categoria int,
	@id_medio_de_pago int,
	@id_rol int
as
begin
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

	-- Buscar si existe id_categoria
	else if not exists (select 1 from socios.categoria 
					where id_categoria = @id_categoria)
	begin
		print 'No existe una categoria con ese id.'
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

	else
	begin
		declare @usuario varchar(83),
				@contraseña varchar(16),
				@id_usuario int

		 -- Generar un usuario y una contraseña de manera automatica
		 set @usuario = @nombre + '_' + @apellido + CAST(RIGHT(@dni, 2) as varchar)
		 select @contraseña = socios.generar_contraseña_aleatoria(16)

		 -- Enviar al mail esta informacion (usuario, contraseña)
		 insert into socios.usuario (usuario, contraseña, fecha_vigencia_contraseña, id_rol)
		 values (@usuario, @contraseña,  DATEADD(DAY, 7, GETDATE()), @id_rol)

		 -- Insertar el socio teniendo en cuenta la creacion del usuario
		 select @id_usuario = id_usuario from socios.usuario where usuario = @usuario
	
		 insert into socios.socio
		 (dni, nombre, apellido, email, fecha_nacimiento, telefono_contacto, telefono_emergencia, habilitado,
		 id_obra_social, id_categoria, id_usuario, id_medio_de_pago)
		 values (@dni, @nombre, @apellido, @email, @fecha_nacimiento, @telefono_contacto, @telefono_emergencia, 'HABILITADO',
		 @id_obra_social, @id_categoria, @id_usuario, @id_medio_de_pago)
		 print 'Se ha creado de manera automatica una cuenta para que disfrutes de los servicios de los socios!'
	end
end
go

-- Procedimiento para modiifcar un socio
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
	if not exists (select 1 from socios.socio 
					where DNI = @DNI)
	begin
		print 'No existe un socio con ese dni.'
	end
	else
	begin
		-- Borrado logico
		update socios.socio 
		set habilitado = 0
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
	@telefono_obra_social int
as
begin
	if exists (select 1 from socios.obra_social 
				where nombre_obra_social = @nombre_obra_social)
	begin
		print 'Ya existe una obra social con ese nombre.'
	end
	else if @telefono_obra_social < 0
	begin
		print 'El numero de telefono no puede ser negativo'
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
	@telefono_obra_social int
as
begin
	if not exists (select 1 from socios.obra_social 
					where nombre_obra_social = @nombre_obra_social)
	begin
		print 'No existe una obra social con ese nombre.'
	end
	else if @telefono_obra_social < 0
	begin
		print 'El numero de telefono no puede ser negativo'
	end
	else
	begin
		update socios.obra_social
		set telefono_obra_social = @telefono_obra_social
		where nombre_obra_social = @nombre_obra_social
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
	@costo_membresia decimal(9,3)
as
begin
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
		insert into socios.categoria(nombre_categoria, edad_minima, edad_maxima, costo_membresía)
		values (@nombre_categoria, @edad_minima, @edad_maxima, @costo_membresia)
	end
end
go

-- Procedimiento para modificar el costo de una cateogira
create or alter procedure socios.modificar_costo_categoria
	@nombre_categoria varchar(16),
	@costo_membresia decimal(9,3)
as
begin
	if not exists (select 1 from socios.categoria where nombre_categoria = @nombre_categoria)
	begin
		print 'No existe una categoría con ese nombre.'
	end
	else if @costo_membresia < 0
	begin
		print 'El nuevo costo de la membresia no puede ser negativo.'
	end
	else
	begin
		update socios.categoria
		set costo_membresía = @costo_membresia
		where nombre_categoria = @nombre_categoria
	end
end
go

-- Procedimiento para eliminar una categoria
create or alter procedure socios.eliminar_categoria
	@nombre_categoria varchar(16)
as
begin
	if not exists (select 1 from socios.categoria 
					where nombre_categoria = @nombre_categoria)
	begin
		print 'No existe una categoría con ese nombre.'
	end
	else
	begin
		delete from socios.categoria
		where nombre_categoria = @nombre_categoria
	end
end
go

-- RESPONSABLE MENOR
-- Procedimiento para crear un responsable de un menor
create or alter procedure socios.insertar_responsable_menor
	@nombre varchar(40),
	@apellido varchar(40),
	@dni int,
	@email varchar(50),
	@fecha_nacimiento date,
	@telefono int,
	@parentesco varchar(30)
as
begin

	insert into socios.responsable_menor (
		nombre, apellido,
		dni, email, fecha_nacimiento, telefono, parentesco
	)
	values (
		@nombre, @apellido,
		@dni, @email, @fecha_nacimiento, @telefono, @parentesco
	)
end
go

-- Procedimiento para eliminar un responsable de un menor
create or alter procedure socios.eliminar_responsable_menor
	@id_socio_responsable int
as
begin
	if not exists (select 1 from socios.responsable_menor 
					where id_socio_responsable = @id_socio_responsable)
	begin
		print 'No existe un responsable de un menor con ese id.'
	end

	delete from socios.responsable_menor
	where id_socio_responsable = @id_socio_responsable
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
			@costo_membresía decimal(9,3);

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
				set @costo_membresía = ROUND(RAND(@random) * (10000), 2)

				-- Una vez creados los valores, se insertan en la tabla
				insert into socios.categoria(nombre_categoria, edad_minima, edad_maxima, costo_membresía)
				values (@nombre_categoria, @edad_minima, @edad_maxima, @costo_membresía)

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
--- Procedimiento para insertar una actividad
create or alter procedure actividades.insertar_actividad(@nombreActividad varchar(36),@costoMensual decimal(9,3))
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
	    insert into actividades.actividad(nombre_actividad, costo_mensual)values(@nombreActividad, @costoMensual)
	 end

end
go

---Procedimiento para eliminar una actividad
create or alter procedure actividades.eliminar_actividad(@id_actividad int)
as
begin
  
   if exists(
      select id_actividad from actividades.actividad
	  where id_actividad = @id_actividad
   )begin
       delete actividades.actividad
	   where id_actividad = @id_actividad
    end
	else
	 begin
	    print 'La actividad a eliminar no existe'
	 end

end
go
--Procedimiento para modificar una actividad
create or alter procedure actividades.modificar_precio_actividad(@id_actividad int, @nuevoPrecio decimal(9,3))
as
begin

   if exists(
      select id_actividad from actividades.actividad
	  where id_actividad = @id_actividad
   )begin
		if @nuevoPrecio > 0
		begin
		update actividades.actividad
	    set costo_mensual = @nuevoPrecio
	    where id_actividad = @id_actividad
		end
		else
			print 'El nuevo costo de actividad no puede ser negativa'
   end
   else
   begin
	    print 'La actividad a modificar no existe'
	 end
end
go
---Procedimiento para insertar una actividad extra
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

---Procedimiento para eliminar una actividad extra
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
---Procedimiento para modificar el precio a una actividad extra
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
---Procedimiento para insertar un horario
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
---Procedimiento para eliminar un horario
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
---Procedimiento para modificar un horario
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
--Procedimiento para generar una factura
create or alter procedure facturacion.crear_factura(@total decimal(9,3),@id_socio int)
as
begin
	if exists(
			select id_socio from socios.socio
			where id_socio = @id_socio
	)begin
	     if(@total > 0)
		 begin
		     insert into facturacion.factura(fecha_emision,primer_vto,segundo_vto,total,total_con_recargo,
			 estado,id_socio)
			 values(getdate(),dateadd(day,5,getdate()),dateadd(day,10,getdate()),
			 @total,(@total+(@total*0.1)),'NO PAGADO',@id_socio)
		 end
		 else
		 begin
		     print 'Monto ingresado no es valido'
		 end
	 end
	 else
	 begin
	   print 'No se encontro el socio para generar la factura'
	 end
end
go
---Procedimiento para inscribirse a una actividad
create or alter procedure actividades.inscripcion_actividad(@id_socio int, @id_horario int, @id_actividad int)
as
begin
   if exists(
        select id_socio from socios.socio
		where id_socio = @id_socio
   )begin
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
				      select * from actividades.horario_actividades
					  where id_actividad = @id_actividad and id_horario = @id_horario
				  )
				  begin
				       --generacion del monto
				       declare @monto decimal(9,3)
					   set @monto = (
					                 select costo_mensual from actividades.actividad
									 where id_actividad = @id_actividad
					                )
					   --inscripcion
				       insert into actividades.inscripcion_actividades(id_socio,id_horario,id_actividad)
					   values(@id_socio,@id_horario,@id_actividad)
					   
					   --generacion de factura
					   exec facturacion.crear_factura @monto, @id_socio --se llama al sp crear factura para crear la factura
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
	else
	begin
	  print 'No se encontro el id del socio a inscribir a la actividad'
	end
end
go
--Procedimiento para la inscripcion de un socio a una actividad
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
				       --generacion de calculos
				        declare @monto decimal(9,3)
						declare @montoInvitado decimal(9,3)
						set @monto = (select costo from actividades.actividad_extra
						             where id_actividad = @id_actividad_extra)
						set @montoInvitado = (@monto + (@monto*0.1)) --+10% invitado
						set @monto = @monto + (@montoInvitado*@cant_invitados)

					    --inscribir
					    insert into actividades.inscripcion_act_extra
					    (id_socio,fecha,hora_inicio,hora_fin,cant_invitados,id_actividad_extra)
					    values(@id_socio,@fecha,@hora_inicio,@hora_fin,@cant_invitados,@id_actividad_extra)
				        --generacion de factura	  

						exec facturacion.crear_factura @monto, @id_socio --se llama al sp crear factura para crear la factura
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

--Procedimiento para eliminar la inscripcion a una activiad extra
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
--Procedimiento para pagar una factura
create or alter procedure facturacion.pago_factura(
		@id_factura int,
		@tipo_movimiento varchar(20),
		@id_medio_pago int
)
as
begin
  SET TRANSACTION ISOLATION LEVEL READ COMMITTED
  BEGIN TRANSACTION

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
		     declare @monto decimal(9,3)
			 set @monto = (
			                 select total from facturacion.factura
							 where id_factura = @id_factura
			              )
			 --inserto los datos en la tabla de pago
		     insert into facturacion.pago(id_factura,fecha_pago,monto_total,tipo_movimiento,id_medio_pago)
			 values(@id_factura,getdate(),@monto,'PAGO',@id_medio_pago)
			 --modifico el estado de la factura

			 update facturacion.factura
			 set estado = 'PAGADO'
			 where id_factura = @id_factura
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
