*&---------------------------------------------------------------------*
*& Report ZR_XRM_IMPORT_PROJECT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_import_project LINE-SIZE 1000.

DATA: filename  TYPE string VALUE 'customizations.xml',
      sol_fname TYPE string VALUE 'solution.xml'.



TRY.
    DATA(lo_proj) = NEW zcl_xrm_project( ).

    DATA(lo_front) = NEW zcl_bc_frontend( ).
    lo_front->load_archive( lo_front->get_filename( ) ).
    lo_proj->solution_from_xstring( lo_front->from_archive( sol_fname ) ).
    lo_proj->import_from_xstring( lo_front->from_archive( filename ) ).

    DELETE FROM zxrm_attribute WHERE entityid = ''.

    lo_proj->save( ).
  CATCH zcx_bc_cancel_action.
    MESSAGE |action cancelled.| TYPE 'I'.
ENDTRY.
