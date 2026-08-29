*&---------------------------------------------------------------------*
*& Include          ZLMMUMC060_I01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*

MODULE exit_2000 INPUT.
  DATA : lv_okcode TYPE sy-ucomm.
  lv_okcode = sy-ucomm.
  CLEAR sy-ucomm.
  CASE lv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM zz_exe_free_objects.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
