*&---------------------------------------------------------------------*
* 모듈/서브모듈    : MM/PR
* Program ID  : ZLMMGMC010
* Desc        : [MM] GR 처리
* Transaction : ZLMMGMC020
* Creator     : 류재열
* Create day  : 2026.06.16
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.25    류재열              최초작성
*&---------------------------------------------------------------------*

REPORT zlmmgmc030 MESSAGE-ID zsyms27.

INCLUDE ZLMMGMC030_TOP. " 전역 타입·변수·객체
INCLUDE ZLMMGMC030_SEL. " Selection Screen
INCLUDE ZLMMGMC030_CO1. " ALV 이벤트 클래스
INCLUDE ZLMMGMC030_OO1. " Screen PBO
INCLUDE ZLMMGMC030_IO1. " Screen PAI
INCLUDE ZLMMGMC030_FO1. " FORM 로직

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
