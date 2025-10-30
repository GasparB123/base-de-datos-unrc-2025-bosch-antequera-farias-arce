import java.sql.*;
import java.util.Scanner;

/**
 * Sistema de Gestión de Reclamos para Empresa Eléctrica
 * Permite insertar usuarios, eliminar reclamos y listar reclamos por usuario
 */
public class Main {
    // Configuración de conexión a la base de datos MySQL
    private static final String URL = "jdbc:mysql://localhost:3306/empresa_electrica";
    private static final String USER = "root"; // Cambiar según tu configuración
    private static final String PASSWORD = "root"; // Cambiar según tu configuración

    public static void main(String[] args) {
        try (Scanner scanner = new Scanner(System.in)) {
            int opcion;

            // Menú principal del sistema
            do {
                System.out.println("\n=== SISTEMA DE GESTIÓN DE RECLAMOS ===");
                System.out.println("1. Insertar Usuario");
                System.out.println("2. Eliminar Reclamo");
                System.out.println("3. Listar Reclamos de un Usuario");
                System.out.println("0. Salir");
                System.out.print("Seleccione una opción: ");
                opcion = scanner.nextInt();
                scanner.nextLine(); // Limpiar buffer del scanner

                // Ejecutar la opción seleccionada
                switch (opcion) {
                    case 1 -> insertarUsuario(scanner);
                    case 2 -> eliminarReclamo(scanner);
                    case 3 -> listarReclamosUsuario(scanner);
                    case 0 -> System.out.println("Saliendo del sistema...");
                    default -> System.out.println("Opción inválida.");
                }
            } while (opcion != 0); // Repetir hasta que el usuario elija salir
        }
    }

    /**
     * Inserta un nuevo usuario en la base de datos
     * Puede ser una Persona o una Empresa
     * Si es Persona, pregunta si también es Empleado
     */
    private static void insertarUsuario(Scanner scanner) {
        System.out.println("\n--- Insertar Usuario ---");
        System.out.println("Tipo de usuario:");
        System.out.println("1. Persona");
        System.out.println("2. Empresa");
        System.out.print("Seleccione: ");
        int tipo = scanner.nextInt();
        scanner.nextLine();

        // Solicitar datos comunes a todos los usuarios
        System.out.print("Dirección: ");
        String direccion = scanner.nextLine();
        System.out.print("Teléfono: ");
        String telefono = scanner.nextLine();

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            // Desactivar auto-commit para manejar transacción manualmente
            conn.setAutoCommit(false);

            // 1. Insertar en la tabla Usuario (tabla padre)
            String sqlUsuario = "INSERT INTO Usuario (direccion, telefono) VALUES (?, ?)";
            PreparedStatement pstUsuario = conn.prepareStatement(sqlUsuario, Statement.RETURN_GENERATED_KEYS);
            pstUsuario.setString(1, direccion);
            pstUsuario.setString(2, telefono);
            pstUsuario.executeUpdate();

            // Obtener el ID auto-generado del usuario insertado
            ResultSet rs = pstUsuario.getGeneratedKeys();
            int idUsuario = 0;
            if (rs.next()) {
                idUsuario = rs.getInt(1);
            }

            // 2. Insertar en la tabla correspondiente según el tipo
            if (tipo == 1) {
                // Insertar Persona
                System.out.print("Documento (DNI, 8 dígitos): ");
                int documento = scanner.nextInt();
                scanner.nextLine();
                System.out.print("Nombre: ");
                String nombre = scanner.nextLine();
                System.out.print("Apellido: ");
                String apellido = scanner.nextLine();

                // Insertar en tabla persona (hereda de usuario)
                String sqlPersona = "INSERT INTO persona (id_usuario, documento, nombre, apellido) VALUES (?, ?, ?, ?)";
                PreparedStatement pstPersona = conn.prepareStatement(sqlPersona);
                pstPersona.setInt(1, idUsuario);
                pstPersona.setInt(2, documento);
                pstPersona.setString(3, nombre);
                pstPersona.setString(4, apellido);
                pstPersona.executeUpdate();

                // 3. Preguntar si la persona es empleado
                System.out.print("¿Es empleado? (s/n): ");
                String esEmpleado = scanner.nextLine();
                if (esEmpleado.equalsIgnoreCase("s")) {
                    System.out.print("Sueldo: ");
                    double sueldo = scanner.nextDouble();
                    scanner.nextLine();

                    // Insertar en tabla empleado (hereda de persona)
                    String sqlEmpleado = "INSERT INTO empleado (id_usuario, sueldo) VALUES (?, ?)";
                    PreparedStatement pstEmpleado = conn.prepareStatement(sqlEmpleado);
                    pstEmpleado.setInt(1, idUsuario);
                    pstEmpleado.setDouble(2, sueldo);
                    pstEmpleado.executeUpdate();
                }
            } else if (tipo == 2) {
                // Insertar Empresa
                System.out.print("CUIT (sin guiones): ");
                long cuit = scanner.nextLong();
                scanner.nextLine();
                System.out.print("Capacidad Instalada (0-50000): ");
                double capacidad = scanner.nextDouble();
                scanner.nextLine();

                // Insertar en tabla empresa (hereda de usuario)
                String sqlEmpresa = "INSERT INTO empresa (id_usuario, cuit, capacidad_instalada) VALUES (?, ?, ?)";
                PreparedStatement pstEmpresa = conn.prepareStatement(sqlEmpresa);
                pstEmpresa.setInt(1, idUsuario);
                pstEmpresa.setLong(2, cuit);
                pstEmpresa.setDouble(3, capacidad);
                pstEmpresa.executeUpdate();
            }

            // Confirmar la transacción (commit)
            conn.commit();
            System.out.println("Usuario insertado exitosamente con ID: " + idUsuario);

        } catch (SQLException e) {
            // Mostrar error si algo sale mal
            System.out.println("Error al insertar usuario: " + e.getMessage());
        }
    }

    /**
     * Elimina un reclamo de la base de datos
     * El trigger automáticamente registra la eliminación en reclamoEliminado
     * El CASCADE elimina también rellamados, materiales y motivos asociados
     */
    private static void eliminarReclamo(Scanner scanner) {
        System.out.println("\n--- Eliminar Reclamo ---");
        System.out.print("Ingrese el número de reclamo: ");
        int numReclamo = scanner.nextInt();
        scanner.nextLine();

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            // Preparar la consulta DELETE
            String sql = "DELETE FROM reclamo WHERE nro_reclamo = ?";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setInt(1, numReclamo);

            // Ejecutar la eliminación
            int filasAfectadas = pst.executeUpdate();

            // Verificar si se eliminó algún registro
            if (filasAfectadas > 0) {
                System.out.println("Reclamo eliminado exitosamente.");
                System.out.println("Se ha registrado la eliminación en la tabla reclamoEliminado.");
            } else {
                System.out.println("No se encontró el reclamo con número: " + numReclamo);
            }

        } catch (SQLException e) {
            System.out.println("Error al eliminar reclamo: " + e.getMessage());
        }
    }

    /**
     * Lista todos los reclamos de un usuario específico
     * Incluye: número, fecha, motivo, estado y cantidad de rellamados
     * Usa LEFT JOIN para incluir reclamos sin rellamados
     */
    private static void listarReclamosUsuario(Scanner scanner) {
        System.out.println("\n--- Listar Reclamos de Usuario ---");
        System.out.print("Ingrese el ID del usuario: ");
        int idUsuario = scanner.nextInt();
        scanner.nextLine();

        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            // Consulta SQL con JOIN para obtener información completa
            // COUNT() cuenta los rellamados de cada reclamo
            // LEFT JOIN asegura que se muestren reclamos incluso sin rellamados
            String sql = "SELECT r.nro_reclamo, r.fecha_reclamo, r.fecha_resolucion, " +
                    "m.descripcion as motivo, " +
                    "COUNT(rl.nro_llamado) as cantidad_rellamados " +
                    "FROM reclamo r " +
                    "INNER JOIN motivo m ON r.codigo_motivo = m.codigo " +
                    "LEFT JOIN rellamado rl ON r.nro_reclamo = rl.nro_reclamo " +
                    "WHERE r.id_usuario = ? " +
                    "GROUP BY r.nro_reclamo, r.fecha_reclamo, r.fecha_resolucion, m.descripcion " +
                    "ORDER BY r.fecha_reclamo DESC";

            // Preparar y ejecutar la consulta
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setInt(1, idUsuario);
            ResultSet rs = pst.executeQuery();

            System.out.println("\n========================================");
            System.out.println("RECLAMOS DEL USUARIO " + idUsuario);
            System.out.println("========================================");

            boolean hayResultados = false;

            // Iterar sobre los resultados
            while (rs.next()) {
                hayResultados = true;

                // Mostrar información de cada reclamo
                System.out.println("\nNúmero de Reclamo: " + rs.getInt("nro_reclamo"));
                System.out.println("Fecha de Reclamo: " + rs.getDate("fecha_reclamo"));
                System.out.println("Motivo: " + rs.getString("motivo"));

                // Verificar si el reclamo está resuelto
                Date fechaResolucion = rs.getDate("fecha_resolucion");
                if (fechaResolucion != null) {
                    System.out.println("Fecha de Resolución: " + fechaResolucion);
                    System.out.println("Estado: RESUELTO");
                } else {
                    System.out.println("Estado: PENDIENTE");
                }

                // Mostrar cantidad de rellamados (COUNT desde la consulta SQL)
                System.out.println("Cantidad de Rellamados: " + rs.getInt("cantidad_rellamados"));
                System.out.println("----------------------------------------");
            }

            // Mensaje si no se encontraron reclamos
            if (!hayResultados) {
                System.out.println("No se encontraron reclamos para el usuario " + idUsuario);
            }

        } catch (SQLException e) {
            System.out.println("Error al listar reclamos: " + e.getMessage());
        }
    }
}