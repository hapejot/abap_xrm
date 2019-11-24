CLASS zcl_xrm_app_state DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_bc_app_state.
    ALIASES: set_state FOR zif_bc_app_state~set_state,
             sync FOR zif_bc_app_state~sync.
    METHODS constructor IMPORTING iv_appname TYPE zxrm_appname.


  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS mv_proc_conn TYPE string VALUE 'R/3*ZXRM_CONN' ##NO_TEXT.
    DATA: m_appname TYPE zxrm_appname,
          mt_values TYPE STANDARD TABLE OF zxrm_app_state WITH DEFAULT KEY.


ENDCLASS.



CLASS zcl_xrm_app_state IMPLEMENTATION.
  METHOD constructor.
    m_appname = iv_appname.
  ENDMETHOD.

  METHOD zif_bc_app_state~set_state.
    DATA(row) = REF #( mt_values[ uname       = sy-uname
                                  appkey      = iv_appkey
                                  appname     = m_appname ] OPTIONAL ).
    IF row IS NOT BOUND.
      APPEND VALUE #( uname       = sy-uname
                      appkey      = iv_appkey
                      appname     = m_appname )
                      TO mt_values
                      REFERENCE INTO row.
    ENDIF.
    row->value = iv_value.
    row->change_date = sy-datum.
    row->change_time = sy-uzeit.
    ro_stat = me.
  ENDMETHOD.

  METHOD zif_bc_app_state~sync.
    MODIFY zxrm_app_state CONNECTION (mv_proc_conn) FROM TABLE mt_values.
*  IF sy-dbcnt = 1.
*    COMMIT CONNECTION (mv_proc_conn).
*    rv_success = abap_true.
*  ELSE.
*    ROLLBACK CONNECTION (mv_proc_conn).
*    rv_success = abap_false.
*  ENDIF.
    COMMIT CONNECTION (mv_proc_conn).
  ENDMETHOD.
ENDCLASS.
