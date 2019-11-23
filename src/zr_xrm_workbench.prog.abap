*&---------------------------------------------------------------------*
*& Report zr_xrm_entitiy
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_workbench.

DATA:
  BEGIN OF gd,
    title TYPE string,
    search type string,
    search_txt type string,
  END OF gd.
DATA go_vm TYPE REF TO zif_bc_view_manager.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

CLASS lcl_solution_cmd DEFINITION INHERITING FROM zcl_bc_command.
  PUBLIC SECTION.
    METHODS execute REDEFINITION.
ENDCLASS.

CLASS lcl_solution_cmd IMPLEMENTATION.

  METHOD execute.

    CALL SCREEN '0002' STARTING AT 10 10 ENDING AT 100 27.


  ENDMETHOD.

ENDCLASS.


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

INITIALIZATION.
  CREATE OBJECT go_vm TYPE zcl_bc_view_manager.
  go_vm->register(
    EXPORTING
      iv_name = 'EXIT'
      ir_cmd  = NEW zcl_bc_cmd_exit( )
  ).
  go_vm->register(
    EXPORTING
        iv_name = 'PRJ_OPEN'
        ir_cmd = NEW lcl_solution_cmd( ) ).
  go_vm->register(
    EXPORTING
        iv_name = 'DLG_CANCEL'
        ir_cmd = NEW zcl_bc_cmd_exit( ) ).
  go_vm->register(
    EXPORTING
        iv_name = 'DLG_CONT'
        ir_cmd = NEW zcl_bc_cmd_exit( ) ).
  CALL SCREEN '0001'.

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
 SET PF-STATUS 'DLG_STATUS'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  PAI_DLG  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE pai_dlg INPUT.
  IF go_vm IS BOUND.
    go_vm->pai(
      CHANGING
        cs_data = gd
    ).
  ENDIF.
ENDMODULE.
