INTERFACE zif_xrm_dao
  PUBLIC .


  METHODS retrieve IMPORTING id TYPE zrowid.
  METHODS retrieve_multiple .
  METHODS create IMPORTING is_row TYPE any .
  METHODS delete IMPORTING id TYPE zrowid.
  METHODS update IMPORTING is_row TYPE any.
  METHODS save IMPORTING is_row TYPE any.
  METHODS add_plugin .
ENDINTERFACE.
