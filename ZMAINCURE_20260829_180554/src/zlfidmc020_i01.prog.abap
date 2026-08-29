*&---------------------------------------------------------------------*
*& Include          ZLFIDMC020_I01
*&---------------------------------------------------------------------*
*& Screen PAI
*&---------------------------------------------------------------------*

MODULE user_command_2000 INPUT.

  gv_save_ok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_save_ok.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN 'RCPT'.
      MESSAGE '수금등록 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'CLRG'.
      MESSAGE '반제실행 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'XDWN'.
      MESSAGE '엑셀다운 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'REFR'.
      PERFORM get_data.
      PERFORM refresh_alv.
      MESSAGE '새로고침 되었습니다.' TYPE 'S'.
  ENDCASE.

ENDMODULE.
