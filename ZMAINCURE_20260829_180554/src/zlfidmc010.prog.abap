*&---------------------------------------------------------------------*
* 모듈/서브모듈    : FI/FID
* Program ID  : ZLFIDMC010
* Desc        : [FI] 지급 결재 프로그램
* Transaction : ZLFIDMC010
* Creator     : 김윤진
* Create day  : 2026.06.15
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.15    김윤진              최초작성
*&---------------------------------------------------------------------*

REPORT ZLFIDMC010 MESSAGE-ID zsyms27.

INCLUDE zlfidmc010_top.  " 전역 타입·변수·객체
INCLUDE zlfidmc010_sel.  " Selection Screen
INCLUDE zlfidmc010_c01.  " ALV 이벤트 클래스
INCLUDE zlfidmc010_o01.  " Screen PBO
INCLUDE zlfidmc010_i01.  " Screen PAI
INCLUDE zlfidmc010_f01.  " FORM 로직

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM set_initial_value.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  IF gt_list IS INITIAL.
    MESSAGE S014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
  ELSE.
    CHECK sy-batch = ''.
    CALL SCREEN 2000.
  ENDIF.
