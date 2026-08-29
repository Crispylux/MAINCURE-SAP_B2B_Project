*&---------------------------------------------------------------------*
*& Include          ZLPPKMC010_PAI
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module EXIT_0100 INPUT
*&---------------------------------------------------------------------*
*& 뒤로 가기, 종료 취소 버튼 처리
*&---------------------------------------------------------------------*
MODULE exit_0100 INPUT.

  gv_okcode = sy-ucomm.
  CLEAR sy-ucomm.

  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      PERFORM free_objects.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
*& 사용자 클릭 버튼 이벤트 처리
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  gv_okcode = sy-ucomm.
  CLEAR sy-ucomm.

  IF go_grid_left IS BOUND.
    CALL METHOD go_grid_left->check_changed_data.
  ENDIF.
  IF go_grid_mid IS BOUND.
    CALL METHOD go_grid_mid->check_changed_data.
  ENDIF.
  IF go_grid_rgt IS BOUND.
    CALL METHOD go_grid_rgt->check_changed_data.
  ENDIF.

  CASE gv_okcode.

    WHEN 'SEARCH'.
      PERFORM get_data.
      PERFORM refresh_alv.

    WHEN 'T_CRE'.
      PERFORM create_temp_plan.

    WHEN 'SAVE'.
      DATA: lv_save_answer TYPE c LENGTH 1.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = '생산계획 저장 확인'
          text_question         = '작성된 임시 생산계획 데이터를 저장하시겠습니까?'
          text_button_1         = '저장'
          icon_button_1         = 'ICON_SYSTEM_SAVE'
          text_button_2         = '취소'
          icon_button_2         = 'ICON_CANCEL'
          display_cancel_button = ' '
        IMPORTING
          answer                = lv_save_answer.

      IF lv_save_answer = '1'.
        PERFORM save_plan.
      ELSE.
        MESSAGE s000 WITH '생산계획 저장이 취소되었습니다.'.
      ENDIF.

    WHEN 'INIT'.
      PERFORM init_data.

    WHEN 'MRP'.
      SUBMIT zlppkmc020 VIA SELECTION-SCREEN AND RETURN.

  ENDCASE.

ENDMODULE.
