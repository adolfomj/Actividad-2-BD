-- ============================================================
-- SCRIPT 04: VALIDAR DATOS EN STAGING - SQL SERVER
-- Propósito: Verificar calidad e integridad de datos cargados
-- ============================================================

USE Staging;
GO

PRINT 'Iniciando validaciones de calidad de datos...';
PRINT 'Fecha/Hora: ' + CONVERT(VARCHAR, GETDATE(), 120);
PRINT '';
GO

-- ============================================================
-- 1) VALIDACIÓN: Conteo de Registros OLTP vs Staging
-- ============================================================

PRINT '============================================================';
PRINT '1. VALIDACIÓN DE COMPLETITUD';
PRINT '============================================================';
PRINT '';

SELECT 
    'oficina' as Tabla,
    (SELECT COUNT(*) FROM jardineria.dbo.oficina) as OLTP,
    (SELECT COUNT(*) FROM stg.STG_Oficina) as Staging,
    CASE 
        WHEN (SELECT COUNT(*) FROM jardineria.dbo.oficina) = (SELECT COUNT(*) FROM stg.STG_Oficina)
        THEN '✅ OK'
        ELSE '❌ DIFERENCIA'
    END as Estado
UNION ALL
SELECT 'empleado',
    (SELECT COUNT(*) FROM jardineria.dbo.empleado),
    (SELECT COUNT(*) FROM stg.STG_Empleado),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.empleado) = (SELECT COUNT(*) FROM stg.STG_Empleado)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END
UNION ALL
SELECT 'Categoria_producto',
    (SELECT COUNT(*) FROM jardineria.dbo.Categoria_producto),
    (SELECT COUNT(*) FROM stg.STG_Categoria),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.Categoria_producto) = (SELECT COUNT(*) FROM stg.STG_Categoria)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END
UNION ALL
SELECT 'cliente',
    (SELECT COUNT(*) FROM jardineria.dbo.cliente),
    (SELECT COUNT(*) FROM stg.STG_Cliente),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.cliente) = (SELECT COUNT(*) FROM stg.STG_Cliente)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END
UNION ALL
SELECT 'producto',
    (SELECT COUNT(*) FROM jardineria.dbo.producto),
    (SELECT COUNT(*) FROM stg.STG_Producto),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.producto) = (SELECT COUNT(*) FROM stg.STG_Producto)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END
UNION ALL
SELECT 'pedido',
    (SELECT COUNT(*) FROM jardineria.dbo.pedido),
    (SELECT COUNT(*) FROM stg.STG_Pedido),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.pedido) = (SELECT COUNT(*) FROM stg.STG_Pedido)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END
UNION ALL
SELECT 'detalle_pedido',
    (SELECT COUNT(*) FROM jardineria.dbo.detalle_pedido),
    (SELECT COUNT(*) FROM stg.STG_DetallePedido),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.detalle_pedido) = (SELECT COUNT(*) FROM stg.STG_DetallePedido)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END
UNION ALL
SELECT 'pago',
    (SELECT COUNT(*) FROM jardineria.dbo.pago),
    (SELECT COUNT(*) FROM stg.STG_Pago),
    CASE WHEN (SELECT COUNT(*) FROM jardineria.dbo.pago) = (SELECT COUNT(*) FROM stg.STG_Pago)
        THEN '✅ OK' ELSE '❌ DIFERENCIA' END;
GO

-- ============================================================
-- 2) VALIDACIÓN: Valores NULOS en Campos Críticos
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '2. VALIDACIÓN DE INTEGRIDAD (Campos NULL)';
PRINT '============================================================';
PRINT '';

-- Clientes sin nombre
SELECT 'Clientes sin nombre' as Validacion, COUNT(*) as Registros
FROM stg.STG_Cliente
WHERE nombre_cliente IS NULL OR LTRIM(RTRIM(nombre_cliente)) = '';

-- Productos sin precio
SELECT 'Productos sin precio' as Validacion, COUNT(*) as Registros
FROM stg.STG_Producto
WHERE precio_venta IS NULL OR precio_venta <= 0;

-- Pedidos sin cliente
SELECT 'Pedidos sin cliente' as Validacion, COUNT(*) as Registros
FROM stg.STG_Pedido
WHERE ID_cliente IS NULL;

-- Detalle pedido con cantidad 0 o negativa
SELECT 'Detalle con cantidad inválida' as Validacion, COUNT(*) as Registros
FROM stg.STG_DetallePedido
WHERE cantidad IS NULL OR cantidad <= 0;

-- Pagos con monto 0 o negativo
SELECT 'Pagos con monto inválido' as Validacion, COUNT(*) as Registros
FROM stg.STG_Pago
WHERE total IS NULL OR total <= 0;
GO

-- ============================================================
-- 3) VALIDACIÓN: Integridad Referencial
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '3. VALIDACIÓN DE INTEGRIDAD REFERENCIAL';
PRINT '============================================================';
PRINT '';

-- Empleados con oficina inexistente
SELECT 'Empleados con oficina inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_Empleado e
WHERE NOT EXISTS (
    SELECT 1 FROM stg.STG_Oficina o WHERE o.ID_oficina = e.ID_oficina
);

-- Clientes con empleado inexistente
SELECT 'Clientes con empleado inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_Cliente c
WHERE ID_empleado_rep_ventas IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM stg.STG_Empleado e WHERE e.ID_empleado = c.ID_empleado_rep_ventas
);

-- Productos con categoría inexistente
SELECT 'Productos con categoría inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_Producto p
WHERE NOT EXISTS (
    SELECT 1 FROM stg.STG_Categoria c WHERE c.Id_Categoria = p.Categoria
);

-- Pedidos con cliente inexistente
SELECT 'Pedidos con cliente inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_Pedido p
WHERE NOT EXISTS (
    SELECT 1 FROM stg.STG_Cliente c WHERE c.ID_cliente = p.ID_cliente
);

-- Detalle pedido con pedido inexistente
SELECT 'Detalle con pedido inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_DetallePedido dp
WHERE NOT EXISTS (
    SELECT 1 FROM stg.STG_Pedido p WHERE p.ID_pedido = dp.ID_pedido
);

-- Detalle pedido con producto inexistente
SELECT 'Detalle con producto inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_DetallePedido dp
WHERE NOT EXISTS (
    SELECT 1 FROM stg.STG_Producto p WHERE p.ID_producto = dp.ID_producto
);

-- Pagos con cliente inexistente
SELECT 'Pagos con cliente inexistente' as Validacion, COUNT(*) as Registros
FROM stg.STG_Pago pg
WHERE NOT EXISTS (
    SELECT 1 FROM stg.STG_Cliente c WHERE c.ID_cliente = pg.ID_cliente
);
GO

-- ============================================================
-- 4) VALIDACIÓN: Duplicados
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '4. VALIDACIÓN DE DUPLICADOS';
PRINT '============================================================';
PRINT '';

-- Oficinas duplicadas
SELECT 'Oficinas duplicadas' as Validacion, COUNT(*) as Registros
FROM (
    SELECT ID_oficina, COUNT(*) as cnt
    FROM stg.STG_Oficina
    GROUP BY ID_oficina
    HAVING COUNT(*) > 1
) t;

-- Empleados duplicados
SELECT 'Empleados duplicados' as Validacion, COUNT(*) as Registros
FROM (
    SELECT ID_empleado, COUNT(*) as cnt
    FROM stg.STG_Empleado
    GROUP BY ID_empleado
    HAVING COUNT(*) > 1
) t;

-- Clientes duplicados
SELECT 'Clientes duplicados' as Validacion, COUNT(*) as Registros
FROM (
    SELECT ID_cliente, COUNT(*) as cnt
    FROM stg.STG_Cliente
    GROUP BY ID_cliente
    HAVING COUNT(*) > 1
) t;

-- Productos duplicados
SELECT 'Productos duplicados' as Validacion, COUNT(*) as Registros
FROM (
    SELECT ID_producto, COUNT(*) as cnt
    FROM stg.STG_Producto
    GROUP BY ID_producto
    HAVING COUNT(*) > 1
) t;
GO

-- ============================================================
-- 5) VALIDACIÓN: Rangos de Fechas
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '5. VALIDACIÓN DE RANGOS DE FECHAS';
PRINT '============================================================';
PRINT '';

-- Fechas de pedido
SELECT 
    'Rango de Fechas Pedido' as Validacion,
    MIN(fecha_pedido) as FechaMinima,
    MAX(fecha_pedido) as FechaMaxima,
    COUNT(*) as TotalPedidos
FROM stg.STG_Pedido;

-- Pedidos con fecha entrega anterior a fecha pedido
SELECT 'Pedidos con fecha entrega antes de pedido' as Validacion, COUNT(*) as Registros
FROM stg.STG_Pedido
WHERE fecha_entrega IS NOT NULL 
  AND fecha_entrega < fecha_pedido;

-- Pedidos con fecha esperada anterior a fecha pedido
SELECT 'Pedidos con fecha esperada antes de pedido' as Validacion, COUNT(*) as Registros
FROM stg.STG_Pedido
WHERE fecha_esperada < fecha_pedido;

-- Fechas de pago
SELECT 
    'Rango de Fechas Pago' as Validacion,
    MIN(fecha_pago) as FechaMinima,
    MAX(fecha_pago) as FechaMaxima,
    COUNT(*) as TotalPagos
FROM stg.STG_Pago;
GO

-- ============================================================
-- 6) ESTADÍSTICAS DE CALIDAD
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '6. ESTADÍSTICAS DE CALIDAD';
PRINT '============================================================';
PRINT '';

-- Distribución por estado de pedido
SELECT 
    'Distribución Estado Pedido' as Estadistica,
    estado,
    COUNT(*) as Total,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stg.STG_Pedido) AS DECIMAL(5,2)) as Porcentaje
FROM stg.STG_Pedido
GROUP BY estado
ORDER BY COUNT(*) DESC;

-- Distribución por forma de pago
SELECT 
    'Distribución Forma Pago' as Estadistica,
    forma_pago,
    COUNT(*) as Total,
    SUM(total) as MontoTotal,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM stg.STG_Pago) AS DECIMAL(5,2)) as Porcentaje
FROM stg.STG_Pago
GROUP BY forma_pago
ORDER BY COUNT(*) DESC;

-- Productos por categoría
SELECT 
    'Productos por Categoría' as Estadistica,
    c.Desc_Categoria,
    COUNT(p.ID_producto) as TotalProductos
FROM stg.STG_Categoria c
LEFT JOIN stg.STG_Producto p ON c.Id_Categoria = p.Categoria
GROUP BY c.Desc_Categoria
ORDER BY COUNT(p.ID_producto) DESC;
GO

-- ============================================================
-- 7) CREAR TABLA DE RESUMEN DE VALIDACIONES
-- ============================================================

IF OBJECT_ID('util.ValidacionesStaging', 'U') IS NOT NULL
    DROP TABLE util.ValidacionesStaging;
GO

CREATE TABLE util.ValidacionesStaging (
    ValidacionID INT IDENTITY(1,1) PRIMARY KEY,
    FechaValidacion DATETIME NOT NULL DEFAULT GETDATE(),
    TipoValidacion VARCHAR(50) NOT NULL,
    Tabla VARCHAR(50) NULL,
    CantidadErrores INT NOT NULL,
    Descripcion VARCHAR(500) NULL,
    Estado VARCHAR(20) NOT NULL -- 'OK', 'Warning', 'Error'
);
GO

PRINT '✓ Tabla util.ValidacionesStaging creada';
GO

-- ============================================================
-- 8) RESUMEN FINAL
-- ============================================================

PRINT '';
PRINT '============================================================';
PRINT '✅ VALIDACIONES COMPLETADAS';
PRINT '============================================================';
PRINT '';
PRINT 'Revisar los resultados de cada sección arriba.';
PRINT 'Si todos los contadores de errores son 0, los datos están OK.';
PRINT '';
PRINT 'Siguiente paso: Ejecutar 05_Backup_Staging.sql (opcional)';
PRINT '============================================================';
GO
