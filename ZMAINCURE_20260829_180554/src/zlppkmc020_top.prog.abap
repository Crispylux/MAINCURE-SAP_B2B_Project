*&---------------------------------------------------------------------*
*& Include          ZLPPKMC020_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: icon.

DATA: gv_okcode   TYPE sy-ucomm,
      gv_scr_mode TYPE c LENGTH 1 VALUE '1',
      gv_dynnr    TYPE sy-dynnr.

DATA: gt_extab TYPE TABLE OF sy-ucomm.

"생산계획 헤더
TYPES: BEGIN OF ty_plan_hdr,
         status_icon TYPE icon_d,
         plnum       TYPE ztppk00030-plnum,
         plan_type   TYPE c LENGTH 20,
         psttr       TYPE ztppk00030-psttr,
         pedtr       TYPE ztppk00030-pedtr,
       END OF ty_plan_hdr.

"생산계획 아이템
TYPES: BEGIN OF ty_plan_itm,
         plnum   TYPE ztppk00030-plnum,
         posnr   TYPE n LENGTH 4,
         matnr   TYPE ztmmg00010-matnr,
         maktx   TYPE ztmmg00020-maktx,
         werks   TYPE ztmmg00030-werks,
         name1   TYPE ztmmg00160-name1,
         gsmng   TYPE ztppk00030-gsmng,
         meins   TYPE ztmmg00010-meins,
       END OF ty_plan_itm.

"MRP 헤더
TYPES: BEGIN OF ty_mrp_hdr,
         mrp_no    TYPE c LENGTH 10,
         plnum     TYPE ztppk00030-plnum,
         plan_type TYPE c LENGTH 20,
         psttr     TYPE ztppk00030-psttr,
         pedtr     TYPE ztppk00030-pedtr,
       END OF ty_mrp_hdr.

"MRP 아이템
TYPES: BEGIN OF ty_mrp_itm,
         bom_matnr TYPE ztmmg00010-matnr,
         bom_maktx TYPE ztmmg00020-maktx,
         posnr     TYPE n LENGTH 4,
         req_qty   TYPE ztmmg00090-menge,
         avl_qty   TYPE ztmmg00040-labst,
         need_qty  TYPE ztmmg00090-menge,
         meins     TYPE ztmmg00010-meins,
         werks     TYPE ztmmg00030-werks,
       END OF ty_mrp_itm.

"구매요청 목록
TYPES: BEGIN OF ty_pr_list,
         pr_no     TYPE banfn,
         matnr     TYPE ztmmg00010-matnr,
         maktx     TYPE ztmmg00020-maktx,
         werks     TYPE ztmmg00030-werks,
         lgort     TYPE ztmmg00040-lgort,
         menge     TYPE ztmmg00070-menge,
         meins     TYPE ztmmg00010-meins,
         lfdat     TYPE ztmmg00070-lfdat,
       END OF ty_pr_list.


DATA: gt_plan_hdr TYPE TABLE OF ty_plan_hdr, gs_plan_hdr TYPE ty_plan_hdr,
      gt_plan_itm TYPE TABLE OF ty_plan_itm, gs_plan_itm TYPE ty_plan_itm,
      gt_mrp_hdr  TYPE TABLE OF ty_mrp_hdr,  gs_mrp_hdr  TYPE ty_mrp_hdr,
      gt_mrp_itm  TYPE TABLE OF ty_mrp_itm,  gs_mrp_itm  TYPE ty_mrp_itm,
      gt_pr_list  TYPE TABLE OF ty_pr_list,  gs_pr_list  TYPE ty_pr_list.


DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_splitter  TYPE REF TO cl_gui_splitter_container,
      go_split_lft TYPE REF TO cl_gui_splitter_container.

DATA: go_con_left  TYPE REF TO cl_gui_container,
      go_con_right TYPE REF TO cl_gui_container,
      go_con_ltop  TYPE REF TO cl_gui_container,
      go_con_lbot  TYPE REF TO cl_gui_container.

DATA: go_grid_plan_hdr TYPE REF TO cl_gui_alv_grid,
      go_grid_plan_itm TYPE REF TO cl_gui_alv_grid,
      go_grid_mrp_hdr  TYPE REF TO cl_gui_alv_grid,
      go_grid_mrp_itm  TYPE REF TO cl_gui_alv_grid,
      go_grid_pr       TYPE REF TO cl_gui_alv_grid.

DATA: gt_fcat TYPE lvc_t_fcat, gs_fcat TYPE lvc_s_fcat,
      gs_layo TYPE lvc_s_layo.


CLASS lcl_event_receiver DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_double_click_plan FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column,
      handle_double_click_mrp FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.
ENDCLASS.

DATA: go_event_receiver TYPE REF TO lcl_event_receiver.
