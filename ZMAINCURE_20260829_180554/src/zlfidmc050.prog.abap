*&---------------------------------------------------------------------*
* 모듈/서브모듈    : FI/FID
* Program ID  : ZLFIDMC050
* Desc        : 결산 전표 프로그램
* Transaction : ZLFIDMC050
* Creator     : 김윤진
* Create day  : 2026.06.23
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.23    김윤진              최초작성
*&---------------------------------------------------------------------*
REPORT ZLFIDMC050.

  INCLUDE ZLFIDMC050_top.   " 전역 타입, 변수, 객체
  INCLUDE ZLFIDMC050_sel.   " Selection Screen
  INCLUDE ZLFIDMC050_c01.   " AVL 이벤트 클래스
  INCLUDE ZLFIDMC050_o01.   " Screen PBO
  INCLUDE ZLFIDMC050_i01.   " Screen PAI
  INCLUDE ZLFIDMC050_f01.   " FORM 로직

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
END-OF-SELECTION.
  IF gt_list IS INITIAL.
    MESSAGE '조회 결과가 없습니다.' TYPE 'E'.
  ELSE.
    CHECK sy-batch = ''.
    CALL SCREEN 2000.
  ENDIF.
