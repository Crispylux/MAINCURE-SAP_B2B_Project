*&---------------------------------------------------------------------*
*& Include          ZLMMGMC050_O01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.27    양윤서              최초작성
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.
  CASE sy-tcode.
    WHEN 'ZLMMGMC053'.
      SET PF-STATUS '2000'.
      SET TITLEBAR  '2000' WITH '구매오더 조회'.
      IF go_grid IS INITIAL.
        PERFORM zz_exe_create_alv.
      ENDIF.
    WHEN 'ZLMMGMC051'.
      SET PF-STATUS '3000'.
      SET TITLEBAR  '3000' WITH '구매오더 생성'.
      IF go_grid IS INITIAL. "여러 줄 생성 가능 alv 만들어야함.
        PERFORM zz_exe_create_alv.
      ENDIF.
    WHEN 'ZLMMGMC052'.
      SET PF-STATUS '2000'.
      SET TITLEBAR  '2000' WITH '구매오더 수정'.
      IF go_grid IS INITIAL. "한 줄씩 수정 가능한 alv 만들어야함.
        PERFORM zz_exe_create_alv.
      ENDIF.
    WHEN OTHERS.
      SET PF-STATUS '2000'.
      SET TITLEBAR  '2000' WITH '구매오더 조회'.
      IF go_grid IS INITIAL.
        PERFORM zz_exe_create_alv.
      ENDIF.
  ENDCASE.
ENDMODULE.
