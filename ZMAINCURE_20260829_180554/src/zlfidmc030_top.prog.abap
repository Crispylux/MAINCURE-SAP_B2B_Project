*&---------------------------------------------------------------------*
*& Include          ZLFIDMC030_TOP
*&---------------------------------------------------------------------*
*& FI-AR 세금계산서 프로그램
*& ALV 출력 구조, 인터널 테이블, ALV 객체 선언
*&---------------------------------------------------------------------*
TYPE-POOLS :
  abap,
  icon.

*---------------------------------------------------------------------*
* TABLES
*---------------------------------------------------------------------*
TABLES : ztfic00050,
         ztsds00030,
         ztfic00010.

*---------------------------------------------------------------------*
* 상단 ALV - 미수금 채권 리스트
*---------------------------------------------------------------------*
TYPES : BEGIN OF ty_list,
          vbeln      TYPE ztfic00050-vbeln,       " Billing 번호
          fkdat      TYPE ztsds00030-fkdat,       " 청구일자
          kunnr      TYPE ztfic00050-kunnr,       " 고객번호
          name1      TYPE kna1-name1,             " 고객명
          stceg      TYPE kna1-stceg,             " 사업자번호
          net_amt    TYPE ztfic00050-netwr,       " 공급가액(세금제외)
          tax_amt    TYPE ztfic00050-wrbtr,       " 부가세
          tot_amt    TYPE ztfic00050-wrbtr,       " 합계금액
          waers      TYPE ztfic00050-waers,       " 통화
          issue_stat TYPE ztfic00090-issue_stat,  " 발행상태
          tax_no     TYPE ztfic00090-tax_no,      " 세금계산서번호
          issue_dt   TYPE ztfic00090-issue_dt,    " 발행일자
          issue_by   TYPE ztfic00090-issue_by,    " 발행자
        END OF ty_list.

DATA : gt_list TYPE TABLE OF ty_list,
       gs_list TYPE ty_list.

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

*---------------------------------------------------------------------*
* OK Code
*---------------------------------------------------------------------*
DATA : gv_okcode  TYPE sy-ucomm,
       gv_save_ok TYPE sy-ucomm.
