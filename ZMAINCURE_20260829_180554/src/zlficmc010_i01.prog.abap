*&---------------------------------------------------------------------*
*& Include          ZLFICMC010_I01
*&---------------------------------------------------------------------*

MODULE exit_2000 INPUT.

  gv_okcode = sy-ucomm.
  CLEAR sy-ucomm.

  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM free_objects.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.


MODULE user_command_2000 INPUT.

  gv_okcode = sy-ucomm.
  CLEAR sy-ucomm.

  IF go_grid IS BOUND.
    CALL METHOD go_grid->check_changed_data.
  ENDIF.

  CASE gv_okcode.

    WHEN 'APPR'.
      PERFORM approve_data.

    WHEN 'RJCT'.
      PERFORM reject_data.

    WHEN 'PAID'.
      PERFORM payment_data.

    WHEN 'XDWN'.
      PERFORM download_excel.

    WHEN 'REFR'.
      PERFORM get_data.
      PERFORM refresh_alv.

  ENDCASE.

ENDMODULE.
