*&---------------------------------------------------------------------*
*& Report ZR_XRM_HELLO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_xrm_hello.

START-OF-SELECTION.
  MESSAGE 'Hello World!' TYPE 'S'.

  WAIT UP TO 10 SECONDS.

  MESSAGE w000(zxrm).

  MESSAGE 'Good bye.' TYPE 'S'.
