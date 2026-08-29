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
DATA : gt_070 type table of ztmmg00070. "EBAN
*---------------------------------------------------------------------*
* Class
*---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION DEFERRED.
DATA: go_event_receiver TYPE REF TO lcl_event_handler.
*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_grid      TYPE REF TO cl_gui_alv_grid,
       go_handler   TYPE REF TO lcl_event_handler.

*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA : gt_fcat   TYPE lvc_t_fcat,
       gs_fcat   TYPE lvc_s_fcat,
       gs_layout TYPE lvc_s_layo.

DATA : gt_exclude TYPE ui_functions.
*---------------------------------------------------------------------*
* Global Values
*---------------------------------------------------------------------*
DATA: gv_wait_cnt   TYPE i,
      gv_done_cnt   TYPE i,
      gv_reject_cnt TYPE i.
