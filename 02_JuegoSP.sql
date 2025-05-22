Use COM5600G03
go
--
/*****	socios.insertarRol(@nombre_rol varchar(20), @descripcion_rol varchar(50))	******/
create or alter procedure juegoDePruebaInsertarRol
as
begin
	delete from socios.rol
	DBCC CHECKIDENT ('socios.rol', RESEED, 0);
	--Se espera que se inserten los sig registros
	exec socios.insertarRol 'a', 'a'
	exec socios.insertarRol 'b', 'a'
	exec socios.insertarRol '', ''
	exec socios.insertarRol NULL, NULL
	exec socios.insertarRol 'aaaaaaaaaaaaaaaaaaab',  'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab'
	--Se espera que se inserte pero con
	--nombre = aaaaaaaaaaaaaaaaaaaa y descripcion = aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
	exec socios.insertarRol 'aaaaaaaaaaaaaaaaaaaab', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab'
	--Se espera mensaje 'El rol que se quiere insertar ya existe en la tabla.'
	exec socios.insertarRol 'a', 'b'
	exec socios.insertarRol '', 'a'
end

go

exec juegoDePruebaInsertarRol

go

/*****	socios.modificarRol(@nombre_rol varchar(20), @nueva_descripcion_rol varchar(50))	*****/
create or alter procedure juegoDePruebaModificarRol
as
begin
	delete from socios.rol
	DBCC CHECKIDENT ('socios.rol', RESEED, 0);
	--Insertando registros para prueba
	exec socios.insertarRol 'a', 'original'
	exec socios.insertarRol 'b', 'original'
	exec socios.insertarRol '', 'original'
	--Se espera que los registros anteriores vean su descripcion = 'modificado'
	exec socios.modificarRol 'a', 'modificado'
	exec socios.modificarRol 'b', 'modificado'
	exec socios.modificarRol '', 'modificado'
	--Se espera mensaje 'El rol que se quiere modificar, no existe segun su nombre.'
	exec socios.modificarRol 'c', 'modificado'
	exec socios.modificarRol 'd', 'modificado'
end

go

exec juegoDePruebaModificarRol

go

/*****	socios.eliminarRol(@nombre_rol varchar(20))	*****/
create or alter procedure juegoDePrubaEliminarRol
as
begin
	delete from socios.rol
	DBCC CHECKIDENT ('socios.rol', RESEED, 0);
	--Insertando registros para prueba
	exec socios.insertarRol 'a', 'a'
	exec socios.insertarRol 'b', 'b'
	exec socios.insertarRol '', ''
	--Se espera la eliminacion exitosa de los registro anteriores
	exec socios.eliminarRol 'a'
	exec socios.eliminarRol 'b'
	exec socios.eliminarRol ''
	--Se espera mensaje 'El rol que se quiere eliminar, no existe segun su nombre.'
	exec socios.eliminarRol 'noExiste'
end

go

exec juegoDePrubaEliminarRol

go

/*****	
	socios.insertarUsuario
						@id_rol int,
						@contraseña varchar(40),
						@fecha_vigencia_contraseña date	
													*****/
create or alter procedure juegoDePruebaInsertarUsuario
as
begin
	delete from socios.usuario
	delete from socios.rol
	DBCC CHECKIDENT ('socios.rol', RESEED, 0);
	DBCC CHECKIDENT ('socios.usuario', RESEED, 0);
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
end

go

exec juegoDePruebaInsertarUsuario

"