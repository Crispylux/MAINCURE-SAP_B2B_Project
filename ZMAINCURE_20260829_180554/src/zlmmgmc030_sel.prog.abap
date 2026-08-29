*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_SEL
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*
TABLES : ZTMMG00070, eban, ekpo, ekko.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.

SELECT-OPTIONS:
  so_banfn FOR eban-banfn,   "구매요청번호
  so_bnfpo FOR eban-bnfpo,   "구매요청품목
  so_ebeln FOR ekpo-ebeln,   "구매오더번호
  so_ebelp FOR ekpo-ebelp,   "구매오더품목
  so_lifnr FOR ekko-lifnr,   "공급업체
  so_matnr FOR ekpo-matnr,   "자재
  so_werks FOR ekpo-werks,   "플랜트
  so_lgort FOR ekpo-lgort,   "저장위치
  so_bedat FOR ekko-bedat.   "PO 증빙일

SELECTION-SCREEN END OF BLOCK b1.
*&---------------------------------------------------------------------*
*& Form zz_set_initial_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_initial_value .
  REFRESH so_bedat.

  APPEND INITIAL LINE TO so_bedat ASSIGNING FIELD-SYMBOL(<fs_bedat>).

  <fs_bedat>-sign   = 'I'.
  <fs_bedat>-option = 'BT'.
  <fs_bedat>-low    = sy-datum - 500.
  <fs_bedat>-high   = sy-datum.
ENDFORM.
