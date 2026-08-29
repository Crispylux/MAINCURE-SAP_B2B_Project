*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_TOP
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*
* Database Tables는 끝에 번호 3자리만 사용.
* EX) gt_010, lt_010...
*&--------------------------------------------------------------------*
* Class
*---------------------------------------------------------------------*
CLASS lcl_event_receiver DEFINITION DEFERRED.
DATA go_event_receiver TYPE REF TO lcl_event_receiver. "이벤트 용
*---------------------------------------------------------------------*
* Internal Tables
*---------------------------------------------------------------------*
DATA : gt_070 TYPE TABLE OF ztmmg00070,
       gt_040 TYPE TABLE OF ztmmg00040. "EBAN

*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_grid      TYPE REF TO cl_gui_alv_grid.

DATA : go_container2 TYPE REF TO cl_gui_custom_container,
       go_grid2      TYPE REF TO cl_gui_alv_grid.

DATA : go_container3 TYPE REF TO cl_gui_custom_container,
       go_grid3      TYPE REF TO cl_gui_alv_grid.
*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA : gt_fcat    TYPE lvc_t_fcat,
       gs_fcat    TYPE lvc_s_fcat,
       gt_fcat2   TYPE lvc_t_fcat,
       gs_fcat2   TYPE lvc_s_fcat,

       gt_fcat3   TYPE lvc_t_fcat,
       gs_fcat3   TYPE lvc_s_fcat,

       gs_layout1 TYPE lvc_s_layo,
       gs_layout2 TYPE lvc_s_layo,
       gs_layout3 TYPE lvc_s_layo.

DATA : gt_exclude TYPE ui_functions.

DATA: gt_070_detail TYPE TABLE OF ztmmg00070,
      gv_banfn      TYPE ztmmg00070-banfn.

DATA : gv_matnr TYPE ztmmg00040-matnr,
       gv_lgort TYPE ztmmg00040-lgort.
