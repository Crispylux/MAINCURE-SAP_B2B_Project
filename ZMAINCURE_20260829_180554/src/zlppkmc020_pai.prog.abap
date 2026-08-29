*&---------------------------------------------------------------------*
*& Include ZLPPKMC020_PAI
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  gv_okcode = sy-ucomm.
  CLEAR sy-ucomm.

  CASE gv_okcode.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE PROGRAM.

    WHEN 'SEARCH'.
      IF gv_scr_mode = '1'.
        PERFORM get_data_mode1.
      ELSE.
        PERFORM get_data_mode2.
      ENDIF.
      PERFORM refresh_alv.

    WHEN 'BTN_PLAN'.
      IF gv_scr_mode = '1'.
        PERFORM get_data_mode1.
        PERFORM refresh_alv.
      ELSE.
        gv_scr_mode = '1'.
        PERFORM free_objects.
        CLEAR: gt_plan_hdr, gt_plan_itm.
      ENDIF.

    WHEN 'BTN_MRP'.
      gv_scr_mode = '2'.
      PERFORM free_objects.
      CLEAR: gt_mrp_hdr, gt_mrp_itm, gt_pr_list.

    WHEN 'BTN_EXEC'.
      DATA: lv_answer TYPE c LENGTH 1.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'MRP 실행 확인'
          text_question         = '계산된 부족 수량으로 구매요청을 생성하시겠습니까?'
          text_button_1         = '실행'
          icon_button_1         = 'ICON_EXECUTE_OBJECT'
          text_button_2         = '취소'
          icon_button_2         = 'ICON_CANCEL'
          display_cancel_button = ' '
        IMPORTING
          answer                = lv_answer.

      IF lv_answer = '1'.
        IF gv_scr_mode = '1'.
          MESSAGE s000 WITH 'MRP 실행은 [MRP 조회] 화면에서 대상을 더블클릭한 후 가능합니다.' DISPLAY LIKE 'E'.
        ELSE.
          PERFORM run_mrp_and_send_to_mm.
        ENDIF.
      ELSE.
        MESSAGE s000 WITH 'MRP 실행이 취소되었습니다.'.
      ENDIF.

  ENDCASE.
ENDMODULE.
