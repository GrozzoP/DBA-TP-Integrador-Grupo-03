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

-- TABLA DE TARIFAS (ACTIVIDADES, 1ra TABLA)

if object_id('importacion.tarifas_actividades', 'U') is null
begin
	create table importacion.tarifas_actividades (
		Actividad VARCHAR(15),
		[Valor por mes] INT,
		[Vigente hasta] DATE
	)
end
else
begin
	print 'La tabla importacion.tarifas_actividades ya existe'
end
go

-- DROP TABLE importacion.tarifas_actividades

-- TABLA DE TARIFAS (CUOTAS, 2da TABLA)

if object_id('importacion.cuotas_socios', 'U') is null
begin
	create table importacion.cuotas_socios (
		[Categoria socio] VARCHAR(15),
		[Valor cuota] INT,
		[Vigente hasta] DATE
	)
end
else
begin
	print 'La tabla importacion.cuotas_socios ya existe'
end
go

-- DROP TABLE importacion.cuotas_socios

-- TABLA DE TARIFAS (PILETA, 3ra TABLA)

if object_id('importacion.tarifas_piletas','U') is null
begin
	create table importacion.tarifas_piletas (
		Concepto      VARCHAR(50),
		Categoria     VARCHAR(30),
		[Valor Socios]   DECIMAL(9,2),
		[Valor Invitados] DECIMAL(9,2),
		[Vigente hasta]  DATE
	);
end
else
begin
	print 'La tabla importacion.tarifas_piletas ya existe'
end
go

-- DROP TABLE importacion.tarifas_piletas

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

		insert into importacion.tarifas_actividades(Actividad, [Valor por mes], [Vigente hasta]) 
		select Actividad, 
			   [Valor por mes], 
			   convert(datetime, [Vigente hasta], 103)
		from #TEMP_TARIFAS;

		print 'El dataset de Tarifas fue cargado exitosamente!';
		drop table #TEMP_TARIFAS;
	end try

	begin catch
		declare @ErrorMessage VARCHAR(4000) = error_message(),
				@ErrorLine INT = error_line();

		print 'Ocurrio un error en la carga del dataset: ' + @ErrorMessage + ' (L�nea ' + cast(@ErrorLine as varchar(5)) + ')';
	end catch
end
go

-- exec importacion.cargar_tarifas  @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
-- select * from importacion.tarifas_actividades;
-- delete from importacion.tarifas_actividades;
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

		insert into importacion.cuotas_socios([Categoria socio], [Valor cuota], [Vigente hasta]) 
		select [Categoria socio], 
			   [Valor cuota], 
			   convert(datetime, [Vigente hasta], 103)
		from #TEMP_CUOTA_SOCIOS;

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
-- select * from importacion.cuotas_socios;
-- delete from importacion.cuotas_socios;
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

		with temp_numerado as (
			select row_number() over (order by (select null)) as rn,
				   COL1, COL2, COL3, COL4, COL5
			from #TEMP_RAW_TABLE
		),
		temp_llenar as (
			-- Si el valor actual es nulo, elige el anterior, de lo contrario, conserva el valor que posee
			select coalesce(COL1, lag(COL1) over (order by rn)) as Concepto,
				   COL2 as Categoria,
				   /* Sacar el simbolo $, sacar el punto de los miles porque no va en el formato, y reemplazar la coma por el punto que representa
					  la separacion entre los enteros y decimales */
				   try_cast(replace(replace(replace(COL3, '$', ''), '.', ''), ',', '.') as decimal(9,2)) as [Valor Socios],
				   -- Lo mismo que el caso anterior
				   try_cast(replace(replace(replace(COL4, '$', ''), '.', ''), ',', '.') as decimal(9,2)) as [Valor Invitados],
				   COL5 as [Vigente hasta]
			from temp_numerado
			where rn > 1
		)

		insert into importacion.tarifas_piletas(Concepto, Categoria, [Valor Socios], [Valor Invitados], [Vigente hasta])
		select Concepto,
			   Categoria,
			   [Valor Socios],
			   [Valor Invitados],
			   convert(datetime, [Vigente hasta], 103)
		from temp_llenar;

		drop table #TEMP_RAW_TABLE;

		print 'El dataset de Tarifas Pileta fue cargado exitosamente!';
	end try
	begin catch
		print 'Error en cargar_tarifas_pileta: ' + error_message();
	end catch
end
go

-- exec importacion.cargar_tarifas_pileta @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
-- select * from importacion.tarifas_piletas;
-- delete from importacion.tarifas_piletas;
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

-- select * from socios.socio
-- select * from socios.obra_social
-- TABLA 'GRUPO FAMILIAR'
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

-- SELECT * FROM socios.socio
-- SELECT * FROM socios.obra_social
-- SELECT * FROM socios.grupo_familiar

go

----------------------------------------------------
--1)
create or alter procedure socios.importar_obra_social(@ruta nvarchar(max))
as
begin 
    declare @bulkInsertar nvarchar(max)
	set @bulkInsertar =    'bulk insert #responsablesdepago
							from ''' + @ruta + '''
							with(
							   fieldterminator = '''+';'+''',
							   rowterminator = '''+'\n'+''',
							   codepage = ''' + 'ACP' + ''',
							   firstrow = 2)'

	create table #responsablesdepago(
	  nrosocio varchar(256),
	  nombre varchar(256),
	  apellido varchar(256),
	  dni varchar(256),
	  email varchar(256),
	  fnacimiento varchar(256),
	  telcontacto varchar(256),
	  telcontactoemergencia varchar(256),
	  nombreobraciocial varchar(256),
	  nrosocioobrasocial varchar(256),
	  telemergenciacontactoObraSocial varchar(256)
    )

	exec sp_executesql @bulkInsertar

	
	insert into obra_social(nombre_obra_social,telefono_obra_social)
	select nombreobraciocial,telemergenciacontactoObraSocial from #responsablesdepago
	group by nombreobraciocial, telemergenciacontactoObraSocial
	
	drop table #responsablesdepago
end
go

--exec socios.importar_obra_social 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(Responsables de Pago).csv'
--select*from socios.obra_social

--sp de socios

create or alter procedure socios.importar_socios(@ruta nvarchar(max))
as
begin 
    declare @bulkInsertar nvarchar(max)
	set @bulkInsertar =    'bulk insert #responsablesdepago
							from ''' + @ruta + '''
							with(
							   fieldterminator = '''+';'+''',
							   rowterminator = '''+'\n'+''',
							   codepage = ''' + 'ACP' + ''',
							   firstrow = 2)'
	declare @dniduplicado nvarchar(max)
	set @dniduplicado = 'with cte(nombre,apellido,dni,duplicada)
							as
							(
							  select nombre,apellido,dni, row_number() over(partition by dni order by dni) as repetida
							  from #responsablesdepago
							)
							update cte
							set dni = NULL
							where duplicada > 1'

	create table #responsablesdepago(
	  nrosocio varchar(256),
	  nombre varchar(256),
	  apellido varchar(256),
	  dni varchar(256),
	  email varchar(256),
	  fnacimiento varchar(256),
	  telcontacto varchar(256),
	  telcontactoemergencia varchar(256),
	  nombreobraciocial varchar(256),
	  nrosocioobrasocial varchar(256),
	  telemergenciacontactoObraSocial varchar(256)
    )

	
	exec sp_executesql @bulkInsertar
	exec sp_executesql @dniduplicado

	update #responsablesdepago
	set fnacimiento = replace(fnacimiento,'19','09')
	where dni = '293367480'

	insert into socios.socio(DNI, nombre, apellido, email, fecha_nacimiento, telefono_contacto, telefono_emergencia,
	habilitado,nro_socio_obra_social)
	select dni,nombre,apellido,email, convert(date, fnacimiento, 103),telcontacto,telcontactoemergencia,
	'HABILITADO',nrosocioobrasocial from #responsablesdepago
	order by nrosocio asc
	
	drop table #responsablesdepago
end
go

--select * from socios.socio
--exec socios.importar_socios 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(Responsables de Pago).csv'

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
   set responsablepagoidsocio = SUBSTRING(responsablepagoidsocio,5,CHARINDEX('-',responsablepagoidsocio))

   insert into socios.pago_cuotas_historico(id_pago,fecha_pago,id_socio,monto,medio_pago)
   select idpago,cast(fechapago as date),cast(responsablepagoidsocio as int),cast(monto as decimal(9,2)),mediopago
   from #pagocuotas

   drop table #pagocuotas

end
go

--exec socios.insertar_pago_couta_historico 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(pago cuotas).csv'
--select*from socios.pago_cuotas_historico