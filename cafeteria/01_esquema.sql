-- Cadena de cafeterías: esquema y datos de ejemplo (ficticios).
-- PostgreSQL. Las fechas son relativas a hoy, así que los resultados cambian según el día.
-- Para volver a empezar después de las consultas de escritura, corre este archivo otra vez.

drop table if exists pedidos_reposicion, detalle_venta, ventas, productos, sucursales;

create table sucursales (
  id     int primary key,
  nombre text not null,
  ciudad text not null
);

create table productos (
  id           int primary key,
  nombre       text not null,
  categoria    text not null,
  precio       numeric(6,2) not null,
  stock        int not null,
  stock_minimo int not null
);

create table ventas (
  id          int primary key,
  sucursal_id int not null references sucursales(id),
  fecha       timestamp not null,
  total       numeric(8,2) not null
);

-- Una venta tiene muchos productos: la cabecera va en ventas y cada línea aquí.
create table detalle_venta (
  id              int primary key,
  venta_id        int not null references ventas(id),
  producto_id     int not null references productos(id),
  cantidad        int not null,
  precio_unitario numeric(6,2) not null
);

create table pedidos_reposicion (
  id          serial primary key,
  producto_id int not null references productos(id),
  cantidad    int not null,
  creado      timestamp not null default now()
);

insert into sucursales values
  (1, 'Mall del Sol', 'Guayaquil'),
  (2, 'Urdesa',       'Guayaquil'),
  (3, 'Samborondón',  'Samborondón');

insert into productos values
  (1, 'Capuchino',      'Bebidas', 3.10, 40, 20),
  (2, 'Americano',      'Bebidas', 2.20, 15, 20),
  (3, 'Mocaccino',      'Bebidas', 3.50, 25, 10),
  (4, 'Cheesecake',     'Postres', 3.80,  4,  8),
  (5, 'Sánduche mixto', 'Comida',  4.20, 12, 10),
  (6, 'Té helado',      'Bebidas', 2.50, 30, 10);

insert into ventas values
  (1, 1, now() - interval '2 days',  9.30),
  (2, 1, now() - interval '5 days',  6.00),
  (3, 2, now() - interval '3 days',  6.60),
  (4, 2, now() - interval '12 days', 4.20),
  (5, 3, now() - interval '1 day',   7.60),
  (6, 3, now() - interval '20 days', 2.20),
  (7, 1, now() - interval '45 days', 3.10),
  (8, 2, now() - interval '8 days',  7.20);

insert into detalle_venta values
  ( 1, 1, 1, 3, 3.10),
  ( 2, 2, 2, 1, 2.20),
  ( 3, 2, 4, 1, 3.80),
  ( 4, 3, 3, 1, 3.50),
  ( 5, 3, 1, 1, 3.10),
  ( 6, 4, 5, 1, 4.20),
  ( 7, 5, 4, 2, 3.80),
  ( 8, 6, 2, 1, 2.20),
  ( 9, 7, 1, 1, 3.10),
  (10, 8, 6, 2, 2.50),
  (11, 8, 2, 1, 2.20);
