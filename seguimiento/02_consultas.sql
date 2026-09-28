-- Seguimiento comercial · consultas (9 a 18).
-- Corre antes 01_esquema.sql.


-- 9. Filtrar y ordenar
--    Contactos de la línea «presencia» creados en los últimos 21 días, del más nuevo al más antiguo.
--    Resultado: 3 filas (El Tornillo, Polar, Don Vito)
select empresa, canal, creado
from contactos
where linea = 'presencia'
  and creado >= now() - interval '21 days'
order by creado desc;


-- 10. Contar por grupo
--     Mensajes enviados cada día de los últimos 7 días.
--     Resultado: 3 días con 1 mensaje cada uno
--     Todo lo que está en el SELECT y no es un conteo tiene que estar en el GROUP BY.
select date(ts) as dia, count(*) as mensajes
from eventos
where tipo = 'mensaje'
  and ts >= now() - interval '7 days'
group by date(ts)
order by dia;


-- 11. Unir dos tablas (JOIN)
--     Las respuestas recibidas, con la empresa que respondió.
--     Resultado: 2 filas (Polar, Punto Norte)
select c.empresa, e.nota, e.ts
from eventos e
join contactos c on c.id = e.contacto
where e.tipo = 'respuesta'
order by e.ts desc;


-- 12. Los que faltan (LEFT JOIN … IS NULL)
--     Contactos que nunca recibieron un mensaje.
--     Resultado: Ferretería El Tornillo
--     La condición e.tipo = 'mensaje' va en el ON. En el WHERE, el LEFT JOIN se vuelve
--     un INNER JOIN y la consulta devuelve cero filas.
select c.empresa
from contactos c
left join eventos e on e.contacto = c.id and e.tipo = 'mensaje'
where e.id is null;


-- 13. Filtrar después de contar (HAVING)
--     Contactos con 3 mensajes o más.
--     Resultado: Punto Norte 3 · Distribuidora Andina 3 · El Trigal 3
--     WHERE filtra filas antes de agrupar; HAVING filtra grupos después de contar.
select c.empresa, count(*) as mensajes
from contactos c
join eventos e on e.contacto = c.id
where e.tipo = 'mensaje'
group by c.id, c.empresa
having count(*) >= 3
order by c.empresa;


-- 14. «Existe al menos uno» (EXISTS)
--     Empresas que respondieron al menos una vez, sin repetirlas.
--     Resultado: Punto Norte, Polar
--     EXISTS se detiene en la primera coincidencia y no duplica filas como un JOIN.
select empresa
from contactos c
where exists (
  select 1 from eventos e
  where e.contacto = c.id and e.tipo = 'respuesta'
);


-- 15. Clasificar (CASE)
--     Cada muestra según sus vistas: sin abrir (0), abierta (1 o 2), muy vista (3 o más).
--     CASE se queda con la primera condición que se cumple.
select slug, vistas,
  case
    when vistas = 0 then 'sin abrir'
    when vistas < 3 then 'abierta'
    else 'muy vista'
  end as estado
from muestras
order by vistas desc;


-- 16. Fechas: ¿a quién tenemos abandonado?
--     Contactos cuyo último mensaje fue hace más de 7 días, del más frío al más reciente.
--     Resultado: 5 filas, de Distribuidora Andina (23 días) a Logística Pacífico Sur (9)
select c.empresa,
       max(e.ts)                          as ultimo_mensaje,
       date_part('day', now() - max(e.ts)) as dias
from contactos c
join eventos e on e.contacto = c.id
where e.tipo = 'mensaje'
group by c.id, c.empresa
having max(e.ts) < now() - interval '7 days'
order by dias desc;


-- 17. Un porcentaje por grupo
--     De los contactos que recibieron mensaje, qué porcentaje respondió, por línea.
--     Resultado: presencia 4 contactados, 2 respondieron, 50.0 % · saas 3, 0, 0.0 %
--     COUNT(DISTINCT) evita contar dos veces a quien recibió varios mensajes.
--     100.0 con decimal: con 100, Postgres divide enteros y casi todo sale 0.
select c.linea,
       count(distinct c.id)       as contactados,
       count(distinct r.contacto) as respondieron,
       round(100.0 * count(distinct r.contacto) / count(distinct c.id), 1) as tasa_pct
from contactos c
join eventos m on m.contacto = c.id and m.tipo = 'mensaje'
left join eventos r on r.contacto = c.id and r.tipo = 'respuesta'
group by c.linea;


-- 18. El primero de cada uno (función de ventana)
--     Solo el primer mensaje de cada contacto.
--     Resultado: 7 filas, una por contacto con mensajes
--     ROW_NUMBER() numera las filas dentro de cada contacto sin juntarlas, como haría
--     un GROUP BY; después nos quedamos con la número 1.
select c.empresa, x.ts, x.nota
from (
  select e.*,
         row_number() over (partition by e.contacto order by e.ts) as n
  from eventos e
  where e.tipo = 'mensaje'
) x
join contactos c on c.id = x.contacto
where x.n = 1
order by x.ts;
