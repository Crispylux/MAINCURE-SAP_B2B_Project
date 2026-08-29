*&---------------------------------------------------------------------*
*& Include          ZLFIDMC030_I01
*&---------------------------------------------------------------------*
*& Screen PAI
*&---------------------------------------------------------------------*

MODULE user_command_2000 INPUT.

  gv_save_ok = gv_okcode.
  clear gv_okcode.

  CASE gv_save_ok.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CRTX'.
      MESSAGE '기능은 추후 구현 예정입니다.' TYPE 'I'.
    WHEN 'PPDF'.
      MESSAGE '기능은 추후 구현 예정입니다.' TYPE 'I'.
    WHEN 'CANC'.
      MESSAGE '기능은 추후 구현 예정입니다.' TYPE 'I'.
    WHEN 'XDWN'.
      MESSAGE '기능은 추후 구현 예정입니다.' TYPE 'I'.
    WHEN 'REFR'.
      MESSAGE '기능은 추후 구현 예정입니다.' TYPE 'I'.
  ENDCASE.

ENDMODULE.
