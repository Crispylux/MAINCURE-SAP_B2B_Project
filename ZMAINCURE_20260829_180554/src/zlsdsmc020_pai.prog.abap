*&---------------------------------------------------------------------*
*& Include          ZLSDSMC020_PAI
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
* 스크린 100 - 버튼 처리
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN 'BTN1'.                               "출고문서 조회
      PERFORM search_quotation1.
      go_alv1->refresh_table_display( ).

    WHEN 'BTN2'.                               "초기화(싹다 비우기)
      CLEAR: b1_field1_100_1, b1_field1_100_2,
             b1_field2_1, b1_field2_2,
             b1_field3_1, b1_field3_2,
             b1_field4_1, b1_field4_2.
      CLEAR: gt_do_head, gt_do_item, gt_bill.
      CLEAR: gv_selected_vbeln.
      go_alv1->refresh_table_display( ).
      go_alv2->refresh_table_display( ).
      go_alv3->refresh_table_display( ).

    WHEN 'BTN3'.                              "대금청구서 조회
      PERFORM search_quotation3.
      go_alv3->refresh_table_display( ).

    WHEN 'BTN4'.                              "전표수동생성 - 나중에 채우기!

    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      "기타 처리
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       스크린 200 - 버튼 처리
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  PERFORM recalc_total. "총 금액 계산

  CASE sy-ucomm.
    WHEN 'CRAT'.
      PERFORM recalc_total.   "총금액 : 배송비, 할인을 반영해서 다시 계산한다!
      PERFORM create_billing. "대금청구서 생성(BI 생성)
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
        LEAVE TO SCREEN 0.
    WHEN OTHERS.
  ENDCASE.

  CLEAR sy-ucomm.
ENDMODULE.
