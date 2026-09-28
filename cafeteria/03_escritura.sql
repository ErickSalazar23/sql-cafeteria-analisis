-- Cafetería · corregir datos sin romper nada (6 a 8).
-- Cada cambio va dentro de una transacción y termina en ROLLBACK, para que el archivo
-- se pueda correr varias veces. Cámbialo por COMMIT para confirmar.


-- 6. Corregir un precio: el Capuchino pasa a $3.30
--    Primero se mira qué se va a tocar, con el mismo WHERE.
--    Sin WHERE se cambiarían los 6 productos. Mejor aún: filtrar por la clave primaria (id = 1).
select id, nombre, precio from productos where nombre = 'Capuchino';

begin;
update productos set precio = 3.30 where nombre = 'Capuchino';
select id, nombre, precio from productos where nombre = 'Capuchino';  -- revisar
rollback;  -- o commit;


-- 7. Borrar una venta cargada por error (la 7), con todo su detalle
--    El orden importa: primero las líneas (hijos), después la venta (padre).
--    Al revés, la clave foránea lo rechaza. Es la base protegiendo los datos.
begin;
delete from detalle_venta where venta_id = 7;
delete from ventas where id = 7;
select count(*) as ventas_restantes from ventas;  -- revisar: 7
rollback;  -- o commit;


-- 8. Generar pedidos de reposición
--    Un pedido por cada producto bajo el mínimo, para llegar al doble del mínimo.
--    Resultado: Americano 25 · Cheesecake 12
--    INSERT puede tomar sus filas de un SELECT. Antes de insertar, se corre solo el SELECT.
begin;
insert into pedidos_reposicion (producto_id, cantidad)
select id, stock_minimo * 2 - stock
from productos
where stock < stock_minimo;
select p.nombre, r.cantidad
from pedidos_reposicion r
join productos p on p.id = r.producto_id;  -- revisar
rollback;  -- o commit;
