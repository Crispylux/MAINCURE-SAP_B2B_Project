*&---------------------------------------------------------------------*
*& Include          ZLPPJMC030_SEL
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* Data Reference
*----------------------------------------------------------------------*
DATA: gv_aufnr TYPE ztppk00050-aufnr,
      gv_plnum TYPE ztppk00030-plnum,
      gv_matnr TYPE ztppk00060-matnr,
      gv_gstrp TYPE ztppk00050-gstrp.

*----------------------------------------------------------------------*
* Selection Screen
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

  " 1. 생산오더 번호 (From ~ To 범위)
  SELECT-OPTIONS: s_aufnr FOR gv_aufnr.

  " 2. 생산계획 번호 (From ~ To 범위)
  SELECT-OPTIONS: s_plnum FOR gv_plnum.

  " 3. 자재번호 (사진처럼 'to' 입력을 숨기고 단일/복수선택 버튼만 제공할 때: NO INTERVALS)
  SELECT-OPTIONS: s_matnr FOR gv_matnr NO INTERVALS.

  " 4. 플랜트 코드 (일반 입력 파라미터 / 필수 지정)
  PARAMETERS: p_werks TYPE ztmmg00030-werks OBLIGATORY DEFAULT 'P001'.

  " 5. 계획 날짜 (년/월 통합하여 날짜 범위 입력)
  SELECT-OPTIONS: s_gstrp FOR gv_gstrp.

SELECTION-SCREEN END OF BLOCK b1.
