*&---------------------------------------------------------------------*
*& Include          ZLFICMC040_I01
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

  CASE gv_okcode.

    WHEN 'XDWN'.
      PERFORM download_excel.

    WHEN 'PRNT'.
      PERFORM print_excel.

    WHEN 'REFR'.
      PERFORM get_data.
      PERFORM rebuild_tree.

  ENDCASE.

ENDMODULE.
