/* =========================================================
Universidad Nacional de La Matanza
Materia: Bases de Datos Aplicada
Grupo 09:
- Molina, Lara Araceli 40187938
- Lopez, Julian Leonel 39712927
- Caceres, Facundo Tomas 46441605
- Puerto, Facundo Nahuel 44597219
Fecha: 2026-06-24
Objetivo: Crea SP de negocio: Ventas de entrada, Registro de actividades, Asignación de guía y Gestión de concesiones
   ========================================================= */

USE ParqueNacionalDB;
GO

/* =========================================================
   1) VENTA DE ENTRADAS
   - Crea el visitante si no existe.
   - Crea la venta.
   - Agrega el detalle con la entrada vigente del parque/tipo visitante.
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_VentaEntradas
    @dni_visitante VARCHAR(20),
    @nombre_visitante VARCHAR(100),
    @id_parque INT,
    @id_tipo_visitante INT,
    @cantidad INT,
    @fecha_acceso DATE,
    @forma_pago VARCHAR(50),
    @punto_venta VARCHAR(100),
    @id_venta_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_visitante INT;
    DECLARE @id_entrada INT;
    DECLARE @precio DECIMAL(12,2);

    SELECT TOP 1
        @id_entrada = id_entrada,
        @precio = precio
    FROM ventas.Entrada
    WHERE id_parque = @id_parque
      AND id_tipo_visitante = @id_tipo_visitante
      AND es_valido = 1

    IF @id_entrada IS NULL
        THROW 50000, 'No existe una entrada vigente para ese parque y tipo de visitante.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @id_visitante = id_visitante
        FROM ventas.Visitante
        WHERE dni = LTRIM(RTRIM(@dni_visitante));

        IF @id_visitante IS NULL
        BEGIN
            INSERT INTO ventas.Visitante(dni, nombre)
            VALUES(LTRIM(RTRIM(@dni_visitante)), LTRIM(RTRIM(@nombre_visitante)));

            SET @id_visitante = SCOPE_IDENTITY();
        END;

        INSERT INTO ventas.Venta(id_visitante, forma_pago, punto_venta)
        VALUES(@id_visitante, LTRIM(RTRIM(@forma_pago)), LTRIM(RTRIM(@punto_venta)));

        SET @id_venta_out = SCOPE_IDENTITY();

        INSERT INTO ventas.DetalleVenta(id_venta, id_entrada, id_actividad, cantidad, precio_unitario, fecha_evento)
        VALUES(@id_venta_out, @id_entrada, NULL, @cantidad, @precio, @fecha_acceso);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/* =========================================================
   2) REGISTRO DE ACTIVIDADES
   Registra una actividad o tour para un parque.
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Registro_de_Actividades
    @id_parque INT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(200) = NULL,
    @duracion INT,
    @cupo_maximo INT,
    @precio DECIMAL(12,2) = 0,
    @tipo VARCHAR(20),
    @id_actividad_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO actividades.Actividad
        (id_parque, id_guia, nombre, descripcion, duracion, cupo_maximo, precio, es_valido, tipo)
    VALUES
        (@id_parque, NULL, LTRIM(RTRIM(@nombre)), NULLIF(LTRIM(RTRIM(@descripcion)), ''),
         @duracion, @cupo_maximo, ISNULL(@precio, 0), 1, @tipo);

    SET @id_actividad_out = SCOPE_IDENTITY();
END;
GO

/* =========================================================
   3) ASIGNACION DE GUIAS
   Asigna un guia a un tour existente.
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Tour_AsignarGuia
    @id_actividad INT,
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM actividades.Actividad
        WHERE id_actividad = @id_actividad
          AND tipo = 'Tour'
          AND es_valido = 1
    )
        THROW 50000, 'La actividad indicada no existe o no es un tour vigente.', 1;

    UPDATE actividades.Actividad
    SET id_guia = @id_guia
    WHERE id_actividad = @id_actividad;
END;
GO

/* =========================================================
   4) GESTION DE CONCESIONES
   - Crea empresa si no existe por nombre.
   - Crea rubro si no existe.
   - Registra la concesion.
   - Registra los 12 pagos pendientes.
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Registro_de_Concesiones
    @nombre_empresa VARCHAR(150),
    @telefono VARCHAR(30) = NULL,
    @id_parque INT,
    @rubro VARCHAR(150),
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL,
    @monto_mensual DECIMAL(12,2),
    @id_concesion_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_empresa INT;
    DECLARE @id_actividad_empresa INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT @id_empresa = id_empresa
        FROM concesiones.EmpresaConcesionaria
        WHERE nombre = LTRIM(RTRIM(@nombre_empresa));

        IF @id_empresa IS NULL
        BEGIN
            INSERT INTO concesiones.EmpresaConcesionaria(nombre, telefono)
            VALUES(LTRIM(RTRIM(@nombre_empresa)), NULLIF(LTRIM(RTRIM(@telefono)), ''));

            SET @id_empresa = SCOPE_IDENTITY();
        END;

        SELECT @id_actividad_empresa = id_actividad_empresa
        FROM concesiones.ActividadEmpresa
        WHERE rubro = LTRIM(RTRIM(@rubro));

        IF @id_actividad_empresa IS NULL
        BEGIN
            INSERT INTO concesiones.ActividadEmpresa(rubro)
            VALUES(LTRIM(RTRIM(@rubro)));

            SET @id_actividad_empresa = SCOPE_IDENTITY();
        END;

        INSERT INTO concesiones.Concesion
            (id_empresa, id_parque, id_actividad_empresa, fecha_inicio, fecha_fin, monto_mensual)
        VALUES
            (@id_empresa, @id_parque, @id_actividad_empresa, @fecha_inicio, @fecha_fin, @monto_mensual);

        SET @id_concesion_out = SCOPE_IDENTITY();

        INSERT INTO concesiones.Pago
            (id_concesion, monto, fecha_pago, fecha_limite)
        VALUES
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 1, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 2, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 3, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 4, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 5, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 6, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 7, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 8, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 9, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 10, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 11, @fecha_inicio)),
            (@id_concesion_out, @monto_mensual, NULL, DATEADD(MONTH, 12, @fecha_inicio));

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

/* =========================================================
   4.1) GESTION DE CONCESIONES
   - Se registra un pago.
   ========================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_PagoConcesion
    @id_concesion INT,
    @nro_pago INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE concesiones.Pago
    SET fecha_pago = GETDATE()
    WHERE id_concesion = @id_concesion
      AND nro_pago = @nro_pago;
END;
GO