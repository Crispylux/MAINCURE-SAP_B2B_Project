*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_SEL
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*
TABLES : ZTMMG00070, eban, ekko.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECT-OPTIONS:
    so_ebeln for ekko-ebeln,
    so_bedat for ekko-bedat OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b01.
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
