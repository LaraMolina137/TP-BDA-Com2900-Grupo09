/* =========================================================
Universidad Nacional de La Matanza
Materia: Bases de Datos Aplicada
Grupo 09: 
- Molina, Lara Araceli 40187938
- Lopez, Julian Leonel 39712927
- Caceres, Facundo Tomás 46441605
- Puerto, Facundo Nahuel 44597219
Fecha: 2026-06-23
Objetivo: Script de creación de la base de datos

   ========================================================= */

IF DB_ID('ParqueNacionalDB') IS NULL
BEGIN
    CREATE DATABASE ParqueNacionalDB;
END;
GO

USE ParqueNacionalDB;
GO

/* =========================================================
   ESQUEMAS
   ========================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'core')
BEGIN
    EXEC('CREATE SCHEMA core');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'concesiones')
BEGIN
    EXEC('CREATE SCHEMA concesiones');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rrhh')
BEGIN
    EXEC('CREATE SCHEMA rrhh');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'actividades')
BEGIN
    EXEC('CREATE SCHEMA actividades');
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ventas')
BEGIN
    EXEC('CREATE SCHEMA ventas');
END;
GO

/* =========================================================
   CORE
   ========================================================= */

IF OBJECT_ID('core.Parque', 'U') IS NULL
BEGIN
    CREATE TABLE core.Parque (
        id_parque INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(150) NOT NULL,
        tipo VARCHAR(50) NOT NULL,
        ubicacion VARCHAR(200) NOT NULL,
        superficie DECIMAL(12,2) NULL,

        CONSTRAINT chk_parque_superficie
            CHECK (superficie IS NULL OR superficie >= 0)
    );
END;
GO

/* =========================================================
   CONCESIONES
   ========================================================= */

IF OBJECT_ID('concesiones.EmpresaConcesionaria', 'U') IS NULL
BEGIN
    CREATE TABLE concesiones.EmpresaConcesionaria (
        id_empresa INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(150) NOT NULL,
        telefono VARCHAR(30) NULL
    );
END;
GO

IF OBJECT_ID('concesiones.ActividadEmpresa', 'U') IS NULL
BEGIN
    CREATE TABLE concesiones.ActividadEmpresa (
        id_actividad_empresa INT IDENTITY(1,1) PRIMARY KEY,
        rubro VARCHAR(150) NOT NULL,

        CONSTRAINT uq_actividad_empresa_rubro
            UNIQUE (rubro)
    );
END;
GO

IF OBJECT_ID('concesiones.Concesion', 'U') IS NULL
BEGIN
    CREATE TABLE concesiones.Concesion (
        id_concesion INT IDENTITY(1,1) PRIMARY KEY,
        id_empresa INT NOT NULL,
        id_parque INT NOT NULL,
        id_actividad_empresa INT NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NULL,
        monto_mensual DECIMAL(12,2) NOT NULL DEFAULT 0,

        CONSTRAINT fk_concesion_empresa
            FOREIGN KEY (id_empresa)
            REFERENCES concesiones.EmpresaConcesionaria(id_empresa),

        CONSTRAINT fk_concesion_parque
            FOREIGN KEY (id_parque)
            REFERENCES core.Parque(id_parque),

        CONSTRAINT fk_concesion_actividad_empresa
            FOREIGN KEY (id_actividad_empresa)
            REFERENCES concesiones.ActividadEmpresa(id_actividad_empresa),

        CONSTRAINT chk_concesion_fechas
            CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),

        CONSTRAINT chk_concesion_monto
            CHECK (monto_mensual >= 0)
    );
END;
GO

IF OBJECT_ID('concesiones.Pago', 'U') IS NULL
BEGIN
    CREATE TABLE concesiones.Pago (
        id_concesion INT NOT NULL,
        nro_pago INT IDENTITY(1,1) NOT NULL,
        monto DECIMAL(12,2) NOT NULL,
        fecha_pago DATE NULL,
        fecha_limite DATE NOT NULL,

        CONSTRAINT pk_pago
            PRIMARY KEY (id_concesion, nro_pago),

        CONSTRAINT fk_pago_concesion
            FOREIGN KEY (id_concesion)
            REFERENCES concesiones.Concesion(id_concesion),

        CONSTRAINT chk_pago_monto
            CHECK (monto >= 0)
    );
END;
GO

/* =========================================================
   RECURSOS HUMANOS
   ========================================================= */

IF OBJECT_ID('rrhh.Guardaparques', 'U') IS NULL
BEGIN
    CREATE TABLE rrhh.Guardaparques (
        id_guardaparques INT IDENTITY(1,1) PRIMARY KEY,
        dni VARCHAR(20) NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        telefono VARCHAR(30) NULL,
        matricula VARCHAR(50) NOT NULL,
        fecha_nac DATE NULL
    );
END;
GO

IF OBJECT_ID('rrhh.RegistroGuardaparques', 'U') IS NULL
BEGIN
    CREATE TABLE rrhh.RegistroGuardaparques (
        id_parque INT NOT NULL,
        nro_registro INT IDENTITY(1,1) NOT NULL,
        id_guardaparques INT NOT NULL,
        fecha_ingreso DATE NOT NULL,
        fecha_egreso DATE NULL,
        motivo_egreso VARCHAR(200) NULL,

        CONSTRAINT pk_registro_guardaparques
            PRIMARY KEY (id_parque, nro_registro),

        CONSTRAINT fk_registro_parque
            FOREIGN KEY (id_parque)
            REFERENCES core.Parque(id_parque),

        CONSTRAINT fk_registro_guardaparques
            FOREIGN KEY (id_guardaparques)
            REFERENCES rrhh.Guardaparques(id_guardaparques),

        CONSTRAINT chk_registro_fechas
            CHECK (fecha_egreso IS NULL OR fecha_egreso >= fecha_ingreso)
    );
END;
GO

IF OBJECT_ID('rrhh.Guia', 'U') IS NULL
BEGIN
    CREATE TABLE rrhh.Guia (
        id_guia INT IDENTITY(1,1) PRIMARY KEY,
        dni VARCHAR(20) NOT NULL,
        legajo VARCHAR(50) NOT NULL,
        titulo VARCHAR(100) NULL,
        nombre VARCHAR(100) NOT NULL,
        especialidad VARCHAR(100) NULL
    );
END;
GO

IF OBJECT_ID('rrhh.Habilitacion', 'U') IS NULL
BEGIN
    CREATE TABLE rrhh.Habilitacion (
        id_guia INT NOT NULL,
        nro_habilitacion INT IDENTITY(1,1) NOT NULL,
        descripcion VARCHAR(150) NOT NULL,
        valida_desde DATE NOT NULL,
        valida_hasta DATE NULL,

        CONSTRAINT pk_habilitacion
            PRIMARY KEY (id_guia, nro_habilitacion),

        CONSTRAINT fk_habilitacion_guia
            FOREIGN KEY (id_guia)
            REFERENCES rrhh.Guia(id_guia),

        CONSTRAINT chk_habilitacion_fechas
            CHECK (valida_hasta IS NULL OR valida_hasta >= valida_desde)
    );
END;
GO

/* =========================================================
   ACTIVIDADES
   ========================================================= */

IF OBJECT_ID('actividades.Actividad', 'U') IS NULL
BEGIN
    CREATE TABLE actividades.Actividad (
        id_actividad INT IDENTITY(1,1) PRIMARY KEY,
        id_parque INT NOT NULL,
        id_guia INT NULL,
        nombre VARCHAR(100) NOT NULL,
        descripcion VARCHAR(200) NULL,
        duracion INT NOT NULL,
        cupo_maximo INT NOT NULL,
        precio DECIMAL(12,2) NOT NULL DEFAULT 0,
        stamp DATETIME NOT NULL DEFAULT GETDATE(),
        es_valido BIT NOT NULL DEFAULT 1,
        tipo VARCHAR(20) NOT NULL,

        CONSTRAINT fk_actividad_parque
            FOREIGN KEY (id_parque)
            REFERENCES core.Parque(id_parque),

        CONSTRAINT fk_actividad_guia
            FOREIGN KEY (id_guia)
            REFERENCES rrhh.Guia(id_guia),

        CONSTRAINT chk_actividad_tipo
            CHECK (tipo IN ('Tour', 'Atraccion')),

        CONSTRAINT chk_actividad_duracion
            CHECK (duracion > 0),

        CONSTRAINT chk_actividad_cupo
            CHECK (cupo_maximo >= 0),

        CONSTRAINT chk_actividad_precio
            CHECK (precio >= 0)
    );
END;
GO

/* =========================================================
   VENTAS
   ========================================================= */

IF OBJECT_ID('ventas.TipoVisitante', 'U') IS NULL
BEGIN
    CREATE TABLE ventas.TipoVisitante (
        id_tipo_visitante INT IDENTITY(1,1) PRIMARY KEY,
        descripcion VARCHAR(100) NOT NULL,

        CONSTRAINT uq_tipo_visitante_descripcion
            UNIQUE (descripcion)
    );
END;
GO

IF OBJECT_ID('ventas.Entrada', 'U') IS NULL
BEGIN
    CREATE TABLE ventas.Entrada (
        id_entrada INT IDENTITY(1,1) PRIMARY KEY,
        id_parque INT NOT NULL,
        id_tipo_visitante INT NOT NULL,
        precio DECIMAL(12,2) NOT NULL DEFAULT 0,
        stamp DATETIME NOT NULL DEFAULT GETDATE(),
        es_valido BIT NOT NULL DEFAULT 1,

        CONSTRAINT fk_entrada_parque
            FOREIGN KEY (id_parque)
            REFERENCES core.Parque(id_parque),

        CONSTRAINT fk_entrada_tipo_visitante
            FOREIGN KEY (id_tipo_visitante)
            REFERENCES ventas.TipoVisitante(id_tipo_visitante),

        CONSTRAINT chk_entrada_precio
            CHECK (precio >= 0)
    );
END;
GO

IF OBJECT_ID('ventas.Visitante', 'U') IS NULL
BEGIN
    CREATE TABLE ventas.Visitante (
        id_visitante INT IDENTITY(1,1) PRIMARY KEY,
        dni VARCHAR(20) NOT NULL,
        nombre VARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('ventas.Venta', 'U') IS NULL
BEGIN
    CREATE TABLE ventas.Venta (
        id_venta INT IDENTITY(1,1) PRIMARY KEY,
        id_visitante INT NOT NULL,
        fecha_venta DATETIME NOT NULL DEFAULT GETDATE(),
        forma_pago VARCHAR(50) NOT NULL,
        punto_venta VARCHAR(100) NOT NULL,

        CONSTRAINT fk_venta_visitante
            FOREIGN KEY (id_visitante)
            REFERENCES ventas.Visitante(id_visitante)
    );
END;
GO

IF OBJECT_ID('ventas.DetalleVenta', 'U') IS NULL
BEGIN
    CREATE TABLE ventas.DetalleVenta (
        id_venta INT NOT NULL,
        nro_item INT IDENTITY(1,1) NOT NULL,
        id_entrada INT NULL,
        id_actividad INT NULL,
        cantidad INT NOT NULL,
        precio_unitario DECIMAL(12,2) NOT NULL,
        fecha_evento DATE NULL,

        CONSTRAINT pk_detalle_venta
            PRIMARY KEY (id_venta, nro_item),

        CONSTRAINT fk_detalle_venta
            FOREIGN KEY (id_venta)
            REFERENCES ventas.Venta(id_venta),

        CONSTRAINT fk_detalle_entrada
            FOREIGN KEY (id_entrada)
            REFERENCES ventas.Entrada(id_entrada),

        CONSTRAINT fk_detalle_actividad
            FOREIGN KEY (id_actividad)
            REFERENCES actividades.Actividad(id_actividad),

        CONSTRAINT chk_detalle_cantidad
            CHECK (cantidad > 0),

        CONSTRAINT chk_detalle_precio_unitario
            CHECK (precio_unitario >= 0),

        CONSTRAINT chk_detalle_entrada_o_actividad
            CHECK (
                (id_entrada IS NOT NULL AND id_actividad IS NULL)
                OR
                (id_entrada IS NULL AND id_actividad IS NOT NULL)
            )
    );
END;
GO
