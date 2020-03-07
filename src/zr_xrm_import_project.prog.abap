*&---------------------------------------------------------------------*
*& Report ZR_XRM_IMPORT_PROJECT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZR_XRM_IMPORT_PROJECT LINE-SIZE 1000.

data: filename type string value 'C:\w\notes\sap\abap_xrm\customizations.xml'.



data(lo_front) = new zcl_bc_frontend( ).
data(lv_data) = lo_front->from_file( filename ).
data(lo_proj) = new zcl_xrm_project( ).
lo_proj->import_from_xstring( lv_data ).
lo_proj->save( ).
