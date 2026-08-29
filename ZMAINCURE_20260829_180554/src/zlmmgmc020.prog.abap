*&---------------------------------------------------------------------*
* 모듈/서브모듈    : MM/PR
* Program ID  : ZLMMGMC010
* Desc        : [MM] 송장 검증 프로그램
* Transaction : ZLMMGMC020
* Creator     : 류재열
* Create day  : 2026.06.16
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.25    류재열              최초작성
*&---------------------------------------------------------------------*

REPORT zlmmgmc020 MESSAGE-ID zsyms27.

INCLUDE zlmmgmc020_top. " 전역 타입·변수·객체
INCLUDE zlmmgmc020_sel. " Selection Screen
INCLUDE zlmmgmc020_c01. " ALV 이벤트 클래스
INCLUDE zlmmgmc020_o01. " Screen PBO
INCLUDE zlmmgmc020_i01. " Screen PAI
INCLUDE zlmmgmc020_f01. " FORM 로직

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM zz_set_initial_value.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM zz_exe_get_data.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK sy-batch = ''.
  CALL SCREEN 2000.
