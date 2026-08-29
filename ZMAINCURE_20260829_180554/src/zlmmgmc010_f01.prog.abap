*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_F01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*& Form zz_exe_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_get_data.
  REFRESH gt_070. "EBAN
  SELECT banfn, bnfpo, bsart, matnr, menge,
         meins, werks, lgort, badat, lfdat,
         ebeln, statu,
         erdat, erzet, ernam,
         aedat, aezet, aenam
      FROM ztmmg00070
      INTO CORRESPONDING FIELDS OF TABLE @gt_070
      WHERE banfn IN @so_banfn
        AND bnfpo IN @so_bnfpo
        AND bsart IN @so_bsart
        AND statu IN @so_statu
        AND matnr IN @so_matnr
        AND werks IN @so_werks
        AND badat IN @so_badat.

  IF p_wait = abap_true.
    DELETE gt_070 WHERE statu <> 'A'.
  ENDIF.


  PERFORM set_status_count.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_exe_free_objects
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_free_objects .
  IF go_grid IS BOUND.
    CALL METHOD go_grid->free.
    FREE go_grid.
  ENDIF.

  IF go_container IS BOUND.
    CALL METHOD go_container->free.
    FREE go_container.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_exe_create_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_create_alv .
  DATA lv_tcode TYPE sy-tcode.

  lv_tcode = sy-tcode.

  PERFORM zz_set_layout_statu. "공통
  PERFORM zz_set_toolbar_exclude USING lv_tcode. "TCODE에 따른 툴바
  PERFORM zz_set_fieldcatalog USING lv_tcode. "TCODE에 따른 필드 카탈로그

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.
  " ZLMMGMC013 조회 화면일 때만 몇 건인지 따로 띄워줌.
  " 수정의 경우 대기인 상태만 수정 가능.
  CASE sy-tcode.
    WHEN 'ZLMMGMC013'.
      CREATE OBJECT go_event_receiver.
      SET HANDLER go_event_receiver->handle_toolbar FOR go_grid.
*      SET HANDLER go_event_receiver->handle_user_command FOR go_grid.
    WHEN 'ZLMMGMC012'.
      " ZLMMGMC012일 때 처리할 내용
      " 딱히 없음
      SET HANDLER go_event_receiver->on_data_changed FOR go_grid.
      SET HANDLER go_event_receiver->on_data_changed_finished FOR go_grid.
    WHEN OTHERS.

      "클래스 추가
      CREATE OBJECT go_event_receiver.
      SET HANDLER go_event_receiver->handle_toolbar FOR go_grid.
*      SET HANDLER go_event_receiver->handle_user_command FOR go_grid.
      "필요 없을 듯. 기본으로 제공해주는 정렬 기능 사용.
*      SET HANDLER go_event_receiver->handle_user_command FOR go_grid.
  ENDCASE.
  " 값 변경 이벤트 감지 코드
  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00070'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_070
      it_fieldcatalog      = gt_fcat.

  " ALV를 입력 가능한 상태로 바꾸는 코드 ( 조회 / 생성 )
  IF sy-tcode = 'ZLMMGMC013'.
    CALL METHOD go_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 0.
  ELSE.
    CALL METHOD go_grid->set_ready_for_input
      EXPORTING
        i_ready_for_input = 1.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu .

  CLEAR gs_layout.

  gs_layout-zebra      = abap_true.       " 행 색상을 번갈아 표시
  gs_layout-cwidth_opt = abap_true.       " 컬럼 너비 자동 조절
*  gs_layout-sel_mode   = 'A'.             " 여러 행 선택 허용
  gs_layout-info_fname = 'ROW_COLOR'.     " 행 색상을 저장한 필드 지정
  gs_layout-sel_mode = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_toolbar_exclude
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_toolbar_exclude USING pv_tcode.
  REFRESH gt_exclude.

  " 행 추가/삭제/복사/붙여넣기 같은 편집 관련 버튼 제거
  CASE pv_tcode.
    WHEN 'ZLMMGMC013'.
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.
    WHEN 'ZLMMGMC011'.
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.

    WHEN 'ZLMMGMC012'.
    WHEN OTHERS.
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TCODE
*&---------------------------------------------------------------------*
FORM zz_set_fieldcatalog USING pv_tcode.
  REFRESH gt_fcat.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTMMG00070'
    CHANGING
      ct_fieldcat      = gt_fcat.

  LOOP AT gt_fcat INTO gs_fcat.

    "기본은 전부 입력 불가
    gs_fcat-edit = abap_false.

    "티코드별 입력 가능 필드만 열기
    CASE pv_tcode.

      WHEN 'ZLMMGMC011'. "생성
        CASE gs_fcat-fieldname.
          WHEN 'BSART'
            OR 'MATNR'
            OR 'MENGE'
            OR 'MEINS'
            OR 'WERKS'
            OR 'LGORT'
            OR 'BADAT'
            OR 'LFDAT'.
            gs_fcat-edit = abap_true.
        ENDCASE.

      WHEN 'ZLMMGMC012'. "수정
        CASE gs_fcat-fieldname.
          WHEN 'MENGE'
            OR 'LGORT'
            OR 'LFDAT'
            OR 'WERKS'.
            gs_fcat-edit = abap_true.
        ENDCASE.

      WHEN 'ZLMMGMC013'. "조회
        gs_fcat-edit = abap_false.

    ENDCASE.

    "시스템 관리 필드는 무조건 입력 불가
    CASE gs_fcat-fieldname.
      WHEN 'BANFN'
        OR 'BNFPO'
        OR 'EBELN'
        OR 'STATU'
        OR 'ERZET'
        OR 'AENAM'.
        gs_fcat-edit = abap_false.
    ENDCASE.

    MODIFY gt_fcat FROM gs_fcat.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form  set_status_count
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TCODE
*& 전체, 승인, 반려, 대기 출력.
*&---------------------------------------------------------------------*
FORM set_status_count.

  CLEAR: gv_wait_cnt,
         gv_done_cnt,
         gv_reject_cnt.

  LOOP AT gt_070 INTO DATA(ls_data).

**TODO 상태에 따라서 숫자 세기
    CASE ls_data-statu.
      WHEN 'A'.
        gv_wait_cnt = gv_wait_cnt + 1.

      WHEN 'D'.
        gv_done_cnt = gv_done_cnt + 1.

      WHEN 'R'.
        gv_reject_cnt = gv_reject_cnt + 1.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_exe_data_appr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_data_appr .

  DATA lt_selected_rows TYPE lvc_t_row.
  DATA lv_answer        TYPE c.

  go_grid->get_selected_rows(
    IMPORTING
      et_index_rows = lt_selected_rows
  ).

  " 1. 선택된 행 검증
  LOOP AT lt_selected_rows ASSIGNING FIELD-SYMBOL(<ls_selected_rows>).

    READ TABLE gt_070 ASSIGNING FIELD-SYMBOL(<ls_070>)
      INDEX <ls_selected_rows>-index.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.

    IF <ls_070>-statu <> 'N'.
      MESSAGE i001(oo) WITH '올바른 행을 입력해주세요'.
      RETURN.
    ENDIF.

  ENDLOOP.


  " 2. 저장 여부 확인 - 한 번만
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '저장 확인'
      text_question         = '변경된 내용을 저장하시겠습니까?'
      text_button_1         = '예'
      text_button_2         = '아니오'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.


  " 3. 예를 누른 경우에만 상태 변경
  LOOP AT lt_selected_rows ASSIGNING <ls_selected_rows>.

    READ TABLE gt_070 ASSIGNING <ls_070>
      INDEX <ls_selected_rows>-index.

    IF sy-subrc = 0.
      <ls_070>-statu = 'A'.
    ENDIF.

  ENDLOOP.


  " 4. DB 저장
  MODIFY ztmmg00070 FROM TABLE gt_070.

  IF sy-subrc = 0.
    COMMIT WORK.
    MESSAGE s000(oo) WITH '저장에 성공하였습니다'.
    PERFORM zz_alv_refresh.
  ELSE.
    ROLLBACK WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_exe_data_chng
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_data_chng .
  DATA lt_selected_rows TYPE lvc_t_row.
  DATA lv_answer        TYPE c.

  " 선택된 행 가져오기
  go_grid->get_selected_rows(
    IMPORTING
      et_index_rows = lt_selected_rows
  ).

  IF lt_selected_rows IS INITIAL.
    MESSAGE i000(oo) WITH '행을 선택해주세요'.
    RETURN.
  ENDIF.


  " 저장 확인
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '저장 확인'
      text_question         = '선택한 행을 저장하시겠습니까?'
      text_button_1         = '예'
      text_button_2         = '아니오'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.


  " 선택된 행만 상태 변경 + DB 저장
  LOOP AT lt_selected_rows ASSIGNING FIELD-SYMBOL(<ls_selected_row>).

    READ TABLE gt_070 ASSIGNING FIELD-SYMBOL(<ls_070>)
      INDEX <ls_selected_row>-index.

    IF sy-subrc = 0.

      <ls_070>-statu = 'N'.
      <ls_070>-aedat = sy-datum.   " 수정일
      <ls_070>-aezet = sy-uzeit.   " 수정시간
      <ls_070>-aenam = sy-uname.   " 수정자
      MODIFY ztmmg00070 FROM <ls_070>.

      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE i001(oo) WITH '저장 중 오류가 발생했습니다'.
        RETURN.
      ENDIF.

    ENDIF.

  ENDLOOP.


  COMMIT WORK.

  MESSAGE s001(zmm_msg).

  PERFORM zz_alv_refresh.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_alv_refresh
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_alv_refresh .
  PERFORM zz_exe_get_data.
  DATA ls_stable TYPE lvc_s_stbl.

  ls_stable-row = 'X'.
  ls_stable-col = 'X'.

  go_grid->refresh_table_display(
    EXPORTING
      is_stable = ls_stable
  ).
ENDFORM.
