# Guia de estilo PL/SQL - Estandar de la casa

Extraida del paquete modelo WS$MAXTRACKER03. Es la norma que el cuaderno debe aplicar.

## 1. Convencion de nombres

### 1.1 Objetos de base de datos

| Objeto | Patron | Ejemplo |
|---|---|---|
| Paquete | `WS$<MODULO><NN>` | `WS$MAXTRACKER03` |
| Procedimiento publico | `WSPR_<ACCION>` | `WSPR_RESUMEN_DIARIO` |
| Funcion publica | `WSFN_<ACCION>` | `WSFN_HAVERSINE_KM` |
| Tabla | `<SISTEMA>_T<NOMBRE>` | `WSMT_TVIAJES`, `WSMT_TEVENTOS` |

Limite Oracle 11g: 30 caracteres por identificador.

### 1.2 Parametros

| Prefijo | Uso | Ejemplo |
|---|---|---|
| `pi_` | Entrada (IN) | `pi_fecha` |
| `po_` | Salida (OUT) | `po_cantidad` |
| `pio_` | Entrada/Salida (IN OUT) | `pio_estado` |

Nota: `po_` y `pio_` se infieren por simetria con `pi_` (el modelo solo usa IN). Ajustar si la casa usa otro prefijo.

Despues del prefijo se usa el mismo prefijo semantico de la columna cuando aplica (ej. `pi_nlat1`, `pi_xevento`, `pi_fh_ini`).

### 1.3 Variables, constantes y cursores (prefijo semantico)

| Prefijo | Significado | Tipo habitual | Ejemplo |
|---|---|---|---|
| `k_` | Constante de negocio (con CONSTANT) o cantidad/acumulador (km, horas) | NUMBER / BOOLEAN | `k_horas_corte_inactividad`, `k_km_recorridos` |
| `sn_` | Indicador Si/No | BOOLEAN | `sn_en_viaje` |
| `f_` | Fecha sin hora (dia) | DATE | `f_viaje` |
| `fh_` | Fecha y hora | DATE | `fh_ini_viaje` |
| `x_` | Texto descriptivo | VARCHAR2 | `x_conductor`, `x_evento_ant` |
| `t_` | Tipo / clasificacion | VARCHAR2 | `t_evento` |
| `n_` | Identificador o numero de referencia | NUMBER | `n_vehiculo_id_ant` |
| `v_` | Valor numerico de calculo (coordenadas, tramos) | NUMBER | `v_lat_ant`, `v_seg_horas` |
| `vl_` | Variable local de control / trazabilidad | VARCHAR2 | `vl_paso` |
| `vn_` | Contador de control | NUMBER / PLS_INTEGER | `vn_viajes` |
| `l_` | Variable local dentro de un subprograma local | cualquiera | `l_totales` |
| `cur_` | Cursor explicito | - | `cur_eventos` |
| `r` | Registro del cursor FOR | - | `for r in cur_eventos` |
| `fn_` | Funcion local (dentro del procedimiento) | - | `fn_es_movimiento` |
| `pr_` | Procedimiento local | - | `pr_insertar_viaje` |

Reglas:
- Anclar tipos con `%TYPE` / `%ROWTYPE` cuando la variable refleja una columna (`wsmt_teventos.x_conductor%type`).
- Los alias del cursor usan el mismo prefijo semantico que las variables (`f_evento as fh_evento`).
- Sufijo `_ant` = valor del evento/registro anterior. Sufijo `_ult_<x>` = ultimo valor con la condicion `<x>`.

## 2. Formato

- Firma publica en MAYUSCULAS con parentesis y comas al inicio de linea:
  ```
  PROCEDURE WSPR_EJEMPLO
   (PI_FECHA DATE
   ,PI_ID    NUMBER
   )
   IS
  ```
- Cuerpo en minusculas. Indentacion de 3 espacios.
- Alinear verticalmente `:=`, `=>`, tipos de datos y comentarios de linea.
- `AND` / `OR` al inicio de la linea, alineados bajo la condicion.
- Llamadas con notacion nombrada (`pi_x => valor`), un parametro por linea.
- Listas de columnas de INSERT/SELECT: una columna por linea.
- Literales de listas `IN (...)`: un valor por linea cuando son mas de dos.
- Sin `dbms_output` de depuracion ni bloques de codigo comentado en la version final.

## 3. Estructura de un procedimiento / funcion

1. Firma.
2. Bloque de documentacion tecnica `/* ... */` con las 15 secciones (ver punto 4).
3. `PARAMETROS DE NEGOCIO` (constantes `k_`).
4. Cursores.
5. Variables agrupadas por bloque tematico, cada grupo con un banner corto:
   `ESTADO DEL ... EN CURSO`, `FOTO DE ...`, `ESTADO DEL EVENTO ANTERIOR`, control.
6. Subprogramas locales: primero funciones `fn_`, luego procedimientos `pr_`, cada uno con banner explicativo.
7. `begin` con pasos numerados.
8. `exception` estandar.

### Banners de comentario

- Bloque principal del cuerpo:
  ```
  /*===================================================================
  3) TITULO DEL PASO
  Explicacion breve. Referencias a codigos de cambio (C1, B2...).
  ===================================================================*/
  ```
- Sub-bloque:
  ```
  /*-------------------------------------------------------------------
  3.a) SUBTITULO
  -------------------------------------------------------------------*/
  ```
- Comentario de linea solo para aclarar un valor o referenciar un cambio: `-- B7: rango sargable`.

## 4. Encabezado de documentacion (15 secciones)

```
DOCUMENTACION TECNICA
  Paquete / Procedimiento / Base de Datos / Modulo / Version / Autor
  Historial (Mes AAAA + ticket + descripcion)
1.  PROPOSITO
2.  SIGNATURA (firma, parametros, requisitos de estructura)
3.  PARAMETROS DE NEGOCIO (CONSTANTES)
4.  VARIABLES PRINCIPALES (agrupadas igual que en el codigo)
5.  SUBPROGRAMAS LOCALES
6.  FUENTE DE DATOS (tablas, columnas, filtros, orden, indice recomendado)
7.  FLUJO DE EJECUCION (pasos numerados, coinciden con los banners del cuerpo)
8.  LOGICA DE NEGOCIO (reglas de apertura/cierre/calculo)
9.  MANEJO DE ERRORES Y CASOS BORDE
10. DEPENDENCIAS (tablas y objetos invocados)
11. CONSIDERACIONES DE DISENO
12. CORRECCIONES APLICADAS (agrupadas por fecha, con codigo R/O/F/B/C/D y ticket)
13. LIMITACIONES CONOCIDAS
14. EJEMPLO DE INVOCACION
15. VERIFICACION SUGERIDA EN TEST (consultas concretas)
```

Reglas del encabezado:
- Sin tildes (compatibilidad de juego de caracteres).
- La documentacion debe coincidir con el codigo: si una constante vale 3, el texto no puede decir 8.
- `Version` = mes/anio del ultimo cambio del Historial.
- Funciones chicas (utilitarias) pueden usar la forma reducida del modelo `WSFN_HAVERSINE_KM`: OBJETIVO, CONTEXTO FUNCIONAL, RETORNO, SUPUESTOS, NOTAS.

## 5. Transacciones y errores

- `vl_paso := '<descripcion del paso>';` antes de cada paso relevante.
- Contadores de control (`vn_...`) para informar avance en el log.
- Handler estandar:
  ```
  exception
     when others then
        rollback;
        ws$maxtracker.ws_insert_log(
           pi_proceso => '<PAQUETE>.<PROCEDIMIENTO>',
           pi_datos   => '<parametros clave>' || ' | Paso: ' || vl_paso,
           pi_sqlerrm => sqlerrm || ' | ' || dbms_utility.format_error_backtrace);
        commit;   -- persistir el log luego del rollback
        raise;
  ```
- Prohibido `when others then null` o terminar "en verde" con datos incompletos.
- COMMIT: post-DELETE de re-proceso (si aplica) y uno al final. Nunca dentro de loops.

## 6. Codigos de cambio

| Codigo | Significado |
|---|---|
| `R<n>` | Refactor sin cambio funcional |
| `O<n>` | Optimizacion de rendimiento |
| `F<n>` | Cambio funcional (solo si el usuario lo aprueba) |
| `B<n>`, `C<n>`, `D<n>` | Codigos historicos del modelo (bugs, cambios de negocio, ajustes de constantes) |

Cada codigo aparece en el comentario del bloque modificado y en la seccion 12.
