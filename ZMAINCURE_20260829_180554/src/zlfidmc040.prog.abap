*&---------------------------------------------------------------------*
* 모듈/서브모듈    : FI/FID
* Program ID  : ZLFIDMC040
* Desc        : [FI] 재무상태표/손익계산서 프로그램
* Transaction : ZLFIDMC040
* Creator     : 김윤진
* Create day  : 2026.06.24
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.24    김윤진              최초작성
*&---------------------------------------------------------------------*

REPORT ZLFIDMC040 MESSAGE-ID zsyms27.

INCLUDE zlfidmc040_top.  " 전역 타입·변수·객체
INCLUDE zlfidmc040_sel.  " Selection Screen
INCLUDE zlfidmc040_c01.  " ALV 이벤트 클래스
INCLUDE zlfidmc040_o01.  " Screen PBO
INCLUDE zlfidmc040_i01.  " Screen PAI
INCLUDE zlfidmc040_f01.  " FORM 로직

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
