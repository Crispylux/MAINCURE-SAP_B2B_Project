*&---------------------------------------------------------------------*
*& Include          ZLFIDMC050_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.

  gv_save_ok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_save_ok.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.

    WHEN 'CRET'.
*     3000번 신규 화면 초기값 설정
      PERFORM set_new_document.

*     3000번 화면 이동
      CALL SCREEN 3000.

    WHEN 'EDIT'.
      MESSAGE '수정 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'POST'.
      MESSAGE '전기 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'RVRS'.
      MESSAGE '역전표 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'XDWN'.
      MESSAGE '엑셀다운 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'REFR'.
      PERFORM get_data.
      PERFORM refresh_alv.
      MESSAGE '새로고침 되었습니다.' TYPE 'S'.
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.

  gv_save_ok = gv_okcode.
  CLEAR gv_okcode.

  CASE gv_save_ok.

    WHEN 'ADDL'.
      MESSAGE '행 추가 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'SAVE'.
      MESSAGE '임시저장 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'POST'.
      MESSAGE '전기 기능은 추후 구현 예정입니다.' TYPE 'I'.

    WHEN 'BACK' OR 'CANC'.

      PERFORM free_item_alv.

      LEAVE TO SCREEN 0.

    WHEN 'EXIT'.

      PERFORM free_item_alv.

      LEAVE PROGRAM.

  ENDCASE.

ENDMODULE.
