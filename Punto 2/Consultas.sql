-- ============================================================
-- CASO TÉCNICO - ANALISTA DE DATOS
-- Punto 2: Consultas SQL sobre la tabla `mensajes`
-- (resultado del Punto 1, cargado en PostgreSQL/MySQL)
-- Validadas contra los datos reales de prueba_limpio.csv
-- ============================================================

-- ------------------------------------------------------------
-- 1) FUNNEL DE ENTREGA
-- Objetivo: % de mensajes salientes por estado final (read/delivered/failed/sent)
-- Uso de Window Function (SUM() OVER) en vez de una subconsulta
-- para calcular el total y evitar un segundo escaneo de la tabla.
-- ------------------------------------------------------------
WITH outgoing_msgs AS (
    SELECT status
    FROM mensajes
    WHERE message_type = 'outgoing'
)
SELECT
    status,
    COUNT(*) AS total_mensajes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS porcentaje
FROM outgoing_msgs
GROUP BY status
ORDER BY total_mensajes DESC;

-- Resultado observado (datos de prueba):
--   failed     -> 55.68%   <-- alerta: más de la mitad de la campaña no llega
--   read       -> 28.24%
--   sent       -> 12.76%   (aún sin confirmar entrega)
--   delivered  ->  3.31%


-- ------------------------------------------------------------
-- 2) SLA DE RESPUESTA OPERATIVA
-- Objetivo: minutos promedio entre un mensaje 'incoming' y la
-- siguiente acción del asesor (activity u outgoing) en la MISMA conversación.
-- Uso de LEAD() (Window Function) particionado por conversation_id
-- para emparejar el mensaje con la siguiente acción sin JOIN ni subconsulta correlacionada.
-- ------------------------------------------------------------
WITH ordenado AS (
    SELECT
        conversation_id,
        message_type,
        created_at,
        LEAD(created_at) OVER (
            PARTITION BY conversation_id ORDER BY created_at
        ) AS siguiente_ts,
        LEAD(message_type) OVER (
            PARTITION BY conversation_id ORDER BY created_at
        ) AS siguiente_tipo
    FROM mensajes
),
pares_respuesta AS (
    SELECT
        conversation_id,
        created_at AS ts_incoming,
        siguiente_ts AS ts_respuesta,
        TIMESTAMPDIFF(SECOND, created_at, siguiente_ts) / 60.0 AS minutos_respuesta
    FROM ordenado
    WHERE message_type = 'incoming'
      AND siguiente_tipo IN ('activity', 'outgoing')
)
SELECT
    ROUND(AVG(minutos_respuesta), 2)  AS sla_promedio_minutos,
    ROUND(MIN(minutos_respuesta), 2)  AS sla_min_minutos,
    ROUND(MAX(minutos_respuesta), 2)  AS sla_max_minutos,
    COUNT(*)                          AS conversaciones_evaluadas
FROM pares_respuesta
WHERE minutos_respuesta >= 0;

-- Resultado observado: promedio ~131.7 minutos, con outliers de +2600 min
-- (sugiere revisar conversaciones abandonadas o sin cierre)


-- ------------------------------------------------------------
-- 3) CURVA DE CALOR HORARIA
-- Objetivo: volumen de mensajes 'incoming' por hora del día,
-- para dimensionar turnos (Workforce Management).
-- ------------------------------------------------------------
SELECT
    EXTRACT(HOUR FROM created_at) AS hora_del_dia,
    COUNT(*)                            AS volumen_incoming
    -- MySQL equivalente: HOUR(created_at)
FROM mensajes
WHERE message_type = 'incoming'
GROUP BY hora_del_dia
ORDER BY hora_del_dia;

-- Resultado observado: pico de entrantes entre las 15h y 19h,
-- con otro repunte leve entre 22h-23h.