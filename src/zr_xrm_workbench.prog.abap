*&---------------------------------------------------------------------*
*& Report zr_xrm_entitiy
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_workbench.

CLASS lcl_screen_dispatcher DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_xrm_screen_dispatcher.
    ALIASES: call_screen FOR zif_xrm_screen_dispatcher~call_screen,
     call_screen_at FOR zif_xrm_screen_dispatcher~call_screen_at.

ENDCLASS.

CLASS lcl_screen_dispatcher IMPLEMENTATION.

  METHOD call_screen.
    CALL SCREEN i_dynnr.
  ENDMETHOD.

  METHOD zif_xrm_screen_dispatcher~call_screen_at.

    CALL SCREEN i_dynnr STARTING AT i_left i_top ENDING AT i_right i_bottom.
  ENDMETHOD.

ENDCLASS.




CLASS lcl_solution_dialog DEFINITION .

  PUBLIC SECTION.
    INTERFACES zif_xrm_dialog.
  PROTECTED SECTION.

  PRIVATE SECTION.

ENDCLASS.

CLASS lcl_solution_dialog IMPLEMENTATION.

  METHOD zif_xrm_dialog~pai.
    CASE sy-ucomm.
      WHEN 'DLG_CONT'.
        LEAVE TO SCREEN 0.
      WHEN 'DLG_CANCEL'.
        LEAVE TO SCREEN 0.
    ENDCASE.

  ENDMETHOD.

  METHOD zif_xrm_dialog~pbo.

  ENDMETHOD.

ENDCLASS.



DATA:
  BEGIN OF gd,
    title      TYPE string,
    search     TYPE string,
    search_txt TYPE string,
  END OF gd.
DATA: go_dlg TYPE REF TO zif_xrm_dialog,
      go_vm  TYPE REF TO zif_bc_view_manager.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS lcl_solution_cmd DEFINITION INHERITING FROM zcl_bc_command.
  PUBLIC SECTION.
    METHODS execute REDEFINITION.
    METHODS constructor.
  PRIVATE SECTION.
    DATA:
           mo_dialog TYPE REF TO zif_xrm_dialog.
ENDCLASS.

CLASS lcl_solution_cmd IMPLEMENTATION.

  METHOD constructor.
    super->constructor( ).
    mo_dialog = NEW lcl_solution_dialog( ).
*  mo_dialog->register(
*    EXPORTING
*        iv_name = 'DLG_CANCEL'
*        ir_cmd = NEW zcl_bc_cmd_exit( ) ).
*  mo_dialog->register(
*    EXPORTING
*        iv_name = 'DLG_CONT'
*        ir_cmd = NEW zcl_bc_cmd_exit( ) ).
  ENDMETHOD.

  METHOD execute.

    go_dlg = mo_dialog.
    CALL SCREEN 2 STARTING AT 10 10 ENDING AT 100 27.
    CLEAR go_dlg.

  ENDMETHOD.

ENDCLASS.




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" MAIN
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

INITIALIZATION.
  DATA(lo_app) = NEW zcl_xrm_workbench( ).

  lo_app->initialization( ).
  go_vm = lo_app->get_vm( ).
  go_vm->register( iv_name = 'PRJ_OPEN'    ir_cmd = NEW lcl_solution_cmd( ) ).
  CALL SCREEN 1.

*&---------------------------------------------------------------------*
*&      Module  PBO_GEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pbo_gen OUTPUT.
  IF go_vm IS BOUND.
    go_vm->set_status(  ).
  ENDIF.
*  SET PF-STATUS 'STATUS'.
  SET TITLEBAR 'TITLE'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_GEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_gen INPUT.
  IF go_vm IS BOUND.
    go_vm->pai(
      CHANGING
        cs_data = gd
    ).
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module PBO_DLG OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE pbo_dlg OUTPUT.
  IF go_dlg IS BOUND.
    go_dlg->pbo( CHANGING data = gd ).
  ENDIF.
  SET PF-STATUS 'DLG_STATUS'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_DLG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_dlg INPUT.
  IF go_dlg IS BOUND.
    go_dlg->pai(
      CHANGING
        data = gd
    ).
  ENDIF.
ENDMODULE.
