CLASS zcl_xrm_entity_dao DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_xrm_dao .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_xrm_entity_dao IMPLEMENTATION.


  METHOD zif_xrm_dao~add_plugin.
  ENDMETHOD.


  METHOD zif_xrm_dao~create.
    INSERT INTO zxrm_entity VALUES is_row.
  ENDMETHOD.


  METHOD zif_xrm_dao~delete.
    DELETE FROM zxrm_entity WHERE id = @id.
  ENDMETHOD.


  METHOD zif_xrm_dao~retrieve.
    SELECT SINGLE * FROM zxrm_entity
              WHERE id = @id INTO @DATA(ls_row).
  ENDMETHOD.


  METHOD zif_xrm_dao~retrieve_multiple.
  ENDMETHOD.


  METHOD zif_xrm_dao~save.
    MODIFY zxrm_entity FROM @is_row.
  ENDMETHOD.


  METHOD zif_xrm_dao~update.
    UPDATE zxrm_entity FROM @is_row.
  ENDMETHOD.
ENDCLASS.
