*&---------------------------------------------------------------------*
* 모듈/서브모듈    : MM/PO
* Program ID      : ZLMMGMC050
* Desc            : [MM] 구매오더 생성(051)/수정(052)/조회(053) 프로그램
* Transaction     : ZLMMGMC051/052/053
* Creator         : 양윤서
* Create day      : 2026.06.27
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.27      양윤서                최초작성
*&---------------------------------------------------------------------*
REPORT zlmmgmc050 MESSAGE-ID zsyms27.

INCLUDE zlmmgmc050_top.
INCLUDE zlmmgmc050_sel.
INCLUDE zlmmgmc050_c01.
INCLUDE zlmmgmc050_o01.
INCLUDE zlmmgmc050_i01.
INCLUDE zlmmgmc050_f01.

*----------------------------------------------------------------------*
* INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  IF sy-tcode = 'ZLMMGMC051'.
    " 생성: 초기값 세팅 없음 (빈 화면)
  ELSEIF sy-tcode = 'ZLMMGMC052'.
    PERFORM zz_set_initial_value.
  ELSEIF sy-tcode = 'ZLMMGMC053'.
    PERFORM zz_set_initial_value.
  ELSE.
    PERFORM zz_set_initial_value.
  ENDIF.

*----------------------------------------------------------------------*
* START-OF-SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.
  IF sy-tcode = 'ZLMMGMC051'.
    " 생성: DB 조회 없음
  ELSEIF sy-tcode = 'ZLMMGMC052'.
    PERFORM zz_exe_get_data.
  ELSEIF sy-tcode = 'ZLMMGMC053'.
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
    WHEN 'ZLMMGMC053'.
      IF gt_050 IS INITIAL.
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
    WHEN 'ZLMMGMC051'.
    WHEN 'ZLMMGMC052'.
      CALL SCREEN 2000.
    WHEN OTHERS.
      IF gt_050 IS INITIAL.        " ← 여기
        MESSAGE s014 WITH '조회 결과가 없습니다.' DISPLAY LIKE 'E'.
      ELSE.
        CALL SCREEN 2000.
      ENDIF.
  ENDCASE.
