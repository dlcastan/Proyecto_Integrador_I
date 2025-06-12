USE sales_company;

# Seleciono los 5 productos más vendidos (por cantidad total). De estos productos busco el vendedor que más unidades 
# vendió unidades de cada una de estas.

WITH top5 AS (
    SELECT 
        s.ProductID,
        p.ProductName,
        SUM(s.Quantity) AS total_vendida
    FROM sales s
    JOIN products p ON s.ProductID = p.ProductID
    GROUP BY s.ProductID, p.ProductName
    ORDER BY total_vendida DESC
    LIMIT 5
),
ventas_vendedor AS (
    SELECT 
        s.ProductID,
        s.SalesPersonID,
        SUM(s.Quantity) AS cantidad_vendida
    FROM sales s
    GROUP BY s.ProductID, s.SalesPersonID
)
SELECT 
    t.ProductID,
    t.ProductName,
    t.total_vendida,
    vv.SalesPersonID,
    CONCAT (e.LastName, ' ', e.FirstName),
    vv.cantidad_vendida
FROM top5 t
JOIN ventas_vendedor vv ON t.ProductID = vv.ProductID
JOIN employees e ON vv.SalesPersonID = e.EmployeeID
WHERE vv.cantidad_vendida = (
    SELECT MAX(vv2.cantidad_vendida)
    FROM ventas_vendedor vv2
    WHERE vv2.ProductID = t.ProductID
)
ORDER BY t.total_vendida DESC, vv.cantidad_vendida DESC;

#  Verifico si reepresenta más del 10% de las ventas totales de cada producto
WITH top5 AS (
    SELECT 
        s.ProductID,
        p.ProductName,
        SUM(s.Quantity) AS total_vendida
    FROM sales s
    JOIN products p ON s.ProductID = p.ProductID
    GROUP BY s.ProductID, p.ProductName
    ORDER BY total_vendida DESC
    LIMIT 5
),
ventas_vendedor AS (
    SELECT 
        s.ProductID,
        s.SalesPersonID,
        SUM(s.Quantity) AS cantidad_vendida
    FROM sales s
    GROUP BY s.ProductID, s.SalesPersonID
),
top_vendedor_x_producto AS (
    SELECT
        vv.ProductID,
        vv.SalesPersonID,
        vv.cantidad_vendida
    FROM ventas_vendedor vv
    INNER JOIN (
        SELECT 
            ProductID,
            MAX(cantidad_vendida) AS max_vendida
        FROM ventas_vendedor
        GROUP BY ProductID
    ) mx ON vv.ProductID = mx.ProductID AND vv.cantidad_vendida = mx.max_vendida
)
SELECT
    t.ProductID,
    t.ProductName,
    CONCAT (e.LastName, ' ', e.FirstName),
    ROUND((tv.cantidad_vendida / t.total_vendida) * 100, 2) AS porcentaje_vendedor
FROM top5 t
JOIN top_vendedor_x_producto tv ON t.ProductID = tv.ProductID
JOIN employees e ON tv.SalesPersonID = e.EmployeeID
ORDER BY t.total_vendida DESC, porcentaje_vendedor DESC;


-- Selecciono los clientes únicos, los clientes totales y el porcentaje de clientes de los 5 productos más vendidos.
WITH top5 AS (
    SELECT 
        s.ProductID,
        p.ProductName,
        SUM(s.Quantity) AS total_vendida
    FROM sales s
    JOIN products p ON s.ProductID = p.ProductID
    GROUP BY s.ProductID, p.ProductName
    ORDER BY total_vendida DESC
    LIMIT 5
),
clientes_x_producto AS (
    SELECT 
        s.ProductID,
        COUNT(DISTINCT s.CustomerID) AS clientes_unicos
    FROM sales s
    WHERE s.ProductID IN (SELECT ProductID FROM top5)
    GROUP BY s.ProductID
),
total_clientes AS (
    SELECT COUNT(DISTINCT CustomerID) AS total_clientes
    FROM sales
)
SELECT 
    t.ProductID,
    t.ProductName,
    cxp.clientes_unicos,
    total_clientes,
    ROUND((cxp.clientes_unicos / tc.total_clientes) * 100, 2) AS porcentaje_clientes
FROM top5 t
JOIN clientes_x_producto cxp ON t.ProductID = cxp.ProductID
CROSS JOIN total_clientes tc
ORDER BY porcentaje_clientes DESC, t.ProductID;


## Busco las categorías de los productos más vendidos
WITH ProductoVentas AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        SUM(s.Quantity) AS TotalVendido,
        SUM(SUM(s.Quantity)) OVER (PARTITION BY p.CategoryID) AS TotalCategoria
    FROM products p
    INNER JOIN sales s ON p.ProductID = s.ProductID
    INNER JOIN categories c ON p.CategoryID = c.CategoryID
    GROUP BY p.ProductID, p.ProductName, c.CategoryName, p.CategoryID
)
SELECT 
    ProductID,
    ProductName,
    CategoryName,
    TotalVendido,
    TotalCategoria,
    ROUND((TotalVendido / TotalCategoria) * 100, 2) AS PorcentajeXCategoria
FROM ProductoVentas
ORDER BY TotalVendido DESC
LIMIT 5;


# Busco los 10 productos con mayor cantidad de unidades vendidas en todo el catálogo 
# indicando su posición dentro de su propia categoría

WITH ProductoCategoria AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        c.CategoryName,
        SUM(s.Quantity) AS TotalVendido,
        RANK() OVER (PARTITION BY p.CategoryID ORDER BY SUM(s.Quantity) DESC) AS PosicionCategoria
    FROM products p
    INNER JOIN sales s ON p.ProductID = s.ProductID
    INNER JOIN categories c ON p.CategoryID = c.CategoryID
    GROUP BY p.ProductID, p.ProductName, p.CategoryID, c.CategoryName
)

SELECT 
    ProductID,
    ProductName,
    CategoryName,
    TotalVendido,
    PosicionCategoria
FROM ProductoCategoria
ORDER BY TotalVendido DESC
LIMIT 10;

