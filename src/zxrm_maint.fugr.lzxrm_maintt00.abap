*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 28.02.2020 at 19:57:53
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZXRM_APP_STATE..................................*
DATA:  BEGIN OF STATUS_ZXRM_APP_STATE                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZXRM_APP_STATE                .
CONTROLS: TCTRL_ZXRM_APP_STATE
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZXRM_APP_STATE                .
TABLES: ZXRM_APP_STATE                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
