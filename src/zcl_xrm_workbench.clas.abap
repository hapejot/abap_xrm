CLASS zcl_xrm_workbench DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zif_xrm_application.
    METHODS initialization.
    METHODS get_vm
      RETURNING
        VALUE(r_result) TYPE REF TO zif_bc_view_manager.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA:
      mo_exit_cmd TYPE REF TO zif_bc_command,
      go_vm       TYPE REF TO zif_bc_view_manager.
ENDCLASS.



CLASS zcl_xrm_workbench IMPLEMENTATION.

  METHOD initialization.
    DATA lt_project TYPE STANDARD TABLE OF zxrm_project.
    DATA: lo_form TYPE REF TO zif_bc_control.
    DATA(lo_state) = NEW zcl_xrm_app_state( iv_appname = 'MAIN-VIEW-SETUP' ).
    CREATE OBJECT go_vm TYPE zcl_bc_view_manager EXPORTING io_stat = lo_state.
    go_vm->register( iv_name = 'EXIT'        ir_cmd = NEW zcl_bc_cmd_exit(  ) ).

    lo_form = NEW zcl_bc_form( io_stat = lo_state ).
    go_vm->add( iv_path = '.form'             iv_ctrl = lo_form ).
    go_vm->add( iv_path = '.form.cont'        iv_ctrl = NEW zcl_bc_split( ) ).
    DATA(lo_tree) = NEW zcl_bc_list_tree( io_stat = lo_state ).
    go_vm->add( iv_path = '.form.cont.1'      iv_ctrl = lo_tree ).
    " setup solution hierarchy with an internal table
    "
    DATA(lo_solution_hierarch) = NEW zcl_bc_hierarchy( ).
    DATA(lt_keys) = VALUE zif_bc_data_source=>tt_fieldnames( ( 'ID' ) ).
    SELECT * FROM zxrm_project
            INTO TABLE @lt_project.
    DATA(lr_data) = REF #( lt_project ).
    DATA(lo_ds) = NEW zcl_bc_itab_datasource(
        it_keys       = lt_keys
        ir_data       = lr_data
*      iv_local_copy =
    ).
    lo_solution_hierarch->zif_bc_data_consumer~set_data_source( i_data_source = lo_ds ).
    lo_solution_hierarch->add_level( 'NAME' ).
    lo_tree->set_hierarchy( i_hier = lo_solution_hierarch ).

    go_vm->apply_settings( io_ctrl = lo_form ).
    lo_form->init( ).
    lo_state->sync( ).
  ENDMETHOD.


  METHOD get_vm.
    r_result = go_vm.
  ENDMETHOD.

ENDCLASS.
