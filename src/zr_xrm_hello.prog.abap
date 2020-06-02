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



  DATA(lt_items1) = VALUE treemlitad(
      ( item_name = 'TEST1' chosen = abap_true u_chosen = abap_true )
      ( item_name = 'TEST2' text = 'Hello' u_text = abap_true ) ).

  DATA(lt_items2) = VALUE treemlitad(
    FOR item IN lt_items1 (
      VALUE #( BASE CORRESPONDING #( item )
                                     node_key = 'MyNodeKey' ) ) ) .


  MODIFY lt_items2 FROM VALUE treemlitef( node_key = 'MyKey' ) TRANSPORTING node_key WHERE node_key = space.
