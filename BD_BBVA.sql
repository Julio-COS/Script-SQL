use master
go
CREATE DATABASE BD_BBVA
ON 
    (
    NAME = BD_BBVA_DATA,
    FILENAME='C:\BD BBVA\data\BD_BBVA_DATA.mdf',
    SIZE=10,
    MAXSIZE=30,
    FILEGROWTH=2%
    )
    LOG ON 
	(
    NAME = BD_BBVA_LOG,
    FILENAME= 'C:\BD BBVA\log\BD_BBVA_LOG.ldf',
    SIZE=5,
    MAXSIZE=40,
    FILEGROWTH=2
    )
GO

--CREACION LOGINS--

CREATE LOGIN Administrador
WITH PASSWORD = 'admin123'
GO
CREATE LOGIN Auditor_Empresa
WITH PASSWORD = 'auditor-emp'
GO
CREATE LOGIN Evaluador_Persona
WITH PASSWORD = 'auditor-per'
GO
CREATE LOGIN Evaluador_SolicitudCredito
WITH PASSWORD = 'auditor-sc'
GO
CREATE LOGIN CodificadorPersona
WITH PASSWORD = 'coderper981' 
GO
CREATE LOGIN CodificadorSolicitudCred
WITH PASSWORD = 'coderSC469'
GO
CREATE LOGIN CodificadorDireccion
WITH PASSWORD = 'coderdr123' 
GO

--CREACION USUARIOS--
USE BD_BBVA
go

CREATE USER admin01 FOR LOGIN Administrador
WITH DEFAULT_SCHEMA= db_accessadmin
GO
CREATE USER auditor01 FOR LOGIN Auditor_Empresa
WITH DEFAULT_SCHEMA= [SCH_AGENCIA_BANC]
GO
CREATE USER auditor02 FOR LOGIN Evaluador_Persona
WITH DEFAULT_SCHEMA= [SCH_PERSONA]
GO
CREATE USER auditor03 FOR LOGIN Evaluador_SolicitudCredito
WITH DEFAULT_SCHEMA= [SCH_SOLICITUD_CREDITO]
GO
CREATE USER CodificadorDireccion FOR LOGIN CodificadorDireccion
WITH DEFAULT_SCHEMA= [SCH_INF_DIRECCION]
GO
CREATE USER CodificadorPersona FOR LOGIN CodificadorPersona
WITH DEFAULT_SCHEMA= [SCH_PERSONA]
GO
CREATE USER CodificadorSolicitudCred FOR LOGIN CodificadorSolicitudCred
WITH DEFAULT_SCHEMA= [SCH_SOLICITUD_CREDITO]
GO

--PERMISOS--

GRANT CONTROL ON SCHEMA:: [SCH_AGENCIA_BANC] TO admin01
GRANT CONTROL ON SCHEMA:: [SCH_INF_DIRECCION] TO admin01
GRANT CONTROL ON SCHEMA:: [SCH_PERSONA] TO admin01
GRANT CONTROL ON SCHEMA:: [SCH_SOLICITUD_CREDITO] TO admin01
GRANT SELECT, CREATE TABLE, DELETE  TO admin01
GRANT SELECT ON SCHEMA :: [SCH_AGENCIA_BANC] TO auditor01 
GRANT SELECT ON SCHEMA :: [SCH_INF_DIRECCION] TO auditor02 
GRANT SELECT ON SCHEMA :: [SCH_PERSONA] TO auditor03
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: [SCH_PERSONA] TO CodificadorPersona
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: [SCH_INF_DIRECCION] TO CodificadorDireccion
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA :: [SCH_SOLICITUD_CREDITO] TO CodificadorSolicitudCred

--CREACION TABLAS--

USE BD_BBVA
GO

--ESQUEMA DATOS_AGENCIA_BANC

CREATE TABLE TB_AGENCIA_BANCARIO
(  
	id_ruc char (11), 
	nombAgenCIA varchar(40)not null,
	constraint PK_ID_RUC PRIMARY KEY(id_ruc)
)
GO
--ESQUEMA DATOS_TRABAJADOR

CREATE TABLE TB_TRABAJADOR 
(  
	id_trabajador char(8)not null, 
	nomb_trabajador varchar(40)not null,
	nomb_trabajador2 varchar(40)not null,
	apellPat_trabajador varchar(30)not null,
	apellMat_trabajador varchar(30)not null,
	correo_trabajador varchar(50)not null unique,
	telefono_trabajador varchar(15) not null,
	id_ruc char(11),
	constraint FK_TRABAJADOR FOREIGN KEY(id_ruc) REFERENCES TB_AGENCIA_BANCARIO (id_ruc),
	constraint PK_trabajador PRIMARY KEY(id_trabajador)
)
GO

CREATE TABLE TB_JEFE_FINANZAS
(  
	id_trabaj_finanzas char(8), 
	constraint PK_ID_FINANZAS PRIMARY KEY(id_trabaj_finanzas),
	constraint FK_TRA_FINANZAS FOREIGN KEY(id_trabaj_finanzas) REFERENCES TB_TRABAJADOR (id_trabajador),
)
GO

CREATE TABLE TB_GERENCIA
(  
	id_trabaj_gerencia char(8), 
	
	constraint PK_ID_GERENCIA PRIMARY KEY(id_trabaj_gerencia),
	constraint FK_TRA_GERENCIA FOREIGN KEY(id_trabaj_gerencia) REFERENCES TB_TRABAJADOR (id_trabajador)
)
GO

CREATE TABLE TB_ANALISTA
(  
	id_trabaj_analista char(8), 
	horasAtencion tinyint,	
	id_supervisor char(8),
	
	constraint PK_ID_ANALISTA PRIMARY KEY(id_trabaj_analista),
	constraint FK_TRA_ANALISTA FOREIGN KEY(id_trabaj_analista) REFERENCES TB_TRABAJADOR (id_trabajador),
	FOREIGN KEY (id_supervisor) references TB_ANALISTA(id_trabaj_analista)
)
GO

--ESQUEMA INF_DIRECCION

CREATE TABLE TB_DEPARTAMENTO
(
	codDepartamento smallint not null, 
	nomDepartamento varchar (50) not null, 
	
	CONSTRAINT PK_DEPARTAMENTO PRIMARY KEY(codDepartamento)
)
go 

CREATE TABLE TB_PROVINCIA 
(
	codProvincia smallint not null, 
	nomProvincia varchar (50) not null,
	codDepartamento smallint not null,
	
	CONSTRAINT PK_PROVINCIA PRIMARY KEY(codProvincia),
	FOREIGN KEY (codDepartamento) REFERENCES TB_DEPARTAMENTO(codDepartamento) 
)
go 

CREATE TABLE TB_DISTRITO
(
	codDistrito smallint not null, 
	nomDistrtito varchar (50) not null,
	codProvincia smallint not null,
	
	CONSTRAINT PK_DISTRITO PRIMARY KEY(codDistrito),
	FOREIGN KEY (codProvincia) REFERENCES TB_PROVINCIA(codProvincia) 
)
go
	
----ESQUEMA PERSONA
CREATE TABLE TB_PERSONA
(    
	codPersona int not null,	    --PK
	numDocIdentidad int not null,       
	primerNombre varchar(40) not null,
	segundoNombre varchar(40) null,
	apellidoPaterno varchar(40) not null,
	apellidoMaterno varchar(40) not null,
	fechaNac DATE  not null,
	direccion varchar(256) not null,
	codDistrito smallint  not null,    --FK
	genero char(1)not null ,
	tipoIdenticacion varchar(15)not null,
	nacionalidad varchar(30) not null,
	estadoCivil varchar(20),

	CONSTRAINT fechaNac CHECK (DATEDIFF(year, fechaNac, GETDATE()) >= 18),
	CONSTRAINT PK_codPersona PRIMARY KEY(codPersona),
	FOREIGN KEY (codDistrito) REFERENCES TB_DISTRITO(codDistrito) 
)
GO

CREATE TABLE TB_PERSONA_CUENTA
(
    codCuenta int not null, --PK, FK
    contrasenia varchar(200),
    correoElectronico varchar(100),
    
    CONSTRAINT PK_cuentaPersona PRIMARY KEY(codCuenta),
    FOREIGN KEY (codCuenta) REFERENCES TB_PERSONA(codPersona)
)
GO

CREATE TABLE TB_PERSONA_SOLICITANTE(

    codSolicitante int not null, --PK, FK
    numTelefono char(9),
    numCelular char(9),
    codigoPostal tinyint,
    situacionVivienda varchar(50),
    tiempoResidencia varchar(80),
    numDependientes varchar(5),
    estudios varchar(50),
    profesion varchar(50),
    
    CONSTRAINT PK_codSolicitante PRIMARY KEY(codSolicitante),
    FOREIGN KEY (codSolicitante) REFERENCES TB_PERSONA(codPersona)
)
GO

CREATE TABLE TB_EMPRESA_S
(
	ruc char(11) NOT NULL, --PK
	nombreEmpresa varchar(40) not null,
	rubroEmpresa varchar(30) not null,
	tipoEmpresa varchar(20),

	CONSTRAINT PK_rucEmpresaS PRIMARY KEY(ruc)
)
GO

CREATE TABLE TB_SOLICITANTE_EMPRESA
(
	ruc char(11) NOT NULL, --PK --FK
	codSolicitante int NOT NULL, --PK --FK
	actual varchar(50),
	cargo varchar(50),
	antiguedadLaboral varchar(50),
	situacionLaboral varchar(50),
	ingresoMensual MONEY,
	domicilioTrabajo varchar(120),
	telefonoEmpleo char(9),
	
	CONSTRAINT PK_solicitanteEmpresa PRIMARY KEY(ruc, codSolicitante),
	FOREIGN KEY(codSolicitante) REFERENCES TB_PERSONA_SOLICITANTE(codSolicitante),
	FOREIGN KEY(ruc) REFERENCES TB_EMPRESA_S(ruc)
)
GO

CREATE TABLE TB_CONYUGE_SOL
(
	codPersonaC int NOT NULL,	--PK
	numRuc char(11),
	nivelEstudios varchar(50),
	profesion varchar(30),
	tituloObtenido varchar(50),
	situacionLaboral varchar(50), --Independiente o dependiente

	CONSTRAINT PK_codPersonaC PRIMARY KEY(codPersonaC),
	CONSTRAINT FK_codPersonaC FOREIGN KEY(codPersonaC) REFERENCES TB_PERSONA(codPersona)
	
)
GO 

CREATE TABLE TB_EMPRESA_C
(
	rucEmpresaC  char(11),
	nombreEmpresa varchar(100),
	actividadEmpresa varchar(50)null,

	CONSTRAINT PK_rucEmpresaC PRIMARY KEY(rucEmpresaC)
)
GO

CREATE TABLE TB_EMPRESA_CONYUGE_SOL
(
	codPersonaC int, --PK, FK
	rucEmpresaC char(11),	--PK, FK
	telefono varchar(9),
	direccionEmpresa varchar(120),

	CONSTRAINT PK_EmpresaConyugeSol PRIMARY KEY(codPersonaC, rucEmpresaC),
	FOREIGN KEY(codPersonaC) REFERENCES TB_CONYUGE_SOL(codPersonaC),
	FOREIGN KEY(rucEmpresaC) REFERENCES TB_EMPRESA_C(rucEmpresaC)
)
GO

--ESQUEMA SOLICITUD_CREDITO

CREATE TABLE TB_SOLICITUD_CREDITO
(
	folio int, --PK
	id_trabaj_analista char(8), --FK
	codSolicitante int not null, --FK
	tipoOperacion varchar(50), 
	fechaSolicitud DATE NOT NULL,
	estado varchar(30),
	fechaAprobacion DATE NOT NULL,

	CONSTRAINT PK_SolicitudCredito PRIMARY KEY(folio),
	FOREIGN KEY(id_trabaj_analista) REFERENCES TB_ANALISTA(id_trabaj_analista),
	FOREIGN KEY(codSolicitante) REFERENCES TB_PERSONA_SOLICITANTE(codSolicitante)
)
GO
CREATE TABLE TB_REFERENCIA
(
	numReferencia int, --PK
	nombreCompleto varchar(120),
	telefono  varchar(15),
	direccion varchar(150),
	
	CONSTRAINT PK_numReferencia PRIMARY KEY(numReferencia)
)
GO
CREATE TABLE TB_SOLICITUD_REFERENCIA
(
	folio int, --PK, FK
	numReferencia int, --PK, FK
	tipoVinculo varchar(50),

	CONSTRAINT PK_SolicitudReferencia PRIMARY KEY(folio, numReferencia),
	FOREIGN KEY(folio) REFERENCES TB_SOLICITUD_CREDITO(folio),
	FOREIGN KEY(numReferencia) REFERENCES TB_REFERENCIA(numReferencia)
)
GO

--CREACION DE ESQUEMAS--

CREATE SCHEMA SCH_AGENCIA_BANC
GO
ALTER SCHEMA SCH_AGENCIA_BANC TRANSFER dbo.TB_AGENCIA_BANCARIO
ALTER SCHEMA SCH_AGENCIA_BANC TRANSFER dbo.TB_TRABAJADOR
ALTER SCHEMA SCH_AGENCIA_BANC TRANSFER dbo.TB_ANALISTA
ALTER SCHEMA SCH_AGENCIA_BANC TRANSFER dbo.TB_GERENCIA
ALTER SCHEMA SCH_AGENCIA_BANC TRANSFER dbo.TB_JEFE_FINANZAS
GO

CREATE SCHEMA SCH_INF_DIRECCION
GO
ALTER SCHEMA SCH_INF_DIRECCION TRANSFER dbo.TB_DEPARTAMENTO
ALTER SCHEMA SCH_INF_DIRECCION TRANSFER dbo.TB_PROVINCIA
ALTER SCHEMA SCH_INF_DIRECCION TRANSFER dbo.TB_DISTRITO
GO

CREATE SCHEMA SCH_PERSONA
GO
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_PERSONA
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_PERSONA_CUENTA
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_PERSONA_SOLICITANTE
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_EMPRESA_S
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_SOLICITANTE_EMPRESA
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_CONYUGE_SOL
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_EMPRESA_C
ALTER SCHEMA SCH_PERSONA TRANSFER dbo.TB_EMPRESA_CONYUGE_SOL
GO

CREATE SCHEMA SCH_SOLICITUD_CREDITO
GO
ALTER SCHEMA SCH_SOLICITUD_CREDITO TRANSFER dbo.TB_SOLICITUD_CREDITO
ALTER SCHEMA SCH_SOLICITUD_CREDITO TRANSFER dbo.TB_REFERENCIA
ALTER SCHEMA SCH_SOLICITUD_CREDITO TRANSFER dbo.TB_SOLICITUD_REFERENCIA
GO

--CREACION VISTAS--
--1--Mostrar detalles de la Solicitud de credito

CREATE VIEW VW_DatosSolicitud
AS
SELECT sc.folio,sr.numReferencia,r.nombreCompleto,sc.estado  FROM SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO sc
JOIN SCH_SOLICITUD_CREDITO.TB_SOLICITUD_REFERENCIA SR ON SR.folio=SC.folio
JOIN SCH_SOLICITUD_CREDITO.TB_REFERENCIA R ON R.numReferencia=SR.numReferencia
GO

SELECT* FROM VW_DatosSolicitud
GO
---2
--MUESTRE SI CUANTOS SOLICITANTES COINCIDEN POR DISTRITO
CREATE VIEW VW_Solicitante_por_distrito
as
SELECT d.codDistrito, COUNT(ps.codSolicitante)numeroSolicitudes FROM SCH_PERSONA.TB_PERSONA_SOLICITANTE ps
inner JOIN  SCH_PERSONA.TB_PERSONA p on p.codPersona =ps.codSolicitante
INNER JOIN SCH_INF_DIRECCION.TB_DISTRITO d on d.codDistrito=p.codDistrito
GROUP BY ps.codSolicitante,d.codDistrito
HAVING COUNT(PS.codSolicitante) > 3; 
go

SELECT* FROM VW_Solicitante_por_distrito
go
--3--Mostrara cuantos creditos realiza un analista

create view vw_Credito_por_analista
AS
SELECT Count(sc.folio)Numero_de_Creditos, a.id_trabaj_analista FROM SCH_AGENCIA_BANC.TB_ANALISTA a
INNER JOIN SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO SC ON SC.id_trabaj_analista = a.id_trabaj_analista 
GROUP BY a.id_trabaj_analista,SC.folio
GO

SELECT * FROM vw_Credito_por_analista
GO

--4/con SCH NO DETECTA codPersonaC
CREATE VIEW VW_FechaSolicitud_SolicitanteyConyuge
AS
SELECT MONTH (SC.fechaSolicitud)MES,DAY(SC.fechaSolicitud)DIA,ps.codSolicitante CodigoSolicitante,c.codPersonaC CodigoConyuge FROM SCH_PERSONA.TB_PERSONA_SOLICITANTE ps
JOIN SCH_PERSONA.TB_CONYUGE_SOL c on c.codPersonaC= ps.codSolicitante
JOIN SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO sc  ON Sc.codSolicitante = c.codPersonaC
group by MONTH (SC.fechaSolicitud),DAY(SC.fechaSolicitud),ps.codSolicitante,c.codPersonaC 
go

select*from VW_FechaSolicitud_SolicitanteyConyuge
GO

--5--mostrara el detalle del dni y su ubicacion
CREATE VIEW vw_UbicacionSolicitante
as
SELECT  p.numDocIdentidad DNI,d.nomDistrtito Distrito,pr.nomProvincia Provincia FROM  SCH_PERSONA.TB_PERSONA p 
INNER JOIN SCH_INF_DIRECCION.TB_DISTRITO d ON d.codDistrito = p.codDistrito
INNER JOIN SCH_INF_DIRECCION.TB_PROVINCIA pr ON pr.codProvincia = d.codProvincia
WHERE d.nomDistrtito='CASTILLA'
go

SELECT*FROM vw_UbicacionSolicitante
GO


use BD_BBVA
--índice para el campo empleado (id_trabajador) de la tabla trabajador
CREATE INDEX idx_empleado on SCH_AGENCIA_BANC.tb_trabajador(id_trabajador)
sp_help 'SCH_AGENCIA_BANC.TB_TRABAJADOR'

--índice para el campo persona(numDocIdentidad) de la tabla persona
CREATE INDEX idx_person on SCH_PERSONA.tb_persona(numDocIdentidad)
sp_help 'SCH_PERSONA.TB_PERSONA'

--índice para el campo Numero persona solicitante(numCelular) de la tabla persona solicitante
CREATE INDEX idx_NumPersSoli on SCH_PERSONA.TB_PERSONA_SOLICITANTE(numCelular)
sp_help 'SCH_PERSONA.TB_PERSONA_SOLICITANTE'

--índice para el campo Ingreso(ingresoMensual) de la tabla Solicitante Empresa
CREATE INDEX idx_ingreso on SCH_PERSONA.TB_SOLICITANTE_EMPRESA(ingresoMensual)
sp_help 'SCH_PERSONA.TB_SOLICITANTE_EMPRESA'

--índice para el campo Dato folio (folio) de la tabla solicitud referencia
CREATE INDEX idx_DatoFolio on SCH_SOLICITUD_CREDITO.TB_SOLICITUD_REFERENCIA(folio)
sp_help 'SCH_SOLICITUD_CREDITO.TB_SOLICITUD_REFERENCIA'
GO

-- Registros para TB_AGENCIA_BANCARIO
INSERT INTO SCH_AGENCIA_BANC.TB_AGENCIA_BANCARIO (id_ruc, nombAgenCIA) VALUES
('12345678901', 'Banco 001'),
('23456789012', 'Banco 002'),
('34567890123', 'Banco 003'),
('45678901234', 'Banco 004'),
('56789012345', 'Banco 005'),
('67890123456', 'Banco 006'),
('78901234567', 'Banco 007'),
('89012345678', 'Banco 008'),
('90123456789', 'Banco 009'),
('98765432109', 'Banco 010');

-- Registros para TB_TRABAJADOR
INSERT INTO SCH_AGENCIA_BANC.TB_TRABAJADOR (id_trabajador, nomb_trabajador, nomb_trabajador2, apellPat_trabajador, apellMat_trabajador, correo_trabajador, telefono_trabajador, id_ruc) VALUES
('12345678', 'Juan', 'Carlos', 'Pérez', 'González', 'juan.perez@gmail.com', '987654321', '12345678901'),
('23456789', 'María', 'Elena', 'López', 'Gómez', 'maria.lopez@gmail.com', '912345678', '23456789012'),
('34567890', 'Pedro', 'José', 'García', 'Hernández', 'pedro.garcia@gmail.com', '999999999', '34567890123'),
('45678901', 'Ana', 'Isabel', 'Rodríguez', 'Jiménez', 'ana.rodriguez@gmail.com', '900000001', '45678901234'),
('56789012', 'Luis', 'Miguel', 'Fernández', 'Sánchez', 'luis.fernandez@gmail.com', '945678912', '56789012345'),
('67890123', 'Laura', 'Patricia', 'Torres', 'López', 'laura.torres@gmail.com', '934567890', '67890123456'),
('78901234', 'Carlos', 'Alberto', 'Mendoza', 'Gómez', 'carlos.mendoza@gmail.com', '956789012', '78901234567'),
('89012345', 'Marcela', 'Alejandra', 'Silva', 'Ramírez', 'marcela.silva@gmail.com', '923456789', '89012345678'),
('90123456', 'Roberto', 'Andrés', 'Pérez', 'Hernández', 'roberto.perez@gmail.com', '989012345', '90123456789'),
('98765432', 'Carolina', 'Fernanda', 'González', 'Soto', 'carolina.gonzalez@gmail.com', '912345679', '98765432109');


-- Registros de prueba para la tabla TB_JEFE_FINANZAS
INSERT INTO SCH_AGENCIA_BANC.TB_JEFE_FINANZAS (id_trabaj_finanzas) VALUES
('12345678'),
('23456789');

-- Registros de prueba para la tabla TB_GERENCIA
INSERT INTO SCH_AGENCIA_BANC.TB_GERENCIA (id_trabaj_gerencia) VALUES
('34567890'),
('45678901'),
('56789012');

-- Registros de prueba para la tabla TB_ANALISTA
INSERT INTO SCH_AGENCIA_BANC.TB_ANALISTA (id_trabaj_analista, horasAtencion, id_supervisor) VALUES
('67890123', 8, NULL),
('78901234', 6, '67890123'),
('89012345', 8, '67890123'),
('98765432', 7, '67890123');

-- Registros para TB_DEPARTAMENTO
INSERT INTO SCH_INF_DIRECCION.TB_DEPARTAMENTO (codDepartamento, nomDepartamento) VALUES
(01, 'Lima'),
(02, 'Arequipa'),
(03, 'Cusco'),
(04, 'Trujillo'),
(05, 'Piura'),
(06, 'Chiclayo'),
(07, 'Iquitos'),
(08, 'Tacna'),
(09, 'Puno'),
(010, 'Huaraz');

-- Registros para TB_PROVINCIA
INSERT INTO SCH_INF_DIRECCION.TB_PROVINCIA (codProvincia, nomProvincia, codDepartamento) VALUES
(001, 'Lima', 01),
(002, 'Callao', 01),
(003, 'Arequipa', 02),
(004, 'Cusco', 03),
(005, 'Trujillo', 04),
(006, 'Piura', 05),
(007, 'Chiclayo',06),
(008, 'Iquitos', 07),
(009, 'Tacna', 08),
(011, 'Puno', 09);

-- Registros para TB_DISTRITO
INSERT INTO SCH_INF_DIRECCION.TB_DISTRITO (codDistrito, nomDistrtito, codProvincia) VALUES
(100, 'Miraflores', 001),
(200, 'San Isidro', 001),
(300, 'Callao', 002),
(400, 'Cerro Colorado',003),
(500, 'Wanchaq', 004),
(600, 'El Porvenir', 005),
(700, 'Castilla', 006),
(800, 'Iquitos', 007),
(900, 'Tacna', 008),
(101, 'Puno', 009);


-- Registros para TB_PERSONA
INSERT INTO SCH_PERSONA.TB_PERSONA (codPersona, numDocIdentidad, primerNombre, segundoNombre, apellidoPaterno, apellidoMaterno, fechaNac, direccion, codDistrito, genero, tipoIdenticacion, nacionalidad, estadoCivil) VALUES
(0001, 12345678, 'Juan', 'José', 'Pérez', 'Candia', '1990-01-01', 'Av. Primavera 123', 100, 'M', 'DNI', 'Peruana', 'Soltero'),
(0002, 23456789, 'María', 'Josefa', 'López', 'García', '1992-05-15', 'Av. Los Pinos 456', 200, 'F', 'DNI', 'Peruana', 'Casada'),
(0003, 34567890, 'Luis', NULL, 'Gómez', 'Mendoza', '1988-11-20', 'Jr. Las Flores 789', 300, 'M', 'DNI', 'Peruana', 'Soltero'),
(0004, 45678901, 'Ana', 'Isabel', 'Torres', 'Ruiz', '1995-08-10', 'Calle Principal 456', 400, 'F', 'DNI', 'Peruana', 'Soltera'),
(0005, 56789012, 'Pedro', 'Pablo', 'Cruz', 'Vargas', '1994-03-05', 'Av. La Merced 789', 500, 'M', 'DNI', 'Peruana', 'Casado'),
(0006, 67890123, 'Carolina', 'Teresa', 'Romero', 'Vera', '1991-12-25', 'Jr. El Sol 345', 600, 'F', 'DNI', 'Peruana', 'Soltera'),
(0007, 78901234, 'Daniel', NULL, 'García', 'Pérez', '1993-09-12', 'Av. Los Robles 567', 700, 'M', 'DNI', 'Peruana', 'Soltero'),
(0008, 89012345, 'Laura', 'Gabriela', 'Luna', 'Sánchez', '1996-06-30', 'Calle Progreso 234', 800, 'F', 'DNI', 'Peruana', 'Casada'),
(0009, 90123456, 'Carlos', 'Alberto', 'Valenzuela', 'Rojas', '1990-02-28', 'Jr. Las Margaritas 678', 900, 'M', 'DNI', 'Peruana', 'Soltero'),
(0010, 98765432, 'Sofía', 'Alejandra', 'Vargas', 'Flores', '1992-07-18', 'Av. Las Palmeras 890', 101, 'F', 'DNI', 'Peruana', 'Soltera');

-- Registros para TB_PERSONA_CUENTA
INSERT INTO SCH_PERSONA.TB_PERSONA_CUENTA (codCuenta, contrasenia, correoElectronico) VALUES
(0001, 'abc123', 'juan@gmail.com'),
(0002, 'def456', 'maria@gmail.com'),
(0003, 'ghi789', 'luis@gmail.com'),
(0004, 'jkl012', 'ana@gmail.com'),
(0005, 'mno345', 'pedro@gmail.com'),
(0006, 'pqr678', 'carolina@gmail.com'),
(0007, 'stu901', 'daniel@gmail.com'),
(0008, 'vwx234', 'laura@gmail.com'),
(0009, 'yz0123', 'carlos@gmail.com'),
(0010, '456abc', 'sofia@gmail.com');

-- Registros para TB_PERSONA_SOLICITANTE
INSERT INTO SCH_PERSONA.TB_PERSONA_SOLICITANTE (codSolicitante, numTelefono, numCelular, codigoPostal, situacionVivienda, tiempoResidencia, numDependientes, estudios, profesion) VALUES
(0001, '012468135', '912345679', 74, 'Alquilada', '2 años', 0, 'Universidad', 'Ingeniero'),
(0002, '015798432', '945678913', 63, 'Propia', '5 años', 2, 'Universidad', 'Contadora'),
(0003, '017123456', '934567891', 52, 'Propia', '4 años', 1, 'Técnico', 'Programador'),
(0004, '018654321', '956789013', 41, 'Alquilada', '1 año', 0, 'Universidad', 'Abogada'),
(0005, '013572894', '923456790', 30, 'Alquilada', '3 años', 1, 'Universidad', 'Médico'),
(0006, '016947582', '989012346', 18, 'Propia', '6 años', 0, 'Universidad', 'Arquitecta'),
(0007, '018216345', '912345680', 07, 'Familiar', '2 años', 0, 'Universidad', 'Contador'),
(0008, '015432167', '945678914', 87, 'Propia', '5 años', 2, 'Técnico', 'Diseñadora'),
(0009, '014152637', '934567892', 76, 'Alquilada', '3 años', 1, 'Universidad', 'Ingeniero'),
(0010, '016789512', '956789014', 65, 'Propia', '4 años', 0, 'Universidad', 'Periodista');

-- Registros de prueba para la tabla TB_EMPRESA_S
INSERT INTO SCH_PERSONA.TB_EMPRESA_S (ruc, nombreEmpresa, rubroEmpresa, tipoEmpresa) VALUES
('12698784901', 'Empresa 1', 'Rubro 1', 'Tipo 1'),
('26548947631', 'Empresa 2', 'Rubro 2', 'Tipo 2'),
('31657945678', 'Empresa 3', 'Rubro 3', 'Tipo 3'),
('45216897364', 'Empresa 4', 'Rubro 4', 'Tipo 4'),
('51324987956', 'Empresa 5', 'Rubro 5', 'Tipo 5'),
('63215795488', 'Empresa 6', 'Rubro 6', 'Tipo 6'),
('71654891256', 'Empresa 7', 'Rubro 7', 'Tipo 7'),
('84154613732', 'Empresa 8', 'Rubro 8', 'Tipo 8'),
('93245241357', 'Empresa 9', 'Rubro 9', 'Tipo 9'),
('10324684674', 'Empresa 10', 'Rubro 10', 'Tipo 10');

-- Registros de prueba para la tabla TB_SOLICITANTE_EMPRESA
INSERT INTO SCH_PERSONA.TB_SOLICITANTE_EMPRESA (ruc, codSolicitante, actual, cargo, antiguedadLaboral, situacionLaboral, ingresoMensual, domicilioTrabajo, telefonoEmpleo) VALUES
('12698784901', 0001, 'Actual 1', 'Cargo 1', '2 años', 'Dependiente', 5000, 'Av. Trabajo 123', '942215377'),
('26548947631', 0002, 'Actual 2', 'Cargo 2', '5 años', 'Independiente', 8000, 'Calle Empleo 456', '933577568'),
('31657945678', 0003, 'Actual 3', 'Cargo 3', '4 años', 'Independiente', 2500, 'Calle Dalias 15', '936909911'),
('45216897364', 0004, 'Actual 4', 'Cargo 4', '1 años', 'Dependiente', 3000, 'Calle Violetas 56', '970698851'),
('51324987956', 0005, 'Actual 5', 'Cargo 5', '3 años', 'Dependiente', 1800, 'Calle Jasminez 489', '973100770'),
('63215795488', 0006, 'Actual 6', 'Cargo 6', '6 años', 'Independiente', 4500, 'Calle Correo 45', '976303518'),
('71654891256', 0007, 'Actual 7', 'Cargo 7', '2 años', 'Independiente', 2300, 'Calle Veatriz  89', '952175239'),
('84154613732', 0008, 'Actual 8', 'Cargo 8', '5 años', 'Independiente', 5900, 'Calle Andahuaylas 78', '956382422'),
('93245241357', 0009, 'Actual 9', 'Cargo 9', '3 años', 'Dependiente', 4200, 'Calle Santa Rosa 485', '923646184'),
('10324684674', 0010, 'Actual 10', 'Cargo 10', '4 años', 'Independiente', 2100, 'Calle Girasoles 345', '926631351');

-- Registros de prueba para la tabla TB_CONYUGE_SOL
INSERT INTO SCH_PERSONA.TB_CONYUGE_SOL (codPersonaC, numRuc, nivelEstudios, profesion, tituloObtenido, situacionLaboral) VALUES
(0001, '11234568789', 'Superior', 'Abogado', 'Título 1', 'Dependiente'),
(0002, '22345678847', 'Técnico', 'Ingeniero', 'Título 2', 'Independiente'),
(0003, NULL, 'Titulado', 'Doctor', 'Título 3', 'Independiente'),
(0004, NULL, 'Técnico', 'Docente', 'Título 4', 'Dependiente'),
(0005, '48987456126', 'Técnico', 'Contador', 'Título 5', 'Independiente'),
(0006, NULL, 'Superior', 'Ingeniero(a)', 'Título 6', 'Independiente'),
(0007, NULL, 'Técnico', 'Ingeniero(a)', 'Título 7', 'Dependiente'),
(0008, NULL, 'Superior', 'Abogado', 'Título 8', 'Independiente'),
(0009, NULL, 'Técnico', 'Contador', 'Título 9', 'Dependiente'),
(0010, NULL, 'Titulado', 'Psicologo', 'Título 10', 'Independiente');

-- Registros de prueba para la tabla TB_EMPRESA_C
INSERT INTO SCH_PERSONA.TB_EMPRESA_C (rucEmpresaC, nombreEmpresa, actividadEmpresa) VALUES
('12345678901', 'EmpresaC 1', 'Act1'),
('98765432109', 'EmpresaC 2', 'Act2'),
('34544564564', 'EmpresaC 3', 'Act3'),
('44564789156', 'EmpresaC 4', 'Act4'),
('12325465454', 'EmpresaC 5', 'Act5'),
('48784545644', 'EmpresaC 6', 'Act6'),
('13223455488', 'EmpresaC 7', 'Act7'),
('78846454512', 'EmpresaC 8', 'Act8'),
('87988445554', 'EmpresaC 9', 'Act9'),
('32456486788', 'EmpresaC 10', 'Act10');

-- Registros de prueba para la tabla TB_EMPRESA_CONYUGE_SOL
INSERT INTO SCH_PERSONA.TB_EMPRESA_CONYUGE_SOL (codPersonaC, rucEmpresaC, telefono, direccionEmpresa) VALUES
(0001, '12345678901', '111', 'Av. EmpresaC 1'),
(0002, '98765432109', '222', 'Calle EmpresaC 2'),
(0003, '34544564564', '333', 'Calle EmpresaC 2'),
(0004, '44564789156', '444', 'Calle EmpresaC 2'),
(0005, '12325465454', '555', 'Calle EmpresaC 2'),
(0006, '48784545644', '666', 'Calle EmpresaC 2'),
(0007, '13223455488', '777', 'Calle EmpresaC 2'),
(0008, '78846454512', '888', 'Calle EmpresaC 2'),
(0009, '87988445554', '999', 'Calle EmpresaC 2'),
(0010, '32456486788', '1011', 'Calle EmpresaC 2');

-- Registros de prueba para la tabla TB_SOLICITUD_CREDITO
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (151, '78901234', 0001, 'Operación 1', '2023-06-01', 'Aprobada', '2023-06-05');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (251, '78901234', 0002, 'Operación 2', '2023-10-03', 'En proceso', '2023-10-07');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (351, '78901234', 0003, 'Operación 3', '2023-05-15', 'En proceso', '2023-05-18');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (451, '78901234', 0004, 'Operación 4', '2023-04-26', 'En Aprobada', '2023-04-29');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (551, '78901234', 0005, 'Operación 5', '2023-09-13', 'En proceso', '2023-09-18');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (651, '78901234', 0006, 'Operación 6', '2023-03-02', 'En proceso', '2023-03-03');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (751, '78901234', 0007, 'Operación 7', '2023-08-15', 'En Aprobada', '2023-08-17');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (851, '78901234', 0008, 'Operación 8', '2023-04-10', 'En proceso', '2023-04-13');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (951, '78901234', 0009, 'Operación 9', '2023-06-19', 'En Aprobada', '2023-06-22');
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO (folio, id_trabaj_analista, codSolicitante, tipoOperacion, fechaSolicitud, estado, fechaAprobacion) VALUES (051, '78901234', 0010, 'Operación 10', '2023-02-27', 'En proceso', '2023-02-25');
 
select * from  SCH_SOLICITUD_CREDITO.TB_SOLICITUD_CREDITO

-- Registros de prueba para la tabla TB_REFERENCIA
INSERT INTO SCH_SOLICITUD_CREDITO.TB_REFERENCIA (numReferencia, nombreCompleto, telefono, direccion) VALUES
(161, 'Referencia 1', '989012349', 'Dirección 1'),
(261, 'Referencia 2', '912345683', 'Dirección 2'),
(361, 'Referencia 3', '999999994', 'Dirección 3'),
(461, 'Referencia 4', '900000006', 'Dirección 4'),
(561, 'Referencia 5', '945678917', 'Dirección 5'),
(661, 'Referencia 6', '934567895', 'Dirección 6'),
(761, 'Referencia 7', '956789017', 'Dirección 7'),
(861, 'Referencia 8', '923456794', 'Dirección 8'),
(961, 'Referencia 9', '989012350', 'Dirección 9'),
(061, 'Referencia 10', '912345684', 'Dirección 10');

-- Registros de prueba para la tabla TB_SOLICITUD_REFERENCIA
INSERT INTO SCH_SOLICITUD_CREDITO.TB_SOLICITUD_REFERENCIA (folio, numReferencia, tipoVinculo) VALUES
(151, 161, 'Vínculo 1'),
(251, 261, 'Vínculo 2'),
(351, 361, 'Vínculo 3'),
(451, 461, 'Vínculo 4'),
(551, 561, 'Vínculo 5'),
(651, 661, 'Vínculo 6'),
(751, 761, 'Vínculo 7'),
(851, 861, 'Vínculo 8'),
(951, 961, 'Vínculo 9'),
(051, 061, 'Vínculo 10');

