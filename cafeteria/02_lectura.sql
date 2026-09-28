-- Cafetería · consultas de lectura (1 a 5).
-- Corre antes 01_esquema.sql.


-- 1. Ventas por sucursal del último mes
--    Cuántas ventas hizo cada sucursal y cuánto vendió, de mayor a menor.
--    Resultado: Urdesa 18.00 · Mall del Sol 15.30 · Samborondón 9.80
--    La venta de hace 45 días del Mall del Sol queda fuera. Si te sale 18.40, falta el filtro de fecha.
select s.nombre, count(*) as ventas, sum(v.total) as total
from ventas v
join sucursales s on s.id = v.sucursal_id
where v.fecha >= now() - interval '1 month'
group by s.nombre
order by total desc;


-- 2. Top 5 productos por unidades vendidas
--    Resultado: Capuchino 5 · Americano 3 · Cheesecake 3 · Té helado 2 · Mocaccino 1
--    Hay empates: el segundo criterio (p.nombre) hace que el orden no cambie entre ejecuciones.
--    «Más vendido» también puede medirse en dinero: sum(d.cantidad * d.precio_unitario).
select p.nombre, sum(d.cantidad) as unidades
from detalle_venta d
join productos p on p.id = d.producto_id
group by p.nombre
order by unidades desc, p.nombre
limit 5;


-- 3. Sucursales que no vendieron ningún Capuchino
--    Resultado: Samborondón
--    El filtro por producto va dentro de la subconsulta, no en el WHERE de afuera.

-- Con NOT EXISTS:
select s.nombre
from sucursales s
where not exists (
  select 1
  from ventas v
  join detalle_venta d on d.venta_id = v.id
  join productos p on p.id = d.producto_id
  where v.sucursal_id = s.id
    and p.nombre = 'Capuchino'
);

-- Con LEFT JOIN:
select s.nombre
from sucursales s
left join (
  select distinct v.sucursal_id
  from ventas v
  join detalle_venta d on d.venta_id = v.id
  join productos p on p.id = d.producto_id
  where p.nombre = 'Capuchino'
) c on c.sucursal_id = s.id
where c.sucursal_id is null;


-- 4. Ticket promedio por día de la semana
--    isodow: 1 = lunes … 7 = domingo. El ticket es el total de una venta.
--    El resultado depende del día en que se corra, porque las fechas son relativas.
select extract(isodow from fecha) as dia_semana,
       count(*)                   as ventas,
       round(avg(total), 2)       as ticket_promedio
from ventas
group by extract(isodow from fecha)
order by dia_semana;


-- 5. Productos bajo su stock mínimo
--    Resultado: Americano (faltan 5) · Cheesecake (faltan 4)
select nombre, stock, stock_minimo, stock_minimo - stock as faltan
from productos
where stock < stock_minimo
order by faltan desc;
