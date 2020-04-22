*&---------------------------------------------------------------------*
*& Report zr_test_xml
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_test_xml.

DATA: filename  TYPE string VALUE 'customizations.xml',
      sol_fname TYPE string VALUE 'solution.xml',
      xmltab    TYPE  STANDARD TABLE OF  smum_xmltb,
      xmlret    TYPE STANDARD TABLE OF bapiret2.



TRY.

    DATA(lo_front) = NEW zcl_bc_frontend( ).
    DATA(xmlraw) = lo_front->from_file( i_filename = lo_front->get_filename( ) ).

    CALL FUNCTION 'SMUM_XML_PARSE'
      EXPORTING
        xml_input = xmlraw
      TABLES
        xml_table = xmltab    " XML Table structure used for retreive and output XML doc
        return    = xmlret.    " XML Table structure used for retreive and output XML doc
    DATA(out) = cl_demo_output=>new(  )->write( xmlret )->write( xmltab ).

    xmltab = VALUE #(
    ( hier = '1' type = ' ' cname = 'CWQ'  )
    ( hier = '1' type = 'A' cname = 'action'  cvalue = 'CallStateless' )
    ( hier = '1' type = 'A' cname = 'TargetContent'  cvalue = 'XML' )
    ( hier = '2' type = 'V' cname = 'KNB'  cvalue = 'KG_SalesCenterAndQuotation' )
    ( hier = '2' type = 'V' cname = 'VER'  cvalue = 'w' )
    ( hier = '2' type = 'V' cname = 'START'  cvalue = 'StartSilent_ExportBOM' )
    ( hier = '2' type = 'V' cname = 'METHOD'  cvalue = 'cC_Execute()' )
    ( hier = '2' type = 'V' cname = 'PARAM'  cvalue = '-DSN=camosSalesCenterProdConfigurator -DSNUI=camosSalesCenterProdConfigurator -UID=THR -PWD=thr -MachineNumber=[Maschinennummer]' )
    ).

    CALL FUNCTION 'SMUM_XML_CREATE_X'
      IMPORTING
        xml_output = xmlraw
      TABLES
        xml_table  = xmltab    " XML Table structure used for retreive and output XML doc
      .

    out->write_xml( xmlraw )->display( ).

  CATCH zcx_bc_cancel_action.
    MESSAGE |action cancelled.| TYPE 'I'.
ENDTRY.
