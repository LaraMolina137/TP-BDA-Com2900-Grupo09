/* =========================================================
Universidad Nacional de La Matanza
Materia: Bases de Datos Aplicada
Grupo 09:
- Molina, Lara Araceli 40187938
- Lopez, Julian Leonel 39712927
- Caceres, Facundo Tomas 46441605
- Puerto, Facundo Nahuel 44597219
Fecha: 2026-06-23
Objetivo: Procedimientos almacenados ABM.
========================================================= */

USE ParqueNacionalDB;
GO

/* =========================================================
   CORE.PARQUE
========================================================= */
CREATE OR ALTER PROCEDURE core.sp_Parque_Alta
    @nombre VARCHAR(100),
    @descripcion VARCHAR(150),
    @tipo VARCHAR(50),
    @ubicacion VARCHAR(200),
    @superficie DECIMAL(12,2) = NULL,
    @id_parque_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre del parque es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La descripcion del parque es obligatoria. ');
    IF NULLIF(LTRIM(RTRIM(@tipo)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El tipo de parque es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@ubicacion)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La ubicacion del parque es obligatoria. ');
    IF EXISTS (SELECT 1 FROM core.Parque WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores = CONCAT(@errores, N'- Ya existe un parque con ese nombre. ');

    IF @errores <> N'' THROW 50001, @errores, 1;

    INSERT INTO core.Parque(nombre, descripcion, tipo, ubicacion, superficie)
    VALUES (LTRIM(RTRIM(@nombre)), LTRIM(RTRIM(@descripcion)), LTRIM(RTRIM(@tipo)), LTRIM(RTRIM(@ubicacion)), @superficie);

    SET @id_parque_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE core.sp_Parque_Modificar
    @id_parque INT,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(150),
    @tipo VARCHAR(50),
    @ubicacion VARCHAR(200),
    @superficie DECIMAL(12,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre del parque es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La descripcion del parque es obligatoria. ');
    IF NULLIF(LTRIM(RTRIM(@tipo)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El tipo de parque es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@ubicacion)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La ubicacion del parque es obligatoria. ');
    IF @superficie IS NOT NULL AND @superficie < 0
        SET @errores = CONCAT(@errores, N'- La superficie no puede ser negativa. ');
    IF EXISTS (SELECT 1 FROM core.Parque WHERE nombre = LTRIM(RTRIM(@nombre)) AND id_parque <> @id_parque)
        SET @errores = CONCAT(@errores, N'- Ya existe otro parque con ese nombre. ');

    IF @errores <> N'' THROW 50002, @errores, 1;

    UPDATE core.Parque
       SET nombre = LTRIM(RTRIM(@nombre)),
           descripcion = LTRIM(RTRIM(@descripcion)),
           tipo = LTRIM(RTRIM(@tipo)),
           ubicacion = LTRIM(RTRIM(@ubicacion)),
           superficie = @superficie
     WHERE id_parque = @id_parque;
END;
GO

CREATE OR ALTER PROCEDURE core.sp_Parque_Baja
    @id_parque INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');
    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: el parque tiene concesiones asociadas. ');
    IF EXISTS (SELECT 1 FROM rrhh.RegistroGuardaparques WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: el parque tiene guardaparques registrados. ');
    IF EXISTS (SELECT 1 FROM actividades.Actividad WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: el parque tiene actividades asociadas. ');
    IF EXISTS (SELECT 1 FROM ventas.Entrada WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: el parque tiene entradas configuradas. ');

    IF @errores <> N'' THROW 50003, @errores, 1;

    DELETE FROM core.Parque WHERE id_parque = @id_parque;
END;
GO

/* =========================================================
   CONCESIONES.EMPRESA_CONCESIONARIA
========================================================= */
CREATE OR ALTER PROCEDURE concesiones.sp_EmpresaConcesionaria_Alta
    @nombre VARCHAR(150),
    @telefono VARCHAR(30) = NULL,
    @id_empresa_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre de la empresa es obligatorio. ');
    IF EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE nombre = LTRIM(RTRIM(@nombre)))
        SET @errores = CONCAT(@errores, N'- Ya existe una empresa concesionaria con ese nombre. ');

    IF @errores <> N'' THROW 50004, @errores, 1;

    INSERT INTO concesiones.EmpresaConcesionaria(nombre, telefono)
    VALUES (LTRIM(RTRIM(@nombre)), NULLIF(LTRIM(RTRIM(@telefono)), ''));

    SET @id_empresa_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_EmpresaConcesionaria_Modificar
    @id_empresa INT,
    @nombre VARCHAR(150),
    @telefono VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id_empresa = @id_empresa)
        SET @errores = CONCAT(@errores, N'- La empresa indicada no existe. ');
    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre de la empresa es obligatorio. ');

    IF @errores <> N'' THROW 50005, @errores, 1;

    UPDATE concesiones.EmpresaConcesionaria
       SET nombre = LTRIM(RTRIM(@nombre)),
           telefono = NULLIF(LTRIM(RTRIM(@telefono)), '')
     WHERE id_empresa = @id_empresa;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_EmpresaConcesionaria_Baja
    @id_empresa INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id_empresa = @id_empresa)
        SET @errores = CONCAT(@errores, N'- La empresa indicada no existe. ');
    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_empresa = @id_empresa)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: la empresa tiene concesiones asociadas. ');

    IF @errores <> N'' THROW 50006, @errores, 1;

    DELETE FROM concesiones.EmpresaConcesionaria WHERE id_empresa = @id_empresa;
END;
GO

/* =========================================================
   CONCESIONES.ACTIVIDAD_EMPRESA
========================================================= */
CREATE OR ALTER PROCEDURE concesiones.sp_ActividadEmpresa_Alta
    @rubro VARCHAR(150),
    @id_actividad_empresa_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@rubro)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El rubro es obligatorio. ');

    IF @errores <> N'' THROW 50007, @errores, 1;

    INSERT INTO concesiones.ActividadEmpresa(rubro) VALUES (LTRIM(RTRIM(@rubro)));
    SET @id_actividad_empresa_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_ActividadEmpresa_Modificar
    @id_actividad_empresa INT,
    @rubro VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresa WHERE id_actividad_empresa = @id_actividad_empresa)
        SET @errores = CONCAT(@errores, N'- La actividad de empresa indicada no existe. ');
    IF NULLIF(LTRIM(RTRIM(@rubro)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El rubro es obligatorio. ');

    IF @errores <> N'' THROW 50008, @errores, 1;

    UPDATE concesiones.ActividadEmpresa SET rubro = LTRIM(RTRIM(@rubro)) WHERE id_actividad_empresa = @id_actividad_empresa;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_ActividadEmpresa_Baja
    @id_actividad_empresa INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.ActividadEmpresa WHERE id_actividad_empresa = @id_actividad_empresa)
        SET @errores = CONCAT(@errores, N'- La actividad de empresa indicada no existe. ');
    IF EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_actividad_empresa = @id_actividad_empresa)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: el rubro tiene concesiones asociadas. ');

    IF @errores <> N'' THROW 50009, @errores, 1;

    DELETE FROM concesiones.ActividadEmpresa WHERE id_actividad_empresa = @id_actividad_empresa;
END;
GO

/* =========================================================
   CONCESIONES.CONCESION
========================================================= */
CREATE OR ALTER PROCEDURE concesiones.sp_Concesion_Alta
    @id_empresa INT,
    @id_parque INT,
    @id_actividad_empresa INT,
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL,
    @monto_mensual DECIMAL(12,2),
    @id_concesion_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id_empresa = @id_empresa)
        SET @errores = CONCAT(@errores, N'- La empresa concesionaria no existe. ');
    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque no existe. ');

    IF @errores <> N'' THROW 50010, @errores, 1;

    INSERT INTO concesiones.Concesion(id_empresa, id_parque, id_actividad_empresa, fecha_inicio, fecha_fin, monto_mensual)
    VALUES (@id_empresa, @id_parque, @id_actividad_empresa, @fecha_inicio, @fecha_fin, @monto_mensual);

    SET @id_concesion_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_Concesion_Modificar
    @id_concesion INT,
    @id_empresa INT,
    @id_parque INT,
    @id_actividad_empresa INT,
    @fecha_inicio DATE,
    @fecha_fin DATE = NULL,
    @monto_mensual DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @id_concesion)
        SET @errores = CONCAT(@errores, N'- La concesion indicada no existe. ');
    IF NOT EXISTS (SELECT 1 FROM concesiones.EmpresaConcesionaria WHERE id_empresa = @id_empresa)
        SET @errores = CONCAT(@errores, N'- La empresa concesionaria no existe. ');
    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque no existe. ');

    IF @errores <> N'' THROW 50011, @errores, 1;

    UPDATE concesiones.Concesion
       SET id_empresa = @id_empresa,
           id_parque = @id_parque,
           id_actividad_empresa = @id_actividad_empresa,
           fecha_inicio = @fecha_inicio,
           fecha_fin = @fecha_fin,
           monto_mensual = @monto_mensual
     WHERE id_concesion = @id_concesion;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_Concesion_Baja
    @id_concesion INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @id_concesion)
        SET @errores = CONCAT(@errores, N'- La concesion indicada no existe. ');
    IF EXISTS (SELECT 1 FROM concesiones.Pago WHERE id_concesion = @id_concesion)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: la concesion tiene pagos registrados. ');

    IF @errores <> N'' THROW 50012, @errores, 1;

    DELETE FROM concesiones.Concesion WHERE id_concesion = @id_concesion;
END;
GO

/* =========================================================
   CONCESIONES.PAGO
========================================================= */
CREATE OR ALTER PROCEDURE concesiones.sp_Pago_Alta
    @id_concesion INT,
    @monto DECIMAL(12,2),
    @fecha_pago DATE = NULL,
    @fecha_limite DATE,
    @nro_pago_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.Concesion WHERE id_concesion = @id_concesion)
        SET @errores = CONCAT(@errores, N'- La concesion indicada no existe. ');
    IF @monto IS NULL OR @monto < 0
        SET @errores = CONCAT(@errores, N'- El monto del pago debe ser mayor o igual a cero. ');
    IF @fecha_limite IS NULL
        SET @errores = CONCAT(@errores, N'- La fecha limite es obligatoria. ');

    IF @errores <> N'' THROW 50013, @errores, 1;

    INSERT INTO concesiones.Pago(id_concesion, monto, fecha_pago, fecha_limite)
    VALUES (@id_concesion, @monto, @fecha_pago, @fecha_limite);

    SET @nro_pago_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_Pago_Modificar
    @id_concesion INT,
    @nro_pago INT,
    @monto DECIMAL(12,2),
    @fecha_pago DATE = NULL,
    @fecha_limite DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM concesiones.Pago WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago)
        SET @errores = CONCAT(@errores, N'- El pago indicado no existe. ');
    IF @monto IS NULL OR @monto < 0
        SET @errores = CONCAT(@errores, N'- El monto del pago debe ser mayor o igual a cero. ');
    IF @fecha_limite IS NULL
        SET @errores = CONCAT(@errores, N'- La fecha limite es obligatoria. ');

    IF @errores <> N'' THROW 50014, @errores, 1;

    UPDATE concesiones.Pago
       SET monto = @monto,
           fecha_pago = @fecha_pago,
           fecha_limite = @fecha_limite
     WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago;
END;
GO

CREATE OR ALTER PROCEDURE concesiones.sp_Pago_Baja
    @id_concesion INT,
    @nro_pago INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM concesiones.Pago WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago)
        THROW 50015, N'El pago indicado no existe.', 1;

    DELETE FROM concesiones.Pago WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago;
END;
GO

/* =========================================================
   RRHH.GUARDAPARQUES
========================================================= */
CREATE OR ALTER PROCEDURE rrhh.sp_Guardaparques_Alta
    @dni VARCHAR(20),
    @nombre VARCHAR(100),
    @telefono VARCHAR(30) = NULL,
    @matricula VARCHAR(50),
    @fecha_nac DATE = NULL,
    @id_guardaparques_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@dni)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El DNI del guardaparques es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@matricula)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La matricula del guardaparques es obligatoria. ');
    IF EXISTS (SELECT 1 FROM rrhh.Guardaparques WHERE matricula = LTRIM(RTRIM(@matricula)))
        SET @errores = CONCAT(@errores, N'- Ya existe un guardaparques con esa matricula. ');

    IF @errores <> N'' THROW 50016, @errores, 1;

    INSERT INTO rrhh.Guardaparques(dni, nombre, telefono, matricula, fecha_nac)
    VALUES (LTRIM(RTRIM(@dni)), LTRIM(RTRIM(@nombre)), NULLIF(LTRIM(RTRIM(@telefono)), ''), LTRIM(RTRIM(@matricula)), @fecha_nac);

    SET @id_guardaparques_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_Guardaparques_Modificar
    @id_guardaparques INT,
    @dni VARCHAR(20),
    @nombre VARCHAR(100),
    @telefono VARCHAR(30) = NULL,
    @matricula VARCHAR(50),
    @fecha_nac DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.Guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = CONCAT(@errores, N'- El guardaparques indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@dni)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El DNI del guardaparques es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@matricula)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La matricula del guardaparques es obligatoria. ');

    IF @errores <> N'' THROW 50017, @errores, 1;

    UPDATE rrhh.Guardaparques
       SET dni = LTRIM(RTRIM(@dni)),
           nombre = LTRIM(RTRIM(@nombre)),
           telefono = NULLIF(LTRIM(RTRIM(@telefono)), ''),
           matricula = LTRIM(RTRIM(@matricula)),
           fecha_nac = @fecha_nac
     WHERE id_guardaparques = @id_guardaparques;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_Guardaparques_Baja
    @id_guardaparques INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.Guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = CONCAT(@errores, N'- El guardaparques indicado no existe. ');

    IF @errores <> N'' THROW 50018, @errores, 1;

    DELETE FROM rrhh.Guardaparques WHERE id_guardaparques = @id_guardaparques;
END;
GO

/* =========================================================
   RRHH.REGISTRO_GUARDAPARQUES
========================================================= */
CREATE OR ALTER PROCEDURE rrhh.sp_RegistroGuardaparques_Alta
    @id_parque INT,
    @id_guardaparques INT,
    @fecha_ingreso DATE,
    @fecha_egreso DATE = NULL,
    @motivo_egreso VARCHAR(200) = NULL,
    @nro_registro_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');
    IF NOT EXISTS (SELECT 1 FROM rrhh.Guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = CONCAT(@errores, N'- El guardaparques indicado no existe. ');
 
    IF @errores <> N'' THROW 50019, @errores, 1;

    INSERT INTO rrhh.RegistroGuardaparques(id_parque, id_guardaparques, fecha_ingreso, fecha_egreso, motivo_egreso)
    VALUES (@id_parque, @id_guardaparques, @fecha_ingreso, @fecha_egreso, NULLIF(LTRIM(RTRIM(@motivo_egreso)), ''));

    SET @nro_registro_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_RegistroGuardaparques_Modificar
    @id_parque INT,
    @nro_registro INT,
    @id_guardaparques INT,
    @fecha_ingreso DATE,
    @fecha_egreso DATE = NULL,
    @motivo_egreso VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.RegistroGuardaparques WHERE id_parque = @id_parque AND nro_registro = @nro_registro)
        SET @errores = CONCAT(@errores, N'- El registro de guardaparques indicado no existe. ');
    IF NOT EXISTS (SELECT 1 FROM rrhh.Guardaparques WHERE id_guardaparques = @id_guardaparques)
        SET @errores = CONCAT(@errores, N'- El guardaparques indicado no existe. ');
 
    IF @errores <> N'' THROW 50020, @errores, 1;

    UPDATE rrhh.RegistroGuardaparques
       SET id_guardaparques = @id_guardaparques,
           fecha_ingreso = @fecha_ingreso,
           fecha_egreso = @fecha_egreso,
           motivo_egreso = NULLIF(LTRIM(RTRIM(@motivo_egreso)), '')
     WHERE id_parque = @id_parque AND nro_registro = @nro_registro;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_RegistroGuardaparques_Baja
    @id_parque INT,
    @nro_registro INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM rrhh.RegistroGuardaparques WHERE id_parque = @id_parque AND nro_registro = @nro_registro)
        THROW 50021, N'El registro de guardaparques indicado no existe.', 1;

    DELETE FROM rrhh.RegistroGuardaparques WHERE id_parque = @id_parque AND nro_registro = @nro_registro;
END;
GO

/* =========================================================
   RRHH.GUIA
========================================================= */
CREATE OR ALTER PROCEDURE rrhh.sp_Guia_Alta
    @dni VARCHAR(20),
    @legajo VARCHAR(50),
    @titulo VARCHAR(100) = NULL,
    @nombre VARCHAR(100),
    @especialidad VARCHAR(100) = NULL,
    @id_guia_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@dni)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El DNI del guia es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@legajo)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El legajo del guia es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre del guia es obligatorio. ');
    IF EXISTS (SELECT 1 FROM rrhh.Guia WHERE legajo = LTRIM(RTRIM(@legajo)))
        SET @errores = CONCAT(@errores, N'- Ya existe un guia con ese legajo. ');

    IF @errores <> N'' THROW 50022, @errores, 1;

    INSERT INTO rrhh.Guia(dni, legajo, titulo, nombre, especialidad)
    VALUES (LTRIM(RTRIM(@dni)), LTRIM(RTRIM(@legajo)), NULLIF(LTRIM(RTRIM(@titulo)), ''), LTRIM(RTRIM(@nombre)), NULLIF(LTRIM(RTRIM(@especialidad)), ''));

    SET @id_guia_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_Guia_Modificar
    @id_guia INT,
    @dni VARCHAR(20),
    @legajo VARCHAR(50),
    @titulo VARCHAR(100) = NULL,
    @nombre VARCHAR(100),
    @especialidad VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.Guia WHERE id_guia = @id_guia)
        SET @errores = CONCAT(@errores, N'- El guia indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@dni)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El DNI del guia es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@legajo)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El legajo del guia es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre del guia es obligatorio. ');
    IF EXISTS (SELECT 1 FROM rrhh.Guia WHERE legajo = LTRIM(RTRIM(@legajo)) AND id_guia <> @id_guia)
        SET @errores = CONCAT(@errores, N'- Ya existe otro guia con ese legajo. ');

    IF @errores <> N'' THROW 50023, @errores, 1;

    UPDATE rrhh.Guia
       SET dni = LTRIM(RTRIM(@dni)),
           legajo = LTRIM(RTRIM(@legajo)),
           titulo = NULLIF(LTRIM(RTRIM(@titulo)), ''),
           nombre = LTRIM(RTRIM(@nombre)),
           especialidad = NULLIF(LTRIM(RTRIM(@especialidad)), '')
     WHERE id_guia = @id_guia;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_Guia_Baja
    @id_guia INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.Guia WHERE id_guia = @id_guia)
        SET @errores = CONCAT(@errores, N'- El guia indicado no existe. ');

    IF @errores <> N'' THROW 50024, @errores, 1;

    DELETE FROM rrhh.Guia WHERE id_guia = @id_guia;
END;
GO

/* =========================================================
   RRHH.HABILITACION
========================================================= */
CREATE OR ALTER PROCEDURE rrhh.sp_Habilitacion_Alta
    @id_guia INT,
    @descripcion VARCHAR(150),
    @valida_desde DATE,
    @valida_hasta DATE = NULL,
    @nro_habilitacion_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.Guia WHERE id_guia = @id_guia)
        SET @errores = CONCAT(@errores, N'- El guia indicado no existe. ');

    IF @errores <> N'' THROW 50025, @errores, 1;

    INSERT INTO rrhh.Habilitacion(id_guia, descripcion, valida_desde, valida_hasta)
    VALUES (@id_guia, LTRIM(RTRIM(@descripcion)), @valida_desde, @valida_hasta);

    SET @nro_habilitacion_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_Habilitacion_Modificar
    @id_guia INT,
    @nro_habilitacion INT,
    @descripcion VARCHAR(150),
    @valida_desde DATE,
    @valida_hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM rrhh.Habilitacion WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion)
        SET @errores = CONCAT(@errores, N'- La habilitacion indicada no existe. ');

    IF @errores <> N'' THROW 50026, @errores, 1;

    UPDATE rrhh.Habilitacion
       SET descripcion = LTRIM(RTRIM(@descripcion)),
           valida_desde = @valida_desde,
           valida_hasta = @valida_hasta
     WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion;
END;
GO

CREATE OR ALTER PROCEDURE rrhh.sp_Habilitacion_Baja
    @id_guia INT,
    @nro_habilitacion INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM rrhh.Habilitacion WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion)
        THROW 50027, N'La habilitacion indicada no existe.', 1;

    DELETE FROM rrhh.Habilitacion WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion;
END;
GO

/* =========================================================
   ACTIVIDADES.ACTIVIDAD
========================================================= */
CREATE OR ALTER PROCEDURE actividades.sp_Actividad_Alta
    @id_parque INT,
    @id_guia INT = NULL,
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
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');
    IF @id_guia IS NOT NULL AND NOT EXISTS (SELECT 1 FROM rrhh.Guia WHERE id_guia = @id_guia)
        SET @errores = CONCAT(@errores, N'- El guia indicado no existe. ');

    IF @errores <> N'' THROW 50028, @errores, 1;

    INSERT INTO actividades.Actividad(id_parque, id_guia, nombre, descripcion, duracion, cupo_maximo, precio, tipo)
    VALUES (@id_parque, @id_guia, LTRIM(RTRIM(@nombre)), NULLIF(LTRIM(RTRIM(@descripcion)), ''), @duracion, @cupo_maximo, @precio, @tipo);

    SET @id_actividad_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE actividades.sp_Actividad_Modificar
    @id_actividad INT,
    @id_parque INT,
    @id_guia INT = NULL,
    @nombre VARCHAR(100),
    @descripcion VARCHAR(200) = NULL,
    @duracion INT,
    @cupo_maximo INT,
    @precio DECIMAL(12,2) = 0,
    @tipo VARCHAR(20),
    @es_valido BIT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id_actividad = @id_actividad)
        SET @errores = CONCAT(@errores, N'- La actividad indicada no existe. ');
    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');

    IF @errores <> N'' THROW 50029, @errores, 1;

    UPDATE actividades.Actividad
       SET id_parque = @id_parque,
           id_guia = @id_guia,
           nombre = LTRIM(RTRIM(@nombre)),
           descripcion = NULLIF(LTRIM(RTRIM(@descripcion)), ''),
           duracion = @duracion,
           cupo_maximo = @cupo_maximo,
           precio = @precio,
           stamp = GETDATE(),
           es_valido = @es_valido,
           tipo = @tipo
     WHERE id_actividad = @id_actividad;
END;
GO

CREATE OR ALTER PROCEDURE actividades.sp_Actividad_Baja
    @id_actividad INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id_actividad = @id_actividad)
        THROW 50030, N'La actividad indicada no existe.', 1;

    UPDATE actividades.Actividad
       SET es_valido = 0,
           stamp = GETDATE()
     WHERE id_actividad = @id_actividad;
END;
GO

/* =========================================================
   VENTAS.TIPO_VISITANTE
========================================================= */
CREATE OR ALTER PROCEDURE ventas.sp_TipoVisitante_Alta
    @descripcion VARCHAR(100),
    @id_tipo_visitante_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La descripcion del tipo de visitante es obligatoria. ');
    IF EXISTS (SELECT 1 FROM ventas.TipoVisitante WHERE descripcion = LTRIM(RTRIM(@descripcion)))
        SET @errores = CONCAT(@errores, N'- Ya existe un tipo de visitante con esa descripcion. ');

    IF @errores <> N'' THROW 50031, @errores, 1;

    INSERT INTO ventas.TipoVisitante(descripcion) VALUES (LTRIM(RTRIM(@descripcion)));
    SET @id_tipo_visitante_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_TipoVisitante_Modificar
    @id_tipo_visitante INT,
    @descripcion VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.TipoVisitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = CONCAT(@errores, N'- El tipo de visitante indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@descripcion)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La descripcion del tipo de visitante es obligatoria. ');
    IF EXISTS (SELECT 1 FROM ventas.TipoVisitante WHERE descripcion = LTRIM(RTRIM(@descripcion)) AND id_tipo_visitante <> @id_tipo_visitante)
        SET @errores = CONCAT(@errores, N'- Ya existe otro tipo de visitante con esa descripcion. ');

    IF @errores <> N'' THROW 50032, @errores, 1;

    UPDATE ventas.TipoVisitante SET descripcion = LTRIM(RTRIM(@descripcion)) WHERE id_tipo_visitante = @id_tipo_visitante;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_TipoVisitante_Baja
    @id_tipo_visitante INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.TipoVisitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = CONCAT(@errores, N'- El tipo de visitante indicado no existe. ');

    IF @errores <> N'' THROW 50033, @errores, 1;

    DELETE FROM ventas.TipoVisitante WHERE id_tipo_visitante = @id_tipo_visitante;
END;
GO

/* =========================================================
   VENTAS.ENTRADA
========================================================= */
CREATE OR ALTER PROCEDURE ventas.sp_Entrada_Alta
    @id_parque INT,
    @id_tipo_visitante INT,
    @precio DECIMAL(12,2) = 0,
    @id_entrada_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');
    IF NOT EXISTS (SELECT 1 FROM ventas.TipoVisitante WHERE id_tipo_visitante = @id_tipo_visitante)
        SET @errores = CONCAT(@errores, N'- El tipo de visitante indicado no existe. ');

    IF @errores <> N'' THROW 50034, @errores, 1;

    INSERT INTO ventas.Entrada(id_parque, id_tipo_visitante, precio)
    VALUES (@id_parque, @id_tipo_visitante, @precio);

    SET @id_entrada_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_Entrada_Modificar
    @id_entrada INT,
    @id_parque INT,
    @id_tipo_visitante INT,
    @precio DECIMAL(12,2) = 0,
    @es_valido BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.Entrada WHERE id_entrada = @id_entrada)
        SET @errores = CONCAT(@errores, N'- La entrada indicada no existe. ');
    IF NOT EXISTS (SELECT 1 FROM core.Parque WHERE id_parque = @id_parque)
        SET @errores = CONCAT(@errores, N'- El parque indicado no existe. ');
    IF @errores <> N'' THROW 50035, @errores, 1;

    UPDATE ventas.Entrada
       SET id_parque = @id_parque,
           id_tipo_visitante = @id_tipo_visitante,
           precio = @precio,
           stamp = GETDATE(),
           es_valido = @es_valido
     WHERE id_entrada = @id_entrada;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_Entrada_Baja
    @id_entrada INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ventas.Entrada WHERE id_entrada = @id_entrada)
        THROW 50036, N'La entrada indicada no existe.', 1;

    UPDATE ventas.Entrada
       SET es_valido = 0,
           stamp = GETDATE()
     WHERE id_entrada = @id_entrada;
END;
GO

/* =========================================================
   VENTAS.VISITANTE
========================================================= */
CREATE OR ALTER PROCEDURE ventas.sp_Visitante_Alta
    @dni VARCHAR(20),
    @nombre VARCHAR(100),
    @id_visitante_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NULLIF(LTRIM(RTRIM(@dni)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El DNI del visitante es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre del visitante es obligatorio. ');
    IF EXISTS (SELECT 1 FROM ventas.Visitante WHERE dni = LTRIM(RTRIM(@dni)))
        SET @errores = CONCAT(@errores, N'- Ya existe un visitante con ese DNI. ');

    IF @errores <> N'' THROW 50037, @errores, 1;

    INSERT INTO ventas.Visitante(dni, nombre) VALUES (LTRIM(RTRIM(@dni)), LTRIM(RTRIM(@nombre)));
    SET @id_visitante_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_Visitante_Modificar
    @id_visitante INT,
    @dni VARCHAR(20),
    @nombre VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.Visitante WHERE id_visitante = @id_visitante)
        SET @errores = CONCAT(@errores, N'- El visitante indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@dni)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El DNI del visitante es obligatorio. ');
    IF NULLIF(LTRIM(RTRIM(@nombre)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El nombre del visitante es obligatorio. ');
    IF EXISTS (SELECT 1 FROM ventas.Visitante WHERE dni = LTRIM(RTRIM(@dni)) AND id_visitante <> @id_visitante)
        SET @errores = CONCAT(@errores, N'- Ya existe otro visitante con ese DNI. ');

    IF @errores <> N'' THROW 50038, @errores, 1;

    UPDATE ventas.Visitante
       SET dni = LTRIM(RTRIM(@dni)),
           nombre = LTRIM(RTRIM(@nombre))
     WHERE id_visitante = @id_visitante;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_Visitante_Baja
    @id_visitante INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.Visitante WHERE id_visitante = @id_visitante)
        SET @errores = CONCAT(@errores, N'- El visitante indicado no existe. ');
    IF EXISTS (SELECT 1 FROM ventas.Venta WHERE id_visitante = @id_visitante)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: el visitante tiene ventas registradas. ');

    IF @errores <> N'' THROW 50039, @errores, 1;

    DELETE FROM ventas.Visitante WHERE id_visitante = @id_visitante;
END;
GO

/* =========================================================
   VENTAS.VENTA
========================================================= */
CREATE OR ALTER PROCEDURE ventas.sp_Venta_Alta
    @id_visitante INT,
    @forma_pago VARCHAR(50),
    @punto_venta VARCHAR(100),
    @id_venta_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.Visitante WHERE id_visitante = @id_visitante)
        SET @errores = CONCAT(@errores, N'- El visitante indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@forma_pago)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La forma de pago es obligatoria. ');
    IF NULLIF(LTRIM(RTRIM(@punto_venta)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El punto de venta es obligatorio. ');

    IF @errores <> N'' THROW 50040, @errores, 1;

    INSERT INTO ventas.Venta(id_visitante, forma_pago, punto_venta)
    VALUES (@id_visitante, LTRIM(RTRIM(@forma_pago)), LTRIM(RTRIM(@punto_venta)));

    SET @id_venta_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_Venta_Modificar
    @id_venta INT,
    @id_visitante INT,
    @forma_pago VARCHAR(50),
    @punto_venta VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id_venta = @id_venta)
        SET @errores = CONCAT(@errores, N'- La venta indicada no existe. ');
    IF NOT EXISTS (SELECT 1 FROM ventas.Visitante WHERE id_visitante = @id_visitante)
        SET @errores = CONCAT(@errores, N'- El visitante indicado no existe. ');
    IF NULLIF(LTRIM(RTRIM(@forma_pago)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- La forma de pago es obligatoria. ');
    IF NULLIF(LTRIM(RTRIM(@punto_venta)), '') IS NULL
        SET @errores = CONCAT(@errores, N'- El punto de venta es obligatrio. ');

    IF @errores <> N'' THROW 50041, @errores, 1;

    UPDATE ventas.Venta
       SET id_visitante = @id_visitante,
           forma_pago = LTRIM(RTRIM(@forma_pago)),
           punto_venta = LTRIM(RTRIM(@punto_venta))
     WHERE id_venta = @id_venta;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_Venta_Baja
    @id_venta INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';

    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id_venta = @id_venta)
        SET @errores = CONCAT(@errores, N'- La venta indicada no existe. ');
    IF EXISTS (SELECT 1 FROM ventas.DetalleVenta WHERE id_venta = @id_venta)
        SET @errores = CONCAT(@errores, N'- No se puede eliminar: la venta tiene items registrados. ');

    IF @errores <> N'' THROW 50042, @errores, 1;

    DELETE FROM ventas.Venta WHERE id_venta = @id_venta;
END;
GO

/* =========================================================
   VENTAS.DETALLE_VENTA
========================================================= */
CREATE OR ALTER PROCEDURE ventas.sp_DetalleVenta_Alta
    @id_venta INT,
    @id_entrada INT = NULL,
    @id_actividad INT = NULL,
    @cantidad INT,
    @precio_unitario DECIMAL(12,2),
    @fecha_evento DATE = NULL,
    @nro_item_out INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';
    DECLARE @cupo_maximo INT;
    DECLARE @cantidad_vendida INT;

    IF NOT EXISTS (SELECT 1 FROM ventas.Venta WHERE id_venta = @id_venta)
        SET @errores = CONCAT(@errores, N'- La venta indicada no existe.');
    IF (@id_entrada IS NULL AND @id_actividad IS NULL) OR (@id_entrada IS NOT NULL AND @id_actividad IS NOT NULL)
        SET @errores = CONCAT(@errores, N'- Solo es valido entrada o actividad. ');
    IF @id_entrada IS NOT NULL AND NOT EXISTS (SELECT 1 FROM ventas.Entrada WHERE id_entrada = @id_entrada AND es_valido = 1)
        SET @errores = CONCAT(@errores, N'- La entrada indicada no existe o no esta vigente ');
    IF @id_actividad IS NOT NULL AND NOT EXISTS (SELECT 1 FROM actividades.Actividad WHERE id_actividad = @id_actividad AND es_valido = 1)
        SET @errores = CONCAT(@errores, N'- La actividad indicada no existe o no esta vigente. ');

    IF @errores <> N'' THROW 50043, @errores, 1;

    INSERT INTO ventas.DetalleVenta(id_venta, id_entrada, id_actividad, cantidad, precio_unitario, fecha_evento)
    VALUES (@id_venta, @id_entrada, @id_actividad, @cantidad, @precio_unitario, @fecha_evento);

    SET @nro_item_out = SCOPE_IDENTITY();
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_DetalleVenta_Modificar
    @id_venta INT,
    @nro_item INT,
    @id_entrada INT = NULL,
    @id_actividad INT = NULL,
    @cantidad INT,
    @precio_unitario DECIMAL(12,2),
    @fecha_evento DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = N'';
    DECLARE @cupo_maximo INT;
    DECLARE @cantidad_vendida INT;

    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleVenta WHERE id_venta = @id_venta AND nro_item = @nro_item)
        SET @errores = CONCAT(@errores, N'- El item de venta indicado no existe. ');
    IF (@id_entrada IS NULL AND @id_actividad IS NULL) OR (@id_entrada IS NOT NULL AND @id_actividad IS NOT NULL)
        SET @errores = CONCAT(@errores, N'- El detalle debe corresponder a una entrada o a una actividad, pero no ambas. ');
   
    IF @errores <> N'' THROW 50044, @errores, 1;

    UPDATE ventas.DetalleVenta
       SET id_entrada = @id_entrada,
           id_actividad = @id_actividad,
           cantidad = @cantidad,
           precio_unitario = @precio_unitario,
           fecha_evento = @fecha_evento
     WHERE id_venta = @id_venta AND nro_item = @nro_item;
END;
GO

CREATE OR ALTER PROCEDURE ventas.sp_DetalleVenta_Baja
    @id_venta INT,
    @nro_item INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM ventas.DetalleVenta WHERE id_venta = @id_venta AND nro_item = @nro_item)
        THROW 50045, N'El item de venta indicado no existe.', 1;

    DELETE FROM ventas.DetalleVenta WHERE id_venta = @id_venta AND nro_item = @nro_item;
END;
GO
