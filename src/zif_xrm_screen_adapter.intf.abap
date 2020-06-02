INTERFACE zif_xrm_screen_adapter
  PUBLIC .
  METHODS call_screen       IMPORTING
                              i_dynnr TYPE dynnr.
  METHODS call_screen_at    IMPORTING
                              i_left   TYPE i
                              i_top    TYPE i
                              i_right  TYPE i
                              i_bottom TYPE i
                              i_dynnr  TYPE dynnr .
ENDINTERFACE.
