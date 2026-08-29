*&---------------------------------------------------------------------*
*& Include          ZLPPKMC010_SEL
*&---------------------------------------------------------------------*
*& 조회 조건 화면
*&---------------------------------------------------------------------*

TABLES: ZTSDS00010, ZTSDS00020, ZTMMG00040.

SELECTION-SCREEN BEGIN OF SCREEN 101 AS SUBSCREEN.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-t01.

  SELECT-OPTIONS:
    so_vbeln FOR ZTSDS00010-vbeln,
    so_matnr FOR ZTSDS00020-matnr,
    so_kunnr FOR ZTSDS00010-kunnr NO INTERVALS,
    "so_spart FOR ZTSDS00010-spart NO INTERVALS,
    so_vdatu FOR ZTSDS00010-vdatu.

SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN END OF SCREEN 101.
