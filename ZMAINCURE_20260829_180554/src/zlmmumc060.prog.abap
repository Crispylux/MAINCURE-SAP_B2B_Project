*&---------------------------------------------------------------------*
* 모듈/서브모듈    : MM/PO
* Program ID      : ZLMMUMC060
* Desc            : [MM] 구매오더 승인(061)/반려(062) 프로그램
* Transaction     : ZLMMUMC061/062
* Creator         : 양윤서
* Create day      : 2026.06.28
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*
REPORT zlmmumc060 MESSAGE-ID zsyms27.

INCLUDE zlmmumc060_top.
INCLUDE zlmmumc060_sel.
INCLUDE zlmmumc060_c01.
INCLUDE zlmmumc060_o01.
INCLUDE zlmmumc060_i01.
INCLUDE zlmmumc060_f01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  IF sy-tcode = 'ZLMMUMC061'.
    PERFORM zz_set_initial_value.
  ELSEIF sy-tcode = 'ZLMMUMC062'.
    PERFORM zz_set_initial_value.
  ELSE.
    PERFORM zz_set_initial_value.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF sy-tcode = 'ZLMMUMC061'.
    PERFORM zz_exe_get_data.
  ELSEIF sy-tcode = 'ZLMMUMC062'.
    PERFORM zz_exe_get_data.
  ELSE.
    PERFORM zz_exe_get_data.
  ENDIF.

*----------------------------------------------------------------------*
* END-OF-SELECTION
*----------------------------------------------------------------------*
END-OF-SELECTION.
  CHECK sy-batch = ''.
  CASE sy-tcode.
    WHEN 'ZLMMUMC061'.
      IF gt_060 IS INITIAL.
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
    WHEN 'ZLMMUMC062'.
      IF gt_060 IS INITIAL.
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
    WHEN OTHERS.
      IF gt_060 IS INITIAL.
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
  ENDCASE.
