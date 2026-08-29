*&---------------------------------------------------------------------*
* 모듈/서브모듈    : FI/FID
* Program ID  : ZLFIDMC020
* Desc        : 수금/반제 프로그램
* Transaction : ZLFIDMC020
* Creator     : 김윤진
* Create day  : 2026.06.23
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.23    김윤진              최초작성
*&---------------------------------------------------------------------*

REPORT ZLFIDMC020.

INCLUDE zlfidmc020_top.  " 전역 타입·변수·객체
INCLUDE zlfidmc020_sel.  " Selection Screen
INCLUDE zlfidmc020_c01.  " ALV 이벤트 클래스
INCLUDE zlfidmc020_o01.  " Screen PBO
INCLUDE zlfidmc020_i01.  " Screen PAI
INCLUDE zlfidmc020_f01.  " FORM 로직

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
  IF gt_fcat_top IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'E'.
  ELSE.
    CHECK sy-batch = ''.
    CALL SCREEN 2000.
  ENDIF.
