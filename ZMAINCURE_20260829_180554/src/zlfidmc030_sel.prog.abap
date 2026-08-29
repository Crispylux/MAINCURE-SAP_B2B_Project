*&---------------------------------------------------------------------*
*& Include          ZLFIDMC030_SEL
*&---------------------------------------------------------------------*
*& Selection Screen
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-t01.

  SELECT-OPTIONS:
    so_bukrs FOR ztfic00050-bukrs OBLIGATORY,  " 회사코드
    so_kunnr FOR ztfic00050-kunnr,             " 고객번호
    so_vbeln FOR ztfic00050-vbeln,             " Billing 번호
    so_fkdat FOR ztsds00030-fkdat,             " 청구일자(SD)
    so_gjahr FOR ztfic00010-gjahr NO INTERVALS " 회계년도
                                  NO-EXTENSION.

  SELECTION-SCREEN BEGIN OF LINE.

    SELECTION-SCREEN COMMENT 1(12) TEXT-r01.

    SELECTION-SCREEN POSITION 15.
    PARAMETERS pa_all RADIOBUTTON GROUP rg1 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 17(6) TEXT-r02 FOR FIELD pa_all.

    SELECTION-SCREEN POSITION 25.
    PARAMETERS pa_uniss RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 27(6) TEXT-r02 FOR FIELD pa_uniss.

    SELECTION-SCREEN POSITION 35.
    PARAMETERS pa_issd RADIOBUTTON GROUP rg1.
    SELECTION-SCREEN COMMENT 37(6) TEXT-r03 FOR FIELD pa_issd.

  SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN END OF BLOCK b01.
