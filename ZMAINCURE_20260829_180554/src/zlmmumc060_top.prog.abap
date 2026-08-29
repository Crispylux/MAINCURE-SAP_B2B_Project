*&---------------------------------------------------------------------*
*& Include          ZLMMUMC060_TOP
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*
* Database Tables는 끝에 번호 3자리만 사용.
* EX) gt_060, lt_060...
*---------------------------------------------------------------------*
* Types
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_060,
  ebeln TYPE ekko-ebeln,    " PO번호
  ebelp TYPE ekpo-ebelp,    " PO라인
  bukrs TYPE ekko-bukrs,    " 회사코드
  bsart TYPE ekko-bsart,    " PO유형
  lifnr TYPE ekko-lifnr,    " 공급업체
  ekgrp TYPE ekko-ekgrp,    " 구매그룹
  bedat TYPE ekko-bedat,    " PO일자
  matnr TYPE ekpo-matnr,    " 자재번호
  maktx TYPE makt-maktx,    " 자재명
  werks TYPE ekpo-werks,    " 플랜트
  menge TYPE ekpo-menge,    " 수량
  meins TYPE ekpo-meins,    " 단위
  netpr TYPE ekpo-netpr,    " 단가
  netwr TYPE ekpo-netwr,    " 순가액
  waers TYPE ekko-waers,    " 통화
  eindt TYPE ekpo-eildt,    " 납기일
END OF ty_060.

*---------------------------------------------------------------------*
* Internal Tables
*---------------------------------------------------------------------*
DATA : gt_060 TYPE TABLE OF ty_060,
       gs_060 TYPE ty_060.

*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA : go_container TYPE REF TO cl_gui_custom_container,
       go_grid      TYPE REF TO cl_gui_alv_grid.

*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA : gt_fcat   TYPE lvc_t_fcat,
       gs_fcat   TYPE lvc_s_fcat,
       gs_layout TYPE lvc_s_layo.

DATA : gt_exclude TYPE ui_functions.

*---------------------------------------------------------------------*
* Mode (A=승인 R=반려)
*---------------------------------------------------------------------*
DATA : gv_mode TYPE c VALUE 'A'.
