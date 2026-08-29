*&---------------------------------------------------------------------*
*& Include          ZLFIDMC050_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS : abap, icon, vrm.

*----------------------------------------------------------------------*
* TABLES
*----------------------------------------------------------------------*
TABLES : ztfic00010, ztfic00020, ztfic00120.
*----------------------------------------------------------------------*
* 2000번 회면 ALV
*----------------------------------------------------------------------*
TYPES : BEGIN OF ty_list,
          zbelnr    TYPE ztfic00020-belnr,
          gjahr     TYPE ztfic00020-gjahr,
          monat     TYPE ztfic00010-monat,
          close_tp  TYPE ztfic00120-close_tp,
          bldat     TYPE ztfic00120-bldat,
          total_amt TYPE ztfic00120-total_amt,
          waers     TYPE ztfic00120-waers,
          status    TYPE ztfic00120-status,
          belnr     TYPE ztfic00010-belnr,
          note      TYPE ztfic00120-note,
          ernam     TYPE ztfic00120-ernam,
          erdat     TYPE ztfic00120-erdat,
        END OF ty_list.


DATA : gt_list TYPE TABLE OF ty_list,
       gs_list TYPE ty_list.

*----------------------------------------------------------------------*
* 3000번 화면 - 헤더
*----------------------------------------------------------------------*
TYPES : BEGIN OF ty_header,
          zbelnr   TYPE ztfic00120-zbelnr,
          gjahr    TYPE ztfic00120-gjahr,
          monat    TYPE ztfic00120-monat,
          close_tp TYPE ztfic00120-close_tp,
          bldat    TYPE ztfic00120-bldat,
          waers    TYPE ztfic00120-waers,
          status   TYPE ztfic00120-status,
          note     TYPE ztfic00120-note,
        END OF ty_header.


DATA : gs_header TYPE ty_header.

*----------------------------------------------------------------------*
* 3000번 화면 - 항목 ALV
*----------------------------------------------------------------------*
TYPES : BEGIN OF ty_item,
          buzei     TYPE ZTFIC00130-buzei,
          hkont     TYPE ZTFIC00130-hkont,
          hkont_txt TYPE char30,
          shkzg     TYPE ZTFIC00130-shkzg,
          dmbtr     TYPE ZTFIC00130-dmbtr,
          waers     TYPE ZTFIC00130-WAERS,
          kostl     TYPE ZTFIC00130-kostl,
          sgtxt     TYPE ZTFIC00130-sgtxt,
        END OF ty_item.

DATA : gt_item TYPE TABLE OF ty_item,
       gs_item TYPE ty_item.

*----------------------------------------------------------------------*
* 2000번 화면  ALV Object
*----------------------------------------------------------------------*
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_grid      TYPE REF TO cl_gui_alv_grid.

*----------------------------------------------------------------------*
* 2000번 화면 ALV Field Catalog / Layout
*----------------------------------------------------------------------*
DATA : gt_fcat   TYPE lvc_t_fcat,
       gs_fcat   TYPE lvc_s_fcat,
       gs_layout TYPE lvc_s_layo.

*----------------------------------------------------------------------*
* 3000번 화면  ALV Object
*----------------------------------------------------------------------*

DATA : go_item_container TYPE REF TO cl_gui_custom_container,
       go_item_grid      TYPE REF TO cl_gui_alv_grid.

*----------------------------------------------------------------------*
* 3000번 화면 ALV Field Catalog / Layout
*----------------------------------------------------------------------*
DATA : gt_item_fcat TYPE lvc_t_fcat,
       gs_item_fcat TYPE lvc_s_fcat,
       gs_item_layo TYPE lvc_s_layo.

*----------------------------------------------------------------------*
* 3000번 화면 합계 변수
*----------------------------------------------------------------------*
DATA : gv_debit  TYPE dmbtr,
       gv_credit TYPE dmbtr,
       gv_diff   TYPE dmbtr.

*----------------------------------------------------------------------*
* OK Code
*----------------------------------------------------------------------*
DATA: gv_okcode  TYPE sy-ucomm,
      gv_save_ok TYPE sy-ucomm.
