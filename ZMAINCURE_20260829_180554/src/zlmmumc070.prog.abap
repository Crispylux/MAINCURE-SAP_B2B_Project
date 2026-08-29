*&---------------------------------------------------------------------*
* 모듈/서브모듈    : MM/PR
* Program ID  : ZLMMGMC010
* Desc        : [MM] 구매요청 생성( 11 ) / 수정 ( 12 ) / 조회 ( 13 ) 프로그램
* Transaction : ZLMMGMC013
* Creator     : 류재열
* Create day  : 2026.06.16
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*

REPORT zlmmumc070 MESSAGE-ID zsyms27.

INCLUDE ZLMMGMC070_TOP.
*INCLUDE zlmmgmc010_top. " 전역 타입·변수·객체
INCLUDE ZLMMGMC070_SEL.
*INCLUDE zlmmgmc010_sel. " Selection Screen
INCLUDE ZLMMGMC070_C01.
*INCLUDE zlmmgmc010_c01. " ALV 이벤트 클래스
INCLUDE ZLMMGMC070_O01.
*INCLUDE zlmmgmc010_o01. " Screen PBO
INCLUDE ZLMMGMC070_I01.
*INCLUDE zlmmgmc010_i01. " Screen PAI
INCLUDE ZLMMGMC070_F01.
*INCLUDE zlmmgmc010_f01. " FORM 로직

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.

  IF sy-tcode = 'ZLMMGMC011'.

  ELSEIF sy-tcode = 'ZLMMGMC012'.
    PERFORM zz_set_initial_value.
  ELSEIF sy-tcode = 'ZLMMGMC013'.
    PERFORM zz_set_initial_value.
  ELSE.
    PERFORM zz_set_initial_value.
  ENDIF.
*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF sy-tcode = 'ZLMMGMC013'.
    PERFORM zz_exe_get_data.
  ELSEIF sy-tcode = 'ZLMMGMC011'.

  ELSEIF sy-tcode = 'ZLMMGMC012'.
    PERFORM zz_exe_get_data.
  ELSE.
    PERFORM zz_exe_get_data.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  DATA : lv_tcode TYPE sy-tcode.
  CHECK sy-batch = ''.

  CASE sy-tcode.
    WHEN 'ZLMMGMC013'.
      IF gt_070 IS INITIAL.
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
    WHEN 'ZLMMGMC011'.


    WHEN 'ZLMMGMC012'.
      CALL SCREEN 2000.

    WHEN OTHERS.
      IF gt_070 IS INITIAL.
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
  ENDCASE.
