/*
Parte 7
...
Por otra parte, se requiere que los datos de los empleados se encuentren encriptados, dado
que los mismos contienen información personal.

    BASE DE DATOS APLICADAS

Fecha de entrega: 19-06-2025
Comision: 5600
Numero de grupo: 03

-Lazarte Ulises 42838702
-Maximo Bertolin Graziano 46364320
-Jordi Marcelo Pairo Albarez 41247253
-Franco Agustin Grosso 46024348
*/


USE COM5600G03
go
--Creacion del esquema para los datos de los empleados
if exists(
	select name from sys.schemas
	where name = 'empleados'
)
	begin
		print 'El esquema de los empleados ya existe'
	end
else
	begin
		exec('Create schema empleados')
	end
go

-- Creacion de la tabla que almacena los puestos que puede ocupar un empleado
IF OBJECT_ID('COM5600G03.empleados.posicion') IS NULL
BEGIN
	CREATE TABLE empleados.posicion(
		id_posicion	INT PRIMARY KEY IDENTITY(1, 1),
		posicion	VARCHAR(100) NOT NULL UNIQUE,
		descipcion_posicion	VARCHAR(400)
	)
END
ELSE
BEGIN
	print 'la tabla empleados.posicion ya existe en la base de datos'
END
go

--Creacion de la tabla con los datos de los empleados
--Informacion sensible:
--dni
--nombre
--apellido
--domicilio
--telefono
--Correo electronico
IF OBJECT_ID('COM5600G03.empleados.empleado') IS NULL
BEGIN
	CREATE TABLE empleados.empleado(
		nro_legajo	INT PRIMARY KEY IDENTITY(1, 1),
		dni			VARBINARY(80),
		nombre		VARBINARY(100),
		apellido	VARBINARY(100),
		domicilio	VARBINARY(250),
		correo_electronico	VARBINARY(160),
		telefono	VARBINARY(100),
		nro_cuil	VARBINARY(100),
		sueldo		VARBINARY(100),
		fecha_ingreso	DATE NOT NULL,
		fecha_salida	DATE
	)
END
ELSE
BEGIN
	print 'la tabla empleados.empleado ya existe en la base de datos'
END
go

--Creacion de la tabla para asignar posiciones a empleados
IF OBJECT_ID('COM5600G03.empleados.posicion_asignada') IS NULL
BEGIN
	CREATE TABLE empleados.posicion_asignada(
		nro_legajo	INT,
		id_posicion	INT,
		fecha_inicio	DATE,
		fecha_fin		DATE DEFAULT NULL,
		CONSTRAINT pk_posicion_empleado PRIMARY KEY(nro_legajo, id_posicion, fecha_inicio),
		CONSTRAINT fk_posicion_empleado_nro_legajo_empleado
					FOREIGN KEY(nro_legajo) REFERENCES empleados.empleado(nro_legajo),
		CONSTRAINT fk_posicion_empleado_id_posicion_posicion
					FOREIGN KEY(id_posicion) REFERENCES empleados.posicion(id_posicion)
	)
END
ELSE
BEGIN
	print 'la tabla empleados.posicion_asignada ya existe en la base de datos'
END
go

--Creacion del procedimiento para insertar nuevas posiciones
CREATE OR ALTER PROCEDURE empleados.insertar_posicion(@posicion VARCHAR(100), @descripcion VARCHAR(400))
AS BEGIN
	IF EXISTS (	SELECT 1 FROM empleados.posicion P
				WHERE P.posicion = @posicion COLLATE modern_spanish_CI_AI)
	BEGIN
		print 'La posicion que intenta crear ya existe'
	END
	ELSE
	BEGIN
		INSERT INTO empleados.posicion VALUES (@posicion, @descripcion)
	END
END
go

--Creacion del procedimiento para actualizar posiciones preexistentes
CREATE OR ALTER PROCEDURE empleados.actualizar_posicion_por_id(
														@id INT,
														@posicion VARCHAR(100),
														@descripcion VARCHAR(400))
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM empleados.posicion P
				WHERE P.id_posicion = @id)
	BEGIN
		UPDATE	empleados.posicion
		SET		posicion = @posicion, descipcion_posicion = @descripcion
		WHERE	id_posicion = @id
	END
	ELSE
	BEGIN
		print 'La posicion que quiere actualizar no existe'
	END
END
go

--Creacion del procedimiento para eliminar posiciones preexistentes
CREATE OR ALTER PROCEDURE empleados.eliminar_posicion_por_id(
														@id INT)
AS
BEGIN
	IF EXISTS (	SELECT 1 FROM empleados.posicion P
				WHERE P.id_posicion = @id)
	BEGIN
		DELETE	empleados.posicion
		WHERE	id_posicion = @id
	END
	ELSE
	BEGIN
		print 'La posicion que quiere eliminar no existe'
	END
END
go

--Creacion del procedimiento para asignar una posicion a un empleado
CREATE OR ALTER PROCEDURE empleados.insertar_posicion_asignada(
														@nro_legajo INT,
														@id_posicion INT,
														@fecha_inicio DATE)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM empleados.posicion_asignada P
				WHERE (P.nro_legajo = @nro_legajo AND
						P.id_posicion = @id_posicion) AND
						(P.fecha_inicio = @fecha_inicio OR P.fecha_fin IS NOT NULL))
	BEGIN
		print 'La posicion ya está asignada al empleado'
	END
	ELSE
	BEGIN
		IF @nro_legajo IS NULL OR @id_posicion IS NULL
		BEGIN
			print 'Error, los parametros no pueden ser nulos'
		END
		ELSE
		BEGIN
			IF @fecha_inicio IS NULL
			BEGIN
				INSERT INTO empleados.posicion_asignada VALUES
				(@nro_legajo, @id_posicion, GETDATE(), NULL)
			END
			ELSE
			BEGIN
				INSERT INTO empleados.posicion_asignada VALUES
				(@nro_legajo, @id_posicion, @fecha_inicio, NULL)
			END
		END
	END
END
Go

--Creacion del procedimiento para anular la posicion asignada a un empleado
CREATE OR ALTER PROCEDURE empleados.anular_posicion_asignada(
														@nro_legajo INT,
														@id_posicion INT,
														@fecha_fin DATE)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.posicion_asignada P
					WHERE P.nro_legajo = @nro_legajo AND
							P.id_posicion = @id_posicion AND
							P.fecha_fin IS NULL)
	BEGIN
		print 'El empleado no tiene la posicion asignada o la misma ya está anulada'
	END
	ELSE
	BEGIN
		IF @fecha_fin IS NULL
		BEGIN
			UPDATE empleados.posicion_asignada
			SET fecha_fin = GETDATE()
			WHERE nro_legajo = @nro_legajo AND id_posicion = @id_posicion AND fecha_fin IS NULL
		END
		ELSE
		BEGIN
			UPDATE empleados.posicion_asignada
			SET fecha_fin = @fecha_fin
			WHERE nro_legajo = @nro_legajo AND id_posicion = @id_posicion AND fecha_fin IS NULL
		END
	END
END
go

--Creacion del procedimiento para insercion de datos encriptados en la tabla de empleados
CREATE OR ALTER PROCEDURE empleados.insertar_empleado(	@dni INT,
														@nombre VARCHAR(50),
														@apellido VARCHAR(50),
														@domicilio VARCHAR(150),
														@correo VARCHAR(100),
														@telefono VARCHAR(30),
														@nro_cuil INT,
														@sueldo DECIMAL(10, 3),
														@fecha_ingreso DATE,
														@passphrase VARCHAR(MAX))
AS
BEGIN
	IF @dni IS NULL OR @nombre IS NULL OR @apellido IS NULL OR
			@nro_cuil IS NULL OR @sueldo IS NULL OR @fecha_ingreso IS NULL
	BEGIN
		print 'Error, el dni, nombre, apellido, cuil, sueldo y fecha de ingreso no pueden ser nulos'
	END
	ELSE
	BEGIN
		IF @sueldo <= 0
		BEGIN
			print 'Error, el sueldo debe ser un numero positivo'
		END
		ELSE
		BEGIN
			IF EXISTS (SELECT 1 FROM empleados.empleado E
				WHERE CAST(CAST(DECRYPTBYPASSPHRASE(@passphrase, CAST(E.dni AS VARCHAR(20))) AS VARCHAR(8)) AS INT) = @dni)
			BEGIN
				print 'Error, ya existe un empleado con ese dni'
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT 1 FROM empleados.Empleado D WHERE CAST(CAST(DECRYPTBYPASSPHRASE(@passphrase, D.dni) AS VARCHAR(10)) AS INT) = @dni)
				BEGIN
					print 'Error, el dni debe ser unico'
				END
				ELSE
				BEGIN
					INSERT INTO empleados.empleado VALUES
					(ENCRYPTBYPASSPHRASE(@passphrase, CAST(@dni AS VARCHAR(10))),
					ENCRYPTBYPASSPHRASE(@passphrase, @nombre),
					ENCRYPTBYPASSPHRASE(@passphrase, @apellido),
					ENCRYPTBYPASSPHRASE(@passphrase, @domicilio),
					ENCRYPTBYPASSPHRASE(@passphrase, @correo),
					ENCRYPTBYPASSPHRASE(@passphrase, @telefono),
					ENCRYPTBYPASSPHRASE(@passphrase, CAST(@nro_cuil AS VARCHAR(30))),
					ENCRYPTBYPASSPHRASE(@passphrase, CAST(@sueldo AS VARCHAR(30))),
					@fecha_ingreso, NULL)
				END
			END
		END
	END
END
go

CREATE Or ALTER PROCEDURE empleados.actualizar_correo_empleado(
																@nro_legajo INT,
																@correo VARCHAR(100),
																@passphrase VARCHAR(MAX))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.empleado E WHERE E.nro_legajo = @nro_legajo)
	BEGIN
		print 'El empleado que quiere actualizar no se encuentra en la base de datos'
	END
	ELSE
	BEGIN
		UPDATE empleados.empleado
		SET correo_electronico = ENCRYPTBYPASSPHRASE(@passphrase, @correo)
		WHERE nro_legajo = @nro_legajo
	END
END
go

CREATE Or ALTER PROCEDURE empleados.actualizar_domicilio(
														@nro_legajo INT,
														@domicilio VARCHAR(150),
														@passphrase VARCHAR(MAX))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.empleado E WHERE E.nro_legajo = @nro_legajo)
	BEGIN
		print 'El empleado que quiere actualizar no se encuentra en la base de datos'
	END
	ELSE
	BEGIN
		UPDATE empleados.empleado
		SET domicilio = ENCRYPTBYPASSPHRASE(@passphrase, @domicilio)
		WHERE nro_legajo = @nro_legajo
	END
END
go

CREATE Or ALTER PROCEDURE empleados.actualizar_telefono(
														@nro_legajo INT,
														@telefono VARCHAR(30),
														@passphrase VARCHAR(MAX))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.empleado E WHERE E.nro_legajo = @nro_legajo)
	BEGIN
		print 'El empleado que quiere actualizar no se encuentra en la base de datos'
	END
	ELSE
	BEGIN
		UPDATE empleados.empleado
		SET telefono = ENCRYPTBYPASSPHRASE(@passphrase, @telefono)
		WHERE nro_legajo = @nro_legajo
	END
END
go

CREATE Or ALTER PROCEDURE empleados.actualizar_sueldo(	@nro_legajo INT,
														@sueldo DECIMAL(10, 3),
														@passphrase VARCHAR(MAX))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.empleado E WHERE E.nro_legajo = @nro_legajo)
	BEGIN
		print 'El empleado que quiere actualizar no se encuentra en la base de datos'
	END
	ELSE
	BEGIN
		IF @sueldo IS NULL OR @sueldo <= 0
		BEGIN
			print 'El sueldo debe ser un valor positivo'
		END
		ELSE
		BEGIN
			UPDATE empleados.empleado
			SET sueldo = ENCRYPTBYPASSPHRASE(@passphrase, CAST(@sueldo AS VARCHAR(30)))
			WHERE nro_legajo = @nro_legajo
		END
	END
END
go

CREATE Or ALTER PROCEDURE empleados.actualizar_nro_cuil(@nro_legajo INT,
														@nro_cuil INT,
														@passphrase VARCHAR(MAX))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.empleado E WHERE E.nro_legajo = @nro_legajo)
	BEGIN
		print 'El empleado que quiere actualizar no se encuentra en la base de datos'
	END
	ELSE
	BEGIN
		IF @nro_cuil IS NULL
		BEGIN
			print 'El numero de cuil no puede ser Nulo'
		END
		ELSE
		BEGIN
			UPDATE empleados.empleado
			SET nro_cuil = ENCRYPTBYPASSPHRASE(@passphrase, CAST(@nro_cuil AS VARCHAR(30)))
			WHERE nro_legajo = @nro_legajo
		END
	END
END
go

CREATE Or ALTER PROCEDURE empleados.actualizar_empleado_fecha_fin(	@nro_legajo INT,
																	@fecha_fin DATE,
																	@passphrase VARCHAR(MAX))
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM empleados.empleado E WHERE E.nro_legajo = @nro_legajo)
	BEGIN
		print 'El empleado que quiere actualizar no se encuentra en la base de datos'
	END
	ELSE
	BEGIN
		IF @fecha_fin IS NULL
		BEGIN
			print 'Error, debe ingresar una fecha válida'
		END
		ELSE
		BEGIN
			UPDATE empleados.empleado
			SET fecha_salida = @fecha_fin
			WHERE nro_legajo = @nro_legajo
		END
	END
END
go

--------------------------------------------Prueba de los SP de Empleados------------------------------------------------------
/*DELETE empleados.Empleado

EXEC empleados.insertar_empleado 112233, 'Marcos', 'Suarez', 'Buenos Aires, La Matanza, Avenida Crovara 1200', 'marcossuarez@gmail.com', '1234-5678', 201122333,
								200000, '2024-02-10', 'Buenos Dias'
EXEC empleados.insertar_empleado 110055, 'Jose', 'Perez', 'Buenos Aires, La Matanza, Boulogne Sur Mer 300', 'joseperez@gmail.com', '4444-7878', 201100553,
								250000, '2023-07-10', 'Buenos Dias'
EXEC empleados.insertar_empleado 900990, 'Luis', 'Gonzalez', 'Buenos Aires, La Matanza, General Paz 8560', 'luisgonzalez@gmail.com', '9090-3434', 209009903,
								340000, '2022-10-07', 'Buenos Dias'

--Los datos de la siguiente consulta deberían aparecer encriptados
SELECT * FROM empleados.Empleado


--Mientras que esta consulta se los desencripta y se muestran como son correctamente
SELECT nro_legajo, CAST(CAST(DECRYPTBYPASSPHRASE('Buenos Dias', dni) AS VARCHAR(10)) AS INT) dni, 
		CAST(DECRYPTBYPASSPHRASE('Buenos Dias', nombre) AS VARCHAR(50)) nombre,
		CAST(DECRYPTBYPASSPHRASE('Buenos Dias', apellido) AS VARCHAR(50)) apellido,
		CAST(CAST(DECRYPTBYPASSPHRASE('Buenos Dias', sueldo) AS VARCHAR(10)) AS DECIMAL(10, 3)) sueldo, 
		CAST(DECRYPTBYPASSPHRASE('Buenos Dias', correo_electronico) AS VARCHAR(100)) correo_electronico,
		CAST(CAST(DECRYPTBYPASSPHRASE('Buenos Dias', nro_cuil) AS VARCHAR(30)) AS INT) nro_cuil, 
		CAST(DECRYPTBYPASSPHRASE('Buenos Dias', telefono) AS VARCHAR(100)) telefono,
		fecha_ingreso,
		fecha_salida
FROM empleados.Empleado

EXEC empleados.actualizar_correo_empleado 1, 'nuevocorreo@gmail.com', 'Buenos Dias'
EXEC empleados.actualizar_sueldo 1, 330000, 'Buenos Dias'

DELETE empleados.Empleado
*/
