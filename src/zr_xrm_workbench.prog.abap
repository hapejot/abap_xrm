*&---------------------------------------------------------------------*
*& Report zr_xrm_entitiy
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_workbench.

DATA:
  BEGIN OF gd,
    title TYPE string,
  END OF gd.
DATA go_vm TYPE REF TO zif_bc_view_manager.
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""




""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

INITIALIZATION.
  CREATE OBJECT go_vm TYPE zcl_bc_view_manager.
  go_vm->register(
    EXPORTING
      iv_name = 'EXIT'
      ir_cmd  = NEW zcl_bc_cmd_exit( )
  ).
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
