*&---------------------------------------------------------------------*
*& Report ZR_XRM_DYNPRO_TO_XML
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_dynpro_to_xml LINE-SIZE 300.


PARAMETERS: program TYPE progname,
            dynpro  TYPE sychar04.

DATA:
  BEGIN OF lx_data,
    header               TYPE rpy_dyhead,
    containers           TYPE STANDARD TABLE OF rpy_dycatt,
    fields_to_containers TYPE STANDARD TABLE OF rpy_dyfatc,
    flow_logic           TYPE STANDARD TABLE OF rpy_dyflow,
    params               TYPE STANDARD TABLE OF rpy_dypara,
*    fields_list          TYPE STANDARD TABLE OF d021s,
  END OF lx_data.


CALL FUNCTION 'RPY_DYNPRO_READ'
  EXPORTING
    progname             = program    " Program name of screen
    dynnr                = dynpro    " Screen number
  IMPORTING
    header               = lx_data-header
  TABLES
    containers           = lx_data-containers
    fields_to_containers = lx_data-fields_to_containers    " Single object in screen (incl. cont. assignment)
    flow_logic           = lx_data-flow_logic
    params               = lx_data-params    " Screen: Parameter Information for Screen
*   fields_list          = lx_data-fields_list
  EXCEPTIONS
    cancelled            = 1
    not_found            = 2
    permission_error     = 3
    OTHERS               = 4.
IF sy-subrc = 0.
  DATA(lo_xml) = NEW zcl_bc_xml_abap( ).
  lo_xml->set_data(
      ir_data = REF #( lx_data )
  ).
  DATA(indent) = 10.
  DATA(lt_lines) = VALUE string_table( ).
  lo_xml->get_xml_as_table( CHANGING ct_lines = lt_lines ).
  LOOP AT lt_lines INTO DATA(lv_line).
    WRITE AT /indent lv_line NO-GAP.
    FIND '</' IN lv_line.
    IF sy-subrc = 0.
      ADD -2 TO indent.
    ELSE.
      FIND '/>' IN lv_line.
      IF sy-subrc > 0.
        ADD 2 TO indent.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDIF.
