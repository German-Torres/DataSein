# Checklist de optimizacion Oracle PL/SQL (11g, con notas 19c)

Evaluar cada punto sobre el codigo recibido. Reportar en la tabla OPTIMIZACIONES solo los que apliquen.
Marcar [19c] lo que no compila o no existe en 11g.

## 1. SQL dentro del PL/SQL (mayor impacto)

| # | Revisar | Reemplazar por |
|---|---|---|
| S1 | Funciones sobre columnas indexadas en el WHERE: `trunc(f_col) = x`, `to_char(f_col,'YYYYMMDD') = x`, `upper(col) = x`, concatenaciones `col1 || '_' || col2 in (...)` | Rango sargable `f_col >= trunc(x) and f_col < trunc(x) + 1`; comparar columnas por separado; indice basado en funcion si no se puede evitar |
| S2 | `IN (select distinct ...)` | `EXISTS` correlacionado o `IN` sin `DISTINCT` (el optimizador ya hace semi-join) |
| S3 | Subconsulta sin filtro sobre tablas grandes (full scan del historico) | Acotar por el mismo rango de fechas / claves del proceso |
| S4 | `select count(*) into ...; if v > 0` para saber si existe | `exists` o `select 1 ... where rownum = 1` |
| S5 | SELECT dentro de un loop por cada fila (patron N+1) | JOIN en el cursor principal, o cargar en coleccion indexada antes del loop |
| S6 | Loop que compara fila actual con anterior | Funciones analiticas `LAG/LEAD/SUM() OVER (PARTITION BY ... ORDER BY ...)` cuando la logica lo permita |
| S7 | INSERT/UPDATE fila a fila que podria ser una sola sentencia | `INSERT ... SELECT`, `MERGE`, `UPDATE` set-based |
| S8 | UPDATE + INSERT condicional ("si existe actualizo, si no inserto") | `MERGE` |
| S9 | Conversiones implicitas (VARCHAR2 vs NUMBER, DATE vs texto) | Tipos correctos y `to_date`/`to_number` con mascara explicita |
| S10 | `select *` | Solo las columnas usadas |
| S11 | `NVL` / `UPPER` repetidos sobre la misma expresion | Calcular una vez en el cursor (alias) |
| S12 | `ORDER BY` innecesario o `DISTINCT` para "tapar" duplicados de un JOIN mal hecho | Corregir el JOIN |

## 2. PL/SQL

| # | Revisar | Reemplazar por |
|---|---|---|
| P1 | DML fila a fila en loops grandes | `BULK COLLECT ... LIMIT 1000` + `FORALL` (11g OK). Con `SAVE EXCEPTIONS` si se necesita continuar ante errores |
| P2 | `COMMIT` dentro del loop | Un COMMIT al final (evita ORA-01555 y sobrecarga de log) |
| P3 | Contadores e indices `NUMBER` | `PLS_INTEGER` (o `SIMPLE_INTEGER` si nunca es NULL) |
| P4 | Calculo constante repetido por fila (ej. `ACOS(-1)/180`) | Constante `k_` calculada una sola vez |
| P5 | Funciones deterministicas invocadas muchas veces | `DETERMINISTIC`; `RESULT_CACHE` para lookups de tablas poco cambiantes (11g OK). [19c] `PRAGMA UDF` si se llama desde SQL |
| P6 | Parametros OUT / IN OUT grandes (colecciones, CLOB) | `NOCOPY` |
| P7 | SQL dinamico concatenando valores | `EXECUTE IMMEDIATE ... USING` (bind variables) |
| P8 | Variables sin anclar | `%TYPE` / `%ROWTYPE` |
| P9 | Cursores explicitos con OPEN/FETCH/CLOSE manual sin necesidad | Cursor FOR (hace bulk de 100 filas implicito desde 10g) |
| P10 | Funcion local que se evalua varias veces con el mismo argumento en la misma iteracion | Guardar resultado en variable booleana de la iteracion |
| P11 | IF/ELSIF largos sobre el mismo valor | `CASE` |
| P12 | Codigo muerto, variables sin uso, `dbms_output` de debug | Eliminar |

## 3. Robustez y mantenimiento (no es rendimiento, pero se reporta)

| # | Revisar | Accion |
|---|---|---|
| M1 | `when others then null` o handler que no hace `raise` | Handler estandar (rollback + log + commit + raise) |
| M2 | NULL no contemplado en comparaciones (`a <> b` con NULL) | `nvl`, `is null`, o logica explicita |
| M3 | Numeros magicos | Constante `k_` en PARAMETROS DE NEGOCIO |
| M4 | Formulas duplicadas en varios lugares | Un subprograma local unico (como `pr_insertar_viaje`) |
| M5 | Documentacion que no coincide con el codigo | Corregir la documentacion |
| M6 | Falta de trazabilidad | `vl_paso` por paso; opcional `dbms_application_info.set_module / set_action` para ver el paso en `v$session` mientras corre (11g OK) |

## 4. Exclusivo 19c (listar aparte con [19c])

- `FETCH FIRST n ROWS ONLY` en lugar de `rownum`.
- `WITH FUNCTION` en SQL y `PRAGMA UDF`.
- Identificadores de hasta 128 caracteres.
- `LISTAGG ... ON OVERFLOW TRUNCATE`, `LISTAGG(DISTINCT ...)`.
- Columnas `IDENTITY` en lugar de secuencia + trigger.
- `VALIDATE_CONVERSION`, `TO_DATE(... DEFAULT NULL ON CONVERSION ERROR)`.
- `JSON_TABLE`, `JSON_OBJECT` (util para servicios Node.js).
- `ACCESSIBLE BY` para restringir quien invoca un paquete.

## 5. Formato de cada propuesta

Para cada optimizacion indicar:
- Codigo `O<n>` y regla del checklist (ej. `O2 - S1`).
- Antes / despues (fragmento corto).
- Beneficio esperado (ej. "evita full scan de WSMT_TEVENTOS").
- Si cambia o no el resultado (R o F).
- Compatible 11g: Si / No.
