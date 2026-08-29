*&---------------------------------------------------------------------*
*& Include          ZLFIDMC010_TOP
*&---------------------------------------------------------------------*
*& ALV 출력 구조, 인터널 테이블, ALV 객체 선언
*&---------------------------------------------------------------------*

TYPE-POOLS:
  abap,
  icon.

TYPES: BEGIN OF ty_list,

         belnr      TYPE ztfic00030-belnr,
         gjahr      TYPE ztfic00030-gjahr,
         bukrs      TYPE ztfic00030-bukrs,
         lifnr      TYPE ztfic00030-lifnr,

         name1      TYPE ZTMMG00150-name1,
         bldat      TYPE ztfic00030-bldat,
         budat      TYPE ztfic00030-budat,
         zfbdt      TYPE ztfic00030-zfbdt,

         wrbtr      TYPE ztfic00030-wrbtr,
         waers      TYPE ztfic00030-waers,

         status     TYPE ztfic00030-status,
         status_txt TYPE char10,

         apprnm     TYPE ztfic00030-apprnm,
         apprdt     TYPE ztfic00030-apprdt,
         paymdt     TYPE ztfic00030-paymdt,

         sgtxt      TYPE ztfic00020-sgtxt,

         row_color  TYPE c LENGTH 4,

       END OF ty_list.

DATA:
  gt_list TYPE TABLE OF ty_list,
  gs_list TYPE ty_list.

*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA:
  go_container TYPE REF TO cl_gui_custom_container,
  go_grid      TYPE REF TO cl_gui_alv_grid.

*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA:
  gt_fcat   TYPE lvc_t_fcat,
  gs_fcat   TYPE lvc_s_fcat,
  gs_layout TYPE lvc_s_layo.

*---------------------------------------------------------------------*
* OK Code
*---------------------------------------------------------------------*
DATA:
  gv_okcode TYPE sy-ucomm.

*---------------------------------------------------------------------*
* 합계
*---------------------------------------------------------------------*
DATA:
  gv_sel_cnt   TYPE i,
  gv_sel_amt   TYPE ztfic00030-wrbtr,
  gv_total_amt TYPE ztfic00030-wrbtr.
