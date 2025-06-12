USE sales_company;

# Creo tabla llamada monitoreo para registrar los productos que superen los 200k de unidades vendidas

CREATE TABLE monitoreo (
    ID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT,
    ProductName VARCHAR(255),
    Unidades_Vendidas INT,
    Fecha DATETIME
);

# Creo un trigger para registrar cuando un producto que superen los 200k de unidades vendidas

CREATE TRIGGER monitoreo_unidades_vendidas
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    DECLARE total INT;
    SELECT SUM(Quantity) INTO total FROM sales WHERE ProductID = NEW.ProductID;

    IF total > 200000 AND 
       NOT EXISTS (
            SELECT 1 FROM monitoreo WHERE ProductID = NEW.ProductID
        ) THEN
        INSERT INTO monitoreo (ProductID, ProductName, Unidades_Vendidas, Fecha)
        SELECT 
            p.ProductID, 
            p.ProductName, 
            total, 
            NOW()
        FROM products p
        WHERE p.ProductID = NEW.ProductID;
    END IF;
END;

# Registra una venta correspondiente al vendedor con ID 9, al cliente con ID 84, del producto con ID 103, 
# por una cantidad de 1.876 unidades y un valor de 1200 unidades.


INSERT INTO sales 
    (SalesID, SalesPersonID, CustomerID, ProductID, Quantity, Discount, TotalPrice, SalesDate, TransactionNumber)
SELECT
   MAX(SalesID) + 1, 9, 84, 103, 1876, 0, 1200, NOW(), 'TX-001'
FROM sales;

# Verifico si ha registrado la compra en la tabla de sales

SELECT * FROM sales WHERE TransactionNumber = 'TX-001';

# Verifico si ha registrado la compra en la tabla de monitoreo

SELECT * FROM monitoreo;

# Selecciono dos consultas del avance 1 y creo los índices que consideres más adecuados para optimizar su ejecución.

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

# Creo indice para optimizar los tiempos
CREATE INDEX ix_sales_products_person ON sales (ProductId, SalesPersonID, Quantity)


