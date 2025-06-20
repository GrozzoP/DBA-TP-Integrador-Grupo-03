/*
Reporte 1

Reporte de los socios morosos, que hayan incumplido en más de dos oportunidades dado un
rango de fechas a ingresar. El reporte debe contener los siguientes datos:
Nombre del reporte: Morosos Recurrentes
Período: rango de fechas
Nro de socio
Nombre y apellido.
Mes incumplido
Ordenados de Mayor a menor por ranking de morosidad
El mismo debe ser desarrollado utilizando Windows Function.

Reporte 2
Reporte acumulado mensual de ingresos por actividad deportiva al momento en que se saca
el reporte tomando como inicio enero.

Reporte 3
Reporte de la cantidad de socios que han realizado alguna actividad de forma alternada
(inasistencias) por categoría de socios y actividad, ordenado según cantidad de inasistencias
ordenadas de mayor a menor.

Reporte 4
Reporte que contenga a los socios que no han asistido a alguna clase de la actividad que
realizan. El reporte debe contener: Nombre, Apellido, edad, categoría y la actividad

    BASE DE DATOS APLICADAS

Fecha de entrega: 19-06-2025
Comision: 5600
Numero de grupo: 03

-Lazarte Ulises 42838702
-Maximo Bertolin Graziano 46364320
-Jordi Marcelo Pairo Albarez 41247253
-Franco Agustin Grosso 46024348
*/

use COM5600G03
go

--Reporte 1
create or alter procedure facturacion.morosos_recurrentes(@inicio date, @fin date, @cant_faltas_minimas int)
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
		declare @SQL nvarchar(MAX)
		set @SQL = '
		with morosos_recurrentes_cant([Nro de socio], [Nombre y apellido], [Mes incumplido], [Cant Incumplidas]) as
		(
			select	ss.id_socio as [Nro de socio], 
			CONCAT(ff.nombre,'' '',ff.apellido) as [Nombre y apellido], 
			DATENAME(MONTH, ff.fecha_emision) as [Mes incumplido],
			COUNT(DATENAME(MONTH, ff.fecha_emision)) as [Cant Incumplidas]
			from socios.socio ss
			inner join facturacion.factura ff on ss.dni = ff.dni 
			where (ff.fecha_emision between '''+FORMAT(@inicio, 'yyyy-MM-dd')+''' and '''+FORMAT(@fin, 'yyyy-MM-dd')+''') and (ff.segundo_vto < '''+FORMAT(@fin, 'yyyy-MM-dd')+''') and ff.estado = ''NO PAGADO''
			group by ss.id_socio, CONCAT(ff.nombre,'' '',ff.apellido), DATENAME(MONTH, ff.fecha_emision)
		),
		morosos_recurrentes_rank ([Nro de socio], [Nombre y apellido], [Mes incumplido], [Cant Incumplidas], [Ranking]) as
		(
			select [Nro de socio], [Nombre y apellido], [Mes incumplido], [Cant Incumplidas], 
			RANK() over (partition by [Mes incumplido] order by [Cant Incumplidas] desc) [Ranking] from morosos_recurrentes_cant
		)
		select 
		(
		select [Nro de socio] as Nro_de_socio, [Nombre y apellido] as Nombre_y_apellido, [Mes incumplido] as Mes_incumplido from morosos_recurrentes_rank where [Cant Incumplidas] > '''+CAST(@cant_faltas_minimas as varchar(2))+''' order by [Ranking]
		for XML PATH(''Socio''), ROOT('''+@rango+'''), TYPE
		)
		for XML PATH(''Morosos_recurrentes'');'
		EXEC sp_executesql @SQL
	end
end
go
--exec facturacion.morosos_recurrentes '2025-01-01', '2025-12-1', 2
go
--Reporte 2
create or alter procedure facturacion.reporte_ingresos_por_actividad
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
			where fp.fecha_pago >= @fecha_inicio
		) t1
		right join actividades.actividad aa on aa.nombre_actividad = t1.servicio
	)select [Deporte],
			ISNULL([Enero], 0) [Enero], ISNULL([Febrero], 0) [Febrero], ISNULL([Marzo], 0) [Marzo], ISNULL([Abril], 0) [Abril],
			ISNULL([Mayo], 0) [Mayo], ISNULL([Junio], 0) [Junio], ISNULL([Julio], 0) [Julio], ISNULL([Agosto], 0) [Agosto],
			ISNULL([Septiembre], 0) [Septiembre], ISNULL([Octubre], 0) [Octubre], ISNULL([Noviembre], 0) [Noviembre], ISNULL([Diciembre], 0) [Diciembre] 
			from facturas_de_deportes_pagadas pivot( sum([Monto]) for [Mes de pago] in 
			([Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre]))nombre_pivot
			for XML PATH('Reporte'), ROOT('Reporte_acumulado_mensual_de_ingresos_por_deporte')
end
--exec facturacion.reporte_ingresos_por_actividad
go
--Reporte 3
create or alter procedure socios.socios_con_ausentes as
begin
	select ss.nombre [Nombre], ss.apellido [Apellido], 
			sc.nombre_categoria [Categoria], ap.nombre_actividad [Actividad],
			COUNT(ap.asistencia) [Cant_inasistencias]
	from actividades.presentismo ap
	left join socios.socio ss on ap.id_socio = ss.id_socio
	left join socios.categoria sc on ss.id_categoria = sc.id_categoria
	where ap.asistencia = 'A'
	group by ss.nombre, ss.apellido, sc.nombre_categoria, ap.nombre_actividad
	order by COUNT(ap.asistencia) desc
	for XML PATH('Socio'), ROOT('Reporte_de_inasistencia_por_Actividad')
end
--exec socios_con_inasistencias
go
--Reporte 4
create or alter procedure socios.socios_sin_presentismo_por_actividad
as
begin
	with socios_con_asistencias (id_socio, [Actividad]) as
	(
		select ap.id_socio, ap.nombre_actividad 
		from actividades.presentismo ap
		where ap.asistencia = 'A'
		group by ap.id_socio, ap.nombre_actividad
	)select ss.nombre [Nombre], ss.apellido [Apellido], DATEDIFF(YEAR, ss.fecha_nacimiento, GETDATE()) [Edad], sc.nombre_categoria [Categoria] , [Actividad]
	from socios_con_asistencias sca
	left join socios.socio ss on ss.id_socio = sca.id_socio
	left join socios.categoria sc on ss.id_categoria = sc.id_categoria
	where not exists( select 1 from actividades.presentismo ap
						where ap.id_socio = sca.id_socio and ap.nombre_actividad = sca.Actividad and ap.asistencia = 'P' )
	for XML PATH('Socio'), ROOT('Socios_sin_asistencias_por_actividad')
end
-- exec socios_sin_asistencias_por_actividad
