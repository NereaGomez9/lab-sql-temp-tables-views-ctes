USE sakila;

-- CREACIÓN DE UNA VISTA DEL RESUMEN DE ALQUILERES POR CLIENTE
CREATE VIEW vista_resumen_alquiler AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS nombre_cliente,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r 
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id, nombre_cliente, c.email;

-- CREAR UNA TABLA TEMPORAL PARA EL TOTAL PAGADO POR CLIENTE.
CREATE TEMPORARY TABLE temp_total_pagado AS
SELECT 
    v.customer_id,
    SUM(p.amount) AS total_pagado
FROM vista_resumen_alquiler v
LEFT JOIN payment p 
    ON v.customer_id = p.customer_id
GROUP BY v.customer_id;

-- CREAR LA CTE MÁS EL INFORME FINAL
-- CTE UNE LA VISTA Y LA TABLA TEMPORAL, Y CALCULAMOS PROMEDIO POR ALQUILER.

WITH cte_resumen AS (
    SELECT 
        v.nombre_cliente,
        v.email,
        v.rental_count,
        t.total_pagado,
        (t.total_pagado / NULLIF(v.rental_count, 0)) AS pago_promedio_por_alquiler
    FROM vista_resumen_alquiler v
    LEFT JOIN temp_total_pagado t 
        ON v.customer_id = t.customer_id
)
SELECT *
FROM cte_resumen
ORDER BY total_pagado DESC;

