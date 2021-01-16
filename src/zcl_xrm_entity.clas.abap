CLASS zcl_xrm_entity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS activate .
    METHODS attributes
      RETURNING
        VALUE(result) TYPE zif_mydd_types=>attributes .
    METHODS constructor
      IMPORTING
        !i_ds  TYPE REF TO zif_mydd_dataset
        !i_row TYPE REF TO zif_mydd_types=>entity .
    METHODS declare_attribute
      IMPORTING
        !i_fldname TYPE fieldname OPTIONAL
        !i_type    TYPE rollname .
    METHODS declare_lookup
      IMPORTING
        !i_fldname TYPE fieldname
        !i_entname TYPE zname
        !i_relname TYPE zname .
    METHODS generate
      RAISING
        zcx_bc_not_found .
    METHODS row
      RETURNING
        VALUE(r_result) TYPE REF TO zif_mydd_types=>entity .
  PROTECTED SECTION.
  PRIVATE SECTION.

    TYPES:
      ty_fields   TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY .
    TYPES:
      ty_fields_1 TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY .

    DATA m_ds TYPE REF TO zcl_mydd_dataset .
    DATA m_row TYPE REF TO zif_mydd_types=>entity .

    METHODS load_ddic_dataelement
      IMPORTING
        !i_rollname      TYPE ddobjname
      RETURNING
        VALUE(r_dtel_hd) TYPE dd04v .
    METHODS load_ddic_domain .
    METHODS load_ddic_table
      RETURNING
        VALUE(r_fields) TYPE ty_fields_1
      RAISING
        zcx_bc_not_found .
    METHODS store_ddic_dataelement
      IMPORTING
        i_name    TYPE ddobjname
        i_domname TYPE domname .
    METHODS store_ddic_domain .
    METHODS store_ddic_table
      IMPORTING
        !i_tab_hd   TYPE dd02v
        !i_tab_tech TYPE dd09v
      CHANGING
        !c_fields   TYPE ty_fields .
    METHODS store_tadir_entry
      IMPORTING
        i_object   TYPE trobjtype DEFAULT 'TABL'
        i_obj_name TYPE sobj_name.
    METHODS activate_ddic_table.
    METHODS activate_ddic_dtel
      IMPORTING
        i_name TYPE zxrm_entity-id_dtel.
ENDCLASS.



CLASS zcl_xrm_entity IMPLEMENTATION.


  METHOD activate.
    activate_ddic_dtel( m_row->id_dtel ).
    activate_ddic_dtel( m_row->name_dtel ).
    activate_ddic_table( ).
  ENDMETHOD.

  METHOD activate_ddic_table.

    DATA: rc TYPE sy-subrc.
    CALL FUNCTION 'DDIF_TABL_ACTIVATE'
      EXPORTING
        name        = m_row->tabname    " Name of the Table to be Activated
*       auth_chk    = 'X'    " 'X': Perform Author. Check for DB Operations
*       prid        = -1    " ID for Log Writer
*       excommit    = 'X'    " Specifies whether a commit is to be sent
      IMPORTING
        rc          = rc    " Result of Activation
      EXCEPTIONS
        not_found   = 1
        put_failure = 2
        OTHERS      = 3.
    IF sy-subrc <> 0 OR rc <> 0.
      MESSAGE |activate failed rc {  rc }, subrc { sy-subrc }| TYPE 'I'.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDMETHOD.




  METHOD attributes.
    result = VALUE #( FOR <x> IN m_ds->attributes( )
                        WHERE ( entityid = m_row->id )
                        ( <x> ) ).
  ENDMETHOD.


  METHOD constructor.

    me->m_ds ?= i_ds.
    me->m_row = i_row.
    IF m_row->tabname IS INITIAL.
      m_row->tabname = |ZXX{ m_row->name }|.
    ENDIF.
    IF m_row->id_dtel IS INITIAL.
      m_row->id_dtel = |Z{ m_row->name }ID| .
      store_ddic_dataelement( i_name = m_row->id_dtel i_domname = 'ZROWID'  ).
    ENDIF.
    declare_attribute(
        i_fldname = 'ID'
        i_type     = m_row->id_dtel
    ).

    IF m_row->name_dtel IS INITIAL.
      m_row->name_dtel = |Z{ m_row->name }NM|.
      store_ddic_dataelement( i_name = m_row->name_dtel i_domname = 'ZNAME' ).
    ENDIF.
    declare_attribute(
        i_fldname = 'NAME'
        i_type = m_row->name_dtel ).

  ENDMETHOD.


  METHOD declare_attribute.
    DATA: tname     TYPE ddobjname,
          state     TYPE ddgotstate,
          dtel_hd   TYPE dd04v,
          dtel_tech TYPE tpara,
          rollname  TYPE ddobjname.

    DATA(name) = i_fldname.
    rollname = to_upper( i_type ).

    dtel_hd = load_ddic_dataelement( rollname ).
    IF name IS INITIAL.
      name = dtel_hd-deffdname.
    ENDIF.
    IF name IS INITIAL.
      name = rollname.
    ENDIF.

    DATA(a) = m_ds->declare_attribute(  i_entityid = m_row->id
                                        i_name = name ).
    DATA(row) = a->row( ).
    row->rollname = rollname.

  ENDMETHOD.


  METHOD declare_lookup.
    DATA(ent2) = m_ds->declare_entity( i_entname ).
    DATA(ent2row) = ent2->row(   ).
    m_ds->declare_relation( i_name = i_relname
                            i_ent1 = m_row->id
                            i_fname1 = i_fldname
                            i_ent2 = ent2row->id ).

    declare_attribute(
        i_fldname = i_fldname
        i_type    =  ent2row->id_dtel
    ).
  ENDMETHOD.


  METHOD generate.
    DATA: state     TYPE ddgotstate,
          tab_hd    TYPE dd02v,
          tab_tech  TYPE dd09v,
          fields    TYPE STANDARD TABLE OF dd03p,
          dtel_hd   TYPE dd04v,
          dtel_tech TYPE tpara,
          tadir     TYPE tadir.
    IF m_row->tabname IS INITIAL.
      RAISE EXCEPTION TYPE zcx_bc_not_found.
    ENDIF.
    fields = load_ddic_table( ).
    tab_hd = VALUE #(
            tabname    = m_row->tabname
            tabclass   = 'TRANSP'
            ddtext     = |generated from entity {  m_row->name }|
            clidep     = 'X'
            mainflag   = 'X'
            contflag   = 'A' " application table
            exclass    = '1'
            ddlanguage = sy-langu ).

    tab_tech = VALUE #(
                tabname    = m_row->tabname
                as4local   = 'A'
                tabkat     = '0'
                tabart     = 'APPL1'
                bufallow   = 'N'
                roworcolst = 'C'
                as4user    = sy-uname
                as4date    = sy-datum
                as4time    = sy-uzeit ).

    DATA(pos) = CONV numc4( 1 ).
    CLEAR fields[].
    APPEND VALUE #( tabname = m_row->tabname
                    fieldname = 'MANDT' position = pos keyflag = 'X' rollname = 'MANDT' ) TO fields.
    DATA(key) = abap_true.
    LOOP AT attributes( ) INTO DATA(attribute).
      ADD 1 TO pos.
      APPEND VALUE #(
            keyflag = key
            tabname   = m_row->tabname
            fieldname = attribute-name
            position  = pos
            rollname  = attribute-rollname
            scrtext_l = |scrtext_l|
            ddtext    = |ddtext|
            ) TO fields.
      key = abap_false.
    ENDLOOP.
    store_ddic_table(
      EXPORTING
        i_tab_hd   = tab_hd
        i_tab_tech = tab_tech
      CHANGING
        c_fields = fields ).


  ENDMETHOD.


  METHOD load_ddic_dataelement.

    DATA dtel_tech TYPE tpara.
    DATA state TYPE ddgotstate.

    CALL FUNCTION 'DDIF_DTEL_GET'
      EXPORTING
        name          = i_rollname    " Name of the Data Element to be Read
*       state         = 'A'    " Read Status of the Data Element
*       langu         = ' '    " Language in which Texts are Read
      IMPORTING
        gotstate      = state    " Status in which Reading took Place
        dd04v_wa      = r_dtel_hd    " Header of the Data Element
        tpara_wa      = dtel_tech    " Technical Settings of the Table
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
*       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDMETHOD.


  METHOD load_ddic_domain.
    DATA: name   TYPE ddobjname,
          state  TYPE ddgotstate,
          domain TYPE dd01v,
          values TYPE STANDARD TABLE OF dd07v.

    CALL FUNCTION 'DDIF_DOMA_GET'
      EXPORTING
        name          = name    " Name of the Domain to be Read
*       state         = 'A'    " Read Status of the Domain
*       langu         = ' '    " Language in which Texts are Read
      IMPORTING
        gotstate      = state    " Status in which Reading took Place
        dd01v_wa      = domain    " Header of the Domain
      TABLES
        dd07v_tab     = values    " Fixed Domain Values
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDMETHOD.


  METHOD load_ddic_table.

    DATA state TYPE ddgotstate.
    DATA tab_hd TYPE dd02v.
    DATA tab_tech TYPE dd09v.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = m_row->tabname    " Name of the Table to be Read
*       state         = 'A'    " Read Status of the Table
*       langu         = ' '    " Language in which Texts are Read
      IMPORTING
        gotstate      = state    " Status in which Reading took Place
        dd02v_wa      = tab_hd    " Table Header
        dd09l_wa      = tab_tech    " Technical Settings of the Table
      TABLES
        dd03p_tab     = r_fields    " Table Fields
*       dd05m_tab     =     " Foreign Key Fields of the Table
*       dd08v_tab     =     " Foreign Keys of the Table
*       dd12v_tab     =     " Table Indexes
*       dd17v_tab     =     " Index Fields of the Table
*       dd35v_tab     =     " Header of the Search Help Assignments of the Table
*       dd36m_tab     =     " Allocations of the Search Help Assignments of the Table
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_bc_not_found.
    ENDIF.


  ENDMETHOD.


  METHOD row.
    r_result = m_row.
  ENDMETHOD.


  METHOD store_ddic_dataelement.

    DATA dataelement TYPE dd04v.


    dataelement-domname = i_domname.
    dataelement-rollname = i_name.
    CALL FUNCTION 'DDIF_DTEL_PUT'
      EXPORTING
        name              = i_name    " Name of the Data Element to be Written
        dd04v_wa          = dataelement
      EXCEPTIONS
        dtel_not_found    = 1
        name_inconsistent = 2
        dtel_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    store_tadir_entry( i_obj_name = CONV #( i_name ) i_object = 'DTEL' ).


  ENDMETHOD.


  METHOD store_ddic_domain.
    DATA: name   TYPE ddobjname,
          state  TYPE ddgotstate,
          domain TYPE dd01v,
          values TYPE STANDARD TABLE OF dd07v.

    CALL FUNCTION 'DDIF_DOMA_PUT'
      EXPORTING
        name              = name   " Name of the Domain to be Written
        dd01v_wa          = domain
      TABLES
        dd07v_tab         = values    " Table Fields
      EXCEPTIONS
        doma_not_found    = 1
        name_inconsistent = 2
        doma_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    store_tadir_entry( i_obj_name = CONV #( name ) i_object = 'DOMA' ).


  ENDMETHOD.


  METHOD store_ddic_table.

    CALL FUNCTION 'DDIF_TABL_PUT'
      EXPORTING
        name              = m_row->tabname
        dd02v_wa          = i_tab_hd
        dd09l_wa          = i_tab_tech
      TABLES
        dd03p_tab         = c_fields
      EXCEPTIONS
        tabl_not_found    = 1
        name_inconsistent = 2
        tabl_inconsistent = 3
        put_failure       = 4
        put_refused       = 5
        OTHERS            = 6.
    IF sy-subrc <> 0.
      MESSAGE |RC { sy-subrc }| TYPE 'I'.
    ENDIF.

    store_tadir_entry( i_obj_name = CONV #( m_row->tabname ) ).


  ENDMETHOD.


  METHOD store_tadir_entry.

    DATA tadir TYPE tadir.
    DATA: korrnum TYPE e070-trkorr,
          objkey  TYPE e071.




    CALL FUNCTION 'TR_TADIR_INTERFACE'
      EXPORTING
        wi_tadir_pgmid                 = 'R3TR'
        wi_tadir_object                = i_object
        wi_tadir_obj_name              = i_obj_name
        wi_read_only                   = abap_false
        wi_tadir_devclass              = 'ZTEST'
        wi_test_modus                  = abap_false
      IMPORTING
        new_tadir_entry                = tadir
      EXCEPTIONS
        tadir_entry_not_existing       = 1
        tadir_entry_ill_type           = 2
        no_systemname                  = 3
        no_systemtype                  = 4
        original_system_conflict       = 5
        object_reserved_for_devclass   = 6
        object_exists_global           = 7
        object_exists_local            = 8
        object_is_distributed          = 9
        obj_specification_not_unique   = 10
        no_authorization_to_delete     = 11
        devclass_not_existing          = 12
        simultanious_set_remove_repair = 13
        order_missing                  = 14
        no_modification_of_head_syst   = 15
        pgmid_object_not_allowed       = 16
        masterlanguage_not_specified   = 17
        devclass_not_specified         = 18
        specify_owner_unique           = 19
        loc_priv_objs_no_repair        = 20
        gtadir_not_reached             = 21
        object_locked_for_order        = 22
        change_of_class_not_allowed    = 23
        no_change_from_sap_to_tmp      = 24
        OTHERS                         = 25.
    IF sy-subrc > 0.
      MESSAGE |rc { sy-subrc }| TYPE 'I'.
    ENDIF.

*    korrnum = 'NPLK900070'.
    korrnum = 'NPLK900071'.
    objkey = CORRESPONDING #( tadir ).
    objkey-lockflag = abap_true.
*    objkey-trkorr =

    CALL FUNCTION 'TR_APPEND_TO_COMM'
      EXPORTING
        pi_korrnum                     = korrnum    " Order, to be appended
        wi_e071                        = objkey    " Object key
*       wi_simulation                  = ' '    " Flag, 'X' - no database update
*       wi_suppress_key_check          = ' '    " Flag, whether key syntax check suppressed
*  TABLES
*       wt_e071k                       =     " Input/output table E071K
      EXCEPTIONS
        no_authorization               = 1
        no_systemname                  = 2
        no_systemtype                  = 3
        tr_check_keysyntax_error       = 4
        tr_check_obj_error             = 5
        tr_enqueue_failed              = 6
        tr_ill_korrnum                 = 7
        tr_key_without_header          = 8
        tr_lockmod_failed              = 9
        tr_lock_enqueue_failed         = 10
        tr_modif_only_in_modif_order   = 11
        tr_not_owner                   = 12
        tr_no_append_of_corr_entry     = 13
        tr_no_append_of_c_member       = 14
        tr_no_shared_repairs           = 15
        tr_order_not_exist             = 16
        tr_order_released              = 17
        tr_order_update_error          = 18
        tr_repair_only_in_repair_order = 19
        tr_wrong_order_type            = 20
        wrong_client                   = 21
        OTHERS                         = 22.
    IF sy-subrc <> 0.
      MESSAGE |Add to transport RC: { sy-subrc }| TYPE 'I'.
    ENDIF.

  ENDMETHOD.

  METHOD activate_ddic_dtel.
    DATA: rc TYPE sy-subrc.
    CALL FUNCTION 'DDIF_DTEL_ACTIVATE'
      EXPORTING
        name        = i_name   " Name of the Data Element to be Activated
*       auth_chk    = 'X'    " 'X': Perform Author. Check for DB Operations
*       prid        = -1    " ID for Log Writer
      IMPORTING
        rc          = rc    " Result of Activation
      EXCEPTIONS
        not_found   = 1
        put_failure = 2
        OTHERS      = 3.
    IF sy-subrc <> 0 OR rc <> 0.
      MESSAGE |activate  { i_name } failed.| TYPE 'I'.
* MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
