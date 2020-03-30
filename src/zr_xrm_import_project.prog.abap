*&---------------------------------------------------------------------*
*& Report ZR_XRM_IMPORT_PROJECT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_import_project LINE-SIZE 1000.

DATA: filename  TYPE string VALUE 'C:\w\notes\sap\abap_xrm\customizations.xml',
      sol_fname TYPE string VALUE 'C:\w\notes\sap\abap_xrm\solution.xml'.




DATA(lo_proj) = NEW zcl_xrm_project( ).

DATA(lo_front) = NEW zcl_bc_frontend( ).

lo_proj->solution_from_xstring( lo_front->from_file( sol_fname ) ).
lo_proj->import_from_xstring( lo_front->from_file( filename ) ).

DELETE FROM zxrm_attribute WHERE entityid = ''.

lo_proj->save( ).
