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
*CLASS lcl_event_receiver DEFINITION DEFERRED.
*DATA go_event_receiver TYPE REF TO lcl_event_receiver. "이벤트 용


*---------------------------------------------------------------------*
* Internal Tables
*---------------------------------------------------------------------*
" 구매요청 생성
DATA : gt_070 TYPE TABLE OF ztmmg00070. "EBAN

" 업체 확인
DATA : gt_150 TYPE TABLE OF zsmmgmc010.


*---------------------------------------------------------------------*
* Global Variables
*---------------------------------------------------------------------*
" 업체 조회 검색조건
DATA : gv_matnr TYPE ztmmg00120-matnr,
       gv_lifnr TYPE ztmmg00120-lifnr.


*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
" 구매요청 생성
DATA : go_container1 TYPE REF TO cl_gui_custom_container,
       go_grid1      TYPE REF TO cl_gui_alv_grid.

" 업체 확인
DATA : go_container2 TYPE REF TO cl_gui_custom_container,
       go_grid2      TYPE REF TO cl_gui_alv_grid.


*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
" 구매요청 생성
DATA : gt_fcat1   TYPE lvc_t_fcat,
       gs_fcat1   TYPE lvc_s_fcat,
       gs_layout1 TYPE lvc_s_layo.

" 업체 확인
DATA : gt_fcat2   TYPE lvc_t_fcat,
       gs_fcat2   TYPE lvc_s_fcat,
       gs_layout2 TYPE lvc_s_layo.


*---------------------------------------------------------------------*
* ALV Toolbar Exclude
*---------------------------------------------------------------------*
DATA : gt_exclude1 TYPE ui_functions,
       gt_exclude2 TYPE ui_functions.
