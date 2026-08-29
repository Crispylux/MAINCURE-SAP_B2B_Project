*&---------------------------------------------------------------------*
* 모듈/서브모듈    : PP/PPK
* Program ID  : ZLPPKMC010
* Desc        : [PP] 자재 소요량 계획 및 구매 요청 생성  프로그램
* Transaction : ZLPPKMC020
* Creator     : 김태희
* Create day  : 2026.06.24
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.24    김태희              최초작성
*&---------------------------------------------------------------------*
REPORT ZLPPKMC020 MESSAGE-ID 00.

INCLUDE ZLPPKMC020_TOP.
INCLUDE ZLPPKMC020_SEL.
INCLUDE ZLPPKMC020_F01.
INCLUDE ZLPPKMC020_PBO.
INCLUDE ZLPPKMC020_PAI.

INITIALIZATION.
  PERFORM set_initial_value.

START-OF-SELECTION.
  CALL SCREEN 100.
