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

-- Creacion de una funcion para pasar los nombres de los meses a español en los reportes
CREATE OR ALTER FUNCTION facturacion.nombre_mes_a_espaniol(@mes VARCHAR(20)) RETURNS VARCHAR(20) AS
BEGIN
	RETURN CASE 
		WHEN @mes = 'January' THEN 'Enero'
		WHEN @mes = 'February' THEN 'Febrero'
		WHEN @mes = 'March' THEN 'Marzo'
		WHEN @mes = 'April' THEN 'Abril'
		WHEN @mes = 'May' THEN 'Mayo'
		WHEN @mes = 'June' THEN 'Junio'
		WHEN @mes = 'July' THEN 'Julio'
		WHEN @mes = 'August' THEN 'Agosto'
		WHEN @mes = 'September' THEN 'Septiembre'
		WHEN @mes = 'October' THEN 'Octubre'
		WHEN @mes = 'November' THEN 'Noviembre'
		WHEN @mes = 'December' THEN 'Diciembre'
			ELSE 'Error, mes no valido'
		END
END
go
-- En las nuevos reportes facturacion.nombre_mes_a_espaniol no es utilizado.

--FuncionAuxiliar para sacar la edad
create or alter function socios.calcular_edad (@fecha_nacimiento date)
returns int
as
begin
	declare @edad int
	declare @fecha_actual date
	set @fecha_actual = GETDATE()
	set @edad = DATEDIFF(YEAR, @fecha_nacimiento, @fecha_actual)
	if MONTH(@fecha_nacimiento) >= MONTH(@fecha_actual) AND
		DAY(@fecha_nacimiento) >= DAY(@fecha_actual)
		begin
			set @edad = @edad
		end
	else
		begin
			set @edad = @edad - 1
		end
	return @edad
end
go
--Fin de FuncionAuxiliar

--Reporte 1
create or alter procedure facturacion.morosos_recurrentes(@inicio date, @fin date, @cant_faltas_minimas int)
as
begin
	if(@inicio > @fin)
	begin
		print('El inicio del rango es una fecha posterior a la fecha fin del rango.')
		return
	end
	else if (@fin > GETDATE())
		begin
			set @fin = GETDATE()
		end
	declare @periodo varchar(23)
	set @periodo = CONCAT(CONVERT(VARCHAR(10), @inicio, 120),' - ', CONVERT(VARCHAR(10), @fin, 120));
	with morosos_recurrentes(Nro_de_Socio, Nombre_y_Apellido, Mes, Cant_Incumplida)
	as
	(
		select ff.id_socio, CONCAT(ss.nombre,' ',ss.apellido) , DATENAME(MONTH,ff.fecha_emision), COUNT(*) over(partition by ff.id_socio) from facturacion.factura ff
		left join socios.socio ss on ss.id_socio = ff.id_socio
		where (ff.segundo_vto between @inicio and @fin) and ff.estado = 'NO PAGADO'
	)
	select @periodo as Periodo, Nro_de_Socio, Nombre_y_Apellido, Mes from morosos_recurrentes
	where Cant_Incumplida > @cant_faltas_minimas
	order by Cant_Incumplida desc
	for XML PATH('Socio'), ROOT('Morosos_Recurrentes')
end
go

-- exec facturacion.morosos_recurrentes '2024-01-01', '2025-12-1', 2
go

--Reporte 2
create or alter procedure facturacion.reporte_ingresos_por_actividad
as
begin
	declare @fecha_actual date
	set @fecha_actual = GETDATE();
	with Meses(nro_mes, nombre_mes) AS
	(
		select 1, 'Enero' UNION ALL
		select 2, 'Febrero' UNION ALL
		select 3, 'Marzo' UNION ALL
		select 4, 'Abril' UNION ALL
		select 5, 'Mayo' UNION ALL
		select 6, 'Junio' UNION ALL
		select 7, 'Julio' UNION ALL
		select 8, 'Agosto' UNION ALL
		select 9, 'Septiembre' UNION ALL
		select 10, 'Octubre' UNION ALL
		select 11, 'Noviembre' UNION ALL
		select 12, 'Diciembre'
	),
	actividad_por_mes(Actividad, Mes, facturado) as
    (
        select
            aa.nombre_actividad as actividad,
            m.nombre_mes as mes,
            ISNULL(SUM(df.subtotal), 0) as facturado
        from actividades.actividad aa
        cross join meses m
        left join facturacion.factura f
            on YEAR(f.fecha_emision) = YEAR(@fecha_actual)
            and MONTH(f.fecha_emision) = m.nro_mes
        left join facturacion.detalle_factura df
            on df.id_factura = f.id_factura
            and df.servicio = aa.nombre_actividad
        group by aa.nombre_actividad, m.nro_mes, m.nombre_mes
    )
	select * from actividad_por_mes
	pivot(sum(facturado) for Mes in ([Enero], [Febrero], [Marzo], [Abril], [Mayo], [Junio], [Julio], [Agosto], [Septiembre], [Octubre], [Noviembre], [Diciembre])) as t1
	for XML PATH('Reporte'), ROOT('Reporte_acumulado_mensual_de_ingresos_por_deporte')
end
go

-- exec facturacion.reporte_ingresos_por_actividad
go
--Reporte 3
create or alter procedure socios.cant_inasitencia_por_cat_act as
begin
	declare @fecha_actual date
	set @fecha_actual = GETDATE()

	;with presentismo_por_cat_y_act (id_socio, Categoria, Actividad, cant_asistencias, cant_inasistencia) as
	(
		select distinct ss.id_socio, sc.nombre_categoria, aa.nombre_actividad, COUNT(case when ap.asistencia = 'P' then 1 end) over (partition by ss.id_socio,aa.nombre_actividad), COUNT(case when ap.asistencia = 'A' then 1 end) over (partition by ss.id_socio,aa.nombre_actividad)
		from actividades.presentismo ap
		inner join socios.socio ss on ss.id_socio = ap.id_socio
		left join actividades.actividad aa on ap.id_actividad = aa.id_actividad
		left join socios.categoria sc on ss.id_categoria = sc.id_categoria
		where YEAR(ap.fecha_asistencia) = YEAR(@fecha_actual) and MONTH(ap.fecha_asistencia) = MONTH(@fecha_actual)
	)
	select Categoria, Actividad, COUNT(id_socio) AS cantidad_socios from presentismo_por_cat_y_act
	where cant_asistencias != 0 and cant_inasistencia != 0
	group by categoria, actividad
	order by cantidad_socios desc
	for XML PATH('Socio'), ROOT('Reporte_de_inasistencia_por_Categoria_y_Actividad')
end
go
-- exec socios.cant_inasitencia_por_cat_act
go

--Reporte 4
create or alter procedure socios.socios_sin_presentismo_por_actividad
as
begin
	declare @fecha_actual date
	set @fecha_actual = GETDATE();
	--set @fecha_actual = poner una fecha aca porque en presentismo no hay datos para el mes actual ej 2025-03-10;
	with socios_con_asistencias (nombre, apellido, edad, categoria, actividad, cant_asistencias) as
	(
		select ss.nombre, ss.apellido, socios.calcular_edad(ss.fecha_nacimiento), sc.nombre_categoria, aa.nombre_actividad,COUNT(case when ap.asistencia = 'P' then 1 end)
		from actividades.presentismo ap
		left join socios.socio ss on ss.id_socio = ap.id_socio
		left join actividades.actividad aa on ap.id_actividad = aa.id_actividad
		left join socios.categoria sc on ss.id_categoria = sc.id_categoria
		where YEAR(ap.fecha_asistencia) = YEAR(@fecha_actual) and MONTH(ap.fecha_asistencia) = MONTH(@fecha_actual)
		group by ss.nombre, ss.apellido, socios.calcular_edad(ss.fecha_nacimiento), sc.nombre_categoria, aa.nombre_actividad
	)
	select nombre, apellido, edad, categoria, actividad from socios_con_asistencias
	where cant_asistencias = 0
	for XML PATH('Socio'), ROOT('Socios_sin_asistencias_por_actividad')
end
go

-- exec socios.socios_sin_presentismo_por_actividad