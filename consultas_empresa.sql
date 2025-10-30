USE empresa_electrica;

-- a) Devolver por cada reclamo el detalle de materiales utilizados
SELECT
    r.nro_reclamo,
    r.fecha_reclamo,
    r.fecha_resolucion,
    m.codigo as codigo_material,
    m.descripcion as descripcion_material,
    req.cantidad,
    CASE
        WHEN m.codigo IS NULL THEN 'Sin materiales'
        ELSE 'Con materiales'
    END as estado_materiales
FROM
    reclamo r
    LEFT JOIN requiere req ON r.nro_reclamo = req.nro_reclamo
    LEFT JOIN material m ON req.codigo_material = m.codigo
ORDER BY
    r.nro_reclamo,
    m.codigo;

-- b) Devolver usuarios que tienen MÁS DE UN reclamo
SELECT
    u.id_usuario,
    u.direccion,
    u.telefono,
    COUNT(r.nro_reclamo) as cantidad_reclamos,
    CASE
        WHEN p.id_usuario IS NOT NULL THEN CONCAT(p.nombre, ' ', p.apellido)
        WHEN e.id_usuario IS NOT NULL THEN CONCAT('Empresa CUIT: ', e.cuit)
        ELSE 'Usuario sin clasificar'
    END as identificacion
FROM
    usuario u
    INNER JOIN reclamo r ON u.id_usuario = r.id_usuario
    LEFT JOIN persona p ON u.id_usuario = p.id_usuario
    LEFT JOIN empresa e ON u.id_usuario = e.id_usuario
GROUP BY
    u.id_usuario,
    u.direccion,
    u.telefono,
    p.nombre,
    p.apellido,
    e.cuit
HAVING
    COUNT(r.nro_reclamo) > 1
ORDER BY
    cantidad_reclamos DESC;

-- c) Reclamos asignados a MÁS DE UN empleado
SELECT
    r.nro_reclamo,
    r.fecha_reclamo,
    r.fecha_resolucion,
    mot.descripcion as motivo,
    COUNT(ap.id_usuario) as cantidad_empleados,
    GROUP_CONCAT(CONCAT(p.nombre, ' ', p.apellido) SEPARATOR ', ') as empleados_asignados
FROM
    reclamo r
    INNER JOIN atendidoPor ap ON r.nro_reclamo = ap.num_reclamo
    INNER JOIN persona p ON ap.id_usuario = p.id_usuario
    INNER JOIN motivo mot ON r.codigo_motivo = mot.codigo
GROUP BY
    r.nro_reclamo,
    r.fecha_reclamo,
    r.fecha_resolucion,
    mot.descripcion
HAVING
    COUNT(ap.id_usuario) > 1
ORDER BY
    cantidad_empleados DESC,
    r.nro_reclamo;