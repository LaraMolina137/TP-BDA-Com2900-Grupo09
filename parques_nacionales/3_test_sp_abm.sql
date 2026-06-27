/* =========================================================
Universidad Nacional de La Matanza
Materia: Bases de Datos Aplicada
Grupo 09:
- Molina, Lara Araceli 40187938
- Lopez, Julian Leonel 39712927
- Caceres, Facundo Tomas 46441605
- Puerto, Facundo Nahuel 44597219
Fecha: 2026-06-26
Objetivo: Testear el ABM
========================================================= */

USE ParqueNacionalDB;
GO

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
GO

DECLARE @sufijo VARCHAR(20) = CONVERT(VARCHAR(36), NEWID());

DECLARE
    @id_parque INT,
    @id_parque_baja INT,
    @id_empresa INT,
    @id_empresa_baja INT,
    @id_actividad_empresa INT,
    @id_actividad_empresa_baja INT,
    @id_concesion INT,
    @id_concesion_baja INT,
    @nro_pago INT,
    @nro_pago_baja INT,
    @id_guardaparques INT,
    @id_guardaparques_baja INT,
    @nro_registro INT,
    @id_guia INT,
    @id_guia_baja INT,
    @nro_habilitacion INT,
    @nro_habilitacion_baja INT,
    @id_actividad INT,
    @id_actividad_baja INT,
    @id_tipo_visitante INT,
    @id_tipo_visitante_baja INT,
    @id_entrada INT,
    @id_entrada_baja INT,
    @id_visitante INT,
    @id_visitante_baja INT,
    @id_venta INT,
    @id_venta_baja INT,
    @nro_item INT,
    @nro_item_baja INT,
    @nombre_parque VARCHAR(150),
    @nombre_parque_mod VARCHAR(150),
    @nombre_empresa VARCHAR(120),
    @nombre_empresa_mod VARCHAR(120),
    @rubro_actividad_empresa VARCHAR(100),
    @rubro_actividad_empresa_mod VARCHAR(100),
    @dni_guardaparques VARCHAR(20),
    @dni_guardaparques_mod VARCHAR(20),
    @matricula_guardaparques VARCHAR(30),
    @matricula_guardaparques_mod VARCHAR(30),
    @dni_guia VARCHAR(20),
    @dni_guia_mod VARCHAR(20),
    @legajo_guia VARCHAR(30),
    @legajo_guia_mod VARCHAR(30),
    @nombre_actividad VARCHAR(120),
    @nombre_actividad_mod VARCHAR(120),
    @descripcion_tipo_visitante VARCHAR(80),
    @descripcion_tipo_visitante_mod VARCHAR(80),
    @dni_visitante VARCHAR(20),
    @dni_visitante_mod VARCHAR(20),
    @nombre_empresa_baja VARCHAR(120),
    @rubro_baja VARCHAR(100),
    @dni_guardaparques_baja VARCHAR(20),
    @matricula_guardaparques_baja VARCHAR(30),
    @dni_guia_baja VARCHAR(20),
    @legajo_guia_baja VARCHAR(30),
    @descripcion_tipo_baja VARCHAR(80),
    @nombre_parque_baja VARCHAR(150);

SELECT
    @nombre_parque = 'Parque Test ' + @sufijo,
    @nombre_parque_mod = 'Parque Test Mod ' + @sufijo,
    @nombre_empresa = 'Empresa Test ' + @sufijo,
    @nombre_empresa_mod = 'Empresa Test Mod ' + @sufijo,
    @rubro_actividad_empresa = 'Rubro Test ' + @sufijo,
    @rubro_actividad_empresa_mod = 'Rubro Test Mod ' + @sufijo,
    @dni_guardaparques = 'GP' + @sufijo,
    @dni_guardaparques_mod = 'GPM' + @sufijo,
    @matricula_guardaparques = 'MAT-' + @sufijo,
    @matricula_guardaparques_mod = 'MAT-M-' + @sufijo,
    @dni_guia = 'GUIA' + @sufijo,
    @dni_guia_mod = 'GUIAM' + @sufijo,
    @legajo_guia = 'LEG-' + @sufijo,
    @legajo_guia_mod = 'LEG-M-' + @sufijo,
    @nombre_actividad = 'Actividad Test ' + @sufijo,
    @nombre_actividad_mod = 'Actividad Test Mod ' + @sufijo,
    @descripcion_tipo_visitante = 'Tipo Visitante Test ' + @sufijo,
    @descripcion_tipo_visitante_mod = 'Tipo Visitante Test Mod ' + @sufijo,
    @dni_visitante = 'VIS' + @sufijo,
    @dni_visitante_mod = 'VISM' + @sufijo,
    @nombre_empresa_baja = 'Empresa Baja ' + @sufijo,
    @rubro_baja = 'Rubro Baja ' + @sufijo,
    @dni_guardaparques_baja = 'GPB' + @sufijo,
    @matricula_guardaparques_baja = 'MAT-B-' + @sufijo,
    @dni_guia_baja = 'GUIAB' + @sufijo,
    @legajo_guia_baja = 'LEG-B-' + @sufijo,
    @descripcion_tipo_baja = 'Tipo Baja ' + @sufijo,
    @nombre_parque_baja = 'Parque Baja ' + @sufijo;

PRINT 'TEST ABM - INICIO';

/* =========================================================
   1) CORE.PARQUE
========================================================= */
PRINT '1) CORE.PARQUE';

-- Resultado esperado: inserta un parque y devuelve id_parque.
EXEC core.sp_Parque_Alta
    @nombre = @nombre_parque,
    @descripcion = 'Parque generado por testing ABM',
    @tipo = 'Parque Nacional',
    @ubicacion = 'Provincia Test',
    @superficie = 1500.50,
    @id_parque_out = @id_parque OUTPUT;

SELECT 'Parque creado' AS prueba, *
FROM core.Parque
WHERE id_parque = @id_parque;

-- Resultado esperado: modifica los datos del parque creado.
EXEC core.sp_Parque_Modificar
    @id_parque = @id_parque,
    @nombre = @nombre_parque_mod,
    @descripcion = 'Parque modificado por testing ABM',
    @tipo = 'Reserva',
    @ubicacion = 'Ubicacion Modificada',
    @superficie = 2000.75;

SELECT 'Parque modificado' AS prueba, *
FROM core.Parque
WHERE id_parque = @id_parque;

-- Resultado esperado: falla por campos obligatorios vacios y muestra un unico mensaje con todas las validaciones.
BEGIN TRY
    DECLARE @id_parque_error INT;
    EXEC core.sp_Parque_Alta
        @nombre = '',
        @descripcion = '',
        @tipo = '',
        @ubicacion = '',
        @superficie = -1,
        @id_parque_out = @id_parque_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Parque_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Parque_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: falla porque el parque tiene una entrada asociada.
-- La entrada se crea mas adelante; esta validacion se prueba luego en la seccion de ventas.

/* =========================================================
   2) CONCESIONES.EMPRESA_CONCESIONARIA
========================================================= */
PRINT '2) CONCESIONES.EMPRESA_CONCESIONARIA';

EXEC concesiones.sp_EmpresaConcesionaria_Alta
    @nombre = @nombre_empresa,
    @telefono = '1111-2222',
    @id_empresa_out = @id_empresa OUTPUT;

SELECT 'Empresa creada' AS prueba, *
FROM concesiones.EmpresaConcesionaria
WHERE id_empresa = @id_empresa;

-- Resultado esperado: modifica la empresa.
EXEC concesiones.sp_EmpresaConcesionaria_Modificar
    @id_empresa = @id_empresa,
    @nombre = @nombre_empresa_mod,
    @telefono = '3333-4444';

SELECT 'Empresa modificada' AS prueba, *
FROM concesiones.EmpresaConcesionaria
WHERE id_empresa = @id_empresa;

-- Resultado esperado: falla por nombre vacio.
BEGIN TRY
    DECLARE @id_empresa_error INT;
    EXEC concesiones.sp_EmpresaConcesionaria_Alta
        @nombre = '',
        @telefono = NULL,
        @id_empresa_out = @id_empresa_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de EmpresaConcesionaria_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion EmpresaConcesionaria_Alta: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   3) CONCESIONES.ACTIVIDAD_EMPRESA
========================================================= */
PRINT '3) CONCESIONES.ACTIVIDAD_EMPRESA';

-- Resultado esperado: inserta un rubro.
EXEC concesiones.sp_ActividadEmpresa_Alta
    @rubro = @rubro_actividad_empresa,
    @id_actividad_empresa_out = @id_actividad_empresa OUTPUT;

SELECT 'ActividadEmpresa creada' AS prueba, *
FROM concesiones.ActividadEmpresa
WHERE id_actividad_empresa = @id_actividad_empresa;

-- Resultado esperado: modifica el rubro.
EXEC concesiones.sp_ActividadEmpresa_Modificar
    @id_actividad_empresa = @id_actividad_empresa,
    @rubro = @rubro_actividad_empresa_mod;

SELECT 'ActividadEmpresa modificada' AS prueba, *
FROM concesiones.ActividadEmpresa
WHERE id_actividad_empresa = @id_actividad_empresa;

-- Resultado esperado: falla por rubro obligatorio.
BEGIN TRY
    DECLARE @id_act_emp_error INT;
    EXEC concesiones.sp_ActividadEmpresa_Alta
        @rubro = '',
        @id_actividad_empresa_out = @id_act_emp_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de ActividadEmpresa_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion ActividadEmpresa_Alta: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   4) CONCESIONES.CONCESION Y PAGO
========================================================= */
PRINT '4) CONCESIONES.CONCESION Y PAGO';

-- Resultado esperado: inserta una concesion asociada a empresa, parque y rubro existentes.
EXEC concesiones.sp_Concesion_Alta
    @id_empresa = @id_empresa,
    @id_parque = @id_parque,
    @id_actividad_empresa = @id_actividad_empresa,
    @fecha_inicio = '2026-01-01',
    @fecha_fin = '2026-12-31',
    @monto_mensual = 100000.00,
    @id_concesion_out = @id_concesion OUTPUT;

SELECT 'Concesion creada' AS prueba, *
FROM concesiones.Concesion
WHERE id_concesion = @id_concesion;

-- Resultado esperado: modifica la concesion.
EXEC concesiones.sp_Concesion_Modificar
    @id_concesion = @id_concesion,
    @id_empresa = @id_empresa,
    @id_parque = @id_parque,
    @id_actividad_empresa = @id_actividad_empresa,
    @fecha_inicio = '2026-02-01',
    @fecha_fin = '2027-01-31',
    @monto_mensual = 125000.00;

SELECT 'Concesion modificada' AS prueba, *
FROM concesiones.Concesion
WHERE id_concesion = @id_concesion;

-- Resultado esperado: falla por empresa/parque inexistentes.
BEGIN TRY
    DECLARE @id_concesion_error INT;
    EXEC concesiones.sp_Concesion_Alta
        @id_empresa = -1,
        @id_parque = -1,
        @id_actividad_empresa = @id_actividad_empresa,
        @fecha_inicio = '2026-01-01',
        @fecha_fin = '2026-12-31',
        @monto_mensual = 1000,
        @id_concesion_out = @id_concesion_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Concesion_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Concesion_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: inserta un pago.
EXEC concesiones.sp_Pago_Alta
    @id_concesion = @id_concesion,
    @monto = 125000.00,
    @fecha_pago = '2026-02-10',
    @fecha_limite = '2026-02-15',
    @nro_pago_out = @nro_pago OUTPUT;

SELECT 'Pago creado' AS prueba, *
FROM concesiones.Pago
WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago;

-- Resultado esperado: modifica el pago.
EXEC concesiones.sp_Pago_Modificar
    @id_concesion = @id_concesion,
    @nro_pago = @nro_pago,
    @monto = 130000.00,
    @fecha_pago = '2026-02-11',
    @fecha_limite = '2026-02-15';

SELECT 'Pago modificado' AS prueba, *
FROM concesiones.Pago
WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago;

-- Resultado esperado: falla por monto negativo y fecha limite nula.
BEGIN TRY
    DECLARE @nro_pago_error INT;
    EXEC concesiones.sp_Pago_Alta
        @id_concesion = @id_concesion,
        @monto = -10,
        @fecha_pago = NULL,
        @fecha_limite = NULL,
        @nro_pago_out = @nro_pago_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Pago_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Pago_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: falla la baja de concesion porque tiene pagos registrados.
BEGIN TRY
    EXEC concesiones.sp_Concesion_Baja @id_concesion = @id_concesion;
    PRINT 'ERROR: La prueba de validacion de Concesion_Baja no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Concesion_Baja con pagos: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   5) RRHH.GUARDAPARQUES Y REGISTRO_GUARDAPARQUES
========================================================= */
PRINT '5) RRHH.GUARDAPARQUES Y REGISTRO_GUARDAPARQUES';

-- Resultado esperado: inserta un guardaparques.
EXEC rrhh.sp_Guardaparques_Alta
    @dni = @dni_guardaparques,
    @nombre = 'Guardaparques Test',
    @telefono = '5555-1111',
    @matricula = @matricula_guardaparques,
    @fecha_nac = '1990-01-01',
    @id_guardaparques_out = @id_guardaparques OUTPUT;

SELECT 'Guardaparques creado' AS prueba, *
FROM rrhh.Guardaparques
WHERE id_guardaparques = @id_guardaparques;

-- Resultado esperado: modifica el guardaparques.
EXEC rrhh.sp_Guardaparques_Modificar
    @id_guardaparques = @id_guardaparques,
    @dni = @dni_guardaparques_mod,
    @nombre = 'Guardaparques Test Modificado',
    @telefono = '5555-2222',
    @matricula = @matricula_guardaparques_mod,
    @fecha_nac = '1991-01-01';

SELECT 'Guardaparques modificado' AS prueba, *
FROM rrhh.Guardaparques
WHERE id_guardaparques = @id_guardaparques;

-- Resultado esperado: falla por DNI y matricula obligatorios.
BEGIN TRY
    DECLARE @id_gp_error INT;
    EXEC rrhh.sp_Guardaparques_Alta
        @dni = '',
        @nombre = 'Sin DNI',
        @telefono = NULL,
        @matricula = '',
        @fecha_nac = NULL,
        @id_guardaparques_out = @id_gp_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Guardaparques_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Guardaparques_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: inserta registro laboral del guardaparques.
EXEC rrhh.sp_RegistroGuardaparques_Alta
    @id_parque = @id_parque,
    @id_guardaparques = @id_guardaparques,
    @fecha_ingreso = '2026-03-01',
    @fecha_egreso = NULL,
    @motivo_egreso = NULL,
    @nro_registro_out = @nro_registro OUTPUT;

SELECT 'RegistroGuardaparques creado' AS prueba, *
FROM rrhh.RegistroGuardaparques
WHERE id_parque = @id_parque AND nro_registro = @nro_registro;

-- Resultado esperado: modifica registro laboral.
EXEC rrhh.sp_RegistroGuardaparques_Modificar
    @id_parque = @id_parque,
    @nro_registro = @nro_registro,
    @id_guardaparques = @id_guardaparques,
    @fecha_ingreso = '2026-03-01',
    @fecha_egreso = '2026-04-01',
    @motivo_egreso = 'Reasignacion';

SELECT 'RegistroGuardaparques modificado' AS prueba, *
FROM rrhh.RegistroGuardaparques
WHERE id_parque = @id_parque AND nro_registro = @nro_registro;

-- Resultado esperado: falla por parque y guardaparques inexistentes.
BEGIN TRY
    DECLARE @nro_reg_error INT;
    EXEC rrhh.sp_RegistroGuardaparques_Alta
        @id_parque = -1,
        @id_guardaparques = -1,
        @fecha_ingreso = '2026-01-01',
        @fecha_egreso = NULL,
        @motivo_egreso = NULL,
        @nro_registro_out = @nro_reg_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de RegistroGuardaparques_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion RegistroGuardaparques_Alta: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   6) RRHH.GUIA Y HABILITACION
========================================================= */
PRINT '6) RRHH.GUIA Y HABILITACION';

-- Resultado esperado: inserta un guia.
EXEC rrhh.sp_Guia_Alta
    @dni = @dni_guia,
    @legajo = @legajo_guia,
    @titulo = 'Tecnico en Turismo',
    @nombre = 'Guia Test',
    @especialidad = 'Senderismo',
    @id_guia_out = @id_guia OUTPUT;

SELECT 'Guia creado' AS prueba, *
FROM rrhh.Guia
WHERE id_guia = @id_guia;

-- Resultado esperado: modifica el guia.
EXEC rrhh.sp_Guia_Modificar
    @id_guia = @id_guia,
    @dni = @dni_guia_mod,
    @legajo = @legajo_guia_mod,
    @titulo = 'Licenciado en Turismo',
    @nombre = 'Guia Test Modificado',
    @especialidad = 'Avistaje';

SELECT 'Guia modificado' AS prueba, *
FROM rrhh.Guia
WHERE id_guia = @id_guia;

-- Resultado esperado: falla por DNI, legajo y nombre obligatorios.
BEGIN TRY
    DECLARE @id_guia_error INT;
    EXEC rrhh.sp_Guia_Alta
        @dni = '',
        @legajo = '',
        @titulo = NULL,
        @nombre = '',
        @especialidad = NULL,
        @id_guia_out = @id_guia_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Guia_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Guia_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: inserta habilitacion del guia.
EXEC rrhh.sp_Habilitacion_Alta
    @id_guia = @id_guia,
    @descripcion = 'Habilitacion Test',
    @valida_desde = '2026-01-01',
    @valida_hasta = '2026-12-31',
    @nro_habilitacion_out = @nro_habilitacion OUTPUT;

SELECT 'Habilitacion creada' AS prueba, *
FROM rrhh.Habilitacion
WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion;

-- Resultado esperado: modifica habilitacion.
EXEC rrhh.sp_Habilitacion_Modificar
    @id_guia = @id_guia,
    @nro_habilitacion = @nro_habilitacion,
    @descripcion = 'Habilitacion Test Modificada',
    @valida_desde = '2026-02-01',
    @valida_hasta = '2027-01-31';

SELECT 'Habilitacion modificada' AS prueba, *
FROM rrhh.Habilitacion
WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion;

-- Resultado esperado: falla por guia inexistente.
BEGIN TRY
    DECLARE @nro_hab_error INT;
    EXEC rrhh.sp_Habilitacion_Alta
        @id_guia = -1,
        @descripcion = 'No debe insertar',
        @valida_desde = '2026-01-01',
        @valida_hasta = NULL,
        @nro_habilitacion_out = @nro_hab_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Habilitacion_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Habilitacion_Alta: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   7) ACTIVIDADES.ACTIVIDAD
========================================================= */
PRINT '7) ACTIVIDADES.ACTIVIDAD';

-- Resultado esperado: inserta una actividad asociada al parque y guia.
EXEC actividades.sp_Actividad_Alta
    @id_parque = @id_parque,
    @id_guia = @id_guia,
    @nombre = @nombre_actividad,
    @descripcion = 'Actividad creada por testing',
    @duracion = 90,
    @cupo_maximo = 30,
    @precio = 5000.00,
    @tipo = 'Tour',
    @id_actividad_out = @id_actividad OUTPUT;

SELECT 'Actividad creada' AS prueba, *
FROM actividades.Actividad
WHERE id_actividad = @id_actividad;

-- Resultado esperado: modifica la actividad.
EXEC actividades.sp_Actividad_Modificar
    @id_actividad = @id_actividad,
    @id_parque = @id_parque,
    @id_guia = @id_guia,
    @nombre = @nombre_actividad_mod,
    @descripcion = 'Actividad modificada por testing',
    @duracion = 120,
    @cupo_maximo = 25,
    @precio = 6500.00,
    @tipo = 'Tour',
    @es_valido = 1;

SELECT 'Actividad modificada' AS prueba, *
FROM actividades.Actividad
WHERE id_actividad = @id_actividad;

-- Resultado esperado: falla por parque y guia inexistentes.
BEGIN TRY
    DECLARE @id_act_error INT;
    EXEC actividades.sp_Actividad_Alta
        @id_parque = -1,
        @id_guia = -1,
        @nombre = 'Actividad invalida',
        @descripcion = NULL,
        @duracion = 60,
        @cupo_maximo = 10,
        @precio = 0,
        @tipo = 'Tour',
        @id_actividad_out = @id_act_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Actividad_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Actividad_Alta: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   8) VENTAS.TIPO_VISITANTE Y ENTRADA
========================================================= */
PRINT '8) VENTAS.TIPO_VISITANTE Y ENTRADA';

-- Resultado esperado: inserta tipo visitante.
EXEC ventas.sp_TipoVisitante_Alta
    @descripcion = @descripcion_tipo_visitante,
    @id_tipo_visitante_out = @id_tipo_visitante OUTPUT;

SELECT 'TipoVisitante creado' AS prueba, *
FROM ventas.TipoVisitante
WHERE id_tipo_visitante = @id_tipo_visitante;

-- Resultado esperado: modifica tipo visitante.
EXEC ventas.sp_TipoVisitante_Modificar
    @id_tipo_visitante = @id_tipo_visitante,
    @descripcion = @descripcion_tipo_visitante_mod;

SELECT 'TipoVisitante modificado' AS prueba, *
FROM ventas.TipoVisitante
WHERE id_tipo_visitante = @id_tipo_visitante;

-- Resultado esperado: falla por descripcion obligatoria.
BEGIN TRY
    DECLARE @id_tv_error INT;
    EXEC ventas.sp_TipoVisitante_Alta
        @descripcion = '',
        @id_tipo_visitante_out = @id_tv_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de TipoVisitante_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion TipoVisitante_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: inserta entrada.
EXEC ventas.sp_Entrada_Alta
    @id_parque = @id_parque,
    @id_tipo_visitante = @id_tipo_visitante,
    @precio = 2500.00,
    @id_entrada_out = @id_entrada OUTPUT;

SELECT 'Entrada creada' AS prueba, *
FROM ventas.Entrada
WHERE id_entrada = @id_entrada;

-- Resultado esperado: modifica entrada.
EXEC ventas.sp_Entrada_Modificar
    @id_entrada = @id_entrada,
    @id_parque = @id_parque,
    @id_tipo_visitante = @id_tipo_visitante,
    @precio = 3000.00,
    @es_valido = 1;

SELECT 'Entrada modificada' AS prueba, *
FROM ventas.Entrada
WHERE id_entrada = @id_entrada;

-- Resultado esperado: falla por parque inexistente.
BEGIN TRY
    DECLARE @id_ent_error INT;
    EXEC ventas.sp_Entrada_Alta
        @id_parque = -1,
        @id_tipo_visitante = @id_tipo_visitante,
        @precio = 1000,
        @id_entrada_out = @id_ent_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Entrada_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Entrada_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: falla la baja de parque porque tiene concesion, registro, actividad y entrada asociadas.
BEGIN TRY
    EXEC core.sp_Parque_Baja @id_parque = @id_parque;
    PRINT 'ERROR: La prueba de validacion de Parque_Baja no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Parque_Baja con dependencias: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   9) VENTAS.VISITANTE, VENTA Y DETALLE_VENTA
========================================================= */
PRINT '9) VENTAS.VISITANTE, VENTA Y DETALLE_VENTA';

-- Resultado esperado: inserta visitante.
EXEC ventas.sp_Visitante_Alta
    @dni = @dni_visitante,
    @nombre = 'Visitante Test',
    @id_visitante_out = @id_visitante OUTPUT;

SELECT 'Visitante creado' AS prueba, *
FROM ventas.Visitante
WHERE id_visitante = @id_visitante;

-- Resultado esperado: modifica visitante.
EXEC ventas.sp_Visitante_Modificar
    @id_visitante = @id_visitante,
    @dni = @dni_visitante_mod,
    @nombre = 'Visitante Test Modificado';

SELECT 'Visitante modificado' AS prueba, *
FROM ventas.Visitante
WHERE id_visitante = @id_visitante;

-- Resultado esperado: falla por DNI y nombre obligatorios.
BEGIN TRY
    DECLARE @id_vis_error INT;
    EXEC ventas.sp_Visitante_Alta
        @dni = '',
        @nombre = '',
        @id_visitante_out = @id_vis_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Visitante_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Visitante_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: inserta venta.
EXEC ventas.sp_Venta_Alta
    @id_visitante = @id_visitante,
    @forma_pago = 'Tarjeta',
    @punto_venta = 'Boleteria Test',
    @id_venta_out = @id_venta OUTPUT;

SELECT 'Venta creada' AS prueba, *
FROM ventas.Venta
WHERE id_venta = @id_venta;

-- Resultado esperado: modifica venta.
EXEC ventas.sp_Venta_Modificar
    @id_venta = @id_venta,
    @id_visitante = @id_visitante,
    @forma_pago = 'Efectivo',
    @punto_venta = 'Boleteria Modificada';

SELECT 'Venta modificada' AS prueba, *
FROM ventas.Venta
WHERE id_venta = @id_venta;

-- Resultado esperado: falla por visitante inexistente, forma de pago vacia y punto de venta vacio.
BEGIN TRY
    DECLARE @id_venta_error INT;
    EXEC ventas.sp_Venta_Alta
        @id_visitante = -1,
        @forma_pago = '',
        @punto_venta = '',
        @id_venta_out = @id_venta_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de Venta_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Venta_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: inserta detalle de venta para entrada.
EXEC ventas.sp_DetalleVenta_Alta
    @id_venta = @id_venta,
    @id_entrada = @id_entrada,
    @id_actividad = NULL,
    @cantidad = 2,
    @precio_unitario = 3000.00,
    @fecha_evento = '2026-06-30',
    @nro_item_out = @nro_item OUTPUT;

SELECT 'DetalleVenta creado' AS prueba, *
FROM ventas.DetalleVenta
WHERE id_venta = @id_venta AND nro_item = @nro_item;

-- Resultado esperado: modifica detalle para actividad.
EXEC ventas.sp_DetalleVenta_Modificar
    @id_venta = @id_venta,
    @nro_item = @nro_item,
    @id_entrada = NULL,
    @id_actividad = @id_actividad,
    @cantidad = 1,
    @precio_unitario = 6500.00,
    @fecha_evento = '2026-07-01';

SELECT 'DetalleVenta modificado' AS prueba, *
FROM ventas.DetalleVenta
WHERE id_venta = @id_venta AND nro_item = @nro_item;

-- Resultado esperado: falla porque se informa entrada y actividad al mismo tiempo.
BEGIN TRY
    DECLARE @nro_item_error INT;
    EXEC ventas.sp_DetalleVenta_Alta
        @id_venta = @id_venta,
        @id_entrada = @id_entrada,
        @id_actividad = @id_actividad,
        @cantidad = 1,
        @precio_unitario = 1000.00,
        @fecha_evento = '2026-07-01',
        @nro_item_out = @nro_item_error OUTPUT;
    PRINT 'ERROR: La prueba de validacion de DetalleVenta_Alta no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion DetalleVenta_Alta: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: falla la baja de venta porque tiene items registrados.
BEGIN TRY
    EXEC ventas.sp_Venta_Baja @id_venta = @id_venta;
    PRINT 'ERROR: La prueba de validacion de Venta_Baja no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Venta_Baja con detalle: ' + ERROR_MESSAGE();
END CATCH;

-- Resultado esperado: falla la baja de visitante porque tiene ventas registradas.
BEGIN TRY
    EXEC ventas.sp_Visitante_Baja @id_visitante = @id_visitante;
    PRINT 'ERROR: La prueba de validacion de Visitante_Baja no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Visitante_Baja con ventas: ' + ERROR_MESSAGE();
END CATCH;

/* =========================================================
   10) PRUEBAS DE BAJA EXITOSA EN REGISTROS SIN DEPENDENCIAS
========================================================= */
PRINT '10) PRUEBAS DE BAJA EXITOSA';

-- Pago: Resultado esperado: elimina pago sin error.
EXEC concesiones.sp_Pago_Baja
    @id_concesion = @id_concesion,
    @nro_pago = @nro_pago;

SELECT 'Pago luego de baja, esperado sin filas' AS prueba, *
FROM concesiones.Pago
WHERE id_concesion = @id_concesion AND nro_pago = @nro_pago;

-- DetalleVenta: Resultado esperado: elimina item sin error.
EXEC ventas.sp_DetalleVenta_Baja
    @id_venta = @id_venta,
    @nro_item = @nro_item;

SELECT 'DetalleVenta luego de baja, esperado sin filas' AS prueba, *
FROM ventas.DetalleVenta
WHERE id_venta = @id_venta AND nro_item = @nro_item;

-- Venta: Resultado esperado: ahora puede eliminarse porque ya no tiene items.
EXEC ventas.sp_Venta_Baja @id_venta = @id_venta;
SELECT 'Venta luego de baja, esperado sin filas' AS prueba, *
FROM ventas.Venta
WHERE id_venta = @id_venta;

-- Visitante: Resultado esperado: ahora puede eliminarse porque ya no tiene ventas.
EXEC ventas.sp_Visitante_Baja @id_visitante = @id_visitante;
SELECT 'Visitante luego de baja, esperado sin filas' AS prueba, *
FROM ventas.Visitante
WHERE id_visitante = @id_visitante;

-- Entrada: Resultado esperado: baja logica, queda es_valido = 0.
EXEC ventas.sp_Entrada_Baja @id_entrada = @id_entrada;
SELECT 'Entrada luego de baja logica, esperado es_valido = 0' AS prueba, *
FROM ventas.Entrada
WHERE id_entrada = @id_entrada;

-- Actividad: Resultado esperado: baja logica, queda es_valido = 0.
EXEC actividades.sp_Actividad_Baja @id_actividad = @id_actividad;
SELECT 'Actividad luego de baja logica, esperado es_valido = 0' AS prueba, *
FROM actividades.Actividad
WHERE id_actividad = @id_actividad;

-- Habilitacion: Resultado esperado: elimina habilitacion.
EXEC rrhh.sp_Habilitacion_Baja
    @id_guia = @id_guia,
    @nro_habilitacion = @nro_habilitacion;
SELECT 'Habilitacion luego de baja, esperado sin filas' AS prueba, *
FROM rrhh.Habilitacion
WHERE id_guia = @id_guia AND nro_habilitacion = @nro_habilitacion;

-- RegistroGuardaparques: Resultado esperado: elimina registro.
EXEC rrhh.sp_RegistroGuardaparques_Baja
    @id_parque = @id_parque,
    @nro_registro = @nro_registro;
SELECT 'RegistroGuardaparques luego de baja, esperado sin filas' AS prueba, *
FROM rrhh.RegistroGuardaparques
WHERE id_parque = @id_parque AND nro_registro = @nro_registro;

-- Concesion: Resultado esperado: ahora puede eliminarse porque no tiene pagos.
EXEC concesiones.sp_Concesion_Baja @id_concesion = @id_concesion;
SELECT 'Concesion luego de baja, esperado sin filas' AS prueba, *
FROM concesiones.Concesion
WHERE id_concesion = @id_concesion;

-- Se crean registros independientes para probar bajas directas de tablas maestras sin dependencias.
EXEC concesiones.sp_EmpresaConcesionaria_Alta
    @nombre = @nombre_empresa_baja,
    @telefono = NULL,
    @id_empresa_out = @id_empresa_baja OUTPUT;
EXEC concesiones.sp_EmpresaConcesionaria_Baja @id_empresa = @id_empresa_baja;
SELECT 'Empresa luego de baja, esperado sin filas' AS prueba, *
FROM concesiones.EmpresaConcesionaria
WHERE id_empresa = @id_empresa_baja;

EXEC concesiones.sp_ActividadEmpresa_Alta
    @rubro = @rubro_baja,
    @id_actividad_empresa_out = @id_actividad_empresa_baja OUTPUT;
EXEC concesiones.sp_ActividadEmpresa_Baja @id_actividad_empresa = @id_actividad_empresa_baja;
SELECT 'ActividadEmpresa luego de baja, esperado sin filas' AS prueba, *
FROM concesiones.ActividadEmpresa
WHERE id_actividad_empresa = @id_actividad_empresa_baja;

EXEC rrhh.sp_Guardaparques_Alta
    @dni = @dni_guardaparques_baja,
    @nombre = 'Guardaparques Baja',
    @telefono = NULL,
    @matricula = @matricula_guardaparques_baja,
    @fecha_nac = NULL,
    @id_guardaparques_out = @id_guardaparques_baja OUTPUT;
EXEC rrhh.sp_Guardaparques_Baja @id_guardaparques = @id_guardaparques_baja;
SELECT 'Guardaparques luego de baja, esperado sin filas' AS prueba, *
FROM rrhh.Guardaparques
WHERE id_guardaparques = @id_guardaparques_baja;

EXEC rrhh.sp_Guia_Alta
    @dni = @dni_guia_baja,
    @legajo = @legajo_guia_baja,
    @titulo = NULL,
    @nombre = 'Guia Baja',
    @especialidad = NULL,
    @id_guia_out = @id_guia_baja OUTPUT;
EXEC rrhh.sp_Guia_Baja @id_guia = @id_guia_baja;
SELECT 'Guia luego de baja, esperado sin filas' AS prueba, *
FROM rrhh.Guia
WHERE id_guia = @id_guia_baja;

EXEC ventas.sp_TipoVisitante_Alta
    @descripcion = @descripcion_tipo_baja,
    @id_tipo_visitante_out = @id_tipo_visitante_baja OUTPUT;
EXEC ventas.sp_TipoVisitante_Baja @id_tipo_visitante = @id_tipo_visitante_baja;
SELECT 'TipoVisitante luego de baja, esperado sin filas' AS prueba, *
FROM ventas.TipoVisitante
WHERE id_tipo_visitante = @id_tipo_visitante_baja;

-- Parque: se crea parque sin dependencias para probar baja fisica exitosa.
EXEC core.sp_Parque_Alta
    @nombre = @nombre_parque_baja,
    @descripcion = 'Parque sin dependencias',
    @tipo = 'Reserva',
    @ubicacion = 'Ubicacion Baja',
    @superficie = 10,
    @id_parque_out = @id_parque_baja OUTPUT;
EXEC core.sp_Parque_Baja @id_parque = @id_parque_baja;
SELECT 'Parque luego de baja, esperado sin filas' AS prueba, *
FROM core.Parque
WHERE id_parque = @id_parque_baja;

/* =========================================================
   11) VALIDACIONES DE BAJA SOBRE IDS INEXISTENTES
========================================================= */
PRINT '11) VALIDACIONES DE BAJA SOBRE IDS INEXISTENTES';

-- Resultado esperado: cada baja falla porque el registro no existe.
BEGIN TRY
    EXEC ventas.sp_DetalleVenta_Baja @id_venta = -1, @nro_item = -1;
    PRINT 'ERROR: DetalleVenta_Baja inexistente no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion DetalleVenta_Baja inexistente: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC actividades.sp_Actividad_Baja @id_actividad = -1;
    PRINT 'ERROR: Actividad_Baja inexistente no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Actividad_Baja inexistente: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    EXEC core.sp_Parque_Baja @id_parque = -1;
    PRINT 'ERROR: Parque_Baja inexistente no fallo.';
END TRY
BEGIN CATCH
    PRINT 'OK validacion Parque_Baja inexistente: ' + ERROR_MESSAGE();
END CATCH;

PRINT '=========================================================';
PRINT 'TEST ABM - FIN. Se hace ROLLBACK para no persistir datos de prueba.';
PRINT '=========================================================';

ROLLBACK TRANSACTION;
GO
