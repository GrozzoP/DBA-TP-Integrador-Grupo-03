USE COM5600G03
go

-- CREACION DE ESQUEMAS Y TABLAS PARA LA administracion

if exists(
	select name from sys.schemas
	where name = 'administracion'
)
	begin
		print 'El esquema de administracion ya existe'
	end
else
	begin
		exec('Create schema administracion')
	end
go

-- TABLA DE TARIFAS (ACTIVIDADES, 1ra TABLA)

IF OBJECT_ID('administracion.tarifas_actividades', 'U') IS NULL
begin
	Create table administracion.tarifas_actividades (
		Actividad VARCHAR(15),
		[Valor por mes] INT,
		[Vigente hasta] DATE
	)
end
else
begin
	print 'La tabla administracion.tarifas_actividades ya existe'
end
go

-- DROP TABLE administracion.tarifas_actividades

-- TABLA DE TARIFAS (CUOTAS, 2da TABLA)

IF OBJECT_ID('administracion.cuotas_socios', 'U') IS NULL
begin
	Create table administracion.cuotas_socios (
		[Categoria socio] VARCHAR(15),
		[Valor cuota] INT,
		[Vigente hasta] DATE
	)
end
else
begin
	print 'La tabla administracion.cuotas_socios ya existe'
end
go

-- DROP TABLE administracion.cuotas_socios

-- TABLA DE TARIFAS (PILETA, 3ra TABLA)

IF OBJECT_ID('administracion.tarifas_piletas','U') IS NULL
BEGIN
    CREATE TABLE administracion.tarifas_piletas (
        Concepto      VARCHAR(50),
        Categoria     VARCHAR(30),
        [Valor Socios]   DECIMAL(9,2),
        [Valor Invitados] DECIMAL(9,2),
        [Vigente hasta]  DATE
    );
END
ELSE
BEGIN
	print 'La tabla administracion.tarifas_piletas ya existe'
END
GO

-- DROP TABLE administracion.tarifas_piletas

/* CONFIGURACION BASICA PARA QUE FUNCIONE EL SERVIDOR, Y NO SUCEDA EL ERROR DE
   'The OLE DB provider "Microsoft.ACE.OLEDB.12.0" for linked server"',
   esto para no configurarlo manualmente y hacer todo desde el codigo */

sp_configure 'show advanced options', 1
GO
RECONFIGURE WITH OverRide
GO
sp_configure 'Ad Hoc Distributed Queries', 1
GO
RECONFIGURE WITH OverRide
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0' , N'DynamicParameters' , 1
GO
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DisallowAdHocAccess', 1
GO

-- IMPORTAR DE 'Datos socios.xlsx', en 'Tarifas', la primer tabla

CREATE OR ALTER PROCEDURE administracion.cargar_tarifas @file VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
	IF OBJECT_ID('tempdb..#TEMP_TARIFAS') IS NULL 
	CREATE TABLE #TEMP_TARIFAS (
		Actividad VARCHAR(16),
		[Valor por mes] INT,
		[Vigente hasta] CHAR(9)
	);

	DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
	INSERT INTO #TEMP_TARIFAS (Actividad, [Valor Por Mes], [Vigente hasta])
	SELECT 
			Actividad,
            CAST([Valor por mes] AS INT)        AS ValorPorMes,
            CAST([Vigente hasta]    AS DATE)   AS VigenteHasta
	FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'', 
            ''Excel 12.0;HDR=YES;IMEX=1;Database=' + REPLACE(@file, '''', '''''') + ''', 
            ''SELECT [Actividad], [Valor por mes], [Vigente hasta] 
              FROM [Tarifas$B2:D8]''
    ) AS X;';

	EXEC sp_executesql @sql;

	INSERT INTO administracion.tarifas_actividades(Actividad, [Valor por mes], [Vigente hasta]) 
	SELECT Actividad, 
		   [Valor por mes], 
		   CONVERT(DATETIME, [Vigente hasta], 103) AS [DD/MM/YYYY]
	FROM #TEMP_TARIFAS;

	PRINT 'El dataset fue cargado exitosamente!';
	DROP TABLE #TEMP_TARIFAS;
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE(),
				@ErrorLine INT = ERROR_LINE()

		PRINT 'Ocurrio un error en la carga del dataset: ' + @ErrorMessage + ' (Línea ' + CAST(@ErrorLine AS VARCHAR(5)) + ')';
	END CATCH
END
GO

-- EXEC administracion.cargar_tarifas  @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
SELECT * FROM administracion.tarifas_actividades;
-- DELETE FROM administracion.tarifas_actividades;

GO

-- IMPORTAR DE 'Datos socios.xlsx', en 'Tarifas', la segunda tabla
CREATE OR ALTER PROCEDURE administracion.cargar_cuotas_socios @file VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
	IF OBJECT_ID('tempdb..#TEMP_CUOTA_SOCIOS') IS NULL 
	CREATE TABLE #TEMP_CUOTA_SOCIOS (
		[Categoria socio] VARCHAR(15),
		[Valor cuota] INT,
		[Vigente hasta] CHAR(9)
	);

	DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
	INSERT INTO #TEMP_CUOTA_SOCIOS ([Categoria socio], [Valor cuota], [Vigente hasta])
	SELECT 
			[Categoria socio],
            CAST([Valor cuota] AS INT),
            CAST([Vigente hasta]    AS DATE)
	FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'', 
            ''Excel 12.0;HDR=YES;IMEX=1;Database=' + REPLACE(@file, '''', '''''') + ''', 
            ''SELECT [Categoria socio], [Valor cuota], [Vigente hasta] 
              FROM [Tarifas$B10:D13]''
    ) AS X;';

	EXEC sp_executesql @sql;

	INSERT INTO administracion.cuotas_socios([Categoria socio], [Valor cuota], [Vigente hasta]) 
	SELECT [Categoria socio], 
		   [Valor cuota], 
		   CONVERT(DATETIME, [Vigente hasta], 103) AS [DD/MM/YYYY]
	FROM #TEMP_CUOTA_SOCIOS;

	PRINT 'El dataset fue cargado exitosamente!';
	DROP TABLE #TEMP_CUOTA_SOCIOS;
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage VARCHAR(4000) = ERROR_MESSAGE(),
				@ErrorLine INT = ERROR_LINE()

		PRINT 'Ocurrio un error en la carga del dataset: ' + @ErrorMessage + ' (Línea ' + CAST(@ErrorLine AS VARCHAR(5)) + ')';
	END CATCH
END
GO

-- EXEC administracion.cargar_cuotas_socios @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
SELECT * FROM administracion.cuotas_socios;
-- DELETE FROM administracion.cuotas_socios;
GO

-- IMPORTAR DE 'Datos socios.xlsx', en 'Tarifas', la tercer tabla
CREATE OR ALTER PROCEDURE administracion.cargar_tarifas_pileta @file VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
    IF OBJECT_ID('tempdb..#TEMP_RAW_TABLE') IS NULL
      CREATE TABLE #TEMP_RAW_TABLE (
        COL1     VARCHAR(2000) ,
        COL2     VARCHAR(2000),
        COL3     VARCHAR(2000),
        COL4     VARCHAR(2000),
        COL5     VARCHAR(2000)
      );

    DECLARE @sql NVARCHAR(MAX) = N'
      INSERT INTO #TEMP_RAW_TABLE (COL1,COL2,COL3,COL4,COL5)
      SELECT *
      FROM OPENROWSET(
        ''Microsoft.ACE.OLEDB.12.0'',
        ''Excel 12.0;HDR=NO;IMEX=1;Database=' + REPLACE(@file,'''','''''') + ''',
        ''SELECT * FROM [Tarifas$B16:F22]''
      ) AS X;
    ';

    EXEC sp_executesql @sql;

	WITH temp_numerado AS (
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) as rn,
		COL1, COL2, COL3, COL4, COL5
		FROM #TEMP_RAW_TABLE
	),
	temp_llenar AS (
		-- Si el valor actual es nulo, elige el anterior, de lo contrario, conserva el valor que posee
		SELECT Concepto = COALESCE(COL1, LAG(COL1) OVER (ORDER BY rn)),
		-- La categoria es un varchar, asi que no hace falta modificarlo
		COL2 AS Categoria, 
		/* Sacar el simbolo $, sacar el punto de los miles porque no va en el formato, y reemplazar la coma por el punto que representa
		   la separacion entre los enteros y decimales */
		TRY_CAST(REPLACE(REPLACE(REPLACE(COL3, '$', ''), '.', ''), ',', '.') AS DECIMAL(9,2)) AS [Valor Socios],
		-- Lo mismo que el caso anterior
		TRY_CAST(REPLACE(REPLACE(REPLACE(COL4, '$', ''), '.', ''), ',', '.') AS DECIMAL(9,2)) AS [Valor Invitados],
		COL5 as [Vigente hasta]
		FROM temp_numerado
		WHERE rn > 1
	)

	INSERT INTO administracion.tarifas_piletas(Concepto, Categoria, [Valor Socios], [Valor Invitados], [Vigente hasta]) 
	SELECT Concepto, 
		   Categoria, 
		   [Valor Socios],
		   [Valor Invitados],
		   CONVERT(DATETIME, [Vigente hasta], 103) AS [DD/MM/YYYY]
	FROM temp_llenar;

	DROP TABLE #TEMP_RAW_TABLE;

    PRINT 'El dataset fue cargado exitosamente!';
	END TRY
	BEGIN CATCH
		PRINT 'Error en cargar_tarifas_piletas: ' + ERROR_MESSAGE();
	END CATCH
END
GO

-- EXEC administracion.cargar_tarifas_pileta @file = 'D:\Base\Universidad\Tercer anio\1er cuatrimestre\Bases de datos aplicadas\DBA-TP-Integrador-Grupo-03\ArchivosImportacion\Datos socios.xlsx';
SELECT * FROM administracion.tarifas_piletas;
GO
-- DELETE FROM administracion.tarifas_piletas;


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
	habilitado,nro_socio_obrasocial)
	select dni,nombre,apellido,email, convert(date, fnacimiento, 103),telcontacto,telcontactoemergencia,
	'HABILITADO',nrosocioobrasocial from #responsablesdepago
	order by nrosocio asc
	
	drop table #responsablesdepago
end
go

--select*from socios.socio
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