-- ================================================================
-- CREACIÓN DE BASE DE DATOS Y TABLAS
-- Sistema de Gestión de Reclamos para Empresa Eléctrica
-- ================================================================
-- Crear la base de datos si no existe
CREATE DATABASE IF NOT EXISTS empresa_electrica;

-- Seleccionar la base de datos para trabajar
USE empresa_electrica;

-- ================================================================
-- TABLAS PRINCIPALES
-- ================================================================
-- Tabla Usuario: Almacena información común de todos los usuarios
-- Es la tabla padre de Persona y Empresa (herencia)
CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT,
    direccion VARCHAR(50),
    telefono VARCHAR(15),
    CONSTRAINT usuario_pk PRIMARY KEY (id_usuario)
);

-- Tabla motivo: Catálogo de motivos de reclamos
CREATE TABLE motivo (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50)
);

-- Tabla material: Catálogo de materiales utilizados en reparaciones
CREATE TABLE material (
    codigo INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(50)
);

-- ================================================================
-- JERARQUÍA DE USUARIOS
-- ================================================================
-- Tabla persona: Usuarios que son personas físicas
-- Hereda de Usuario mediante id_usuario
CREATE TABLE persona (
    id_usuario INT PRIMARY KEY,
    documento INT UNIQUE NOT NULL, -- DNI, debe ser único
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    CONSTRAINT idFK FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    -- Validación: DNI entre 1 y 999.999.999
    CONSTRAINT CHECK (
        documento > 0
        AND documento < 1000000000
    )
);

-- Tabla empleado: Personas que trabajan en la empresa
-- Hereda de Persona mediante id_usuario
CREATE TABLE empleado (
    id_usuario INT PRIMARY KEY,
    sueldo DECIMAL(10, 2), -- Formato: 10 dígitos totales, 2 decimales (ej: 99999999.99)
    -- CASCADE: si se elimina la persona, se elimina el empleado
    CONSTRAINT empladoUsuarioFK FOREIGN KEY (id_usuario) REFERENCES persona (id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabla empresa: Usuarios que son empresas/industrias
-- Hereda de Usuario mediante id_usuario
CREATE TABLE empresa (
    id_usuario INT,
    cuit BIGINT UNIQUE, -- CUIT debe ser único
    capacidad_instalada DECIMAL(10, 2), -- Formato: 10 dígitos totales, 2 decimales
    CONSTRAINT empresaPK PRIMARY KEY (id_usuario),
    -- CASCADE: si se elimina el usuario, se elimina la empresa
    CONSTRAINT empresaUsuarioFK FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    -- Validación: capacidad entre 0 y 50.000
    CONSTRAINT CHECK (
        capacidad_instalada > 0
        AND capacidad_instalada < 50000
    )
);

-- ================================================================
-- TABLAS DE RECLAMOS Y RELACIONES
-- ================================================================
-- Tabla reclamo: Almacena los reclamos realizados por usuarios
CREATE TABLE reclamo (
    nro_reclamo INT PRIMARY KEY AUTO_INCREMENT,
    codigo_motivo INT NOT NULL, -- Motivo del reclamo (obligatorio)
    id_usuario INT NOT NULL, -- Usuario que realiza el reclamo (obligatorio)
    fecha_resolucion DATETIME, -- Fecha en que se resolvió (NULL si está pendiente)
    fecha_reclamo DATETIME NOT NULL, -- Fecha del reclamo
    -- FK: actualiza motivo si cambia el código
    CONSTRAINT motivoFK FOREIGN KEY (codigo_motivo) REFERENCES motivo (codigo) ON UPDATE CASCADE,
    -- FK: si se elimina el usuario, se eliminan sus reclamos (CASCADE)
    CONSTRAINT usuarioReclamoFK FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE
);

-- Tabla rellamado: Almacena seguimientos/llamadas adicionales de un reclamo
CREATE TABLE rellamado (
    nro_llamado INT, -- Número secuencial del llamado para ese reclamo
    nro_reclamo INT, -- Reclamo al que pertenece
    fecha_hora DATETIME NOT NULL,
    CONSTRAINT rellamadoPK PRIMARY KEY (nro_llamado, nro_reclamo), -- Clave compuesta
    -- CASCADE: si se elimina el reclamo, se eliminan sus rellamados
    CONSTRAINT rellamadoFK FOREIGN KEY (nro_reclamo) REFERENCES reclamo (nro_reclamo) ON DELETE CASCADE
);

-- Tabla requiere: Relación N:M entre reclamos y materiales
-- Indica qué materiales se usaron en cada reclamo y en qué cantidad
CREATE TABLE requiere (
    nro_reclamo INT,
    codigo_material INT,
    cantidad INT NOT NULL, -- Cantidad de material utilizado
    CONSTRAINT requierePK PRIMARY KEY (nro_reclamo, codigo_material), -- Clave compuesta
    -- CASCADE: si se elimina el reclamo, se eliminan sus materiales asociados
    CONSTRAINT requiereReclamo FOREIGN KEY (nro_reclamo) REFERENCES reclamo (nro_reclamo) ON DELETE CASCADE,
    -- CASCADE: si se elimina el material, se eliminan sus asociaciones
    CONSTRAINT requiereMaterial FOREIGN KEY (codigo_material) REFERENCES material (codigo) ON DELETE CASCADE
);

-- Tabla atendidoPor: Relación N:M entre reclamos y empleados
-- Indica qué empleados atendieron cada reclamo
CREATE TABLE atendidoPor (
    id_usuario INT, -- ID del empleado
    num_reclamo INT, -- Número del reclamo
    CONSTRAINT atendidoPK PRIMARY KEY (id_usuario, num_reclamo), -- Clave compuesta
    -- CASCADE: si se elimina el usuario/empleado, se eliminan sus asignaciones
    CONSTRAINT atendidoUsuarioFK FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario) ON DELETE CASCADE,
    -- CASCADE: si se elimina el reclamo, se eliminan sus asignaciones
    CONSTRAINT atendidoReclamoFK FOREIGN KEY (num_reclamo) REFERENCES reclamo (nro_reclamo) ON DELETE CASCADE
);

-- ================================================================
-- TABLA DE AUDITORÍA
-- ================================================================
-- Tabla reclamoEliminado: Almacena registro de reclamos eliminados
-- Se llena automáticamente mediante un trigger
CREATE TABLE reclamoEliminado (
    nro_reclamo INT PRIMARY KEY, -- Número del reclamo eliminado
    fecha_elim DATE NOT NULL, -- Fecha de eliminación
    usuario VARCHAR(128) CHARACTER SET utf8mb4 NOT NULL -- Usuario de BD que eliminó el registro
);

-- ================================================================
-- TRIGGER DE AUDITORÍA
-- ================================================================
-- Trigger que se ejecuta DESPUÉS de eliminar un reclamo
-- Registra automáticamente la eliminación en reclamoEliminado
CREATE TRIGGER trigger_eliminar_reclamo AFTER DELETE ON reclamo FOR EACH ROW
INSERT INTO
    reclamoEliminado
VALUES
    (OLD.nro_reclamo, NOW(), CURRENT_USER());

-- ================================================================
-- DATOS DE PRUEBA
-- ================================================================
-- Insertar 5 usuarios base
INSERT INTO
    Usuario (direccion, telefono)
VALUES
    ('Av. San Martín 1234, Córdoba', '351-4567890'),
    ('Calle Rivadavia 567, Córdoba', '351-2345678'),
    ('Boulevard Chacabuco 890, Córdoba', '351-3456789'),
    ('Calle 9 de Julio 456, Córdoba', '351-5678901'),
    ('Av. Colón 789, Córdoba', '351-6789012');

-- Insertar 3 personas (heredan de los primeros 3 usuarios)
INSERT INTO
    persona (id_usuario, documento, nombre, apellido)
VALUES
    (1, 12345678, 'Juan', 'Pérez'),
    (2, 23456789, 'María', 'González'),
    (3, 34567890, 'Carlos', 'Rodríguez');

-- Insertar 2 empresas (heredan de los usuarios 4 y 5)
INSERT INTO
    empresa (id_usuario, cuit, capacidad_instalada)
VALUES
    (4, 2012345678, 5000.50),
    (5, 3023456789, 15000.75);

-- Marcar a 2 personas como empleados de la empresa
INSERT INTO
    empleado (id_usuario, sueldo)
VALUES
    (2, 85000.00), -- María González es empleada
    (3, 92000.50);

-- Carlos Rodríguez es empleado
-- Insertar catálogo de 6 materiales
INSERT INTO
    material (descripcion)
VALUES
    ('Cable de alta tensión 15KV'),
    ('Transformador monofásico 25KVA'),
    ('Poste de hormigón 12 metros'),
    ('Aislador de porcelana'),
    ('Medidor eléctrico digital'),
    ('Fusible de protección 63A');

-- Insertar catálogo de 6 motivos de reclamo
INSERT INTO
    motivo (descripcion)
VALUES
    ('Falta de suministro eléctrico'),
    ('Tensión irregular'),
    ('Daño en equipos por sobretensión'),
    ('Corte de energía frecuente'),
    ('Medidor defectuoso'),
    ('Cables en mal estado');

-- Insertar 5 reclamos con diferentes motivos y usuarios
INSERT INTO
    reclamo (
        codigo_motivo,
        id_usuario,
        fecha_reclamo,
        fecha_resolucion
    )
VALUES
    (1, 1, '2024-10-01', '2024-10-05'), -- Juan Pérez - Falta de suministro (resuelto)
    (2, 4, '2024-10-03', NULL), -- Empresa - Tensión irregular (pendiente)
    (5, 1, '2024-10-05', '2024-10-08'), -- Juan Pérez - Medidor defectuoso (resuelto)
    (1, 5, '2024-10-07', NULL), -- Empresa - Falta de suministro (pendiente)
    (3, 4, '2024-10-10', '2024-10-12');

-- Empresa - Daño por sobretensión (resuelto)
-- Relacionar reclamos con materiales utilizados (tabla N:M)
INSERT INTO
    requiere (nro_reclamo, codigo_material, cantidad)
VALUES
    (1, 1, 50), -- Reclamo 1 usó 50 cables
    (1, 4, 20), -- Reclamo 1 usó 20 aisladores
    (2, 2, 2), -- Reclamo 2 usó 2 transformadores
    (2, 3, 1), -- Reclamo 2 usó 1 poste
    (3, 5, 1), -- Reclamo 3 usó 1 medidor
    (4, 1, 100), -- Reclamo 4 usó 100 cables
    (4, 6, 10), -- Reclamo 4 usó 10 fusibles
    (5, 5, 3);

-- Reclamo 5 usó 3 medidores
-- Insertar rellamados (seguimientos) de reclamos
-- Los reclamos 2 y 4 tienen múltiples llamados de seguimiento
INSERT INTO
    rellamado (nro_llamado, nro_reclamo, fecha_hora)
VALUES
    (1, 2, '2024-10-04 09:30:00'), -- Primer seguimiento del reclamo 2
    (2, 2, '2024-10-06 14:15:00'), -- Segundo seguimiento del reclamo 2
    (1, 4, '2024-10-08 11:20:00'), -- Primer seguimiento del reclamo 4
    (2, 4, '2024-10-09 16:45:00'), -- Segundo seguimiento del reclamo 4
    (3, 4, '2024-10-11 10:10:00');

-- Tercer seguimiento del reclamo 4
-- Asignar empleados a reclamos (tabla N:M)
-- El reclamo 4 fue atendido por 2 empleados
INSERT INTO
    atendidoPor (id_usuario, num_reclamo)
VALUES
    (2, 1), -- María atendió reclamo 1
    (3, 2), -- Carlos atendió reclamo 2
    (2, 3), -- María atendió reclamo 3
    (2, 4), -- María atendió reclamo 4
    (3, 4), -- Carlos también atendió reclamo 4 (múltiples empleados)
    (3, 5);

-- Carlos atendió reclamo 5