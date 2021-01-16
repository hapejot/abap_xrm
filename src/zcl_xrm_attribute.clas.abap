CLASS zcl_xrm_attribute DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        i_ds  TYPE REF TO zcl_mydd_dataset
        i_row TYPE REF TO zif_mydd_types=>attribute.
    METHODS row
      RETURNING
        VALUE(result) TYPE REF TO zif_mydd_types=>attribute.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA m_ds TYPE REF TO zcl_mydd_dataset.
    DATA m_row TYPE REF TO zif_mydd_types=>attribute.
ENDCLASS.



CLASS zcl_xrm_attribute IMPLEMENTATION.

  METHOD constructor.

    me->m_ds = i_ds.
    me->m_row = i_row.

  ENDMETHOD.

  METHOD row.
    result = m_row.
  ENDMETHOD.

ENDCLASS.
