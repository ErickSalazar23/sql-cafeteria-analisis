-- Seguimiento comercial: esquema y datos de ejemplo.
-- Es la misma estructura que uso en mi propio panel de prospección (contactos, eventos
-- y muestras), con empresas y datos inventados. Ninguna fila es un prospecto real.
-- PostgreSQL. Las fechas son relativas a hoy.

drop table if exists muestras, eventos, contactos;

create table contactos (
  id      int primary key,
  empresa text not null,
  linea   text not null check (linea in ('presencia', 'saas')),
  canal   text not null,
  creado  timestamptz not null
);

-- El historial de cada contacto. Solo se agregan filas: un error se corrige
-- con un evento nuevo, nunca editando o borrando uno viejo.
create table eventos (
  id       int primary key,
  contacto int not null references contactos(id),
  tipo     text not null check (tipo in ('mensaje', 'respuesta', 'descartado')),
  nota     text,
  ts       timestamptz not null
);

create index eventos_contacto_idx on eventos (contacto);

-- Menús de muestra enviados a cada contacto, con cuántas veces se abrieron.
create table muestras (
  slug     text primary key,
  contacto int references contactos(id),
  vistas   int not null default 0
);

insert into contactos values
  (1, 'Cafetería Punto Norte',   'presencia', 'whatsapp', now() - interval '30 days'),
  (2, 'Panadería El Trigal',     'presencia', 'whatsapp', now() - interval '25 days'),
  (3, 'Pizzería Don Vito',       'presencia', 'llamada',  now() - interval '20 days'),
  (4, 'Heladería Polar',         'presencia', 'whatsapp', now() - interval '5 days'),
  (5, 'Distribuidora Andina',    'saas',      'linkedin', now() - interval '40 days'),
  (6, 'Laboratorio Delta',       'saas',      'linkedin', now() - interval '15 days'),
  (7, 'Logística Pacífico Sur',  'saas',      'linkedin', now() - interval '10 days'),
  (8, 'Ferretería El Tornillo',  'presencia', 'whatsapp', now() - interval '2 days');

insert into eventos values
  ( 1, 1, 'mensaje',    'toque 1',                      now() - interval '28 days'),
  ( 2, 1, 'mensaje',    'toque 2',                      now() - interval '24 days'),
  ( 3, 1, 'mensaje',    'toque 3',                      now() - interval '20 days'),
  ( 4, 1, 'respuesta',  '[interés] pidió ver un ejemplo', now() - interval '19 days'),
  ( 5, 2, 'mensaje',    'toque 1',                      now() - interval '24 days'),
  ( 6, 2, 'mensaje',    'toque 2',                      now() - interval '21 days'),
  ( 7, 2, 'mensaje',    'toque 3',                      now() - interval '14 days'),
  ( 8, 3, 'mensaje',    'toque 1',                      now() - interval '18 days'),
  ( 9, 4, 'mensaje',    'toque 1',                      now() - interval '4 days'),
  (10, 4, 'mensaje',    'toque 2',                      now() - interval '1 day'),
  (11, 4, 'respuesta',  '[no] ya tienen menú en línea', now() - interval '20 hours'),
  (12, 5, 'mensaje',    'toque 1',                      now() - interval '38 days'),
  (13, 5, 'mensaje',    'toque 2',                      now() - interval '30 days'),
  (14, 5, 'mensaje',    'toque 3',                      now() - interval '23 days'),
  (15, 5, 'descartado', 'sin respuesta tras 3 toques',  now() - interval '15 days'),
  (16, 6, 'mensaje',    'toque 1',                      now() - interval '14 days'),
  (17, 6, 'mensaje',    'toque 2',                      now() - interval '3 days'),
  (18, 7, 'mensaje',    'toque 1',                      now() - interval '9 days');

insert into muestras values
  ('punto-norte',  1, 3),
  ('el-trigal',    2, 0),
  ('polar',        4, 1),
  ('ejemplo-menu', null, 5);
