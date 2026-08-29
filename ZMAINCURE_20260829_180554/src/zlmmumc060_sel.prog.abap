*&---------------------------------------------------------------------*
*& Include          ZLMMUMC060_SEL
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*

TABLES : ekko, ekpo.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.
  SELECT-OPTIONS:
    so_ebeln FOR ekko-ebeln,
    so_bsart FOR ekko-bsart,
    so_lifnr FOR ekko-lifnr,
    so_bukrs FOR ekko-bukrs,
    so_matnr FOR ekpo-matnr,
    so_werks FOR ekpo-werks,
    so_bedat FOR ekko-bedat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b01.
