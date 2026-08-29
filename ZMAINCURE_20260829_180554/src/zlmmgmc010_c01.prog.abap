**&---------------------------------------------------------------------*
**& Include          ZLMMGMC010_C01
**&---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.

    CLASS-METHODS on_data_changed
      FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING er_data_changed.

    CLASS-METHODS on_data_changed_finished
      FOR EVENT data_changed_finished OF cl_gui_alv_grid
      IMPORTING e_modified
                et_good_cells.


ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.

  " 변경된 셀들
  METHOD on_data_changed.

    LOOP AT er_data_changed->mt_mod_cells
      ASSIGNING FIELD-SYMBOL(<ls_mod_cell>).

      " 기존 인터널 테이블 행
      READ TABLE gt_070 ASSIGNING FIELD-SYMBOL(<ls_070>)
        INDEX <ls_mod_cell>-row_id.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      CASE <ls_mod_cell>-fieldname.

          " 수량
        WHEN 'MENGE'.

          IF CONV menge_d( <ls_mod_cell>-value ) <= 0.

            " 기존 값으로 복원
            er_data_changed->modify_cell(
              i_row_id    = <ls_mod_cell>-row_id
              i_fieldname = <ls_mod_cell>-fieldname
              i_value     = <ls_070>-menge
            ).

*          er_data_changed->add_protocol_entry(
*            i_msgid     = 'ZMM_MSG'
*            i_msgno     = '001'
*            i_msgty     = 'E'
*            i_msgv1     = '수량은 0보다 커야 합니다.'
*            i_fieldname = <ls_mod_cell>-fieldname
*            i_row_id    = <ls_mod_cell>-row_id
*          ).
            MESSAGE i001(zmm_msg) WITH '수량은 0보다 커야 합니다.'.
          ENDIF.


          " Plant
        WHEN 'WERKS'.

          IF <ls_mod_cell>-value IS INITIAL.

            er_data_changed->modify_cell(
              i_row_id    = <ls_mod_cell>-row_id
              i_fieldname = <ls_mod_cell>-fieldname
              i_value     = <ls_070>-werks
            ).

            MESSAGE i001(zmm_msg) WITH '플랜트를 입력해주세요.'.

          ENDIF.


          " Storage Location
        WHEN 'LGORT'.

          IF <ls_mod_cell>-value IS INITIAL.

            er_data_changed->modify_cell(
              i_row_id    = <ls_mod_cell>-row_id
              i_fieldname = <ls_mod_cell>-fieldname
              i_value     = <ls_070>-lgort
            ).

            MESSAGE i001(zmm_msg) WITH '저장위치를 입력해주세요.'.
          ENDIF.


          " Delivery Date
        WHEN 'LFDAT'.

          IF CONV datum( <ls_mod_cell>-value ) < sy-datum.

            er_data_changed->modify_cell(
              i_row_id    = <ls_mod_cell>-row_id
              i_fieldname = <ls_mod_cell>-fieldname
              i_value     = <ls_070>-lfdat
            ).

            MESSAGE i001(zmm_msg) WITH '납품일은 오늘 이전일 수 없습니다.'.
          ENDIF.

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.


  METHOD on_data_changed_finished.

    IF e_modified <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT et_good_cells
      ASSIGNING FIELD-SYMBOL(<ls_good_cell>).

      READ TABLE gt_070 ASSIGNING FIELD-SYMBOL(<ls_070>)
        INDEX <ls_good_cell>-row_id.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CASE <ls_good_cell>-fieldname.

        WHEN 'MENGE'.
          <ls_070>-menge =
            CONV menge_d( <ls_good_cell>-value ).

        WHEN 'WERKS'.
          <ls_070>-werks =
            <ls_good_cell>-value.

        WHEN 'LGORT'.
          <ls_070>-lgort =
            <ls_good_cell>-value.

        WHEN 'LFDAT'.
          <ls_070>-lfdat =
            CONV datum( <ls_good_cell>-value ).

      ENDCASE.

    ENDLOOP.

  ENDMETHOD.

  METHOD handle_toolbar.

    DATA ls_toolbar TYPE stb_button.

    " 구분선
    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    " 승인대기
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'TXT_WAIT'.
    ls_toolbar-icon      = icon_yellow_light.
    ls_toolbar-text      = |승인대기 : { gv_wait_cnt }건|.
    ls_toolbar-quickinfo = '승인대기 건수'.
*    ls_toolbar-disabled  = 'X'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    " 승인완료
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'TXT_DONE'.
    ls_toolbar-icon      = icon_green_light.
    ls_toolbar-text      = |승인완료 : { gv_done_cnt }건|.
    ls_toolbar-quickinfo = '승인완료 건수'.
*    ls_toolbar-disabled  = 'X'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    " 반려
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'TXT_REJECT'.
    ls_toolbar-icon      = icon_red_light.
    ls_toolbar-text      = |반려 : { gv_reject_cnt }건|.
    ls_toolbar-quickinfo = '반려 건수'.
*    ls_toolbar-disabled  = 'X'.
    APPEND ls_toolbar TO e_object->mt_toolbar.


  ENDMETHOD.

  METHOD handle_user_command.

    CASE e_ucomm.

      WHEN 'TXT_WAIT'.
        MESSAGE i000(oo) WITH '정렬 로직 추가 예정'.

      WHEN 'TXT_DONE'.
        MESSAGE i000(oo) WITH '정렬 로직 추가 예정'.

      WHEN 'TXT_REJECT'.
        MESSAGE i000(oo) WITH '정렬 로직 추가 예정'.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
