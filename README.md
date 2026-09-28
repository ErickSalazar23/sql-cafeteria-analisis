# SQL para análisis de ventas y seguimiento comercial

18 consultas en PostgreSQL sobre dos casos de negocio: las ventas de una cadena de cafeterías y el seguimiento de prospectos de una empresa de servicios. Cada consulta responde una pregunta concreta y trae su resultado esperado en un comentario, para comprobarla.

Los datos son **ficticios**. El esquema de seguimiento es el mismo que uso en mi propio panel de prospección; las empresas y los eventos son inventados.

## Cómo correrlo

**Sin instalar nada:** abre [db-fiddle.com](https://www.db-fiddle.com/), elige PostgreSQL 15, pega el esquema en el panel izquierdo y las consultas en el derecho.

**Con `psql`:**

```bash
psql -d practica -f cafeteria/01_esquema.sql -f cafeteria/02_lectura.sql
psql -d practica -f seguimiento/01_esquema.sql -f seguimiento/02_consultas.sql
```

Las fechas se calculan desde el día en que se corre, así que los resultados no envejecen. Las consultas de escritura terminan en `ROLLBACK`: el archivo se puede correr varias veces sin cambiar los datos.

## Caso 1 · Cadena de cafeterías

```
sucursales ──< ventas ──< detalle_venta >── productos
                                             └──< pedidos_reposicion
```

| # | Pregunta | Qué practica |
| :-: | :--- | :--- |
| 1 | ¿Cuánto vendió cada sucursal el último mes? | `JOIN`, `GROUP BY`, filtro de fechas |
| 2 | ¿Cuáles son los 5 productos más vendidos? | `SUM`, `LIMIT`, desempate estable |
| 3 | ¿Qué sucursales no vendieron un producto? | `NOT EXISTS` y `LEFT JOIN … IS NULL` |
| 4 | ¿Cuál es el ticket promedio por día de la semana? | `EXTRACT(isodow)`, `AVG`, `ROUND` |
| 5 | ¿Qué productos están bajo su stock mínimo? | Columnas calculadas |
| 6 | Corregir un precio | `UPDATE` dentro de una transacción |
| 7 | Borrar una venta cargada por error | `DELETE` en orden hijo → padre, claves foráneas |
| 8 | Generar pedidos de reposición | `INSERT … SELECT` |

Archivos: [`cafeteria/01_esquema.sql`](cafeteria/01_esquema.sql) · [`02_lectura.sql`](cafeteria/02_lectura.sql) · [`03_escritura.sql`](cafeteria/03_escritura.sql)

## Caso 2 · Seguimiento comercial

```
contactos ──< eventos        (mensaje · respuesta · descartado)
          └──< muestras      (menús de muestra y cuántas veces se abrieron)
```

| # | Pregunta | Qué practica |
| :-: | :--- | :--- |
| 9 | ¿Qué contactos nuevos hay en una línea? | `WHERE`, `ORDER BY … DESC` |
| 10 | ¿Cuántos mensajes se enviaron cada día? | `GROUP BY` sobre una fecha |
| 11 | ¿Quién respondió? | `JOIN` por clave foránea |
| 12 | ¿A quién nunca se le escribió? | `LEFT JOIN … IS NULL` (y su trampa) |
| 13 | ¿Quién recibió 3 mensajes o más? | `HAVING` frente a `WHERE` |
| 14 | ¿Qué empresas respondieron al menos una vez? | `EXISTS` |
| 15 | ¿Qué muestras se abrieron? | `CASE` |
| 16 | ¿A quién tenemos abandonado? | `MAX` sobre fechas, intervalos |
| 17 | ¿Qué porcentaje respondió, por línea? | `COUNT(DISTINCT)`, división decimal |
| 18 | ¿Cuál fue el primer mensaje a cada contacto? | `ROW_NUMBER() OVER (PARTITION BY …)` |

Archivos: [`seguimiento/01_esquema.sql`](seguimiento/01_esquema.sql) · [`02_consultas.sql`](seguimiento/02_consultas.sql)

## Decisiones de diseño

- **Una venta, muchas líneas.** La cabecera va en `ventas` y cada producto en `detalle_venta`, para que la sucursal y la fecha se guarden una sola vez.
- **El historial solo crece.** En `eventos` un error se corrige agregando un evento, no editando uno viejo. Así el historial queda completo.
- **Correcciones dentro de una transacción.** Primero un `SELECT` con el mismo `WHERE`, después el cambio, después la revisión y recién ahí `COMMIT`.

---

Erick Salazar · Guayaquil · [portafolio](https://portafolio-one-rho-10.vercel.app/)
