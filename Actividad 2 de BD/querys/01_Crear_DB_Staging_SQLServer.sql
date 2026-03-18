-- ============================================================
-- SCRIPT 01: CREAR BASE DE DATOS STAGING - SQL SERVER
-- Base de Datos: Staging
-- Propósito: Base intermedia entre OLTP y Data Mart
-- Autor: Sistema ETL
-- Fecha: 2024
-- ============================================================

USE master;
GO

-- ============================================================
-- 1) ELIMINAR BASE DE DATOS SI EXISTE
-- ============================================================

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Staging')
BEGIN
    ALTER DATABASE Staging SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Staging;
    PRINT '✓ Base de datos Staging eliminada';
END
GO

-- ============================================================
-- 2) CREAR BASE DE DATOS STAGING
-- ============================================================

CREATE DATABASE Staging
ON PRIMARY
(
    NAME = 'Staging_Data',
    FILENAME = 'C:\SQLData\Staging_Data.mdf',
    SIZE = 50MB,
    MAXSIZE = 500MB,
    FILEGROWTH = 10MB
)
LOG ON
(
    NAME = 'Staging_Log',
    FILENAME = 'C:\SQLData\Staging_Log.ldf',
    SIZE = 25MB,
    MAXSIZE = 250MB,
    FILEGROWTH = 5MB
);
GO

PRINT '==== Base de datos Staging creada exitosamente ====';
GO

-- ============================================================
-- 3) CONFIGURAR BASE DE DATOS
-- ============================================================

USE Staging;
GO

-- Configuración de recuperación
ALTER DATABASE Staging SET RECOVERY SIMPLE;
GO

-- Configuración de compatibilidad
ALTER DATABASE Staging SET COMPATIBILITY_LEVEL = 150; -- SQL Server 2019
GO

PRINT '✓ Configuración de base de datos aplicada';
GO

-- ============================================================
-- 4) CREAR ESQUEMAS
-- ============================================================

-- Esquema para tablas staging
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg')
BEGIN
    EXEC('CREATE SCHEMA stg');
    PRINT '✓ Esquema stg creado';
END
GO

-- Esquema para utilidades
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'util')
BEGIN
    EXEC('CREATE SCHEMA util');
    PRINT '✓ Esquema util creado';
END
GO

-- ============================================================
-- 5) CREAR TABLA DE AUDITORÍA (LOG DE CARGAS)
-- ============================================================

CREATE TABLE util.LogCarga (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    TablaDestino VARCHAR(100) NOT NULL,
    FechaInicio DATETIME NOT NULL DEFAULT GETDATE(),
    FechaFin DATETIME NULL,
    RegistrosCargados INT NULL,
    Estado VARCHAR(20) NOT NULL DEFAULT 'En Proceso', -- 'Exitoso', 'Error'
    MensajeError VARCHAR(500) NULL,
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME()
);
GO

PRINT '✓ Tabla de auditoría util.LogCarga creada';
GO

-- ============================================================
-- 6) CREAR TABLA DE CONFIGURACIÓN
-- ============================================================

CREATE TABLE util.Configuracion (
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,
    Parametro VARCHAR(100) NOT NULL UNIQUE,
    Valor VARCHAR(500) NOT NULL,
    Descripcion VARCHAR(500) NULL,
    FechaActualizacion DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- Insertar parámetros de configuración
INSERT INTO util.Configuracion (Parametro, Valor, Descripcion) VALUES
('DB_Origen', 'jardineria', 'Base de datos origen OLTP'),
('Servidor_Origen', 'localhost', 'Servidor de base de datos origen'),
('UltimaCargaCompleta', '1900-01-01', 'Fecha de última carga completa'),
('UltimaCargaIncremental', '1900-01-01', 'Fecha de última carga incremental'),
('TipoCarga', 'FULL', 'Tipo de carga: FULL o INCREMENTAL');
GO

PRINT '✓ Tabla de configuración util.Configuracion creada';
GO

-- ============================================================
-- 7) CREAR ÍNDICE EN TABLAS DE UTILIDAD
-- ============================================================

CREATE NONCLUSTERED INDEX IX_LogCarga_Fecha 
ON util.LogCarga(FechaInicio DESC);
GO

PRINT '✓ Índices de utilidad creados';
GO

-- ============================================================
-- 8) INFORMACIÓN FINAL
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '=       BASE DE DATOS STAGING CREADA EXITOSAMENTE          =';
PRINT '============================================================';
PRINT 'Base de Datos: Staging';
PRINT 'Esquemas: stg (datos), util (utilidades)';
PRINT 'Tablas de Soporte: LogCarga, Configuracion';
PRINT '';
PRINT 'Siguiente paso: Ejecutar 02_Crear_Tablas_Staging.sql';
PRINT '============================================================';
GO

-- Verificar creación
SELECT 
    'Base de Datos' as Objeto,
    name as Nombre,
    create_date as FechaCreacion,
    state_desc as Estado
FROM sys.databases 
WHERE name = 'Staging'
UNION ALL
SELECT 
    'Esquema' as Objeto,
    name as Nombre,
    NULL as FechaCreacion,
    NULL as Estado
FROM sys.schemas 
WHERE name IN ('stg', 'util')
UNION ALL
SELECT 
    'Tabla' as Objeto,
    OBJECT_SCHEMA_NAME(object_id) + '.' + name as Nombre,
    create_date as FechaCreacion,
    NULL as Estado
FROM sys.tables
WHERE OBJECT_SCHEMA_NAME(object_id) = 'util';
GO
