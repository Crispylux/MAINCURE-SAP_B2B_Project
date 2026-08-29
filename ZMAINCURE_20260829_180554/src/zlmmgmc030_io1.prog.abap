*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_I01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.15    이승아              최초작성
*&---------------------------------------------------------------------*




*&---------------------------------------------------------------------*
*&      Module  EXIT_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
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
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  CLEAR lv_okcode.
  lv_okcode = sy-ucomm.
  CLEAR sy-ucomm.

  IF go_grid IS BOUND.
    CALL METHOD go_grid->check_changed_data.
  ENDIF.

  CASE lv_okcode.

    WHEN 'PROC'.
      PERFORM zz_exe_data_appr.

    WHEN 'SRCH'.
      PERFORM zz_exe_search_stock.

  ENDCASE.

ENDMODULE.
