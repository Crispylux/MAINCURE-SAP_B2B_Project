*&---------------------------------------------------------------------*
*& Include          ZLMMUMC060_O01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.
  CASE sy-tcode.
    WHEN 'ZLMMUMC061'.
      SET PF-STATUS '2000'.
      SET TITLEBAR  '2000' WITH '구매오더 승인'.
      IF go_grid IS INITIAL.
        PERFORM zz_exe_create_alv.
      ENDIF.
    WHEN 'ZLMMUMC062'.
      SET PF-STATUS '2000'.
      SET TITLEBAR  '2000' WITH '구매오더 반려'.
      IF go_grid IS INITIAL.
        PERFORM zz_exe_create_alv.
      ENDIF.
    WHEN OTHERS.
      SET PF-STATUS '2000'.
      SET TITLEBAR  '2000' WITH '구매오더 승인'.
      IF go_grid IS INITIAL.
        PERFORM zz_exe_create_alv.
      ENDIF.
  ENDCASE.
ENDMODULE.
