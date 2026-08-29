*&---------------------------------------------------------------------*
* 모듈/서브모듈    : PP/PPK
* Program ID  : ZLPPKMC010
* Desc        : [PP] 생산 계획 생성  프로그램
* Transaction : ZLPPKMC010
* Creator     : 김태희
* Create day  : 2026.06.24
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.24    김태희              최초작성
*&---------------------------------------------------------------------*
REPORT ZLPPKMC010 MESSAGE-ID 00.

INCLUDE ZLPPKMC010_TOP.
INCLUDE ZLPPKMC010_SEL.
INCLUDE ZLPPKMC010_F01.
INCLUDE ZLPPKMC010_PBO.
INCLUDE ZLPPKMC010_PAI.

INITIALIZATION.
  PERFORM set_initial_value.

START-OF-SELECTION.
  PERFORM GET_DATA.
  CALL SCREEN 100.
