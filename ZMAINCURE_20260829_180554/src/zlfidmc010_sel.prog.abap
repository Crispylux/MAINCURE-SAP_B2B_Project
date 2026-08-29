*&---------------------------------------------------------------------*
*& Include          ZLFIDMC010_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Include          ZLFICMC010_SEL
*&---------------------------------------------------------------------*

TABLES : ztfic00010, ztfic00030.

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECT-OPTIONS:
    so_bukrs FOR ztfic00030-bukrs OBLIGATORY,
    so_lifnr FOR ztfic00030-lifnr,
    so_bldat FOR ztfic00010-bldat,
    so_budat FOR ztfic00030-budat,
    so_zfbdt FOR ztfic00030-zfbdt.

  PARAMETERS:
    pa_gjahr TYPE ztfic00010-gjahr OBLIGATORY.

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN COMMENT 1(12) text-s01.

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

SELECTION-SCREEN END OF BLOCK b01.
