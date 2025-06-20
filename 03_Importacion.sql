use COM5600G03
go

-- CREACION DE ESQUEMAS Y TABLAS PARA LA IMPORTACION

if exists(
	select name from sys.schemas
	where name = 'importacion'
)
	begin
		print 'El esquema de importacion ya existe'
	end
else
	begin
		exec('create schema importacion')
	end
go

/* CONFIGURACION BASICA PARA QUE FUNCIONE EL SERVIDOR, Y NO SUCEDA EL ERROR DE
   'The OLE DB provider "Microsoft.ACE.OLEDB.12.0" for linked server"',
   esto para no configurarlo manualmente y hacer todo desde el codigo */

sp_configure 'show advanced options', 1
go
reconfigure with override
go
sp_configure 'ad hoc distributed queries', 1
go
reconfigure with override
go
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1
go
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DisallowAdHocAccess', 1
go
exec master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1 
go

-- IMPORTAR DE 'Datos socios.xlsx', en 'Tarifas', la primer tabla

create or alter procedure importacion.cargar_tarifas @file VARCHAR(MAX)
as
begin
	set nocount on

	begin try
		if object_id('tempdb..#TEMP_TARIFAS') is null 
			create table #TEMP_TARIFAS (
				Actividad VARCHAR(16),
				[Valor por mes] INT,
				[Vigente hasta] CHAR(9)
			);

		declare @sql NVARCHAR(MAX);

		set @sql = N'
		insert into #TEMP_TARIFAS (Actividad, [Valor Por Mes], [Vigente hasta])
		select 
				Actividad,
				cast([Valor por mes] as int)        as ValorPorMes,
				cast([Vigente hasta]    as date)   as VigenteHasta
		from openrowset(
				''Microsoft.ACE.OLEDB.12.0'', 
				''Excel 12.0;HDR=YES;IMEX=1;Database=' + replace(@file, '''', '''''') + ''', 
				''SELECT [Actividad], [Valor por mes], [Vigente hasta] 
				  FROM [Tarifas$B2:D8]''
		) as x;';

		exec sp_executesql @sql;

		insert into actividades.actividad(nombre_actividad) 
		select Actividad
		from #TEMP_TARIFAS tp
		where not exists (
			select 1 from actividades.actividad a
			where a.nombre_actividad = tp.Actividad
		)

		insert into actividades.actividad_precios(id_actividad, costo_mensual, vigencia_desde, vigencia_hasta)
		select a.id_actividad, 
           tp.[Valor por mes],
		   getdate(),
           convert(datetime, tp.[Vigente hasta], 103)
		from #TEMP_TARIFAS tp
		join actividades.actividad a on a.nombre_actividad = tp.Actividad;

		print 'El dataset de tarifas fue cargado exitosamente!';
		drop table #TEMP_TARIFAS;
	end try

	begin catch
		declare @ErrorMessage VARCHAR(4000) = error_message(),
				@ErrorLine INT = error_line();

		print 'Ocurrio un error en la carga del dataset: ' + @ErrorMessage + ' (Linea ' + cast(@ErrorLine as varchar(5)) + ')';
	end catch
end
go

-- exec importacion.cargar_tarifas  @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
go

-- IMPORTAR DE 'Datos socios.xlsx', en 'Tarifas', la segunda tabla

create or alter procedure importacion.cargar_cuotas_socios @file VARCHAR(MAX)
as
begin
	set nocount on

	begin try
		if object_id('tempdb..#TEMP_CUOTA_SOCIOS') is null 
			create table #TEMP_CUOTA_SOCIOS (
				[Categoria socio] VARCHAR(15),
				[Valor cuota] INT,
				[Vigente hasta] CHAR(9)
			);

		declare @sql NVARCHAR(MAX);

		set @sql = N'
		insert into #TEMP_CUOTA_SOCIOS ([Categoria socio], [Valor cuota], [Vigente hasta])
		select 
				[Categoria socio],
				cast([Valor cuota] as int),
				cast([Vigente hasta]    as date)
		from openrowset(
				''Microsoft.ACE.OLEDB.12.0'', 
				''Excel 12.0;HDR=YES;IMEX=1;Database=' + replace(@file, '''', '''''') + ''', 
				''SELECT [Categoria socio], [Valor cuota], [Vigente hasta] 
				  FROM [Tarifas$B10:D13]''
		) as x;';

		exec sp_executesql @sql;

		-- Inserto las categorias si no existen, lo pongo generico de 1 a 99 porque se supone que ya deberian estar
		insert into socios.categoria(nombre_categoria, edad_minima, edad_maxima)
		select t.[Categoria socio], 1, 99
		from #TEMP_CUOTA_SOCIOS t
		where not exists (
			select 1 from socios.categoria c
			where c.nombre_categoria = t.[Categoria socio]
		)
		group by t.[Categoria socio]

		-- Inserto los precios de las categorias
		insert into socios.categoria_precios (id_categoria, fecha_vigencia_desde, fecha_vigencia_hasta, costo_membresia)
        select c.id_categoria, GETDATE(), convert(datetime, t.[Vigente hasta], 103), t.[Valor cuota]
        from #TEMP_CUOTA_SOCIOS t
        join socios.categoria c on c.nombre_categoria = t.[Categoria socio];

		print 'El dataset de Cuotas Socios fue cargado exitosamente!';
		drop table #TEMP_CUOTA_SOCIOS;
	end try

	begin catch
		declare @ErrorMessage VARCHAR(4000) = error_message(),
				@ErrorLine INT = error_line();

		print 'Ocurrio un error en la carga del dataset: ' + @ErrorMessage + ' (Linea ' + cast(@ErrorLine as varchar(5)) + ')';
	end catch
end
go

-- exec importacion.cargar_cuotas_socios @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
go

-- IMPORTAR DE 'Datos socios.xlsx', en 'Tarifas', la tercer tabla

create or alter procedure importacion.cargar_tarifas_pileta @file VARCHAR(MAX)
as
begin
	set nocount on;
	begin try
		if object_id('tempdb..#TEMP_RAW_TABLE') is null
			create table #TEMP_RAW_TABLE (
				COL1     VARCHAR(2000),
				COL2     VARCHAR(2000),
				COL3     VARCHAR(2000),
				COL4     VARCHAR(2000),
				COL5     VARCHAR(2000)
			);

		if object_id('tempdb..#TEMP_TARIFAS_PILETA') is null
			create table #TEMP_PILETA (
				Concepto VARCHAR(40),
				Categoria VARCHAR(40),
				[Valor Socios] DECIMAL(9, 2),
				[Valor Invitados] DECIMAL(9, 2),
				[Vigente Hasta] date
			);

		declare @sql NVARCHAR(MAX) = N'
			insert into #TEMP_RAW_TABLE (COL1,COL2,COL3,COL4,COL5)
			select *
			from openrowset(
				''Microsoft.ACE.OLEDB.12.0'',
				''Excel 12.0;HDR=NO;IMEX=1;Database=' + replace(@file,'''','''''') + ''',
				''SELECT * FROM [Tarifas$B16:F22]''
			) as x;
		';

		exec sp_executesql @sql;

		select 
			   coalesce(COL1, lag(COL1) over (order by rn)) as Concepto,
			   COL2 as Categoria,
			   try_cast(replace(replace(replace(COL3, '$', ''), '.', ''), ',', '.') as decimal(9,2)) as [Valor Socios],
			   try_cast(replace(replace(replace(COL4, '$', ''), '.', ''), ',', '.') as decimal(9,2)) as [Valor Invitados],
			   COL5 [Vigente hasta]
		into #TEMP_TARIFAS_PILETA
		from (
				select row_number() over (order by (select null)) as rn,
					COL1, COL2, COL3, COL4, COL5
				from #TEMP_RAW_TABLE
		) as T
			where rn > 1

		-- Inserto primero el 'concepto'
		insert into actividades.concepto_pileta(nombre)
		select distinct Concepto
		from #TEMP_TARIFAS_PILETA tp
		where not exists (select 1
			from actividades.concepto_pileta cp
			where cp.nombre = tp.Concepto)

		-- Inserto la categoria de la pileta
		insert into actividades.categoria_pileta(nombre)
		select distinct Categoria
		from #TEMP_TARIFAS_PILETA tp
		where not exists (select 1
			from actividades.categoria_pileta cp
			where cp.nombre = tp.Categoria)

		-- Insertar tarifas de la pileta
		insert into actividades.tarifa_pileta(id_concepto, id_categoria_pileta,  precio_socio, precio_invitado, vigencia_hasta)
		select c.id_concepto,
			   cat.id_categoria_pileta,
			   try_cast(tp.[Valor Socios] as DECIMAL(9, 3)),
			   try_cast(tp.[Valor Invitados] as DECIMAL(9, 3)),
			   convert(datetime, [Vigente hasta], 103)
		from #TEMP_TARIFAS_PILETA tp
		inner join actividades.concepto_pileta c on c.nombre = tp.concepto
		inner join actividades.categoria_pileta cat on cat.nombre = tp.categoria;

		drop table #TEMP_RAW_TABLE;
		drop table #TEMP_TARIFAS_PILETA;

		print 'El dataset de Tarifas Pileta fue cargado exitosamente!';
	end try
	begin catch
		print 'Error en cargar_tarifas_pileta: ' + error_message();
	end catch
end
go

-- exec importacion.cargar_tarifas_pileta @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';

go

-- TABLA 'RESPONSABLES PAGO'
create or alter procedure importacion.cargar_responsables_de_pago
    @file varchar(max)
as
begin
    set nocount on;
    begin try
        if object_id('tempdb..#TEMP_SOCIOS') is null
            create table #TEMP_SOCIOS (
                [Nro de Socio] varchar(20),
                [Nombre] varchar(50),
                [Apellido] varchar(50),
                [DNI] varchar(20),
                [Email personal] varchar(100),
                [Fecha de nacimiento] varchar(50),
                [Telefono de contacto] INT,
                [Telefono de contacto emerge] INT,
                [Nombre obra social] varchar(100),
                [Nro de socio obra social] varchar(100),
                [Telefono emergencia Obra Social] varchar(100)
            );

        declare @sql nvarchar(max) = N'
		insert into #TEMP_SOCIOS
		select 
			cast([Nro de Socio] as varchar(20)),
			[Nombre],
			[ apellido],
			cast([ DNI] as varchar(20)),
			[ email personal],
			cast([ fecha de nacimiento] as varchar(50)),
			cast([ teléfono de contacto] as INT),
			cast([ teléfono de contacto emergencia] as INT),
			[ Nombre de la obra social o prepaga],
			cast([nro# de socio obra social/prepaga ] as varchar(100)),
			cast([teléfono de contacto de emergencia] as varchar(100))
		 from openrowset(
			''Microsoft.ACE.OLEDB.12.0'',
			''Excel 12.0;HDR=YES;IMEX=1;Database=' + replace(@file, '''', '''''') + ''',
			''SELECT * FROM [Responsables de Pago$A1:K121]''
		) as x;'

        exec sp_executesql @sql;

		insert into socios.obra_social (nombre_obra_social, telefono_obra_social)
		select distinct
			s.[Nombre obra social],
			s.[Telefono emergencia Obra Social]
		from #TEMP_SOCIOS s
		where s.[Nombre obra social] is not null
			and not exists (
				select 1
				from socios.obra_social os
				where os.nombre_obra_social = s.[Nombre obra social]
		)

		delete ts from #TEMP_SOCIOS ts
		join (
			select [DNI], row_number() over(partition by [DNI] order by [Nombre]) as rn
			from #TEMP_SOCIOS
			where [DNI] is not null
		) dup on dup.[DNI] = ts.[DNI]
		where dup.rn > 1;

		SET IDENTITY_INSERT socios.socio ON

		insert into socios.socio (
			id_socio,
			dni,
			nombre,
			apellido,
			email,
			fecha_nacimiento,
			telefono_contacto,
			telefono_emergencia,
			id_obra_social,
			nro_socio_obra_social,
			habilitado
		)
		select
			CAST(PARSENAME(REPLACE(s.[Nro de Socio], '-', '.'), 1) as int),
			TRY_CAST(s.[DNI] as int),
			s.[Nombre],
			s.[Apellido],
			s.[Email personal],
			CONVERT(date, s.[Fecha de nacimiento], 103),
			s.[Telefono de contacto],
			s.[Telefono de contacto emerge],
			os.id_obra_social,
			s.[Nro de socio obra social],
			'HABILITADO'             
		from #TEMP_SOCIOS s
		inner join socios.obra_social os
		on os.nombre_obra_social = s.[Nombre obra social]
		where TRY_CAST(s.[DNI] as int) is not null
		and not exists (
		  select 1 from socios.socio ss where ss.dni = TRY_CAST(s.[DNI] as int)
		)

		SET IDENTITY_INSERT socios.socio OFF

        drop table #TEMP_SOCIOS;

        print 'Se ha importado correctamente el dataset de responsables de pago!';
    end try
    begin catch
        print 'Error en importacion.cargar_responsables_de_pago: ' + error_message();
    end catch
end
go

-- exec importacion.cargar_responsables_de_pago @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx'
go

create or alter procedure importacion.cargar_grupo_familiar @file varchar(max)
as
begin
  set nocount on;

  begin try
    -- si no existe, creo la temp donde volcaré el Excel
    if object_id('tempdb..#TEMP_GRUPO_FAMILIAR') is null
    begin
      create table #TEMP_GRUPO_FAMILIAR (
        [Nro de Socio] varchar(50),
        [Nro de socio responsable] varchar(50),
        [Nombre] varchar(100),
        [Apellido] varchar(100),
        [DNI] INT,
        [Email personal] varchar(200),
        [Fecha de nacimiento] varchar(50),
        [Telefono de contacto] varchar(100),
        [Telefono de contacto emergencia] INT,
        [Nombre obra social] varchar(200),
        [Nro obra social] varchar(50),
        [Telefono contacto de emergencia obra social] varchar(100)
      );
    end

    declare @sql nvarchar(max) = N'
      insert into #TEMP_GRUPO_FAMILIAR
      select *
      from openrowset(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=YES;IMEX=1;Database=' + replace(@file,'''','''''') + ''',
        ''select * from [Grupo Familiar$A2:L35]''
      ) as x;'

    exec sp_executesql @sql;

	update #TEMP_GRUPO_FAMILIAR
    set [Nro de Socio] = CAST(PARSENAME(REPLACE([Nro de Socio], '-', '.'), 1) as int)

    update #TEMP_GRUPO_FAMILIAR
    set [Nro de socio responsable] = CAST(PARSENAME(REPLACE([Nro de socio responsable], '-', '.'), 1) as int)


	-- INSERTO LAS OBRAS SOCIALES (QUE NO ESTEN YA EN LA TABLA)

	insert into socios.obra_social (nombre_obra_social, telefono_obra_social)
	select distinct
		[Nombre obra social],
		[Telefono contacto de emergencia obra social]
	from #TEMP_GRUPO_FAMILIAR
	where [Nombre obra social] is not null
			and not exists (
				select 1
				from socios.obra_social os
				where os.nombre_obra_social = [Nombre obra social]
	)

	-- INSERTO LOS SOCIOS MENORES DE EDAD

	SET IDENTITY_INSERT socios.socio ON
	insert into socios.socio (
		id_socio,
		dni,
		nombre,
		apellido,
		email,
		fecha_nacimiento,
		telefono_contacto,
		telefono_emergencia,
		id_obra_social,
		nro_socio_obra_social,
		habilitado
	)
	select
		[Nro de Socio],
		[DNI],
		[Nombre],
		[Apellido],
		[Email personal],
		CONVERT(date, [Fecha de nacimiento], 103),
		[Telefono de contacto],
		[Telefono de contacto emergencia],
		os.id_obra_social,
		[Nro obra social],
		'HABILITADO'
		from #TEMP_GRUPO_FAMILIAR s
		inner join socios.obra_social os
		on os.nombre_obra_social = s.[Nombre obra social]
		where TRY_CAST(s.[DNI] as int) is not null
		and not exists (
		  select 1 from socios.socio ss where ss.dni = TRY_CAST(s.[DNI] as int)
		)
	SET IDENTITY_INSERT socios.socio OFF

	insert into socios.grupo_familiar (id_socio_menor, id_responsable, parentesco)
	select
		[Nro de Socio],
		[Nro de socio responsable],
		'Familiar'
	from #TEMP_GRUPO_FAMILIAR tf
	join socios.socio s1 on s1.id_socio = tf.[Nro de Socio]
	join socios.socio s2 on s2.id_socio = tf.[Nro de socio responsable]
	where tf.[Nro de socio responsable] is not null;

    print 'El dataset de Grupo Familiar fue cargado exitosamente!';

    drop table #TEMP_GRUPO_FAMILIAR;
  end try
  begin catch
    print 'Error en cargar_grupo_familiar: ' + error_message();
  end catch
end
go

-- exec importacion.cargar_grupo_familiar @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';

go

IF OBJECT_ID('socios.pago_cuotas_historico', 'U') IS NULL
Begin
	CREATE TABLE socios.pago_cuotas_historico(
    id_pago char(200),
	fecha_pago date,
	id_socio int,
	monto decimal(9,2),
	medio_pago varchar(100)
)
End
else
begin
	print 'La tabla socios.pago_cuotas_historico ya existe'
end
go

create or alter procedure socios.insertar_pago_couta_historico(@ruta nvarchar(MAX))
as
begin
	declare @bulkInsertar nvarchar(max)
	set @bulkInsertar =    'bulk insert #pagocuotas
							from ''' + @ruta + '''
							with(
							   fieldterminator = '''+';'+''',
							   rowterminator = '''+'\n'+''',
							   codepage = ''' + 'ACP' + ''',
							   firstrow = 2)'
	
  create table #pagocuotas(
	   idpago varchar(250),
	   fechapago varchar(250),
	   responsablepagoidsocio varchar(250),
	   monto varchar(250),
	   mediopago varchar(250)
   )

   exec sp_executesql @bulkInsertar

   update #pagocuotas
   set responsablepagoidsocio = SUBSTRING(responsablepagoidsocio,4,CHARINDEX('4',responsablepagoidsocio))

   insert into socios.pago_cuotas_historico(id_pago,fecha_pago,id_socio,monto,medio_pago)
   select idpago,cast(fechapago as date),cast(responsablepagoidsocio as int),cast(monto as decimal(9,2)),mediopago
   from #pagocuotas

   drop table #pagocuotas

end
go

--exec socios.insertar_pago_couta_historico 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(pago cuotas).csv'

-- Procedimiento para la importacion de los archivos con datos meteorológicos

CREATE OR ALTER PROCEDURE importacion.importar_archivos_metorologicos(@ruta varchar(MAX),
								@fieldTerminator VARCHAR(3),
								@rowterminator VARCHAR(5),
								@codepage VARCHAR(20),
								@datafiletype VARCHAR(20),
								@firstRow INT)
AS
BEGIN
	IF OBJECT_ID('COM5600G03.facturacion.#tabla_temp_meteo') IS NULL
	BEGIN
		Create table facturacion.#tabla_temp_meteo(
		fecha VARCHAR(100),
		temperatura DECIMAL(3,1),
		precipitaciones DECIMAL(4,2),
		humedad INT,
		viento DECIMAL(4,2)
		)
	END
	ELSE
	BEGIN
		DELETE facturacion.#tabla_temp_meteo
	END

	IF OBJECT_ID('COM5600G03.facturacion.dias_lluviosos') IS NULL
	BEGIN
		CREATE TABLE facturacion.dias_lluviosos(
			fecha DATE PRIMARY KEY,
			lluvia BIT
		)
	END

	DECLARE @SQL VARCHAR(500)
	SET @SQL = 'Bulk insert facturacion.#tabla_temp_meteo
	From ''' + @ruta +'''
	with (
	firstrow = ' + CAST(@firstRow AS VARCHAR(6)) + ',
	rowterminator = ''' + @rowterminator + ''',
	fieldterminator = ''' + @fieldterminator+''',
	codepage = ''' + @codepage + ''',
	DATAFILETYPE = ''' + @datafiletype + ''')'

	EXEC sp_sqlexec @SQL

	INSERT INTO facturacion.dias_lluviosos
	SELECT	CONVERT(DATE, dia),
		CASE
			WHEN SUM(precipitaciones) > 0 THEN 1
			ELSE 0
		END AS hubo_lluvia
	FROM	(SELECT CAST(REPLACE(fecha, 'T', ' ')AS DATETIME) as dia, precipitaciones
			FROM facturacion.#tabla_temp_meteo) T
	GROUP BY CONVERT(DATE, dia)
	ORDER BY CONVERT(DATE, dia)
END
go

--EXEC importacion.importar_archivos_metorologicos 'C:\Users\Maximo\Downloads\open-meteo-buenosaires_2024.csv', ',', '\n', 'ACP', 'char', 4
--EXEC importacion.importar_archivos_metorologicos 'C:\Users\Maximo\Downloads\open-meteo-buenosaires_2025.csv', ',', '\n', 'ACP', 'char', 4

--SELECT * FROM facturacion.dias_lluviosos D ORDER BY D.fecha

-- Procedimiento para la importacion del 'presentismo de actividades'
create or alter procedure importacion.presentismo_actividades @file VARCHAR(MAX)
as
begin
	set nocount on

	begin try
		if object_id('tempdb..#TEMP_PRESENTISMO') is null 
			create table #TEMP_PRESENTISMO (
				[Nro de Socio] VARCHAR(10),
				[Actividad] VARCHAR(25),
				[Fecha de asistencia] CHAR(10),
				[Asistencia] CHAR(2),
				[Profesor] VARCHAR(65)
			);

		declare @sql NVARCHAR(MAX);

		set @sql = N'
		insert into #TEMP_PRESENTISMO ([Nro de Socio], [Actividad], [Fecha de asistencia], [Asistencia], [Profesor])
		select 
				[Nro de Socio],
				Actividad,
				CAST([fecha de asistencia] as date),
				Asistencia,
				Profesor
		from openrowset(
				''Microsoft.ACE.OLEDB.12.0'', 
				''Excel 12.0;HDR=YES;IMEX=1;Database=' + replace(@file, '''', '''''') + ''', 
				''SELECT * FROM [presentismo_actividades$A1:E928]''
		) as x;';

		exec sp_executesql @sql;

		update #TEMP_PRESENTISMO
		set [Nro de Socio] = CAST(PARSENAME(REPLACE([Nro de Socio], '-', '.'), 1) as int)

		print 'El dataset de presentismo fue cargado exitosamente!';

		update #TEMP_PRESENTISMO
		set [Asistencia] = 'P'
		where [Asistencia] = 'PP'

		update #TEMP_PRESENTISMO
		set [Nro de Socio] = SUBSTRING([Nro de Socio],4,CHARINDEX('4',[Nro de Socio]))

		update #TEMP_PRESENTISMO
		set [Profesor] = SUBSTRING([Profesor],0,CHARINDEX(';',[Profesor]))

		--Admite duplicados porque puedo hacer la misma actividad, con el mismo profesor en un mismo dia

		insert into actividades.presentismo(id_socio, nombre_actividad, fecha_asistencia,asistencia,nombre_profesor)
		select [Nro de Socio],[Actividad],[Fecha de asistencia],[Asistencia],[Profesor] from #TEMP_PRESENTISMO

		drop table #TEMP_PRESENTISMO;
	end try

	begin catch
		declare @ErrorMessage VARCHAR(4000) = error_message(),
				@ErrorLine INT = error_line();

		print 'Ocurrio un error en la carga del dataset: ' + @ErrorMessage + ' (Linea ' + cast(@ErrorLine as varchar(5)) + ')';
	end catch
end
go

--exec importacion.presentismo_actividades @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx'