*&---------------------------------------------------------------------*
*& Include          ZLPPKMC020_SEL
*&---------------------------------------------------------------------*

TABLES: ztppk00030, ztmmg00010.

*---------------------------------------------------------------------*
* 생산계획 조회 조건
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 101 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-t01.
    SELECT-OPTIONS: so_plnum FOR ztppk00030-plnum,
                    so_gubun FOR ztppk00030-plnum NO INTERVALS,
                    so_matnr FOR ztmmg00010-matnr,
                    so_werks FOR ztppk00030-plnum NO INTERVALS,
                    so_psttr FOR ztppk00030-psttr.
  SELECTION-SCREEN END OF BLOCK b01.
SELECTION-SCREEN END OF SCREEN 101.

*---------------------------------------------------------------------*
* MRP 조회 조건
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 102 AS SUBSCREEN.
  SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-t02.
    SELECT-OPTIONS: so_mrpno FOR ztppk00030-plnum NO INTERVALS,
                    so_mplnm FOR ztppk00030-plnum NO INTERVALS,
                    so_mpstt FOR ztppk00030-psttr NO INTERVALS,
                    so_quatr FOR ztppk00030-plnum NO INTERVALS.
  SELECTION-SCREEN END OF BLOCK b02.
SELECTION-SCREEN END OF SCREEN 102.
