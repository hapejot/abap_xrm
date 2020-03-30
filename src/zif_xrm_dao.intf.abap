INTERFACE zif_xrm_dao
  PUBLIC .


  METHODS retrieve
    IMPORTING
      !id     TYPE zrowid
    CHANGING
      !cs_row TYPE any
    RAISING
      zcx_bc_not_found .
  METHODS retrieve_multiple
    IMPORTING
      !query   TYPE string
    CHANGING
      !ct_rows TYPE STANDARD TABLE .
  METHODS create
    IMPORTING
      !is_row TYPE any .
  METHODS delete
    IMPORTING
      !id TYPE zrowid .
  METHODS update
    IMPORTING
      !is_row TYPE any .
  METHODS save     IMPORTING
                             !is_row     TYPE any
                   RETURNING VALUE(r_id) TYPE zrowid.
  METHODS add_plugin .
ENDINTERFACE.
