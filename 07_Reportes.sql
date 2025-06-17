/*
Reporte 1
---------

Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un 
rango de fechas a ingresar.  El reporte debe contener los siguientes datos: 
Nombre del reporte: Morosos Recurrentes 
Período: rango de fechas 
Nro de socio 
Nombre y apellido. 
Mes incumplido 
Ordenados de Mayor a menor por ranking de morosidad 
El mismo debe ser desarrollado utilizando Windows Function.

Reporte 2
---------

Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca 
el reporte tomando como inicio enero. 
*/

use [COM5600G03]
go

--Reporte 1
create or alter procedure morosos_recurrentes(@inicio date, @fin date, @cant_faltas_minimas int)
as
begin
	if @inicio > @fin
	begin
		print('El inicio del rango es una fecha posterior a la fecha fin del rango.')
	end
	else
	begin
		declare @rango varchar(50)
		set @rango = CONCAT('Periodo_de_',FORMAT(@inicio, 'yyyy-MM-dd'),'_a_',FORMAT(@fin, 'yyyy-MM-dd'));
		print(@rango)
		declare @SQL nvarchar(MAX)
		set @SQL = '
		with morosos_recurrentes_cant([Nro de socio], [Nombre y apellido], [Mes incumplido], [Cant Incumplidas]) as
		(
			select	s.id_socio as [Nro de socio], 
			CONCAT(s.nombre,'' '',s.apellido) as [Nombre y apellido], 
			DATENAME(MONTH, f.fecha_emision) as [Mes incumplido],
			COUNT(DATENAME(MONTH, f.fecha_emision)) as [Cant Incumplidas]
			from socios.socio s 
			inner join facturacion.factura f on s.id_socio = f.id_socio 
			where (f.fecha_emision between '''+FORMAT(@inicio, 'yyyy-MM-dd')+''' and '''+FORMAT(@fin, 'yyyy-MM-dd')+''') and (f.segundo_vto < '''+FORMAT(@fin, 'yyyy-MM-dd')+''') and f.estado = ''NO PAGADO''
			group by s.id_socio, CONCAT(s.nombre,'' '',s.apellido), DATENAME(MONTH, f.fecha_emision)
		),
		morosos_recurrentes_rank ([Nro de socio], [Nombre y apellido], [Mes incumplido], [Cant Incumplidas], [Ranking]) as
		(
			select [Nro de socio], [Nombre y apellido], [Mes incumplido], [Cant Incumplidas], 
			RANK() over (partition by [Mes incumplido] order by [Cant Incumplidas] desc) [Ranking] from morosos_recurrentes_cant
		)
		select 
		(
		select [Nro de socio] as ''@Nro_de_socio'', [Nombre y apellido] as Nombre_y_apellido, [Mes incumplido] as Mes_incumplido from morosos_recurrentes_rank where [Cant Incumplidas] > '''+CAST(@cant_faltas_minimas as varchar(2))+''' order by [Ranking]
		for XML PATH(''Socio''), ROOT('''+@rango+'''), TYPE
		)
		for XML PATH(''Morosos_recurrentes'');'
		EXEC sp_executesql @SQL
	end
end

go

--Reporte 2
create or alter procedure reporte_ingresos_por_actividad
as
begin
	 declare @fecha_actual date
	 declare @fecha_inicio date
	 set @fecha_actual = GETDATE()
	 set @fecha_inicio = CONCAT(YEAR(@fecha_actual),'-','01','-','01');
	with facturas_de_deportes_pagadas ([Deporte], [Mes de pago], [Monto]) as
	(
		select aa.nombre_actividad [Deporte], [Mes de pago], [Monto] from 
		(
			select ff.servicio , DATENAME(MONTH, fp.fecha_pago) [Mes de pago] ,fp.monto_total [Monto] from facturacion.factura ff 
			inner join facturacion.pago fp on ff.id_factura = fp.id_factura
			where fp.fecha_pago >= '2025-01-01'
		) t1
		right join actividades.actividad aa on aa.nombre_actividad = t1.servicio
	)select [Deporte],
			ISNULL([Enero], 0) [Enero], ISNULL([Febrero], 0) [Febrero], ISNULL([Marzo], 0) [Marzo], ISNULL([Abril], 0) [Abril],
			ISNULL([Mayo], 0) [Mayo], ISNULL([Junio], 0) [Junio], ISNULL([Julio], 0) [Julio], ISNULL([Agosto], 0) [Agosto],
			ISNULL([Septiembre], 0) [Septiembre], ISNULL([Octubre], 0) [Octubre], ISNULL([Noviembre], 0) [Noviembre], ISNULL([Diciembre], 0) [Diciembre] 
			from facturas_de_deportes_pagadas pivot( sum([Monto]) for [Mes de pago] in 
			([Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre]))nombre_pivot
			for XML PATH('Reporte'), ROOT('ReporteAcumuladoMensualDeIngresosPorDeporte')
end