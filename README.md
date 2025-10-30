# Sistema de Gestión de Reclamos - Empresa Eléctrica

Sistema de base de datos para la gestión integral de reclamos de una empresa de servicios eléctricos, desarrollado como proyecto académico para la materia Base de Datos de la UNRC.

## 📋 Descripción

Este proyecto implementa un sistema completo de gestión de reclamos que permite:

- Registrar usuarios (personas y empresas)
- Gestionar reclamos de servicios eléctricos
- Asignar empleados a la resolución de reclamos
- Controlar materiales utilizados en reparaciones
- Realizar seguimiento mediante rellamados
- Auditar eliminaciones de reclamos

## 🏗️ Estructura del Proyecto

```
.
├── src/
│   ├── Main.java           # Aplicación Java principal
│   └── App.java            # Archivo de configuración
├── lib/                    # Dependencias (MySQL Connector)
├── bin/                    # Archivos compilados
├── empresa.sql            # Script de creación de BD y datos de prueba
├── consultas_empresa.sql  # Consultas SQL de análisis
└── README.md              # Este archivo
```

## 🗄️ Modelo de Datos

### Entidades Principales

- **Usuario**: Clase base para personas y empresas
  - **Persona**: Usuarios individuales con DNI
    - **Empleado**: Personas que trabajan en la empresa
  - **Empresa**: Clientes corporativos con CUIT
- **Reclamo**: Solicitudes de servicio o reparación
- **Motivo**: Catálogo de motivos de reclamos
- **Material**: Catálogo de materiales para reparaciones
- **Rellamado**: Seguimientos de reclamos
- **ReclamoEliminado**: Auditoría de eliminaciones

### Relaciones

- Un usuario puede tener múltiples reclamos
- Un reclamo puede requerir múltiples materiales (N:M)
- Un reclamo puede ser atendido por múltiples empleados (N:M)
- Un reclamo puede tener múltiples rellamados (1:N)

## 🚀 Instalación

### Prerrequisitos

- Java JDK 11 o superior
- MySQL Server 8.0 o superior
- MySQL Connector/J (JDBC Driver)
- Visual Studio Code con extensiones Java

### Configuración de la Base de Datos

1. Iniciar MySQL Server

2. Ejecutar el script de creación:

```bash
mysql -u root -p < empresa.sql
```

3. Verificar la creación:

```sql
USE empresa_electrica;
SHOW TABLES;
```

### Configuración de la Aplicación Java

1. Descargar MySQL Connector/J desde [mysql.com](https://dev.mysql.com/downloads/connector/j/)

2. Colocar el archivo `.jar` en la carpeta `lib/`

3. Configurar credenciales en [`Main.java`](src/Main.java):

```java
private static final String URL = "jdbc:mysql://localhost:3306/empresa_electrica";
private static final String USER = "tu_usuario";
private static final String PASSWORD = "tu_contraseña";
```

## 💻 Uso

### Compilar y Ejecutar

En Visual Studio Code:

1. Abrir el proyecto
2. Presionar `F5` o usar el botón "Run"

Desde terminal:

```bash
# Compilar
javac -cp "lib/*" -d bin src/Main.java

# Ejecutar
java -cp "bin:lib/*" Main
```

### Funcionalidades del Sistema

#### 1. Insertar Usuario

- Permite agregar personas o empresas
- Para personas: solicita DNI, nombre y apellido
- Opción de marcar persona como empleado
- Para empresas: solicita CUIT y capacidad instalada

#### 2. Eliminar Reclamo

- Elimina un reclamo por su número
- **Trigger automático**: registra la eliminación en tabla de auditoría
- **Cascade**: elimina automáticamente rellamados y materiales asociados

#### 3. Listar Reclamos de Usuario

- Muestra todos los reclamos de un usuario específico
- Incluye: fecha, motivo, estado y cantidad de rellamados
- Diferencia entre reclamos RESUELTOS y PENDIENTES

## 📊 Consultas SQL Disponibles

El archivo [`consultas_empresa.sql`](consultas_empresa.sql) contiene consultas analíticas:

### a) Detalle de Materiales por Reclamo

Muestra todos los materiales utilizados en cada reclamo, incluyendo reclamos sin materiales.

### b) Usuarios con Múltiples Reclamos

Lista usuarios que tienen más de un reclamo, ordenados por cantidad.

### c) Reclamos con Múltiples Empleados

Identifica reclamos atendidos por más de un empleado, mostrando sus nombres.

## 🔒 Características de Seguridad

- **Constraints de integridad**: Validaciones de DNI, CUIT y capacidad instalada
- **Claves foráneas con CASCADE**: Previene datos huérfanos
- **Trigger de auditoría**: Registra automáticamente eliminaciones
- **Transacciones**: Garantiza consistencia en operaciones múltiples

## 📝 Datos de Prueba

El script [`empresa.sql`](empresa.sql) incluye datos iniciales:

- 5 usuarios (3 personas, 2 empresas)
- 2 empleados
- 6 materiales disponibles
- 6 motivos de reclamo
- 5 reclamos de ejemplo
- Rellamados y asignaciones de empleados

## 👥 Autores

- Gaspar Bosch
- Gabriel Lautaro Antequera
- Alexis Farías
- Joaquin Arce

**Universidad Nacional de Río Cuarto**  
Base de Datos - 2do Año - 2025

## 📄 Licencia

Proyecto académico desarrollado con fines educativos.

## 🔧 Solución de Problemas

### Error de conexión a MySQL

```
Verificar que MySQL esté ejecutándose:
sudo systemctl status mysql
```

### ClassNotFoundException: com.mysql.cj.jdbc.Driver

```
Asegurarse de que mysql-connector-j.jar esté en lib/
y configurado en el classpath
```

### Violación de constraints

```
Revisar las validaciones:
- DNI: entre 1 y 999.999.999
- CUIT: único
- Capacidad instalada: entre 0 y 50.000
```

## 📚 Recursos Adicionales

- [Documentación MySQL](https://dev.mysql.com/doc/)
- [JDBC Tutorial](https://docs.oracle.com/javase/tutorial/jdbc/)
- [SQL Constraints](https://dev.mysql.com/doc/refman/8.0/en/constraints.html)
