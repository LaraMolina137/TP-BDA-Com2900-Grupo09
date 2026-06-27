/* =========================================================
Universidad Nacional de La Matanza
Materia: Bases de Datos Aplicada
Grupo 09:
- Molina, Lara Araceli 40187938
- Lopez, Julian Leonel 39712927
- Caceres, Facundo Tomas 46441605
- Puerto, Facundo Nahuel 44597219
Fecha: 2026-06-24
Objetivo: Se testean los SP de negocio
   ========================================================= */

USE ParqueNacionalDB;
GO

SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    /* =========================================================
       DATOS DUMMY MINIMOS
       ========================================================= */
    DECLARE @id_parque INT;
    DECLARE @id_tipo_visitante INT;
    DECLARE @id_guia INT;

    -- Parque dummy
    BEGIN
        INSERT INTO core.Parque(nombre, descripcion, tipo, ubicacion, superficie)
        VALUES('Parque Dummy Test', 'Parque creado para tests', 'Parque Nacional', 'Ubicacion Test', 1000);

        SET @id_parque = SCOPE_IDENTITY();
    END;

    -- Tipo visitante dummy
    BEGIN
        INSERT INTO ventas.TipoVisitante(descripcion)
        VALUES('Visitante Test');

        SET @id_tipo_visitante = SCOPE_IDENTITY();
    END;

    BEGIN
        INSERT INTO ventas.Entrada(id_parque, id_tipo_visitante, precio, es_valido)
        VALUES(@id_parque, @id_tipo_visitante, 1500, 1);
    END;

    -- Guia dummy
    BEGIN
        INSERT INTO rrhh.Guia(dni, legajo, titulo, nombre, especialidad)
        VALUES('99999999', 'TEST-001', 'Guia de prueba', 'Guia Dummy Test', 'Senderismo');

        SET @id_guia = SCOPE_IDENTITY();
    END;

    /* =========================================================
       TEST 1: dbo.sp_VentaEntradas
       Resultado esperado: crea una venta y un detalle.
       ========================================================= */
    DECLARE @id_venta INT;

    EXEC dbo.sp_VentaEntradas
        @dni_visitante = '40111222',
        @nombre_visitante = 'Visitante Dummy Test',
        @id_parque = @id_parque,
        @id_tipo_visitante = @id_tipo_visitante,
        @cantidad = 1,
        @fecha_acceso = '2026-07-01',
        @forma_pago = 'Efectivo Test',
        @punto_venta = 'Caja Test',
        @id_venta_out = @id_venta OUTPUT;

    SELECT 'TEST 1 - sp_VentaEntradas - Venta creada' AS test, *
    FROM ventas.Venta
    WHERE id_venta = @id_venta;

    SELECT 'TEST 1 - sp_VentaEntradas - Detalle creado' AS test, *
    FROM ventas.DetalleVenta
    WHERE id_venta = @id_venta;

    /* =========================================================
       TEST 2: dbo.sp_Registro_de_Actividades
       Resultado esperado: crea una actividad.
       ========================================================= */
    DECLARE @id_actividad INT;

    EXEC dbo.sp_Registro_de_Actividades
        @id_parque = @id_parque,
        @nombre = 'Actividad Dummy Test',
        @descripcion = 'Actividad creada para test',
        @duracion = 60,
        @cupo_maximo = 20,
        @precio = 1000,
        @tipo = 'Atraccion',
        @id_actividad_out = @id_actividad OUTPUT;

    SELECT 'TEST 2 - sp_Registro_de_Actividades' AS test, *
    FROM actividades.Actividad
    WHERE id_actividad = @id_actividad;

    /* =========================================================
       TEST 3: dbo.sp_Tour_AsignarGuia
       Resultado esperado: crea un tour y le asigna un guia.
       ========================================================= */
    DECLARE @id_tour INT;

    EXEC dbo.sp_Registro_de_Actividades
        @id_parque = @id_parque,
        @nombre = 'Tour Dummy Test',
        @descripcion = 'Tour creado para test',
        @duracion = 90,
        @cupo_maximo = 10,
        @precio = 2000,
        @tipo = 'Tour',
        @id_actividad_out = @id_tour OUTPUT;

    EXEC dbo.sp_Tour_AsignarGuia
        @id_actividad = @id_tour,
        @id_guia = @id_guia;

    SELECT 'TEST 3 - sp_Tour_AsignarGuia' AS test, *
    FROM actividades.Actividad
    WHERE id_actividad = @id_tour;

    /* =========================================================
       TEST 4: dbo.sp_Registro_de_Concesiones
       Resultado esperado: crea una concesion y 12 pagos pendientes.
       ========================================================= */
    DECLARE @id_concesion INT;

    EXEC dbo.sp_Registro_de_Concesiones
        @nombre_empresa = 'Empresa Dummy Test',
        @telefono = '1111-2222',
        @id_parque = @id_parque,
        @rubro = 'Gastronomia Test',
        @fecha_inicio = '2026-01-01',
        @fecha_fin = '2026-12-31',
        @monto_mensual = 50000,
        @id_concesion_out = @id_concesion OUTPUT;

    SELECT 'TEST 4 - sp_Registro_de_Concesiones - Concesion' AS test, *
    FROM concesiones.Concesion
    WHERE id_concesion = @id_concesion;

    SELECT 'TEST 4 - sp_Registro_de_Concesiones - Pagos pendientes' AS test, *
    FROM concesiones.Pago
    WHERE id_concesion = @id_concesion;

    /* =========================================================
       TEST 5: dbo.sp_PagoConcesion
       Resultado esperado: actualiza fecha_pago del pago nro 1.
       ========================================================= */
    EXEC dbo.sp_PagoConcesion
        @id_concesion = @id_concesion,
        @nro_pago = 1;

    SELECT 'TEST 5 - sp_PagoConcesion' AS test, *
    FROM concesiones.Pago
    WHERE id_concesion = @id_concesion
      AND nro_pago = 1;

    /* =========================================================
       ROLLBACK FINAL
       Se deshacen todos los inserts/updates dummy hechos por este script.
       ========================================================= */
    ROLLBACK TRANSACTION;

    PRINT 'Tests ejecutados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    PRINT 'Error en los tests. Se hizo ROLLBACK.';
    THROW;
END CATCH;
GO
