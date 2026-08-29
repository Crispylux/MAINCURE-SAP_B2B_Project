*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_SEL
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*
TABLES : ZTMMG00070, eban.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECT-OPTIONS:
    so_banfn for eban-banfn,
    so_bnfpo for eban-bnfpo,
    so_bsart for eban-bsart,
    so_statu for eban-statu,
    so_matnr for eban-matnr,
    so_werks for eban-werks,
    so_badat for eban-badat OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-t02.
  SELECTION-SCREEN BEGIN OF LINE.

*    SELECTION-SCREEN COMMENT 1(12) text-s01.

    SELECTION-SCREEN POSITION 15.
    PARAMETERS p_all RADIOBUTTON GROUP rg1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 17(6) text-s02
      FOR FIELD p_all.

    SELECTION-SCREEN POSITION 25.
    PARAMETERS p_wait RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 27(6) text-s03
      FOR FIELD p_wait.

    SELECTION-SCREEN POSITION 35.
    PARAMETERS p_appr RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 37(6) text-s04
      FOR FIELD p_appr.

    SELECTION-SCREEN POSITION 45.
    PARAMETERS p_paid RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 47(10) text-s05
      FOR FIELD p_paid.

  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b02.
*&---------------------------------------------------------------------*
*& Form zz_set_initial_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_initial_value .
  REFRESH so_badat.

  APPEND INITIAL LINE TO so_badat ASSIGNING FIELD-SYMBOL(<fs_badat>).

  <fs_badat>-sign   = 'I'.
  <fs_badat>-option = 'BT'.
  <fs_badat>-low    = sy-datum - 500.
  <fs_badat>-high   = sy-datum.
ENDFORM.
