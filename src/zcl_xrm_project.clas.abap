CLASS zcl_xrm_project DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS import_from_xstring
      IMPORTING
        i_lv_data TYPE xstring.
    METHODS save.
    METHODS solution_from_xstring
      IMPORTING
        i_data TYPE xstring.
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_lt_ent   TYPE STANDARD TABLE OF zxrm_entity WITH DEFAULT KEY,
      ty_lt_ent_1 TYPE STANDARD TABLE OF zxrm_entity WITH DEFAULT KEY.
    METHODS save_entity
      IMPORTING
        i_entity TYPE zxrm_api_entity_s.

    DATA mr_row TYPE REF TO data .
    DATA mr_entity TYPE REF TO zxrm_api_entity_s .
    DATA mr_attribute TYPE REF TO zxrm_api_attribute_s .
    DATA ms_prj TYPE zxrm_project .
    DATA:
      mt_entities TYPE STANDARD TABLE OF zxrm_api_entity_s,
      lo_ent_dao  TYPE REF TO zif_xrm_dao,
      lo_att_dao  TYPE REF TO zif_xrm_dao.

    METHODS get_entity_by_name
      IMPORTING
        !i_name         TYPE zname
      RETURNING
        VALUE(r_entity) TYPE REF TO zxrm_entity .
    METHODS save_entities .
    METHODS attribute
      RETURNING
        VALUE(r) TYPE abap_bool .
    METHODS field
      IMPORTING
        !d       TYPE REF TO data
        !f       TYPE string
        !e       TYPE REF TO if_ixml_node
      RETURNING
        VALUE(r) TYPE abap_bool .
    METHODS check_name
      IMPORTING
        !el       TYPE REF TO if_ixml_node
        !nm       TYPE string
      RETURNING
        VALUE(rr) TYPE abap_bool .
    METHODS entity
      RETURNING
        VALUE(rr) TYPE abap_bool .
    METHODS handle_root
      IMPORTING
        !i_element TYPE REF TO if_ixml_node .
    METHODS handle_children
      IMPORTING
        !i_indent  TYPE i DEFAULT 1
        !i_path    TYPE string OPTIONAL
        !i_element TYPE REF TO if_ixml_node .
    METHODS handle_attributes
      IMPORTING
        !i_indent TYPE i
        !i_attrs  TYPE REF TO if_ixml_named_node_map .

ENDCLASS.



CLASS zcl_xrm_project IMPLEMENTATION.


  METHOD attribute.
    APPEND INITIAL LINE TO mr_entity->attributes REFERENCE INTO mr_attribute.
    mr_row = mr_attribute.
    r = abap_true.
  ENDMETHOD.


  METHOD check_name.

    IF nm = el->get_name( ).
      rr = abap_true.
    ELSE.
      rr = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD entity.
    APPEND INITIAL LINE TO mt_entities REFERENCE INTO mr_entity.
    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        ev_guid_32 = mr_entity->id.
    mr_row = mr_entity.
    rr = abap_true.
  ENDMETHOD.


  METHOD field.
    FIELD-SYMBOLS: <f> TYPE any.

    ASSIGN d->(f) TO <f>.
    IF sy-subrc = 0.
      <f> = e->get_first_child( )->get_value( ).
      r = abap_true.
    ELSE.
      r = abap_false.
    ENDIF.

  ENDMETHOD.


  METHOD get_entity_by_name.
  ENDMETHOD.


  METHOD handle_attributes.
    CHECK i_attrs IS BOUND.
    DO i_attrs->get_length( ) TIMES.
      DATA(l_idx) = sy-index - 1. " index counts from zero! in contrast to all other in SAP
      DATA(l_attr) = i_attrs->get_item( l_idx ).
      WRITE: AT /i_indent '@', l_attr->get_name( ), l_attr->get_value( ) .
    ENDDO.

  ENDMETHOD.


  METHOD handle_children.
    DATA(l_el) = i_element.
    WHILE l_el IS BOUND.
      DATA(el_type) = l_el->get_type( ).
      CASE el_type.
        WHEN if_ixml_node=>co_node_text.
          WRITE: AT /i_indent '#', l_el->get_value( ).

        WHEN OTHERS.
          WRITE: AT /i_indent l_el->get_name( ), i_path.

          IF   check_name( el = l_el nm = 'Entity' )
                AND entity( )
            OR check_name( el = l_el nm = 'attribute' )
                AND i_path = '.Entities.Entity.EntityInfo.entity.attributes'
                AND attribute( )
            OR check_name( el = l_el nm = 'Name' )
                AND i_path = '.Entities.Entity'
                AND field( e = l_el d = mr_row f = 'NAME' )
            OR check_name( el = l_el nm = 'Type' )
                AND field( e = l_el d = mr_row f = 'DATATYPE' )
            OR check_name( el = l_el nm = 'Name' )
                AND i_path = '.Entities.Entity.EntityInfo.entity.attributes.attribute'
                AND field( e = l_el d = mr_row f = 'NAME' )
            OR check_name( el = l_el nm = 'UniqueName' )
                AND i_path = '.SolutionManifest'
                AND field( e = l_el d = REF #( ms_prj ) f = 'NAME' )
            .
            WRITE: AT /i_indent '----'.
          ENDIF.

          handle_attributes( i_indent = i_indent + 1
                             i_attrs = l_el->get_attributes( ) ).
          handle_children( i_indent = i_indent + 1
                           i_path = |{ i_path }.{ l_el->get_name( ) }|
                           i_element = l_el->get_first_child( ) ).
      ENDCASE.
      l_el = l_el->get_next( ).
    ENDWHILE.
  ENDMETHOD.


  METHOD handle_root.

*    WRITE / l_element->get_name( ). " ImportExportXml"
    WRITE / i_element->get_name( ).
    handle_children( i_element->get_first_child( ) ).

  ENDMETHOD.


  METHOD import_from_xstring.
    DATA: l_xml_doc      TYPE REF TO if_ixml_document,
          c_root_tag     TYPE string,
          c_attr_version TYPE string.
    DATA(l_ixml) = cl_ixml=>create( ).
    DATA(l_stream_factory) = l_ixml->create_stream_factory( ).
    DATA(l_istream) = l_stream_factory->create_istream_xstring( i_lv_data ).
    l_xml_doc = l_ixml->create_document( ).
    DATA(l_parser) = l_ixml->create_parser( stream_factory = l_stream_factory
                                        istream        = l_istream
                                        document       = l_xml_doc ).
    l_parser->add_strip_space_element( ).
    IF l_parser->parse( ) <> 0.
*      error( li_parser ).
    ENDIF.

    l_istream->close( ).


*    DATA(l_element) = l_xml_doc->find_from_name_ns( depth = 0 name = c_root_tag ).
    DATA(l_element) = CAST if_ixml_node( l_xml_doc->get_root_element( ) ).

    handle_root( l_element ).

*    DATA(l_version) = l_element->if_ixml_node~get_attributes(
*      )->get_named_item_ns( c_attr_version ) ##no_text.
*    IF l_version->get_value( ) <> zif_abapgit_version=>gc_xml_version.
**      display_version_mismatch( ).
*    ENDIF.
  ENDMETHOD.


  METHOD save.
    DATA: l_entity    TYPE zxrm_entity_s,
          lt_prj      TYPE STANDARD TABLE OF zxrm_project,
          lr_prj      TYPE REF TO zxrm_project,
          lt_ent      TYPE STANDARD TABLE OF zxrm_entity,
          lr_ent      TYPE REF TO zxrm_entity,
          l_attribute TYPE zxrm_attribute_s,
          lo_prj_dao  TYPE REF TO zif_xrm_dao,
          lo_ent_dao  TYPE REF TO zif_xrm_dao.

    CREATE OBJECT lo_prj_dao TYPE zcl_xrm_generic_dao
      EXPORTING
        iv_table = 'ZXRM_PROJECT'.



    lo_prj_dao->retrieve_multiple(
      EXPORTING
        query   = |name = '{ ms_prj-name }'|
      CHANGING
        ct_rows = lt_prj
    ).
    IF lines( lt_prj ) = 0.
      APPEND INITIAL LINE TO lt_prj REFERENCE INTO lr_prj.
    ELSE.
      lr_prj = REF #( lt_prj[ 1 ] ).
    ENDIF.
    lr_prj->* = CORRESPONDING #( ms_prj EXCEPT id ).

    lo_prj_dao->save( is_row = lr_prj->* ).





    save_entities( ).


    COMMIT WORK.

  ENDMETHOD.





  METHOD save_entities.

    DATA:
      lr_ent      TYPE REF TO zxrm_entity,
      lt_ent      TYPE STANDARD TABLE OF zxrm_entity,
      lt_att      TYPE STANDARD TABLE OF zxrm_attribute,
      l_entity    TYPE zxrm_api_entity_s,
      l_attribute TYPE zxrm_api_attribute_s.


    CREATE OBJECT lo_ent_dao TYPE zcl_xrm_generic_dao
      EXPORTING
        iv_table = 'ZXRM_ENTITY'.
    CREATE OBJECT lo_att_dao TYPE zcl_xrm_generic_dao
      EXPORTING
        iv_table = 'ZXRM_ATTRIBUTE'.
    LOOP AT mt_entities INTO l_entity.
      save_entity(
      i_entity   = l_entity ).
    ENDLOOP.


  ENDMETHOD.

  METHOD save_entity.

    DATA: lr_ent   TYPE REF TO zxrm_entity,
          l_ent_id TYPE zrowid,
          lt_ent   TYPE STANDARD TABLE OF zxrm_entity,
          lr_att   TYPE REF TO zxrm_attribute,
          lt_att   TYPE STANDARD TABLE OF zxrm_attribute.

    CLEAR lt_ent[].
    lo_ent_dao->retrieve_multiple(  EXPORTING
                                      query   = |name = '{ i_entity-name }'|
                                    CHANGING
                                      ct_rows = lt_ent ).
    IF lines( lt_ent ) = 0.
      APPEND INITIAL LINE TO lt_ent REFERENCE INTO lr_ent.
    ELSE.
      lr_ent = REF #( lt_ent[ 1 ] ).
    ENDIF.
    lr_ent->* = CORRESPONDING #( i_entity EXCEPT id ).
    l_ent_id = lo_ent_dao->save( is_row = lr_ent->* ).
    LOOP AT i_entity-attributes INTO DATA(l_attr).
      CLEAR lt_att[].
      lo_att_dao->retrieve_multiple(  EXPORTING
                                        query   = |entityid = '{ l_ent_id }' and name = '{ l_attr-name }'|
                                      CHANGING
                                        ct_rows = lt_att ).
      IF lines( lt_att ) = 0.
        APPEND INITIAL LINE TO lt_att REFERENCE INTO lr_att.
      ELSE.
        lr_att = REF #( lt_att[ 1 ] ).
      ENDIF.
      lr_att->* = CORRESPONDING #( l_attr ).
      lr_att->entityid = l_ent_id.
      lo_att_dao->save( is_row = lr_att->* ).
    ENDLOOP.


  ENDMETHOD.




  METHOD solution_from_xstring.
    DATA: l_xml_doc        TYPE REF TO if_ixml_document,
          c_root_tag       TYPE string,
          c_attr_version   TYPE string,
          l_ixml           TYPE REF TO if_ixml,
          l_stream_factory TYPE REF TO if_ixml_stream_factory,
          l_istream        TYPE REF TO if_ixml_istream,
          l_parser         TYPE REF TO if_ixml_parser,
          l_element        TYPE REF TO if_ixml_node.
    l_ixml = cl_ixml=>create( ).
    l_stream_factory = l_ixml->create_stream_factory( ).
    l_istream = l_stream_factory->create_istream_xstring( i_data ).
    l_xml_doc = l_ixml->create_document( ).
    l_parser = l_ixml->create_parser( stream_factory = l_stream_factory
                                        istream        = l_istream
                                        document       = l_xml_doc ).
    l_parser->add_strip_space_element( ).
    IF l_parser->parse( ) <> 0.
*      error( li_parser ).
    ENDIF.

    l_istream->close( ).
    l_element = CAST if_ixml_node( l_xml_doc->get_root_element( ) ).
    handle_root( l_element ).

  ENDMETHOD.
ENDCLASS.
