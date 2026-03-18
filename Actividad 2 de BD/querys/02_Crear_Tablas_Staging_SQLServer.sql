-- ============================================================
-- SCRIPT 02: CREAR TABLAS STAGING - SQL SERVER
-- Base de Datos: Staging
-- Propósito: Tablas intermedias para proceso ETL
-- ============================================================

USE Staging;
GO

PRINT 'Iniciando creación de tablas Staging...';
GO

-- ============================================================
-- 1) STG_Oficina
-- ============================================================

IF OBJECT_ID('stg.STG_Oficina', 'U') IS NOT NULL
    DROP TABLE stg.STG_Oficina;
GO

CREATE TABLE stg.STG_Oficina (
    ID_oficina INT NOT NULL,
    Descripcion VARCHAR(10) NOT NULL,
    ciudad VARCHAR(30) NOT NULL,
    pais VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL,
    codigo_postal VARCHAR(10) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    linea_direccion1 VARCHAR(50) NOT NULL,
    linea_direccion2 VARCHAR(50) NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Oficina_ID ON stg.STG_Oficina(ID_oficina);
GO

PRINT '✓ Tabla stg.STG_Oficina creada';
GO

-- ============================================================
-- 2) STG_Empleado
-- ============================================================

IF OBJECT_ID('stg.STG_Empleado', 'U') IS NOT NULL
    DROP TABLE stg.STG_Empleado;
GO

CREATE TABLE stg.STG_Empleado (
    ID_empleado INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    apellido1 VARCHAR(50) NOT NULL,
    apellido2 VARCHAR(50) NULL,
    extension VARCHAR(10) NOT NULL,
    email VARCHAR(100) NOT NULL,
    ID_oficina INT NOT NULL,
    ID_jefe INT NULL,
    puesto VARCHAR(50) NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Empleado_ID ON stg.STG_Empleado(ID_empleado);
CREATE NONCLUSTERED INDEX IX_STG_Empleado_Oficina ON stg.STG_Empleado(ID_oficina);
GO

PRINT '✓ Tabla stg.STG_Empleado creada';
GO

-- ============================================================
-- 3) STG_Categoria
-- ============================================================

IF OBJECT_ID('stg.STG_Categoria', 'U') IS NOT NULL
    DROP TABLE stg.STG_Categoria;
GO

CREATE TABLE stg.STG_Categoria (
    Id_Categoria INT NOT NULL,
    Desc_Categoria VARCHAR(50) NOT NULL,
    descripcion_texto TEXT NULL,
    descripcion_html TEXT NULL,
    imagen VARCHAR(256) NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Categoria_ID ON stg.STG_Categoria(Id_Categoria);
GO

PRINT '✓ Tabla stg.STG_Categoria creada';
GO

-- ============================================================
-- 4) STG_Cliente
-- ============================================================

IF OBJECT_ID('stg.STG_Cliente', 'U') IS NOT NULL
    DROP TABLE stg.STG_Cliente;
GO

CREATE TABLE stg.STG_Cliente (
    ID_cliente INT NOT NULL,
    nombre_cliente VARCHAR(50) NOT NULL,
    nombre_contacto VARCHAR(30) NULL,
    apellido_contacto VARCHAR(30) NULL,
    telefono VARCHAR(15) NOT NULL,
    fax VARCHAR(15) NOT NULL,
    linea_direccion1 VARCHAR(50) NOT NULL,
    linea_direccion2 VARCHAR(50) NULL,
    ciudad VARCHAR(50) NOT NULL,
    region VARCHAR(50) NULL,
    pais VARCHAR(50) NULL,
    codigo_postal VARCHAR(10) NULL,
    ID_empleado_rep_ventas INT NULL,
    limite_credito NUMERIC(15,2) NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Cliente_ID ON stg.STG_Cliente(ID_cliente);
CREATE NONCLUSTERED INDEX IX_STG_Cliente_Pais ON stg.STG_Cliente(pais);
CREATE NONCLUSTERED INDEX IX_STG_Cliente_Ciudad ON stg.STG_Cliente(ciudad);
GO

PRINT '✓ Tabla stg.STG_Cliente creada';
GO

-- ============================================================
-- 5) STG_Producto
-- ============================================================

IF OBJECT_ID('stg.STG_Producto', 'U') IS NOT NULL
    DROP TABLE stg.STG_Producto;
GO

CREATE TABLE stg.STG_Producto (
    ID_producto VARCHAR(15) NOT NULL,
    nombre VARCHAR(70) NOT NULL,
    Categoria INT NOT NULL,
    dimensiones VARCHAR(25) NULL,
    proveedor VARCHAR(50) NULL,
    descripcion TEXT NULL,
    cantidad_en_stock SMALLINT NOT NULL,
    precio_venta NUMERIC(15,2) NOT NULL,
    precio_proveedor NUMERIC(15,2) NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Producto_ID ON stg.STG_Producto(ID_producto);
CREATE NONCLUSTERED INDEX IX_STG_Producto_Categoria ON stg.STG_Producto(Categoria);
GO

PRINT '✓ Tabla stg.STG_Producto creada';
GO

-- ============================================================
-- 6) STG_Pedido
-- ============================================================

IF OBJECT_ID('stg.STG_Pedido', 'U') IS NOT NULL
    DROP TABLE stg.STG_Pedido;
GO

CREATE TABLE stg.STG_Pedido (
    ID_pedido INT NOT NULL,
    fecha_pedido DATE NOT NULL,
    fecha_esperada DATE NOT NULL,
    fecha_entrega DATE NULL,
    estado VARCHAR(15) NOT NULL,
    comentarios TEXT NULL,
    ID_cliente INT NOT NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Pedido_ID ON stg.STG_Pedido(ID_pedido);
CREATE NONCLUSTERED INDEX IX_STG_Pedido_Cliente ON stg.STG_Pedido(ID_cliente);
CREATE NONCLUSTERED INDEX IX_STG_Pedido_Fecha ON stg.STG_Pedido(fecha_pedido);
GO

PRINT '✓ Tabla stg.STG_Pedido creada';
GO

-- ============================================================
-- 7) STG_DetallePedido
-- ============================================================

IF OBJECT_ID('stg.STG_DetallePedido', 'U') IS NOT NULL
    DROP TABLE stg.STG_DetallePedido;
GO

CREATE TABLE stg.STG_DetallePedido (
    ID_pedido INT NOT NULL,
    ID_producto VARCHAR(15) NOT NULL,
    cantidad INT NOT NULL,
    precio_unidad NUMERIC(15,2) NOT NULL,
    numero_linea SMALLINT NOT NULL,
    -- Campo calculado
    Importe AS (cantidad * precio_unidad),
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_DetallePedido_Pedido ON stg.STG_DetallePedido(ID_pedido);
CREATE NONCLUSTERED INDEX IX_STG_DetallePedido_Producto ON stg.STG_DetallePedido(ID_producto);
GO

PRINT '✓ Tabla stg.STG_DetallePedido creada';
GO

-- ============================================================
-- 8) STG_Pago
-- ============================================================

IF OBJECT_ID('stg.STG_Pago', 'U') IS NOT NULL
    DROP TABLE stg.STG_Pago;
GO

CREATE TABLE stg.STG_Pago (
    ID_cliente INT NOT NULL,
    forma_pago VARCHAR(40) NOT NULL,
    id_transaccion VARCHAR(50) NOT NULL,
    fecha_pago DATE NOT NULL,
    total NUMERIC(15,2) NOT NULL,
    -- Campos de Auditoría
    FechaCarga DATETIME NOT NULL DEFAULT GETDATE(),
    UsuarioCarga VARCHAR(100) NOT NULL DEFAULT SUSER_NAME(),
    OrigenDatos VARCHAR(50) NOT NULL DEFAULT 'OLTP_Jardineria'
);
GO

CREATE CLUSTERED INDEX IX_STG_Pago_Cliente ON stg.STG_Pago(ID_cliente);
CREATE NONCLUSTERED INDEX IX_STG_Pago_Fecha ON stg.STG_Pago(fecha_pago);
CREATE NONCLUSTERED INDEX IX_STG_Pago_FormaPago ON stg.STG_Pago(forma_pago);
GO

PRINT '✓ Tabla stg.STG_Pago creada';
GO

-- ============================================================
-- 9) VISTA DE RESUMEN DE TABLAS STAGING
-- ============================================================

IF OBJECT_ID('util.v_ResumenStaging', 'V') IS NOT NULL
    DROP VIEW util.v_ResumenStaging;
GO

CREATE VIEW util.v_ResumenStaging
AS
SELECT 
    'STG_Oficina' as Tabla,
    COUNT(*) as Registros,
    MAX(FechaCarga) as UltimaCarga
FROM stg.STG_Oficina
UNION ALL
SELECT 'STG_Empleado', COUNT(*), MAX(FechaCarga) FROM stg.STG_Empleado
UNION ALL
SELECT 'STG_Categoria', COUNT(*), MAX(FechaCarga) FROM stg.STG_Categoria
UNION ALL
SELECT 'STG_Cliente', COUNT(*), MAX(FechaCarga) FROM stg.STG_Cliente
UNION ALL
SELECT 'STG_Producto', COUNT(*), MAX(FechaCarga) FROM stg.STG_Producto
UNION ALL
SELECT 'STG_Pedido', COUNT(*), MAX(FechaCarga) FROM stg.STG_Pedido
UNION ALL
SELECT 'STG_DetallePedido', COUNT(*), MAX(FechaCarga) FROM stg.STG_DetallePedido
UNION ALL
SELECT 'STG_Pago', COUNT(*), MAX(FechaCarga) FROM stg.STG_Pago;
GO

PRINT '✓ Vista util.v_ResumenStaging creada';
GO

-- ============================================================
-- 10) INFORMACIÓN FINAL
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '✅ TABLAS STAGING CREADAS EXITOSAMENTE';
PRINT '============================================================';
PRINT '';

-- Listar tablas creadas
SELECT 
    OBJECT_SCHEMA_NAME(object_id) as Esquema,
    name as Tabla,
    create_date as FechaCreacion
FROM sys.tables
WHERE OBJECT_SCHEMA_NAME(object_id) = 'stg'
ORDER BY name;

PRINT '';
PRINT 'Total de tablas Staging: 8';
PRINT 'Total de índices creados: 15+';
PRINT '';
PRINT 'Siguiente paso: Ejecutar 03_Cargar_Staging.sql';
PRINT '============================================================';
GO

USE Staging;
GO

-- Ver estructura de una tabla (ejemplo: STG_Cliente)
SELECT 
    COLUMN_NAME as Columna,
    DATA_TYPE as TipoDato,
    CHARACTER_MAXIMUM_LENGTH as Longitud,
    IS_NULLABLE as PermiteNULL
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
  AND TABLE_NAME = 'STG_Cliente'
ORDER BY ORDINAL_POSITION;

-- Verificar que TODAS las tablas tienen campos de auditoría
SELECT 
    TABLE_NAME as Tabla,
    COUNT(*) as TotalColumnas,
    SUM(CASE WHEN COLUMN_NAME IN ('FechaCarga', 'UsuarioCarga', 'OrigenDatos') THEN 1 ELSE 0 END) as CamposAuditoria
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'stg'
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

-- Verificar que la vista v_ResumenStaging existe
SELECT * FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'util'
  AND TABLE_NAME = 'v_ResumenStaging';

-- Probar la vista (debería mostrar 0 registros en todas las tablas)
SELECT * FROM util.v_ResumenStaging
ORDER BY Tabla;