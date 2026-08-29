*&---------------------------------------------------------------------*
*& Include          ZRPP00010_TOP
*&---------------------------------------------------------------------*
*& ALV 출력 구조, 인터널 테이블, ALV 객체 선언
*&---------------------------------------------------------------------*

TYPE-POOLS:
  abap,
  icon.

TYPES: BEGIN OF ty_list,
         mark           TYPE c,
         vbeln          TYPE ZTSDS00010-vbeln,
         posnr          TYPE ZTSDS00020-posnr,
         matnr          TYPE ZTSDS00020-matnr,
         maktx          TYPE ZTMMG00020-maktx,
         kwmeng         TYPE ZTSDS00020-kwmeng,
         vrkme          TYPE ZTSDS00020-vrkme,
         edatu          TYPE ZTSDS00010-vdatu,
         labst          TYPE ZTMMG00040-labst,
         plan_qty       TYPE ZTPPK00030-gsmng,
         plan_date      TYPE ZTPPK00030-psttr,
         pldord_profile TYPE ZTPPK00030-PAART,
         plnum          TYPE ZTPPK00030-plnum,
         status_icon    TYPE icon_d,

         cell_style     TYPE lvc_t_styl,
         row_color      TYPE c LENGTH 4,

       END OF ty_list.

DATA:
  gt_list TYPE TABLE OF ty_list,
  gs_list TYPE ty_list.

FIELD-SYMBOLS:
  <fs_list> TYPE ty_list.

*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA:
  go_container  TYPE REF TO cl_gui_custom_container,
  go_splitter   TYPE REF TO cl_gui_splitter_container,
  go_con_left   TYPE REF TO cl_gui_container,
  go_con_mid    TYPE REF TO cl_gui_container,
  go_con_rgt    TYPE REF TO cl_gui_container.

DATA:
  go_grid_left  TYPE REF TO cl_gui_alv_grid,
  go_grid_mid   TYPE REF TO cl_gui_alv_grid,
  go_grid_rgt   TYPE REF TO cl_gui_alv_grid.

*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA:
  gt_fcat   TYPE lvc_t_fcat,
  gs_fcat   TYPE lvc_s_fcat,
  gs_layout TYPE lvc_s_layo,
  gs_layout_rgt TYPE lvc_s_layo.

*---------------------------------------------------------------------*
* 우측 하단  ALV 전용 데이터 구조 선언
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_rgt,
         vbeln    TYPE ztsds00010-vbeln,
         matnr    TYPE ZTSDS00020-matnr,
         plnum    TYPE ZTPPK00030-plnum,
         posnr    TYPE ZTSDS00020-posnr,
         werks    TYPE ZTMMG00040-werks,
         plan_qty TYPE ZTPPK00030-gsmng,
         kwmeng   TYPE ZTSDS00020-kwmeng,
         vrkme    TYPE ZTSDS00020-vrkme,
       END OF ty_rgt.

DATA:
  gt_list_rgt TYPE TABLE OF ty_rgt,
  gs_list_rgt TYPE ty_rgt.

DATA:
  gt_fcat_rgt TYPE lvc_t_fcat,
  gs_fcat_rgt TYPE lvc_s_fcat.

*---------------------------------------------------------------------*
* 중간 ALV 전용 데이터 구조 선언
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_mid,
         plnum TYPE ZTPPK00030-plnum,
         gubun TYPE c LENGTH 20,
         psttr TYPE ZTPPK00030-psttr,
         pedtr TYPE ZTPPK00030-pedtr,
       END OF ty_mid.

DATA: gt_list_mid   TYPE TABLE OF ty_mid,
      gs_list_mid   TYPE ty_mid.

DATA: gt_fcat_mid   TYPE lvc_t_fcat,
      gs_fcat_mid   TYPE lvc_s_fcat,
      gs_layout_mid TYPE lvc_s_layo.

*---------------------------------------------------------------------*
*  ALV Top-of-Page (아이콘 설명) 전용 객체
*---------------------------------------------------------------------*
DATA: go_splitter_left TYPE REF TO cl_gui_splitter_container,
      go_con_left_top  TYPE REF TO cl_gui_container,
      go_con_left_alv  TYPE REF TO cl_gui_container.

DATA: go_dyndoc        TYPE REF TO cl_dd_document,
      go_html_viewer   TYPE REF TO cl_gui_html_viewer.
*---------------------------------------------------------------------*
* OK Code
*---------------------------------------------------------------------*
DATA:
  gv_okcode TYPE sy-ucomm.

*---------------------------------------------------------------------*
* 합계 및 상태 제어 변수
*---------------------------------------------------------------------*
DATA:
  gv_sel_cnt   TYPE i,
  gv_total_qty TYPE plaf-gsmng,
  gv_tmp_seq   TYPE i.
