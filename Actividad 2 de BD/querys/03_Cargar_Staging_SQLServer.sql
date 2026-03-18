-- ============================================================
-- SCRIPT 03: CARGAR STAGING - VERSIÓN SIMPLIFICADA
-- Compatible con: SQL Server
-- Sin errores de sintaxis
-- ============================================================

USE Staging;
GO

PRINT '============================================================';
PRINT '=                INICIANDO CARGA DE STAGING                =';
PRINT '============================================================';
PRINT 'Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT ''
GO

-- ============================================================
-- PASO 1: LIMPIAR TABLAS STAGING
-- ============================================================

PRINT '***** Limpiando tablas Staging ***** ';

TRUNCATE TABLE stg.STG_Oficina;
TRUNCATE TABLE stg.STG_Empleado;
TRUNCATE TABLE stg.STG_Categoria;
TRUNCATE TABLE stg.STG_Cliente;
TRUNCATE TABLE stg.STG_Producto;
TRUNCATE TABLE stg.STG_Pedido;
TRUNCATE TABLE stg.STG_DetallePedido;
TRUNCATE TABLE stg.STG_Pago;

PRINT ' ***** Tablas limpiadas ***** ';
PRINT '';
GO

-- ============================================================
-- PASO 2: CARGAR STG_Oficina
-- ============================================================

PRINT ' ***** Cargando STG_Oficina ***** ';

INSERT INTO stg.STG_Oficina (
    ID_oficina, Descripcion, ciudad, pais, region, 
    codigo_postal, telefono, linea_direccion1, linea_direccion2,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_oficina,
    Descripcion,
    ciudad,
    pais,
    region,
    codigo_postal,
    telefono,
    linea_direccion1,
    linea_direccion2,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.oficina;

PRINT '***** STG_Oficina: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- PASO 3: CARGAR STG_Empleado
-- ============================================================

PRINT ' ***** Cargando STG_Empleado ***** ';

INSERT INTO stg.STG_Empleado (
    ID_empleado, nombre, apellido1, apellido2, extension,
    email, ID_oficina, ID_jefe, puesto,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_empleado,
    LTRIM(RTRIM(nombre)),
    LTRIM(RTRIM(apellido1)),
    LTRIM(RTRIM(apellido2)),
    extension,
    LOWER(LTRIM(RTRIM(email))),
    ID_oficina,
    ID_jefe,
    puesto,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.empleado;

PRINT '***** STG_Empleado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- PASO 4: CARGAR STG_Categoria
-- ============================================================

PRINT '***** Cargando STG_Categoria ***** ';

INSERT INTO stg.STG_Categoria (
    Id_Categoria, Desc_Categoria, descripcion_texto, 
    descripcion_html, imagen,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    Id_Categoria,
    Desc_Categoria,
    descripcion_texto,
    descripcion_html,
    imagen,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.Categoria_producto;

PRINT '***** STG_Categoria: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- PASO 5: CARGAR STG_Cliente
-- ============================================================

PRINT '***** Cargando STG_Cliente ***** ';

INSERT INTO stg.STG_Cliente (
    ID_cliente, nombre_cliente, nombre_contacto, apellido_contacto,
    telefono, fax, linea_direccion1, linea_direccion2, ciudad, region,
    pais, codigo_postal, ID_empleado_rep_ventas, limite_credito,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_cliente,
    LTRIM(RTRIM(nombre_cliente)),
    LTRIM(RTRIM(nombre_contacto)),
    LTRIM(RTRIM(apellido_contacto)),
    telefono,
    fax,
    linea_direccion1,
    linea_direccion2,
    LTRIM(RTRIM(ciudad)),
    region,
    pais,
    codigo_postal,
    ID_empleado_rep_ventas,
    limite_credito,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.cliente;

PRINT '***** STG_Cliente: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- =                 PASO 6: CARGAR STG_Producto              =
-- ============================================================

PRINT '***** Cargando STG_Producto ***** ';

INSERT INTO stg.STG_Producto (
    ID_producto, nombre, Categoria, dimensiones, proveedor,
    descripcion, cantidad_en_stock, precio_venta, precio_proveedor,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_producto,
    LTRIM(RTRIM(nombre)),
    Categoria,
    dimensiones,
    proveedor,
    descripcion,
    cantidad_en_stock,
    precio_venta,
    precio_proveedor,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.producto;

PRINT '***** STG_Producto: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- =              PASO 7: CARGAR STG_Pedido                   =
-- ============================================================

PRINT '***** Cargando STG_Pedido ***** ';

INSERT INTO stg.STG_Pedido (
    ID_pedido, fecha_pedido, fecha_esperada, fecha_entrega,
    estado, comentarios, ID_cliente,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_pedido,
    fecha_pedido,
    fecha_esperada,
    fecha_entrega,
    estado,
    comentarios,
    ID_cliente,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.pedido;

PRINT '***** STG_Pedido: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- =           PASO 8: CARGAR STG_DetallePedido               =
-- ============================================================

PRINT '***** Cargando STG_DetallePedido ***** ';

INSERT INTO stg.STG_DetallePedido (
    ID_pedido, ID_producto, cantidad, precio_unidad, numero_linea,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_pedido,
    ID_producto,
    cantidad,
    precio_unidad,
    numero_linea,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.detalle_pedido;

PRINT '***** STG_DetallePedido: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados *****';
GO

-- ============================================================
-- PASO 9: CARGAR STG_Pago
-- ============================================================

PRINT '***** Cargando STG_Pago ***** ';

INSERT INTO stg.STG_Pago (
    ID_cliente, forma_pago, id_transaccion, fecha_pago, total,
    FechaCarga, UsuarioCarga, OrigenDatos
)
SELECT 
    ID_cliente,
    forma_pago,
    id_transaccion,
    fecha_pago,
    total,
    GETDATE(),
    SUSER_NAME(),
    'OLTP_Jardineria'
FROM jardineria.dbo.pago;

PRINT '***** STG_Pago: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros cargados ***** ';
GO

-- ============================================================
-- PASO 10: ACTUALIZAR CONFIGURACIÓN
-- ============================================================

UPDATE util.Configuracion
SET Valor = CONVERT(VARCHAR, GETDATE(), 120),
    FechaActualizacion = GETDATE()
WHERE Parametro = 'UltimaCargaCompleta';
GO

-- ============================================================
-- PASO 11: VERIFICACIÓN Y RESUMEN
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '=              CARGA COMPLETADA - RESUMEN:                 =';
PRINT '============================================================';
PRINT '';

-- Mostrar resumen
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
SELECT 'STG_Pago', COUNT(*), MAX(FechaCarga) FROM stg.STG_Pago
ORDER BY Tabla;

PRINT '';
PRINT '============================================================';
PRINT '=             COMPARACIÓN OLTP vs STAGING:                 =';
PRINT '============================================================';
PRINT '';

-- Comparar con OLTP
SELECT 
    'oficina' as Tabla,
    (SELECT COUNT(*) FROM jardineria.dbo.oficina) as OLTP,
    (SELECT COUNT(*) FROM stg.STG_Oficina) as Staging,
    CASE 
        WHEN (SELECT COUNT(*) FROM jardineria.dbo.oficina) = (SELECT COUNT(*) FROM stg.STG_Oficina)
        THEN 'OK'
        ELSE 'DIFERENCIA'
    END as Estado
UNION ALL
SELECT 'empleado',
    (SELECT COUNT(*) FROM jardineria.dbo.empleado),
    (SELECT COUNT(*) FROM stg.STG_Empleado),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.empleado) = (SELECT COUNT(*) FROM stg.STG_Empleado)
        THEN 'OK' ELSE 'DIFERENCIA' END
UNION ALL
SELECT 'Categoria_producto',
    (SELECT COUNT(*) FROM jardineria.dbo.Categoria_producto),
    (SELECT COUNT(*) FROM stg.STG_Categoria),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.Categoria_producto) = (SELECT COUNT(*) FROM stg.STG_Categoria)
        THEN 'OK' ELSE 'DIFERENCIA' END
UNION ALL
SELECT 'cliente',
    (SELECT COUNT(*) FROM jardineria.dbo.cliente),
    (SELECT COUNT(*) FROM stg.STG_Cliente),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.cliente) = (SELECT COUNT(*) FROM stg.STG_Cliente)
        THEN 'OK' ELSE 'DIFERENCIA' END
UNION ALL
SELECT 'producto',
    (SELECT COUNT(*) FROM jardineria.dbo.producto),
    (SELECT COUNT(*) FROM stg.STG_Producto),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.producto) = (SELECT COUNT(*) FROM stg.STG_Producto)
        THEN 'OK' ELSE 'DIFERENCIA' END
UNION ALL
SELECT 'pedido',
    (SELECT COUNT(*) FROM jardineria.dbo.pedido),
    (SELECT COUNT(*) FROM stg.STG_Pedido),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.pedido) = (SELECT COUNT(*) FROM stg.STG_Pedido)
        THEN 'OK' ELSE 'DIFERENCIA' END
UNION ALL
SELECT 'detalle_pedido',
    (SELECT COUNT(*) FROM jardineria.dbo.detalle_pedido),
    (SELECT COUNT(*) FROM stg.STG_DetallePedido),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.detalle_pedido) = (SELECT COUNT(*) FROM stg.STG_DetallePedido)
        THEN 'OK' ELSE 'DIFERENCIA' END
UNION ALL
SELECT 'pago',
    (SELECT COUNT(*) FROM jardineria.dbo.pago),
    (SELECT COUNT(*) FROM stg.STG_Pago),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.pago) = (SELECT COUNT(*) FROM stg.STG_Pago)
        THEN 'OK' ELSE 'DIFERENCIA' END;

PRINT '';
PRINT '============================================================';
PRINT 'SIGUIENTE PASO:';
PRINT 'Ejecutar: 04_Validar_Staging_SQLServer.sql';
PRINT '============================================================';
GO
