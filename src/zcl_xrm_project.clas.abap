CLASS zcl_xrm_project DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS import_from_xstring
      IMPORTING
        i_lv_data TYPE xstring.
    METHODS save.
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mr_row TYPE REF TO data .
    DATA mr_entity TYPE REF TO zxrm_entity_s .
    DATA mr_attribute TYPE REF TO zxrm_attribute_s.

    DATA:
      mt_attributes TYPE STANDARD TABLE OF zxrm_attribute_s,
      mt_entities   TYPE STANDARD TABLE OF zxrm_entity_s.

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



CLASS ZCL_XRM_PROJECT IMPLEMENTATION.


  METHOD attribute.
    APPEND INITIAL LINE TO mt_attributes REFERENCE INTO mr_attribute.
    CALL FUNCTION 'GUID_CREATE'
      IMPORTING
        ev_guid_32 = mr_attribute->id.
    mr_attribute->entity = mr_entity->name.
    mr_attribute->entityid = mr_entity->id.
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
                AND field( e = l_el d = mr_row f = 'NAME' ).

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
          l_attribute TYPE zxrm_attribute_s.

    WRITE: / 'Entities:', lines( mt_entities ).
    LOOP AT mt_entities INTO l_entity.
      WRITE / l_entity.
    ENDLOOP.

    WRITE: / 'Attributes:', lines( mt_attributes ).
    LOOP AT mt_attributes INTO l_attribute.
      WRITE:
            /  l_attribute-ID,
            /  l_attribute-NAME,
            /  l_attribute-entity,
            /  l_attribute-entityid,
            /  l_attribute-datatype.
    ENDLOOP.


  ENDMETHOD.
ENDCLASS.
