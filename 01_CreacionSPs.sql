Use COM5600G03
go
-- ROL
-- Procedimiento para insertar un rol
create or alter procedure socios.insertarRol(@nombre_rol varchar(20), @descripcion_rol varchar(50))
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
create or alter procedure socios.modificarRol(@nombre_rol varchar(20), @nueva_descripcion_rol varchar(50))
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
create or alter procedure socios.eliminarRol(@nombre_rol varchar(20))
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
create or alter procedure facturacion.crearMedioPago(@nombre_medio_de_pago varchar(40), @permite_debito_automatico BIT)
as
begin
	if not exists(select 1 from facturacion.medio_de_pago
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
create or alter procedure facturacion.modificarMedioPago(@nombre_medio_de_pago varchar(40))
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
create or alter procedure facturacion.eliminarMedioPago(@nombre_medio_de_pago varchar(40))
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
-- Procedimiento para insertar un socio
create or alter procedure socios.insertarSocio
	@dni int,
	@nombre varchar(40),
	@apellido varchar(40),
	@email varchar(150),
	@fecha_nacimiento date,
	@telefono_contacto int,
	@telefono_emergencia int,
	@id_obra_social int,
	@id_categoria int,
	@id_usuario int,
	@id_medio_de_pago int
as
begin
	if exists (select 1 from socios.socio 
			   where dni = @dni)
	begin
		print 'ya existe un socio con ese dni.'
	end
	else
	begin
		insert into socios.socio
		(dni, nombre, apellido, email, fecha_nacimiento, telefono_contacto, telefono_emergencia, habilitado,
		 id_obra_social, id_categoria, id_usuario, id_medio_de_pago)
		values
		(@dni, @nombre, @apellido, @email, @fecha_nacimiento, @telefono_contacto, @telefono_emergencia, 1,
		 @id_obra_social, @id_categoria, @id_usuario, @id_medio_de_pago)
	end
end
go

-- Procedimiento para modiifcar un socio
create or alter procedure socios.modificarHabilitarSocio
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
		/* Como tenemos un campo de 'bit' y solo tiene dos valores posibles, si lo quiero modificar, simplemente
		   niego el bit actual vinculado con el habilitar */
		update socios.socio
		set habilitado = ~habilitado
		where id_socio = @id_socio
	end
end
go

-- Procedimiento para eliminar un socio (mediante borrado logico)
create or alter procedure socios.eliminarSocio
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
create or alter procedure socios.insertarUsuario
	@id_rol int,
	@contraseña varchar(40),
	@fecha_vigencia_contraseña date
as
begin
	insert into socios.usuario(id_rol, contraseña, fecha_vigencia_contraseña)
	values (@id_rol, @contraseña, @fecha_vigencia_contraseña)
end
go

-- Procedimiento para modificar la contraseña del usuario
create or alter procedure socios.modificarContraseñaUsuario
	@id_usuario int,
	@contraseña varchar(40)
as
begin
	if not exists (select 1 from socios.usuario 
					where id_usuario = @id_usuario)
	begin
		print 'No existe un usuario con ese id.'
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
create or alter procedure socios.modificarFechaVigenciaUsuario
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
		if CONVERT(date, GETDATE()) < @fecha_vigencia_contraseña
		update socios.usuario
		set fecha_vigencia_contraseña = @fecha_vigencia_contraseña
		where id_usuario = @id_usuario
	end
end
go

-- Procedimiento para eliminar usuarios
create or alter procedure socios.eliminarUsuario
	@id_usuario int
as
begin
	if not exists (select 1 from socios.usuario where id_usuario = @id_usuario)
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
create or alter procedure socios.insertarObraSocial
	@nombre_obra_social varchar(60),
	@telefono_obra_social int
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
create or alter procedure socios.modificarObraSocial
	@nombre_obra_social varchar(60),
	@telefono_obra_social int
as
begin
	if not exists (select 1 from socios.obra_social 
					where nombre_obra_social = @nombre_obra_social)
	begin
		print 'No existe una obra social con ese nombre.'
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
create or alter procedure socios.eliminarObraSocial
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
create or alter procedure socios.insertarCategoria
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

	else if @edad_minima >= @edad_maxima
	begin
		print 'Es incoherente que la edad minima sea mayor o igual que la maxima.'
	end

	else if @costo_membresia < 0
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
create or alter procedure socios.modificarCostoCategoria
	@nombre_categoria varchar(16),
	@costo_membresia decimal(9,3)
as
begin
	if not exists (select 1 from socios.categoria where nombre_categoria = @nombre_categoria)
	begin
		print 'No existe una categoría con ese nombre.'
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
create or alter procedure socios.eliminarCategoria
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
create or alter procedure socios.insertarResponsableMenor
	@id_socio_menor int,
	@nombre varchar(40),
	@apellido varchar(40),
	@dni int,
	@email varchar(50),
	@fecha_nacimiento date,
	@telefono int,
	@parentesco varchar(30)
as
begin
	if not exists (select 1 from socios.socio 
					where id_socio = @id_socio_menor)
	begin
		print 'No existe un socio con ese id.'
	end

	insert into socios.responsable_menor (
		id_socio_menor, nombre, apellido,
		dni, email, fecha_nacimiento, telefono, parentesco
	)
	values (
		@id_socio_menor, @nombre, @apellido,
		@dni, @email, @fecha_nacimiento, @telefono, @parentesco
	)
end
go

-- Procedimiento para eliminar un responsable de un menor
create or alter procedure socios.eliminarResponsableMenor
	@id_socio_responsable int
as
begin
	if not exists (select 1 from socios.responsable_menor 
					where id_socio_menor = @id_socio_responsable)
	begin
		print 'No existe un responsable de un menor con ese id.'
	end

	delete from socios.responsable_menor
	where id_socio_responsable = @id_socio_responsable
end
go