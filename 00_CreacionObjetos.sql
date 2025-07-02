/*
Luego de decidirse por un motor de base de datos relacional, llegó el momento de generar la 
base de datos. En esta oportunidad utilizarán SQL Server. 
Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle 
las configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos, 
etc.) en un documento como el que le entregaría al DBA. 
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar 
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es 
entregado en una sola ejecución). Incluya comentarios para indicar qué hace cada módulo 
de código.  
Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, 
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla. 
Los nombres de los store procedures NO deben comenzar con “SP”.  
Algunas operaciones implicarán store procedures que involucran varias tablas, uso de 
transacciones, etc. Puede que incluso realicen ciertas operaciones mediante varios SPs. 
Asegúrense de que los comentarios que acompañen al código lo expliquen. 
Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto 
en la creación de objetos. NO use el esquema “dbo”.  
Todos los SP creados deben estar acompañados de juegos de prueba. Se espera que 
realicen validaciones básicas en los SP (p/e cantidad mayor a cero, CUIT válido, etc.) y que 
en los juegos de prueba demuestren la correcta aplicación de las validaciones. 
Las pruebas deben realizarse en un script separado, donde con comentarios se indique en 
cada caso el resultado esperado 
El archivo .sql con el script debe incluir comentarios donde consten este enunciado, la fecha 
de entrega, número de grupo, nombre de la materia, nombres y DNI de los alumnos.  
Entregar todo en un zip (observar las pautas para nomenclatura antes expuestas) mediante 
la sección de prácticas de MIEL. Solo uno de los miembros del grupo debe hacer la entrega.

    BASE DE DATOS APLICADAS

Fecha de entrega: 19-06-2025
Comision: 5600
Numero de grupo: 03

-Lazarte Ulises 42838702
-Maximo Bertolin Graziano 46364320
-Jordi Marcelo Pairo Albarez 41247253
-Franco Agustin Grosso 46024348
*/

/*
Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar 
un archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es 
entregado en una sola ejecución). Incluya comentarios para indicar qué hace cada módulo 
de código.  
*/

-- DROP DATABASE [COM5600G03]

use master
go

-- Creacion de la base de datos
if exists (
	select name from master.dbo.sysdatabases
	where name = 'COM5600G03'
)
	begin
		print 'La base de datos ya existe'
	end
else
	begin
		create database COM5600G03
	end
go

use COM5600G03
go

-- Creacion del esquema de los socios
if exists(
	select name from sys.schemas
	where name = 'socios'
)
	begin
		print 'El esquema de los socios ya existe'
	end
else
	begin
		exec('Create schema socios')
	end
go

-- Creacion del esquema de actividades
if exists(
	select name from sys.schemas
	where name = 'actividades'
)
	begin
		print 'El esquema de actividades ya existe'
	end
else
	begin
		exec('Create schema actividades')
	end
go

-- Creacion del esquema de facturacion
if exists(
	select name from sys.schemas
	where name = 'facturacion'
)
	begin
		print 'El esquema de facturacion ya existe'
	end
else
	begin
		exec('Create schema facturacion')
	end
go

-- Creacion de la tabla socios.rol
IF OBJECT_ID('socios.rol', 'U') IS NULL
begin
	Create table socios.rol(
		id_rol int identity(1, 1),
		nombre varchar(40) UNIQUE not null,
		descripcion varchar(200),
		Constraint Socios_rol_PK_id_rol Primary key(id_rol),
		Constraint CK_Nombre_No_Vacio CHECK(LTRIM(RTRIM(nombre)) <> '')
	)
end
else
begin
	print 'La tabla socios.rol ya existe'
end
go

-- Creacion de la tabla facturacion.medio_de_pago
IF OBJECT_ID('facturacion.medio_de_pago', 'U') IS NULL
begin
	Create table facturacion.medio_de_pago(
		id_medio_de_pago int identity(1, 1),
		nombre_medio_pago varchar(40),
		permite_debito_automatico bit 
		Constraint Facturacion_medio_de_pago_PK_id_medio_de_pago Primary key(id_medio_de_pago)
	)
end
else
begin
	print 'La tabla facturacion.medio_de_pago ya existe'
end
go

-- Creacion de la tabla socios.usuario
IF OBJECT_ID('socios.usuario', 'U') IS NULL
begin
	Create table socios.usuario(
		id_usuario int identity(1,1),
		id_rol int,
		usuario varchar(40) UNIQUE,
		contraseña varchar(40) not null,
		fecha_vigencia_contraseña date,
		saldo decimal(10, 2) default 0,
		Constraint socios_usuario_PK_id_user Primary key(id_usuario),
		Constraint socios_usuario_FK_id_rol Foreign Key(id_rol) References socios.rol(id_rol)
	)
end
else
begin
	print 'La tabla socios.usuario ya existe'
end
go


-- Creacion de la tabla socios.obra_social
IF OBJECT_ID('socios.obra_social', 'U') IS NULL
Begin
	Create table socios.obra_social(
		id_obra_social int identity(1, 1),
		nombre_obra_social varchar(60) UNIQUE,
		telefono_obra_social varchar(30)
		Constraint Socios_obra_social_PK_id_obra_social Primary key(id_obra_social)
	)
End
else
begin
	print 'La tabla socios.obra_social ya existe'
end
go

-- Creacion de la tabla socios.categoria
if OBJECT_ID('socios.categoria', 'U') IS NULL
begin
	Create table socios.categoria(
		id_categoria int identity(1,1),
		nombre_categoria varchar(16) unique,
		edad_minima int,
		edad_maxima int,
		costo_membresia decimal(10, 2)
		constraint Socios_categoria_PK_id_categoria primary key(id_categoria)
	)
end
else
begin
	print 'La tabla socios.categoria ya existe'
end
go

-- Creacion de la tabla socios.categoria_precios
if OBJECT_ID('socios.categoria_precios', 'U') IS NULL
begin
	Create table socios.categoria_precios(
		id_precio int identity(1, 1),
		id_categoria int not null,
		fecha_vigencia_desde date not null,
		fecha_vigencia_hasta date,
		costo_membresia decimal(10, 2),
		constraint categoria_precios_historicos_PK primary key(id_precio),
		constraint categoria_precios_historico_FK_id_categoria foreign key(id_categoria)
			references socios.categoria(id_categoria)
	)
end
else
begin
	print 'La tabla  socios.categoria_precios ya existe'
end
go

-- Crear indice para acelerar la busqueda en el caso de precios historicos de las categorias
if not exists (
    select 1
    from sys.indexes
    where name = 'IX_categoria_precios'
    and object_id = object_id('socios.categoria_precios')
)
begin
    create nonclustered index IX_categoria_precios
    on socios.categoria_precios(id_categoria, fecha_vigencia_desde, fecha_vigencia_hasta)
end
else
begin
    print 'El índice IX_categoria_precios ya existe'
end
go

-- Creacion de la tabla socios.socio
IF OBJECT_ID('socios.socio', 'U') IS NULL
Begin
	Create table socios.socio(
		id_socio int IDENTITY(1, 1),
		DNI int	UNIQUE,
		nombre varchar(40),
		apellido varchar(40),
		email varchar(150),
		fecha_nacimiento date,
		telefono_contacto char(18),
		telefono_emergencia char(18),
		habilitado varchar(15) check (habilitado like 'HABILITADO' or habilitado LIKE 'NO HABILITADO'),
		id_obra_social int null,
		nro_socio_obra_social char(50),
		id_categoria int,
		id_usuario int,
		id_medio_de_pago int,
		Constraint Socios_socio_PK_id_socio Primary key(id_socio),
		Constraint Socios_socio_FK_id_obra_social Foreign Key(id_obra_social) References socios.obra_social(id_obra_social),
		Constraint Socios_socio_FK_categoria Foreign Key(id_categoria) References socios.categoria(id_categoria),
		Constraint Socios_socio_FK_usuario Foreign Key(id_usuario) References socios.usuario(id_usuario),
		Constraint Socios_socio_FK_medio_de_pago Foreign Key(id_medio_de_pago) References facturacion.medio_de_pago(id_medio_de_pago)
	)
End
else
begin
	print 'La tabla socios.socio ya existe'
end
go

-- Creacion de la tabla socios.grupo_familiar
IF OBJECT_ID('socios.grupo_familiar', 'U') IS NULL
begin
	Create table socios.grupo_familiar(
		id_socio_menor int,
		id_responsable int,
		parentesco varchar(15),
		Constraint Grupo_familiar_id_socio_y_responsable Primary key (id_socio_menor, id_responsable),
		Constraint Grupo_familiar_fk_responsable foreign key (id_responsable) references socios.socio(id_socio),
		Constraint Grupo_familiar_fk_socio_menor foreign key (id_socio_menor) references socios.socio(id_socio)
	)
end
else
begin
	print 'La tabla socios.grupo_familiar ya existe'
end
go

-- Creacion de la tabla actividades.actividad
IF OBJECT_ID('actividades.actividad', 'U') IS NULL
Begin
	Create table actividades.actividad(
		id_actividad int identity(1,1),
		nombre_actividad varchar(36) UNIQUE,
		precio_mensual decimal(10, 2)
		Constraint Actividades_actividad_PK_id_actividad Primary key(id_actividad)
	)
End
else
begin
	print 'La tabla actividades.actividad ya existe'
end
go

-- Creacion de la tabla actividades.actividad_precios
IF OBJECT_ID('actividades.actividad_precios', 'U') IS NULL
begin
	Create table actividades.actividad_precios(
		id_precio int identity(1,1),
		id_actividad int not null,
		costo_mensual decimal(10, 2) not null,
		vigencia_desde date,
		vigencia_hasta date null
		constraint Actividades_precios_PK primary key(id_precio),
		constraint FK_actividad_precio_actividad 
			foreign key (id_actividad) references actividades.actividad(id_actividad)
	)
end
else
begin
	print 'La tabla actividades.actividad_precios ya existe'
end
go

-- Creacion de la tabla actividades.actividad_extra
IF OBJECT_ID('actividades.actividad_extra', 'U') IS NULL
Begin
	Create table actividades.actividad_extra(
		id_actividad int identity(1,1),
		nombre_actividad varchar(36) UNIQUE,
		costo decimal(10, 2)
		Constraint Actividades_actividad_extra_PK_id_actividad Primary key(id_actividad)
	)
End
else
begin
	print 'La tabla actividades.actividad_extra ya existe'
end
go

-- Crear la tabla para los profesores, actividades.profesor
if OBJECT_ID('actividades.profesor') IS NULL
begin
	create table actividades.profesor(
		id_profesor int identity(1, 1),
		nombre_apellido varchar(45),
		email varchar(50) UNIQUE,
		constraint Actividades_id_profesor_PK Primary key(id_profesor)
	)
end
else
begin
	print 'La tabla actividades.profesor ya existe'
end
go

-- Creacion de la tabla actividades.horario_actividades
if OBJECT_ID('actividades.horario_actividades', 'U') IS NULL
begin
	Create table actividades.horario_actividades(
		id_horario int identity(1,1),
		dia_semana varchar(18),
		hora_inicio time,
		hora_fin time,
		id_actividad int,
		id_categoria int,
		id_profesor int
		Constraint Actividades_horario_PK_id_horario Primary key(id_horario),
		Constraint Actividades_horario_FK_id_actividad
				Foreign Key(id_actividad) References actividades.actividad(id_actividad),
		Constraint Actividades_horario_FK_id_categoria
				Foreign Key(id_categoria) References socios.categoria(id_categoria),
		Constraint Actividades_horario_FK_id_profesor
				Foreign Key(id_profesor) References actividades.profesor(id_profesor)
				ON DELETE SET NULL
	)
end
else
begin
	print 'La tabla actividades.horario_actividades ya existe'
end
go

-- Creacion de la tabla actividades.inscripcion_actividades
if OBJECT_ID('actividades.inscripcion_actividades', 'U') IS NULL
begin
	Create table actividades.inscripcion_actividades(
		id_inscripcion int identity(1,1),
		id_socio int not null,
		id_actividad int not null,
		fecha_inscripcion datetime DEFAULT GETDATE()
		Constraint Actividades_inscripcion_actividades_PK_id_inscripcion Primary key(id_inscripcion),
		Constraint Actividades_inscripcion_actividades_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio),
		Constraint Actividades_inscripcion_actividades_FK_id_actividad
				Foreign Key(id_actividad) References actividades.actividad(id_actividad)
	)
end
else
begin
	print 'La tabla actividades.inscripcion_actividades ya existe'
end
go

-- Crear indice para acelerar la busqueda con los id_socio + id_actividad
if not exists (
    select 1
    from sys.indexes
    where name = 'IX_inscripcion_actividades_id_socio_id_actividad'
    and object_id = object_id('actividades.inscripcion_actividades')
)
begin
    create nonclustered index IX_inscripcion_actividades_id_socio_id_actividad
    on actividades.inscripcion_actividades(id_socio, id_actividad)
end
else
begin
    print 'El índice IX_inscripcion_actividades_id_socio_id_actividad ya existe!'
end
go

-- Creacion de la tabla actividades.inscripcion_actividades_horarios
if object_id('actividades.inscripcion_actividades_horarios', 'U') is null
begin
    create table actividades.inscripcion_actividades_horarios(
        id_inscripcion int not null,
        id_horario int not null,
		constraint Activividades_inscripcion_horarios_FK_id_inscripcion foreign key(id_inscripcion)
				references actividades.inscripcion_actividades(id_inscripcion),
        constraint Activividades_inscripcion_horarios_FK_id_horario foreign key(id_horario)
				references actividades.horario_actividades(id_horario),
        constraint Actividades_inscripcion_horarios_PK_id_inscripcion_horario primary key(id_inscripcion, id_horario)
    )
end
else
    print 'La tabla actividades.inscripcion_actividades_horarios ya existe';
go

-- Creacion de la tabla actividades.inscripcion_act_extra
if OBJECT_ID('actividades.inscripcion_act_extra', 'U') IS NULL
begin
	create table actividades.inscripcion_act_extra(
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
end
else
begin
	print 'La tabla actividades.inscripcion_act_extra ya existe'
end
go

-- Creacion de la tabla facturacion.factura
if OBJECT_ID('facturacion.factura', 'U') IS NULL
begin
	Create table facturacion.factura(
		id_factura int identity(1,1),
		id_socio int,
		fecha_emision date,
		primer_vto date,
		segundo_vto date,
		total decimal(10,2),
		total_con_recargo decimal(10, 2),
		periodo_desde date,
		periodo_hasta date,
		estado varchar(30) check (estado IN ('PAGADO', 'NO PAGADO')),
		razon_social varchar(80),
		dni int,
		tipo_comprobante char(1) default 'B',
		punto_venta varchar(40) default 'Club SQL Norte Janson 1145',
		condicion_frente_iva varchar(30) default 'IVA Sujeto extento',
		email varchar(30) default 'sqlnorte10@gmail.com',
		Constraint Facturacion_factura_PK_id_factura Primary key(id_factura),
		Constraint Facturacion_factura_FK_id_socio Foreign key (id_socio) references socios.socio(id_socio)
	)
end
else
begin
	print 'La tabla facturacion.factura ya existe'
end
go

-- Creacion de la tabla facturacion.detalle_factura
if OBJECT_ID('facturacion.detalle_factura', 'U') IS NULL
begin
	Create table facturacion.detalle_factura(
		id_detalle_factura int identity(1, 1),
		id_factura int,
		servicio varchar(60),
		precio_unitario decimal(10, 2),
		subtotal decimal(10, 2),
		cantidad tinyint DEFAULT 1
		Constraint Facturacion_detalle_factura_PK_id_factura Primary key(id_detalle_factura),
		Constraint Facturacion_detalle_factura_FK_id_factura
				Foreign Key(id_factura) References facturacion.factura(id_factura)
	)
end
else
begin
	print 'La tabla facturacion.detalle_factura ya existe'
end
go

-- Creacion de la tabla facturacion.pago
if OBJECT_ID('facturacion.pago', 'U') IS NULL
begin
	create table facturacion.pago(
		id_pago int identity(1,1),
		fecha_pago date,
		monto_total decimal(10, 2),
		id_factura int,
		tipo_movimiento varchar(20),
		id_medio_pago int,
		id_socio int,
		Constraint Facturacion_pago_PK_id_pago Primary key(id_pago),
		Constraint Facturacion_pago_FK_id_factura
				Foreign Key(id_factura) References facturacion.factura(id_factura),
		Constraint Facturacion_pago_FK_id_medio_pago
				Foreign Key(id_medio_pago) References facturacion.medio_de_pago(id_medio_de_pago),
		Constraint Facturacion_pago_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio)
	)
end
else
begin
	print 'La tabla facturacion.pago ya existe'
end
go

-- Creacion de las tablas vinculadas con la pileta
-- Crear la tabla del concepto de la pileta
if OBJECT_ID('actividades.concepto_pileta') IS NULL
begin
	create table actividades.concepto_pileta(
		id_concepto int identity(1, 1),
		nombre varchar(30) not null unique,
		constraint Actividades_concepto_pileta_PK Primary key(id_concepto),
	)
end
else
begin
	print 'La tabla actividades.concepto_pileta ya existe'
end
go

-- Crear la tabla de la categoira de la pileta
if OBJECT_ID('actividades.categoria_pileta') IS NULL
begin
	create table actividades.categoria_pileta(
		id_categoria_pileta int identity(1, 1),
		nombre varchar(30) not null unique,
		constraint Actividades_id_categoria_pileta_PK Primary key(id_categoria_pileta)
	)
end
else
begin
	print 'La tabla actividades.categoria_pileta ya existe'
end
go

-- Crear la tabla vinculada con las tarifas de las piletas
if OBJECT_ID('actividades.tarifa_pileta') IS NULL
begin
	create table actividades.tarifa_pileta(
		id_tarifa int identity(1, 1),
		id_concepto int not null,
		id_categoria_pileta int,
		precio_socio decimal(9, 2),
		precio_invitado decimal(9, 2),
		vigencia_hasta date,
		Constraint Actividades_tarifa_pileta_PK Primary Key(id_tarifa),
		Constraint Actividades_concepto_pileta_FK_id_concepto
				Foreign Key(id_concepto) References actividades.concepto_pileta(id_concepto),
		Constraint Actividades_categoria_tarifa_pileta_FK_id_categoria_pileta
				Foreign Key(id_categoria_pileta) References actividades.categoria_pileta(id_categoria_pileta)
	)
end
else
begin
	print 'La tabla actividades.tarifa_pileta ya existe'
end
go

-- Crear la tabla vinculada con el invitado de un socio a la pileta
if OBJECT_ID('actividades.invitado_pileta') IS NULL
begin
	create table actividades.invitado_pileta(
		id_invitado int identity(1, 1),
		id_socio int not null,
		nombre varchar(40),
		apellido varchar(40),
		DNI int,
		edad int,
		Constraint Actividades_id_invitado_pileta_PK Primary Key(id_invitado),
		Constraint Actividades_id_socio_pileta_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio)
	)
end
else
begin
	print 'La tabla actividades.invitado_pileta ya existe'
end
go

-- Creacion de la tabla de acceso a la pileta
if OBJECT_ID('actividades.acceso_pileta') IS NULL
begin
	create table actividades.acceso_pileta(
		id_acceso int identity(1, 1),
		fecha_inscripcion date,
		id_socio int not null,
		id_invitado int,
		id_tarifa int not null,
		id_factura int not null,
		Constraint Actividades_id_acceso_pileta_PK Primary Key(id_acceso),
		Constraint Actividades_id_socio_acceso_pileta_FK_id_socio
				Foreign Key(id_socio) References socios.socio(id_socio),
		Constraint Actividades_id_tarifa_acceso_pileta_FK_id_tarifa
				Foreign Key(id_socio) References actividades.tarifa_pileta(id_tarifa),
		Constraint Actividades_id_factura_acceso_pileta_FK_id_factura
				Foreign Key(id_factura) References facturacion.factura(id_factura)
	)
end
else
begin
	print 'La tabla actividades.acceso_pileta ya existe'
end
go

--Creacion de la tabla facturacion_dias_lluviosos
IF OBJECT_ID('COM5600G03.facturacion.dias_lluviosos') IS NULL
BEGIN
	CREATE TABLE facturacion.dias_lluviosos(
		fecha DATE PRIMARY KEY,
		lluvia BIT
	)
END
ELSE
BEGIN
	print 'la tabla facturacion.dias_lluviosos ya existe'
END
go

--Creacion del trigger facturacion.inserta_dias_lluviosos para la tabla facturacion.dias_lluviosos
CREATE OR ALTER TRIGGER facturacion.inserta_dias_lluviosos ON facturacion.dias_lluviosos INSTEAD OF INSERT
AS BEGIN
	UPDATE facturacion.dias_lluviosos
	SET lluvia = (SELECT I.lluvia FROM inserted I WHERE I.fecha = facturacion.dias_lluviosos.fecha)
	WHERE EXISTS (SELECT 1 FROM inserted I WHERE facturacion.dias_lluviosos.fecha = I.fecha)

	INSERT INTO facturacion.dias_lluviosos SELECT I.fecha, I.lluvia
								FROM inserted I
								WHERE I.fecha NOT IN (SELECT DF.fecha FROM facturacion.dias_lluviosos DF)
END
go


IF OBJECT_ID('COM5600G03.actividades.presentismo') IS NULL
BEGIN
	CREATE TABLE actividades.presentismo(
		id_presentismo int identity(1, 1),
		id_socio int,
		id_actividad int,
		fecha_asistencia date,
		asistencia char(2) check (asistencia like 'P' or asistencia like 'A' or asistencia like 'J'),
		id_profesor int,
		Constraint id_socio_FK_Presentismo_Socios foreign key (id_socio) references socios.socio(id_socio),
		Constraint id_actividad_FK_Presentismo_Socios foreign key (id_actividad) references actividades.actividad(id_actividad),
		Constraint id_profesor_FK_Presentismo_Socios foreign key (id_profesor) references actividades.profesor(id_profesor),
		Constraint Actividades_id_presentismo_PK Primary Key(id_presentismo)
	)
END
ELSE
BEGIN
	print 'La tabla actividades.presentismo ya existe'
END
go


IF OBJECT_ID('COM5600G03.actividades.Sum_Reservas') IS NULL
BEGIN
	CREATE TABLE actividades.Sum_Reservas(
		id_reserva int identity(1,1),
		monto decimal(10, 2),
		fecha_reserva date,
		estado varchar(100) default 'RESERVADO'
    )
END
ELSE
BEGIN
	print 'La tabla actividades.Sum_Reservas ya existe'
END
go

IF OBJECT_ID('socios.pago_cuotas_historico', 'U') IS NULL
Begin
	CREATE TABLE socios.pago_cuotas_historico(
    id_pago bigint,
	fecha_pago date,
	id_socio int,
	monto decimal(10, 2),
	medio_pago varchar(100),
	Constraint Pago_historico_id_pago_PK Primary Key(id_pago)
)
End
else
begin
	print 'La tabla socios.pago_cuotas_historico ya existe'
end
go