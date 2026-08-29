*&---------------------------------------------------------------------*
* 모듈/서브모듈    : FI/FID
* Program ID  : ZLFIDMC030
* Desc        : 세금계산서 프로그램
* Transaction : ZLFIDMC030
* Creator     : 김윤진
* Create day  : 2026.06.23
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.23    김윤진              최초작성
*&---------------------------------------------------------------------*
REPORT zlfidmc030.

INCLUDE zlfidmc030_top. " 전역 타입·변수·객체
INCLUDE zlfidmc030_sel. " Selection Screen
INCLUDE zlfidmc030_c01. " ALV 이벤트 클래스
INCLUDE zlfidmc030_o01. " Screen PBO
INCLUDE zlfidmc030_i01. " Screen PAI
INCLUDE zlfidmc030_f01. " FORM 로직

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
  CALL SCREEN 2000.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
end-OF-SELECTION.
  IF gt_list IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'E'.
  ELSE.
    CHECK sy-batch = ''.
    CALL SCREEN 2000.
  ENDIF.
