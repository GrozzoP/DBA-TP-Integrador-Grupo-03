use importacion
go

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

bulk insert #responsablesdepago
from 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(Responsables de Pago).csv'
with(
  fieldterminator = ';',
  rowterminator = '\n',
  codepage = 'ACP',
  firstrow = 2
)
go
update #responsablesdepago
set nrosocio = SUBSTRING(nrosocio,5,CHARINDEX('-',nrosocio))

select fnacimiento from #responsablesdepago
where dni = '293367480'

update #responsablesdepago
set fnacimiento = replace(fnacimiento,'19','09')
where dni = '293367480'

select*from #responsablesdepago
order by nrosocio asc

drop table #responsablesdepago


insert into obra_social(nombre_obra_social,telefono_obra_social)
select nombreobraciocial,telemergenciacontactoObraSocial from #responsablesdepago
group by nombreobraciocial, telemergenciacontactoObraSocial

Create table obra_social(
		id_obra_social int identity(1,1),
		nombre_obra_social varchar(60) UNIQUE,
		telefono_obra_social varchar(100)
		Constraint Socios_obra_social_PK_id_obra_social Primary key(id_obra_social)
	)

select*from obra_social
--drop table obra_social

with cte(nombre,apellido,dni,duplicada)
as
(
  select nombre,apellido,dni, row_number() over(partition by dni order by dni) as repetida
  from #responsablesdepago
)
update cte
set dni = NULL
where duplicada > 1


create table #pagocuotas(
   idpago varchar(250),
   fechapago varchar(250),
   responsablepagoidsocio varchar(250),
   monto varchar(250),
   mediopago varchar(250)
)

--drop table pagocuotas
--select*from #pagocuotas

bulk insert #pagocuotas
from 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(pago cuotas).csv'
with(
  fieldterminator = ';',
  rowterminator = '\n',
  codepage = 'ACP',
  firstrow = 2
)
go

update #pagocuotas
set responsablepagoidsocio = SUBSTRING(responsablepagoidsocio,5,CHARINDEX('-',responsablepagoidsocio))

CREATE TABLE pago_historico(
    id_pago char(200),
	fecha_pago date,
	id_socio int,
	monto decimal(9,2),
	medio_pago varchar(100)
)

select*from pago_historico
drop table pago_historico

insert into pago_historico(id_pago,fecha_pago,id_socio,monto,medio_pago)
select idpago,
   cast(fechapago as date),
   cast(responsablepagoidsocio as int),
   cast(monto as decimal(9,2)),
   mediopago
from #pagocuotas


--de pago cuotas puedo sacar todos los socios que obtengo
select*from #pagocuotas
select SUBSTRING(responsablepagoidsocio,5,CHARINDEX('-',responsablepagoidsocio)) from #pagocuotas

--update al campo de ids pago socios
update #pagocuotas
set responsablepagoidsocio = SUBSTRING(responsablepagoidsocio,5,CHARINDEX('-',responsablepagoidsocio))

--todos los ids de socios que hay
select responsablepagoidsocio from #pagocuotas
group by responsablepagoidsocio

--de esta manera hay que insertar los socios
select*from #responsablesdepago
order by nrosocio asc

update #responsablesdepago
set nrosocio = SUBSTRING(nrosocio,5,CHARINDEX('-',nrosocio))

select * from #pagocuotas p
join #responsablesdepago r
on r.nrosocio = p.responsablepagoidsocio

--aca ya tengo todos los datos de cada socio
select r.nrosocio,r.dni,r.nombre,r.apellido,r.fnacimiento,r.telcontacto,r.telcontactoemergencia,
r.nombreobraciocial from #pagocuotas p
join #responsablesdepago r
on r.nrosocio = p.responsablepagoidsocio
group by nrosocio,r.dni,r.nombre,r.apellido,r.fnacimiento,r.telcontacto,r.telcontactoemergencia,
r.nombreobraciocial

with cte (nro,socio,dni,duplicada)
as
(
  select nrosocio,nombre,dni, row_number() over(partition by nrosocio order by nrosocio) as duplicada from(
		select r.nrosocio,r.dni,r.nombre,r.apellido,r.fnacimiento,r.telcontacto,r.telcontactoemergencia,
		r.nombreobraciocial from #pagocuotas p
		join #responsablesdepago r
		on r.nrosocio = p.responsablepagoidsocio
		group by nrosocio,r.dni,r.nombre,r.apellido,r.fnacimiento,r.telcontacto,r.telcontactoemergencia,
		r.nombreobraciocial
  )as j
)
select*from cte
where duplicada > 1
--no hay duplicadas


create table #grupofamiliar(
  nrosocio varchar(256),
  nrosocioresponsable varchar(256),
  nombre varchar(256),
  apellido varchar(256),
  dni varchar(256),
  emailpersonal varchar(256),
  fnacimiento varchar(256),
  telcontacto varchar(256),
  telcontactoemergencia varchar(256),
  nombreobraciocial varchar(256),
  nrosocioobrasocial varchar(256),
  telemergenciacontactoObraSocial varchar(256)
)

select*from #grupofamiliar
order by nrosocio asc
--drop table grupofamiliar

--email,telcontacto, nombreobrasocial,nroobrasocial,telobrasocial, deben admitir nulos, porque no todos los socios 
--tienen esos valores
--en el grupo familiar ya hay nro de socios responsables, por lo tanto ya deberian de esta en la tabla socios
--porque es un foreing key, 

bulk insert #grupofamiliar
from 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(Grupo Familiar).csv'
with(
  fieldterminator = ';',
  rowterminator = '\n',
  codepage = 'ACP',
  firstrow = 2
)
go

with cte(idsocio,duplicada)
as
(
  select nrosocio,row_number() over(partition by nrosocio,nrosocioresponsable order by nrosocio) as dupli
  from #grupofamiliar
)
select*from cte
where duplicada > 1
--no hay duplicadas

update #grupofamiliar
set nrosocio = SUBSTRING(nrosocio,5,CHARINDEX('-',nrosocio))

update #grupofamiliar
set nrosocioresponsable = SUBSTRING(nrosocioresponsable,5,CHARINDEX('-',nrosocioresponsable))

--ya tengo todos los datos de socios y de socios menores


create table #presentismoActividades(
   nrosocio varchar(256),
   actividad varchar(256),
   fechaAsistencia varchar(256),
   asistencia varchar(20),
   profesor varchar(200)
)

select*from #presentismoActividades
order by nrosocio desc

--drop table presentismoActividades
--al final de los nombres de profesores hay puntos y comas que eliminar
--hay presentismo, P,A,J presente, ausente, justificado(?)

bulk insert #presentismoActividades
from 'C:\Users\ulaza\OneDrive\Escritorio\imp\Datos socios 1(presentismo_actividades).csv'
with(
  fieldterminator = ';',
  rowterminator = '\n',
  codepage = 'ACP',
  firstrow = 2
)
go

update #presentismoActividades
set nrosocio = SUBSTRING(nrosocio,5,CHARINDEX('-',nrosocio))

--select SUBSTRING(profesor,0,CHARINDEX(';',profesor)) as prof from #presentismoActividades
--group by profesor

update #presentismoActividades
set profesor = SUBSTRING(profesor,0,CHARINDEX(';',profesor))

select*from #presentismoActividades

select profesor from #presentismoActividades
group by profesor
----------------------
