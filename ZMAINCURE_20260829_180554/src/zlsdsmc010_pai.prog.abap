*&---------------------------------------------------------------------*
*& Include          ZLSDSMC010_PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
    WHEN 'QGET'.                          "견적정보 불러오기
      PERFORM load_quot_data.
      CALL SCREEN 0200
        STARTING AT 10 5
        ENDING AT   120 25.
    WHEN 'ORDC'.                          "주문정보 생성
      PERFORM create_order.
    WHEN 'APRV'.                          "주문 승인/반려
      CALL SCREEN 0201
        STARTING AT 10 5
        ENDING AT 120 25.
    WHEN 'TAB1'.                          "스크린 101
      down_tabstrip-activetab = 'TAB1'.
    WHEN 'TAB2'.                          "스크린 102
      down_tabstrip-activetab = 'TAB2'.
    WHEN 'TAB3'.                          "스크린 103
      down_tabstrip-activetab = 'TAB3'.
    WHEN OTHERS.
      " 기타 처리
  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       견적정보 조회 안에서 처리할 동작들
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  DATA: lt_sel_rows_200 TYPE lvc_t_row,
        ls_sel_row_200  TYPE lvc_s_row.

  CASE sy-ucomm.
    WHEN 'ENTR'.                          "Enter는 아무 동작도 하지 않음 (일단 막기)
      " 아무 것도 안 함
    WHEN 'CANC' OR 'E'.
      LEAVE TO SCREEN 0.

    WHEN 'SRCH'.
      PERFORM search_quotation.
      go_alv->refresh_table_display( ).

    WHEN 'LOAD'.
      CALL METHOD go_alv->get_selected_rows
        IMPORTING et_index_rows = lt_sel_rows_200.

      IF lines( lt_sel_rows_200 ) <> 1.
        MESSAGE '불러올 행을 하나만 선택해주세요.' TYPE 'I'.
        EXIT.
      ENDIF.

      READ TABLE lt_sel_rows_200 INTO ls_sel_row_200 INDEX 1.
      READ TABLE gt_quot INTO gs_quot INDEX ls_sel_row_200-index.

      IF sy-subrc = 0.
        PERFORM fill_order_fields USING gs_quot.
        LEAVE TO SCREEN 0.
      ENDIF.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0201  INPUT
*&---------------------------------------------------------------------*
*       주문 승인/반려에서 처리할 동작들
*----------------------------------------------------------------------*
MODULE user_command_0201 INPUT.
  DATA: lt_sel_rows TYPE lvc_t_row,
        ls_sel_row  TYPE lvc_s_row,
        lv_vbeln    TYPE vbeln_va.

  CASE sy-ucomm.
    WHEN 'CANCEL' OR 'EXIT' OR 'BACK' or 'E'.
      LEAVE TO SCREEN 0.

    WHEN 'REJF' OR 'APPR'.
      CALL METHOD go_alv3->get_selected_rows
        IMPORTING et_index_rows = lt_sel_rows.

    IF lines( lt_sel_rows ) <> 1.
      MESSAGE '처리할 행을 하나만 선택해주세요.' TYPE 'I'.
      EXIT.
    ENDIF.

    READ TABLE lt_sel_rows INTO ls_sel_row INDEX 1.
    READ TABLE gt_appr INTO gs_appr INDEX ls_sel_row-index.

    IF gs_appr-status IS INITIAL.
      MESSAGE '반려 상태인 건만 처리할 수 있습니다.' TYPE 'I'.
      EXIT.
    ENDIF.

    lv_vbeln = gs_appr-vbeln.

    IF sy-ucomm = 'REJF'.
      PERFORM final_reject USING lv_vbeln.  "'최종 반려' 버튼 눌렀을 때 실행됨!
    ELSE.
      PERFORM approve_order USING lv_vbeln. "'승인' 버튼 눌렀을 때 실행됨!
    ENDIF.

    PERFORM search_approval_list.
    go_alv3->refresh_table_display( ).
  ENDCASE.

  CALL METHOD cl_gui_cfw=>dispatch.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  SEARCH_CUSTOMER_INPUT  INPUT
*&---------------------------------------------------------------------*
*       스크린 100 - 검색 기능
*----------------------------------------------------------------------*
MODULE search_customer_input INPUT.
  PERFORM search_quot_by_customer.
ENDMODULE.
