*&---------------------------------------------------------------------*
*& Include          ZLFIDMC020_SEL
*&---------------------------------------------------------------------*
*& Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECT-OPTIONS:
    so_bukrs FOR ztfic00050-bukrs OBLIGATORY,  "회사코드
    so_kunnr FOR ztfic00050-kunnr,             "고객번호
    so_vbeln FOR ztfic00050-vbeln,             "Billing 번호
    so_bldat FOR ztfic00010-bldat,             "전표일자
    so_zfbdt FOR ztfic00050-zfbdt.             "만기일

  PARAMETERS:
    pa_gjahr TYPE ztfic00010-gjahr OBLIGATORY. "회계연도

  SELECTION-SCREEN SKIP 1.

  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN COMMENT 1(12) text-r01.

    SELECTION-SCREEN POSITION 15.
    PARAMETERS p_all RADIOBUTTON GROUP rg1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 17(6) text-r02
      FOR FIELD p_all.

   SELECTION-SCREEN POSITION 25.
    PARAMETERS p_open RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 27(6) text-r03
      FOR FIELD p_open.

   SELECTION-SCREEN POSITION 35.
    PARAMETERS p_part RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 37(6) text-r04
      FOR FIELD p_part.

    SELECTION-SCREEN POSITION 45.
    PARAMETERS p_done RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 47(6) text-r05
      FOR FIELD p_done.

  SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK b01.
