use master
go

-- Creacion de la base de datos
if exists (
	select name from master.dbo.sysdatabases
	where name = 'sol_norte_grupo3'
)
	Begin
		print 'La base de datos ya existe'
	end
else
	begin
		Create database sol_norte_grupo3
	end
go

Use sol_norte_grupo3
go

if exists(
	select name from sys.schemas
	where name = 'socios'
)
	Begin
		print 'El esquema de los socios ya existe'
	end
Else
	Begin
		exec('Create schema socios')
	end
go

if exists(
	select name from sys.schemas
	where name = 'actividades'
)
	Begin
		print 'El esquema de actividades ya existe'
	end
Else
	Begin
		exec('Create schema actividades')
	end
go

if exists(
	select name from sys.schemas
	where name = 'facturacion'
)
	Begin
		print 'El esquema de actividades ya existe'
	end
Else
	Begin
		exec('Create schema facturacion')
	end
go

IF OBJECT_ID('socios.rol', 'U') IS NULL
Begin
	Create table socios.rol(
		id_rol int,
		nombre varchar(40)	UNIQUE,
		descripcion varchar(200)	UNIQUE,
		Constraint Socios_rol_PK_id_rol Primary key(id_rol)
	)
End
else
begin
	print 'La tabla socios.rol ya existe'
end
go

IF OBJECT_ID('facturacion.medio_de_pago', 'U') IS NULL
Begin
	Create table facturacion.medio_de_pago(
		id_medio_de_pago int identity(1,1),
		nombre_medio_pago varchar(40),
		permite_debito_automatico bit
		Constraint Facturacion_medio_de_pago_PK_id_medio_de_pago Primary key(id_medio_de_pago)
	)
End
else
begin
	print 'La tabla facturacion.medio_de_pago ya existe'
end
go

IF OBJECT_ID('socios.usuario', 'U') IS NULL
Begin
	Create table socios.usuario(
		id_user int identity(1,1),
		id_rol int,
		contraseña varchar(40),
		fecha_vigencia_contraseña date,
		Constraint socios_usuario_PK_id_user Primary key(id_user),
		Constraint socios_usuario_FK_id_rol Foreign Key(id_rol) References socios.rol(id_rol)
	)
End
else
begin
	print 'La tabla socios.usuario ya existe'
end
go

IF OBJECT_ID('socios.obra_social', 'U') IS NULL
Begin
	Create table socios.obra_social(
		id_obra_social int,
		nombre_obra_social varchar(60) UNIQUE,
		telefono_obra_social int
		Constraint Socios_obra_social_PK_id_obra_social Primary key(id_obra_social)
	)
End
else
begin
	print 'La tabla socios.obra_social ya existe'
end
go

IF OBJECT_ID('socios.categoria', 'U') IS NULL
Begin
	Create table socios.categoria(
		id_categoria int,
		nombreCategoria varchar(16) UNIQUE,
		edad_minima int,
		edad_maxima int,
		costo_membresía float
		Constraint Socios_categoria_PK_id_categoria Primary key(id_categoria)
	)
End
else
begin
	print 'La tabla socios.responsable_menor ya existe'
end
go

IF OBJECT_ID('socios.socio', 'U') IS NULL
Begin
	Create table socios.socio(
		id_socio int identity(1,1),
		DNI int	UNIQUE,
		nombre varchar,
		apellido varchar,
		email varchar,
		fecha_nacimiento date,
		telefono_contacto int,
		telefono_emergencia int,
		habilitado bit,
		id_obra_social int,
		id_categoria int,
		id_usuario int,
		id_medio_de_pago int,
		Constraint Socios_socio_PK_id_socio Primary key(id_socio),
		Constraint Socios_socio_FK_id_obra_social Foreign Key(id_obra_social) References socios.obra_social(id_obra_social),
		Constraint Socios_socio_FK_categoria Foreign Key(id_categoria) References socios.categoria(id_categoria),
		Constraint Socios_socio_FK_usuario Foreign Key(id_usuario) References socios.usuario(id_user),
		Constraint Socios_socio_FK_medio_de_pago Foreign Key(id_medio_de_pago) References facturacion.medio_de_pago(id_medio_de_pago)
	)
End
else
begin
	print 'La tabla socios.socio ya existe'
end
go

IF OBJECT_ID('socios.responsable_menor', 'U') IS NULL
Begin
	Create table socios.responsable_menor(
		id_socio_menor int,
		id_socio_responsable int,
		nombre varchar(40),
		apellido varchar(40),
		DNI int,
		email varchar(50),
		fecha_nacimiento date,
		telefono int,
		parentesco varchar(10),
		Constraint Socios_responsable_menor_PK_id_socio_menor
				Primary key(id_socio_menor),
		Constraint Socios_responsable_menor_FK_id_socio_menor
				Foreign key(id_socio_menor) References socios.socio(id_socio),
		Constraint Socios_responsable_menor_FK_id_socio_responsable
				Foreign Key(id_socio_responsable) References socios.socio(id_socio)
	)
End
else
begin
	print 'La tabla socios.responsable_menor ya existe'
end
go

IF OBJECT_ID('actividades.actividad', 'U') IS NULL
Begin
	Create table actividades.actividad(
		id_actividad int identity(1,1),
		nombreActividad varchar(36) UNIQUE,
		costo_mensual float
		Constraint Actividades_actividad_PK_id_actividad Primary key(id_actividad)
	)
End
else
begin
	print 'La tabla actividades.actividad ya existe'
end
go

IF OBJECT_ID('actividades.actividad_extra', 'U') IS NULL
Begin
	Create table actividades.actividad_extra(
		id_actividad int identity(1,1),
		nombreActividad varchar(36) UNIQUE,
		costo float
		Constraint Actividades_actividad_extra_PK_id_actividad Primary key(id_actividad)
	)
End
else
begin
	print 'La tabla actividades.actividad_extra ya existe'
end
go

IF OBJECT_ID('actividades.horario_actividades', 'U') IS NULL
Begin
	Create table actividades.horario_actividades(
		id_horario int identity(1,1),
		dia_semana varchar(8),
		hora_inicio time,
		hora_fin time,
		id_actividad int,
		id_categoria int,
		Constraint Actividades_horario_actividades_PK_id_horario Primary key(id_horario),
		Constraint Actividades_horario_actividades_FK_id_actividad
				Foreign Key(id_actividad) References actividades.actividad(id_actividad),
		Constraint Actividades_horario_actividades_FK_id_categoria
				Foreign Key(id_categoria) References socios.categoria(id_categoria)
	)
End
else
begin
	print 'La tabla actividades.horario_actividades ya existe'
end
go

IF OBJECT_ID('actividades.inscripcion_actividades', 'U') IS NULL
Begin
	Create table actividades.inscripcion_actividades(
		id_inscripcion int identity(1,1),
		id_horario int,
		id_socio int,
		id_actividad int
		Constraint Actividades_inscripcion_actividades_PK_id_inscripcion Primary key(id_inscripcion),
		Constraint Actividades_inscripcion_actividades_FK_id_horario
				Foreign Key(id_horario) References actividades.horario_actividades(id_horario),
		Constraint Actividades_inscripcion_actividades_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio),
		Constraint Actividades_inscripcion_actividades_FK_id_actividad
				Foreign Key(id_actividad) References actividades.actividad(id_actividad)
	)
End
else
begin
	print 'La tabla actividades.inscripcion_actividades ya existe'
end
go

IF OBJECT_ID('actividades.inscripcion_act_extra', 'U') IS NULL
Begin
	Create table actividades.inscripcion_act_extra(
		id_inscripcion_extra int identity(1,1),
		id_socio int,
		id_actividad_extra int,
		fecha date,
		hora_inicio time,
		hora_fin time,
		cant_invitados int
		Constraint Actividades_inscripcion_act_extra_PK_id_inscripcion Primary key(id_inscripcion_extra),
		Constraint Actividades_inscripcion_act_extra_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio),
		Constraint Actividades_inscripcion_actividades_FK_id_actividad_extra
				Foreign Key(id_actividad_extra) References actividades.actividad_extra(id_actividad)
	)
End
else
begin
	print 'La tabla actividades.inscripcion_act_extra ya existe'
end
go

IF OBJECT_ID('facturacion.factura', 'U') IS NULL
Begin
	Create table facturacion.factura(
		id_factura int identity(1,1),
		fecha_emision date,
		primer_vto date,
		segundo_vto date,
		total float,
		total_con_recargo float,
		id_estado varchar,
		id_medio_de_pago int,
		id_socio int
		Constraint Facturacion_factura_PK_id_factura Primary key(id_factura),
		Constraint Facturacion_factura_FK_id_medio_de_pago
				Foreign Key(id_medio_de_pago) References facturacion.medio_de_pago(id_medio_de_pago),
		Constraint Facturacion_factura_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio)
	)
End
else
begin
	print 'La tabla facturacion.factura ya existe'
end
go

IF OBJECT_ID('facturacion.pago', 'U') IS NULL
Begin
	Create table facturacion.pago(
		id_pago int identity(1,1),
		fecha_pago date,
		montoTotal float,
		id_factura int,
		tipo_movimiento varchar,
		--id_medio_pago int,
		Constraint Facturacion_pago_PK_id_pago Primary key(id_pago),
		Constraint Facturacion_pago_FK_id_factura
				Foreign Key(id_factura) References facturacion.factura(id_factura)
	)
End
else
begin
	print 'La tabla facturacion.pago ya existe'
end
go