PROCEDURE WSPR_<NOMBRE>
 (PI_<PARAM1> <TIPO>
 ,PI_<PARAM2> <TIPO>
 )
 IS
/*
============================================================
DOCUMENTACION TECNICA
============================================================

Paquete       : WS$<MODULO><NN>
Procedimiento : WSPR_<NOMBRE>
Base de Datos : Oracle Database 11g
Modulo        : <descripcion del modulo>
Version       : <MES AAAA>
Autor         : <AUTOR>

Historial     : <MES AAAA>
                    <TICKET> - <descripcion del cambio>

============================================================
1. PROPOSITO
============================================================
<Que hace, que genera, en que se basa el calculo.>

============================================================
2. SIGNATURA
============================================================

PROCEDURE wspr_<nombre>(
    pi_<param1> IN <tipo>,
    pi_<param2> IN <tipo>
);

Parametros:
- PI_<PARAM1> : <descripcion>
- PI_<PARAM2> : <descripcion>

Requisito de estructura:
- <columnas / indices / grants necesarios, o "Ninguno">

============================================================
3. PARAMETROS DE NEGOCIO (CONSTANTES)
============================================================

k_<nombre>   <TIPO> := <valor>
   <significado y unidad>

============================================================
4. VARIABLES PRINCIPALES
============================================================

<GRUPO 1>
<variable>   <TIPO> -> <descripcion>

CONTROL
vl_paso      VARCHAR2 -> Trazabilidad del paso actual
vn_<conteo>  NUMBER   -> <descripcion>

============================================================
5. SUBPROGRAMAS LOCALES
============================================================

fn_<nombre>(<params>) RETURN <tipo>
   <descripcion>

pr_<nombre>(<params>)
   <descripcion>

============================================================
6. FUENTE DE DATOS
============================================================

Tabla origen: <TABLA>

Columnas leidas:
- <COLUMNA>

Filtros:
- <predicado> (indicar si es sargable)

Orden:
- <columnas>

Indice recomendado:
- <TABLA> (<COLUMNAS>)

============================================================
7. FLUJO DE EJECUCION
============================================================

1) <paso>
2) <paso>
   2.1) <sub-paso>
3) COMMIT final

============================================================
8. LOGICA DE NEGOCIO
============================================================

<REGLA>:
- <condicion>

============================================================
9. MANEJO DE ERRORES Y CASOS BORDE
============================================================

- <caso>:
  <como se resuelve>

- Falla durante el proceso:
  ROLLBACK del trabajo parcial, registro en el log de
  errores y RAISE.

============================================================
10. DEPENDENCIAS
============================================================

<TABLA / OBJETO>              -> <uso>

============================================================
11. CONSIDERACIONES DE DISENO
============================================================

- <decision y motivo>

============================================================
12. CORRECCIONES APLICADAS
============================================================

<MES AAAA> - NORMALIZACION <TICKET>
R1) <refactor sin cambio funcional>
O1) <optimizacion>
F1) <cambio funcional PROPUESTO - no aplicado / aplicado a pedido>

============================================================
13. LIMITACIONES CONOCIDAS
============================================================

- <limitacion>

============================================================
14. EJEMPLO DE INVOCACION
============================================================

BEGIN

  ws$<modulo><nn>.wspr_<nombre>(
    pi_<param1> => <valor>,
    pi_<param2> => <valor>
  );

END;

============================================================
15. VERIFICACION SUGERIDA EN TEST
============================================================

- <verificacion>:
    SELECT ...

============================================================

*/

      /*----------------------------------------------------------------------
      PARAMETROS DE NEGOCIO
      ----------------------------------------------------------------------*/
      k_<nombre>        constant <tipo> := <valor>;   -- <comentario>

      cursor cur_<nombre> is
      select <columna> as <alias_con_prefijo>
        from <tabla>
       where <columna_fecha> >= trunc(pi_<fecha>)      -- rango sargable
         and <columna_fecha> <  trunc(pi_<fecha>) + 1
       order by <columnas>;

      /*----------------------------------------------------------------------
      <GRUPO DE VARIABLES>
      ----------------------------------------------------------------------*/
      <variable>        <tabla>.<columna>%type;

      /*----------------------------------------------------------------------
      CONTROL
      ----------------------------------------------------------------------*/
      vl_paso           varchar2(100) := 'Inicio <proceso>';
      vn_<conteo>       pls_integer   := 0;

      /*----------------------------------------------------------------------
      <Descripcion de la funcion local>
      ----------------------------------------------------------------------*/
      function fn_<nombre> (
         pi_<param> <tipo>
      ) return <tipo> is
      begin
         return <expresion>;
      end fn_<nombre>;

      /*----------------------------------------------------------------------
      <Descripcion del procedimiento local>
      ----------------------------------------------------------------------*/
      procedure pr_<nombre> (
         pi_<param> in <tipo>
      ) is
         l_<var> <tipo>;
      begin
         null;
      end pr_<nombre>;

   begin

      /*===================================================================
      1) <TITULO DEL PASO>
      <explicacion>
      ===================================================================*/
      vl_paso := '<descripcion del paso 1>';

      /*===================================================================
      2) <TITULO DEL PASO>
      ===================================================================*/
      vl_paso := '<descripcion del paso 2>';
      for r in cur_<nombre> loop

         /*----------------------------------------------------------------
         2.a) <SUB-PASO>
         ----------------------------------------------------------------*/
         null;

      end loop;

      commit;

   exception
      when others then
         rollback;
         ws$maxtracker.ws_insert_log(
            pi_proceso => 'WS$<MODULO><NN>.WSPR_<NOMBRE>',
            pi_datos   => '<Param> ' || to_char(pi_<param1>)
                          || ' | Paso: ' || vl_paso,
            pi_sqlerrm => sqlerrm || ' | ' || dbms_utility.format_error_backtrace);
         commit;   -- persistir el log luego del rollback
         raise;
   end wspr_<nombre>;
