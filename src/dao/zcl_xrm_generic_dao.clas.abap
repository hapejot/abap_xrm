CLASS zcl_xrm_generic_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_xrm_dao .

    METHODS constructor
      IMPORTING
        !iv_table TYPE string .
    CLASS-METHODS test_perf
      EXPORTING
        ev_t0 TYPE i
        ev_t1 TYPE i .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mv_table TYPE string .

    CLASS-METHODS prepare_guid_1
      CHANGING
        !cs_row     TYPE any
      RETURNING
        VALUE(r_id) TYPE zrowid.
    CLASS-METHODS prepare_guid_2
      CHANGING
        !cs_row TYPE any .
ENDCLASS.



CLASS zcl_xrm_generic_dao IMPLEMENTATION.


  METHOD constructor.
    mv_table = iv_table.
  ENDMETHOD.


  METHOD prepare_guid_1.

    ASSIGN COMPONENT 'ID' OF STRUCTURE cs_row TO FIELD-SYMBOL(<id>).
    IF <id> IS INITIAL.
      CALL FUNCTION 'GUID_CREATE'
        IMPORTING
          ev_guid_32 = <id>.    " Guid of length 32 (CHAR Format) Uppper Case
    ENDIF.
    r_id = <id>.
  ENDMETHOD.


  METHOD prepare_guid_2.
    DATA: BEGIN OF ls_row,
            id TYPE zrowid,
          END OF ls_row.

    MOVE-CORRESPONDING cs_row TO ls_row.
    IF ls_row-id IS INITIAL.
      CALL FUNCTION 'GUID_CREATE'
        IMPORTING
          ev_guid_32 = ls_row-id.    " Guid of length 32 (CHAR Format) Uppper Case
      MOVE-CORRESPONDING ls_row TO cs_row.
    ENDIF.

  ENDMETHOD.


  METHOD test_perf.
    DATA: ls_row   TYPE zxrm_attribute,
          lv_rt    TYPE i,
          lv_times TYPE i VALUE 100000.
    GET RUN TIME FIELD lv_rt.
    DO lv_times TIMES.
      CLEAR ls_row.
      CALL METHOD prepare_guid_1
        CHANGING
          cs_row = ls_row.
    ENDDO.
    ev_t0 = lv_rt.
    GET RUN TIME FIELD lv_rt.
    ev_t0 = lv_rt - ev_t0.

    DO lv_times TIMES.
      CLEAR ls_row.
      CALL METHOD prepare_guid_2
        CHANGING
          cs_row = ls_row.
    ENDDO.

    ev_t1 = lv_rt.
    GET RUN TIME FIELD lv_rt.
    ev_t1 = lv_rt - ev_t1.

  ENDMETHOD.


  METHOD zif_xrm_dao~add_plugin.
  ENDMETHOD.


  METHOD zif_xrm_dao~create.
    DATA: lr_row TYPE REF TO data.
    CREATE DATA lr_row LIKE is_row.
    ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
    <row> = is_row.
    prepare_guid_1( CHANGING cs_row = <row> ).
    INSERT INTO (mv_table) VALUES <row>.
  ENDMETHOD.


  METHOD zif_xrm_dao~delete.
    DELETE FROM (mv_table) WHERE id = @id.
  ENDMETHOD.


  METHOD zif_xrm_dao~retrieve.
    SELECT SINGLE * FROM (mv_table)
              WHERE id = @id INTO CORRESPONDING FIELDS OF @cs_row.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_bc_not_found.
    ENDIF.
  ENDMETHOD.


  METHOD zif_xrm_dao~retrieve_multiple.
    SELECT *
        FROM (mv_table)
        INTO CORRESPONDING FIELDS OF TABLE @ct_rows
        WHERE (query).
  ENDMETHOD.


  METHOD zif_xrm_dao~save.
    DATA: lr_row TYPE REF TO data.
    CREATE DATA lr_row LIKE is_row.
    ASSIGN lr_row->* TO FIELD-SYMBOL(<row>).
    <row> = is_row.
    r_id = prepare_guid_1( CHANGING cs_row = <row> ).

    MODIFY (mv_table)  FROM  @<row>.
  ENDMETHOD.


  METHOD zif_xrm_dao~update.
    UPDATE (mv_table) FROM @is_row.
  ENDMETHOD.
ENDCLASS.
