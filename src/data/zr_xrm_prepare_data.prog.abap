*&---------------------------------------------------------------------*
*& Report zr_xrm_prepare_data
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_prepare_data.

DATA: lr_data TYPE REF TO data,
      src     TYPE string_table,
      json    TYPE string.
FIELD-SYMBOLS <lt_tab> TYPE STANDARD TABLE.

src = VALUE #(
  ( `{"DATA":[` )
  ( `{"ID":"514822a4fccc4a9c8c398a0ae8ddc8de", "NAME": "Default Project"}` )
  ( `]}` )
).
CONCATENATE LINES OF src INTO json.
CREATE DATA lr_data TYPE STANDARD TABLE OF ('ZXRM_PROJECT').
ASSIGN lr_data->* TO <lt_tab>.
CALL TRANSFORMATION id SOURCE XML json RESULT data = <lt_tab>.
MODIFY ('ZXRM_PROJECT') FROM TABLE <lt_tab>.
WRITE: / 'PROJECT ', sy-dbcnt, 'rows'.

src = VALUE #(
  ( `{"DATA":[` )
  ( `{"ID":"270a2d94995b422593cae2ff74f1be23", "NAME": "Entity"}` )
  ( `]}` )
).
CONCATENATE LINES OF src INTO json.
CREATE DATA lr_data TYPE STANDARD TABLE OF ('ZXRM_ENTITY').
ASSIGN lr_data->* TO <lt_tab>.
CALL TRANSFORMATION id SOURCE XML json RESULT data = <lt_tab>.
MODIFY ('ZXRM_ENTITY') FROM TABLE <lt_tab>.
WRITE: / 'ENTITY', sy-dbcnt, 'rows'.
COMMIT WORK.
