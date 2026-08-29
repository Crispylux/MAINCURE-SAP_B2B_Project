*&---------------------------------------------------------------------*
*& Include          ZLFIDMC020_TOP
*&---------------------------------------------------------------------*
*& FI-AR 수금/반제 프로그램
*& ALV 출력 구조, 인터널 테이블, ALV 객체 선언
*&---------------------------------------------------------------------*

TYPE-POOLS:
  abap,
  icon.

*---------------------------------------------------------------------*
* TABLES
*---------------------------------------------------------------------*
TABLES:
  ztfic00010,   "회계 전표 헤더
  ztfic00050.   "고객 미결 항목

*---------------------------------------------------------------------*
* 상단 ALV - 고객 미결 항목 / 미수금
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_ar_open,

         belnr      TYPE ztfic00050-belnr,    "전표번호
         gjahr      TYPE ztfic00050-gjahr,    "회계연도
         kunnr      TYPE ztfic00050-kunnr,    "고객번호
         name1      TYPE char40,              "고객명
         vbeln      TYPE ztfic00050-vbeln,    "Billing번호
         bldat      TYPE ztfic00010-bldat,    "전표일자
         zfbdt      TYPE ztfic00050-zfbdt,    "만기일
         netwr      TYPE ztfic00050-netwr,    "원금
         wrbtr      TYPE ztfic00050-wrbtr,    "미수잔액
         waers      TYPE ztfic00050-waers,    "통화
         status     TYPE ztfic00050-status,   "상태
         status_txt TYPE char10,              "상태 텍스트
         zterm      TYPE ztfic00050-zterm,    "지급조건

       END OF ty_ar_open.

DATA: gt_ar_open TYPE TABLE OF ty_ar_open,
      gs_ar_open TYPE ty_ar_open.

*---------------------------------------------------------------------*
* 하단 ALV - 수금 이력
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_ar_rcpt,

         rcpt_no   TYPE ztfic00070-rcpt_no,    "수금번호
         rcpt_dt   TYPE ztfic00070-rcpt_dt,    "수금일자
         rcpt_amt  TYPE ztfic00070-rcpt_amt,   "수금금액
         waers     TYPE ztfic00070-waers,      "통화
         clear_dt  TYPE ztfic00080-clear_dt,   "반제일
         clear_amt TYPE ztfic00080-clear_amt,  "반제금액
         note      TYPE ztfic00070-note,       "비고
         ernam     TYPE ztfic00070-ernam,      "등록자

       END OF ty_ar_rcpt.

DATA : gt_ar_rcpt TYPE TABLE OF ty_ar_rcpt,
       gs_ar_rcpt TYPE ty_ar_rcpt.

*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA:
  go_container TYPE REF TO cl_gui_custom_container,
  go_splitter  TYPE REF TO cl_gui_splitter_container,
  go_cont_top  TYPE REF TO cl_gui_container,
  go_cont_bot  TYPE REF TO cl_gui_container,
  go_grid_top  TYPE REF TO cl_gui_alv_grid,
  go_grid_bot  TYPE REF TO cl_gui_alv_grid.

*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA:
  gt_fcat_top   TYPE lvc_t_fcat,
  gs_fcat_top   TYPE lvc_s_fcat,
  gt_fcat_bot   TYPE lvc_t_fcat,
  gs_fcat_bot   TYPE lvc_s_fcat,
  gs_layout_top TYPE lvc_s_layo,
  gs_layout_bot TYPE lvc_s_layo.

*---------------------------------------------------------------------*
* OK Code
*---------------------------------------------------------------------*
DATA:
  gv_okcode  TYPE sy-ucomm,
  gv_save_ok TYPE sy-ucomm.
