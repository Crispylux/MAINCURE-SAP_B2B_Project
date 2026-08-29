*&---------------------------------------------------------------------*
*& Form zz_exe_get_data
*&---------------------------------------------------------------------*
FORM zz_exe_get_data.

  "----------------------------------------------------
  " 상단 입고 리스트만 최초 조회
  "----------------------------------------------------
  REFRESH gt_070.

  SELECT banfn,
         bnfpo,
         bsart,
         matnr,
         menge,
         meins,
         werks,
         lgort,
         badat,
         lfdat,
         ebeln,
         statu,
         erzet,
         aenam
    FROM ztmmg00070
    INTO CORRESPONDING FIELDS OF TABLE @gt_070
    WHERE banfn IN @so_banfn
      AND badat IN @so_bedat.

  "----------------------------------------------------
  " 신호등
  " N = 입고처리 완료
  " 그 외 = 아직 처리할 항목 존재
  "----------------------------------------------------
  LOOP AT gt_070 ASSIGNING FIELD-SYMBOL(<ls_070>).

    SELECT SINGLE @abap_true
      FROM ztmmg00070
      WHERE banfn = @<ls_070>-banfn
        AND statu <> 'N'
      INTO @DATA(lv_not_finished).

    IF sy-subrc = 0.
      <ls_070>-light = '2'.     " 노랑 : 미처리 ITEM 존재
    ELSE.
      <ls_070>-light = '3'.     " 초록 : 모든 ITEM 완료
    ENDIF.

  ENDLOOP.
  " 처음 실행 시 검수항목은 표시하지 않음
  REFRESH gt_070_detail.

  " 처음 실행 시 재고현황도 표시하지 않음
  REFRESH gt_040.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_free_objects
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


  IF go_grid2 IS BOUND.
    CALL METHOD go_grid2->free.
    FREE go_grid2.
  ENDIF.

  IF go_container2 IS BOUND.
    CALL METHOD go_container2->free.
    FREE go_container2.
  ENDIF.


  IF go_grid3 IS BOUND.
    CALL METHOD go_grid3->free.
    FREE go_grid3.
  ENDIF.

  IF go_container3 IS BOUND.
    CALL METHOD go_container3->free.
    FREE go_container3.
  ENDIF.


  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_create_alv
*&---------------------------------------------------------------------*
FORM zz_exe_create_alv .

  PERFORM zz_set_toolbar_exclude.
  PERFORM zz_set_fieldcatalog.


  "----------------------------------------------------
  " 상단 : 입고 리스트
  "----------------------------------------------------
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.


  "----------------------------------------------------
  " 왼쪽 아래 : 검수 항목
  "----------------------------------------------------
  CREATE OBJECT go_container2
    EXPORTING
      container_name = 'CC_ALV_002'.

  CREATE OBJECT go_grid2
    EXPORTING
      i_parent = go_container2.


  "----------------------------------------------------
  " 오른쪽 아래 : 저장위치별 재고
  "----------------------------------------------------
  CREATE OBJECT go_container3
    EXPORTING
      container_name = 'CC_ALV_003'.

  CREATE OBJECT go_grid3
    EXPORTING
      i_parent = go_container3.

  CREATE OBJECT go_event_receiver.

  SET HANDLER go_event_receiver->handle_double_click
    FOR go_grid.
  " 이벤트 객체/SET HANDLER는 나중에 추가


  PERFORM zz_set_alv_grid1.
  PERFORM zz_set_alv_grid2.
  PERFORM zz_set_alv_grid3.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_layout_statu1
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu1 .

  CLEAR gs_layout1.
  gs_layout1-excp_fname = 'LIGHT'.
  gs_layout1-excp_led   = abap_true.
  gs_layout1-grid_title = '입고 리스트'.
  gs_layout1-zebra      = abap_true.
  gs_layout1-cwidth_opt = abap_true.
  gs_layout1-info_fname = 'ROW_COLOR'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_layout_statu2
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu2 .

  CLEAR gs_layout2.

  gs_layout2-grid_title = '검수 항목'.
  gs_layout2-zebra      = abap_true.
  gs_layout2-cwidth_opt = abap_true.
  gs_layout2-info_fname = 'ROW_COLOR'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_layout_statu3
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu3 .

  CLEAR gs_layout3.

  gs_layout3-grid_title = '저장 위치별 물품 현황'.
  gs_layout3-zebra      = abap_true.
  gs_layout3-cwidth_opt = abap_true.
  gs_layout3-info_fname = 'ROW_COLOR'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_toolbar_exclude
*&---------------------------------------------------------------------*
FORM zz_set_toolbar_exclude .

  REFRESH gt_exclude.

  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_alv_grid1
*& 상단 : 입고 리스트
*&---------------------------------------------------------------------*
FORM zz_set_alv_grid1 .

  PERFORM zz_set_layout_statu1.


  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout1
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00070'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_070
      it_fieldcatalog      = gt_fcat.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_alv_grid2
*& 왼쪽 아래 : 검수 항목
*&---------------------------------------------------------------------*
FORM zz_set_alv_grid2 .

  PERFORM zz_set_layout_statu2.


  CALL METHOD go_grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


  CALL METHOD go_grid2->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout2
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00070'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_070_detail
      it_fieldcatalog      = gt_fcat2.


  " 검수 항목은 MENGE 수정 가능
  CALL METHOD go_grid2->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_alv_grid3
*& 오른쪽 아래 : 저장위치별 재고
*&---------------------------------------------------------------------*
FORM zz_set_alv_grid3 .

  PERFORM zz_set_layout_statu3.


  CALL METHOD go_grid3->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout3
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00040'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_040
      it_fieldcatalog      = gt_fcat3.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_fieldcatalog
*&---------------------------------------------------------------------*
FORM zz_set_fieldcatalog .

  "====================================================
  " ALV 1 : 입고 리스트
  "====================================================
  REFRESH gt_fcat.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTMMG00070'
    CHANGING
      ct_fieldcat      = gt_fcat.

  LOOP AT gt_fcat INTO gs_fcat.

    " 상단은 조회 전용
    gs_fcat-edit = abap_false.

    MODIFY gt_fcat FROM gs_fcat.

  ENDLOOP.


  "====================================================
  " ALV 2 : 검수 항목
  "====================================================
  REFRESH gt_fcat2.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTMMG00070'
    CHANGING
      ct_fieldcat      = gt_fcat2.

  LOOP AT gt_fcat2 INTO gs_fcat2.

    " 기본적으로 수정 불가
    gs_fcat2-edit = abap_false.


    " 수량만 수정 가능
    CASE gs_fcat2-fieldname.

      WHEN 'MENGE'.
        gs_fcat2-edit = abap_true.

    ENDCASE.


    MODIFY gt_fcat2 FROM gs_fcat2.

  ENDLOOP.


  "====================================================
  " ALV 3 : 저장위치별 재고
  "====================================================
  REFRESH gt_fcat3.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTMMG00040'
    CHANGING
      ct_fieldcat      = gt_fcat3.

  LOOP AT gt_fcat3 INTO gs_fcat3.

    " 재고 현황은 조회 전용
    gs_fcat3-edit = abap_false.

    MODIFY gt_fcat3 FROM gs_fcat3.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_get_inspection_data
*& 입고 리스트에서 BANFN 더블클릭 시 호출 예정
*&---------------------------------------------------------------------*
FORM zz_get_inspection_data
  USING pv_banfn TYPE ztmmg00070-banfn.

  REFRESH gt_070_detail.


  SELECT *
    FROM ztmmg00070
    INTO CORRESPONDING FIELDS OF TABLE @gt_070_detail
    WHERE banfn = @pv_banfn
    ORDER BY bnfpo.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_search_stock
*& 오른쪽 검색 버튼 클릭 시 호출
*&---------------------------------------------------------------------*
FORM zz_exe_search_stock .

  DATA ls_stable TYPE lvc_s_stbl.

  REFRESH gt_040.


  "----------------------------------------------------
  " 검색조건 확인
  "----------------------------------------------------
  IF gv_matnr IS INITIAL
     AND gv_lgort IS INITIAL.

    MESSAGE i000(oo) WITH
      '자재 또는 저장위치를 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 자재 + 저장위치
  "----------------------------------------------------
  IF gv_matnr IS NOT INITIAL
     AND gv_lgort IS NOT INITIAL.

    SELECT *
      FROM ztmmg00040
      INTO CORRESPONDING FIELDS OF TABLE @gt_040
      WHERE matnr = @gv_matnr
        AND lgort = @gv_lgort.


    "----------------------------------------------------
    " 자재만
    "----------------------------------------------------
  ELSEIF gv_matnr IS NOT INITIAL.

    SELECT *
      FROM ztmmg00040
      INTO CORRESPONDING FIELDS OF TABLE @gt_040
      WHERE matnr = @gv_matnr.


    "----------------------------------------------------
    " 저장위치만
    "----------------------------------------------------
  ELSEIF gv_lgort IS NOT INITIAL.

    SELECT *
      FROM ztmmg00040
      INTO CORRESPONDING FIELDS OF TABLE @gt_040
      WHERE lgort = @gv_lgort.

  ENDIF.


  IF gt_040 IS INITIAL.
    MESSAGE i000(oo) WITH '재고 데이터가 없습니다'.
  ENDIF.


  "----------------------------------------------------
  " 재고 ALV Refresh
  "----------------------------------------------------
  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  IF go_grid3 IS BOUND.

    CALL METHOD go_grid3->refresh_table_display
      EXPORTING
        is_stable = ls_stable.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_data_appr
*& 입고처리
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zz_exe_data_appr
*& 입고처리
*&---------------------------------------------------------------------*
FORM zz_exe_data_appr .

  DATA: lt_selected_rows TYPE lvc_t_row,
        ls_040           TYPE ztmmg00040,
        ls_stable        TYPE lvc_s_stbl,
        lv_answer        TYPE c.


  "----------------------------------------------------
  " 1. ALV에서 수정한 MENGE를 GT_070_DETAIL에 반영
  "----------------------------------------------------
  go_grid2->check_changed_data( ).


  "----------------------------------------------------
  " 2. 검수 항목에서 선택한 행 가져오기
  "----------------------------------------------------
  go_grid2->get_selected_rows(
    IMPORTING
      et_index_rows = lt_selected_rows
  ).

  IF lt_selected_rows IS INITIAL.

    MESSAGE i000(oo) WITH
      '입고할 검수 항목을 선택해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 3. 선택한 데이터 사전 검증
  "    실제 DB 변경 전에 먼저 전부 확인
  "----------------------------------------------------
  LOOP AT lt_selected_rows
    ASSIGNING FIELD-SYMBOL(<ls_selected_row>).

    READ TABLE gt_070_detail
      ASSIGNING FIELD-SYMBOL(<ls_070>)
      INDEX <ls_selected_row>-index.

    IF sy-subrc <> 0.

      MESSAGE i000(oo) WITH
        '선택한 검수 항목을 읽을 수 없습니다'.

      RETURN.

    ENDIF.


    " 이미 입고 완료된 항목
    IF <ls_070>-statu = 'N'.

      MESSAGE i000(oo) WITH
        <ls_070>-banfn
        <ls_070>-bnfpo
        '이미 입고 처리된 항목입니다'.

      RETURN.

    ENDIF.


    " 입고 수량 검증
    IF <ls_070>-menge <= 0.

      MESSAGE i000(oo) WITH
        '입고 수량은 0보다 커야 합니다'.

      RETURN.

    ENDIF.


    " 재고 반영에 필요한 값 검증
    IF <ls_070>-matnr IS INITIAL
       OR <ls_070>-werks IS INITIAL
       OR <ls_070>-lgort IS INITIAL.

      MESSAGE i000(oo) WITH
        '자재, 플랜트, 저장위치를 확인해주세요'.

      RETURN.

    ENDIF.

  ENDLOOP.


  "----------------------------------------------------
  " 4. 입고처리 확인
  "----------------------------------------------------
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '입고 처리'
      text_question         = '선택한 검수 항목을 입고 처리하시겠습니까?'
      text_button_1         = '예'
      text_button_2         = '아니오'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.


  "----------------------------------------------------
  " 5. 선택한 검수 항목 실제 입고처리
  "----------------------------------------------------
  LOOP AT lt_selected_rows
    ASSIGNING <ls_selected_row>.

    READ TABLE gt_070_detail
      ASSIGNING <ls_070>
      INDEX <ls_selected_row>-index.

    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.


    "--------------------------------------------------
    " 6. 기존 저장위치 재고 조회
    "    MATNR + WERKS + LGORT
    "--------------------------------------------------
    CLEAR ls_040.

    SELECT SINGLE *
      FROM ztmmg00040
      INTO @ls_040
      WHERE matnr = @<ls_070>-matnr
        AND werks = @<ls_070>-werks
        AND lgort = @<ls_070>-lgort.


    IF sy-subrc = 0.

      "------------------------------------------------
      " 기존 재고 있음
      " → 입고 수량만큼 가용재고 증가
      "------------------------------------------------
      ls_040-labst =
        ls_040-labst + <ls_070>-menge.


      MODIFY ztmmg00040 FROM ls_040.

      IF sy-subrc <> 0.

        ROLLBACK WORK.

        MESSAGE i000(oo) WITH
          '재고 변경 중 오류가 발생했습니다'.

        RETURN.

      ENDIF.


    ELSE.

      "------------------------------------------------
      " 해당 자재/플랜트/저장위치 재고가 없음
      " → 신규 재고 데이터 생성
      "------------------------------------------------
      CLEAR ls_040.

      ls_040-matnr = <ls_070>-matnr.
      ls_040-werks = <ls_070>-werks.
      ls_040-lgort = <ls_070>-lgort.

      " 입고 수량
      ls_040-labst = <ls_070>-menge.

      " 기본 단위
      ls_040-meins = <ls_070>-meins.

      " 현재 연도 / 월
      ls_040-lfgja = sy-datum(4).
      ls_040-lfmon = sy-datum+4(2).


      " MODIFY이므로 없으면 INSERT 역할
      MODIFY ztmmg00040 FROM ls_040.

      IF sy-subrc <> 0.

        ROLLBACK WORK.

        MESSAGE i000(oo) WITH
          '신규 재고 생성 중 오류가 발생했습니다'.

        RETURN.

      ENDIF.

    ENDIF.


    "--------------------------------------------------
    " 7. 검수 항목 입고완료 상태 변경
    "
    " 사용자가 수정한 MENGE도 <LS_070>에 들어 있으므로
    " MODIFY 하면 수량 + 상태가 같이 DB에 반영됨
    "--------------------------------------------------
    <ls_070>-statu = 'N'.


    MODIFY ztmmg00070 FROM <ls_070>.

    IF sy-subrc <> 0.

      ROLLBACK WORK.

      MESSAGE i000(oo) WITH
        '검수 항목 저장 중 오류가 발생했습니다'.

      RETURN.

    ENDIF.

  ENDLOOP.


  "----------------------------------------------------
  " 8. 모든 입고처리가 성공했을 때만 COMMIT
  "----------------------------------------------------
  COMMIT WORK.


  "----------------------------------------------------
  " 9. 상단 입고 리스트 재조회
  "
  " 여기서 BANFN별 STATU를 다시 확인해서
  "
  " 미처리 존재 → LIGHT = 2 노랑
  " 모두 N      → LIGHT = 3 초록
  "----------------------------------------------------
  PERFORM zz_exe_get_data.


  "----------------------------------------------------
  " 10. 현재 더블클릭했던 구매요청 검수항목 재조회
  "
  " zz_exe_get_data에서 GT_070_DETAIL을 REFRESH하므로
  " 반드시 그 뒤에 호출
  "----------------------------------------------------
  IF gv_banfn IS NOT INITIAL.

    PERFORM zz_get_inspection_data
      USING gv_banfn.

  ENDIF.


  "----------------------------------------------------
  " 11. 오른쪽 재고검색 조건이 있으면 재조회
  "----------------------------------------------------
  IF gv_matnr IS NOT INITIAL
     OR gv_lgort IS NOT INITIAL.

    PERFORM zz_exe_search_stock.

  ENDIF.


  "----------------------------------------------------
  " 12. ALV Refresh
  "----------------------------------------------------
  ls_stable-row = abap_true.
  ls_stable-col = abap_true.


  " 상단 입고 리스트
  IF go_grid IS BOUND.

    go_grid->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).

  ENDIF.


  " 하단 검수 항목
  IF go_grid2 IS BOUND.

    go_grid2->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).

  ENDIF.


  " 오른쪽 저장위치별 재고
  IF go_grid3 IS BOUND.

    go_grid3->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).

  ENDIF.


  MESSAGE s000(oo) WITH
    '입고 처리가 완료되었습니다'.

ENDFORM.
*FORM zz_exe_data_appr .
*
*  DATA: lt_selected_rows TYPE lvc_t_row,
*        ls_040           TYPE ztmmg00040,
*        ls_stable        TYPE lvc_s_stbl,
*        lv_answer        TYPE c.
*
*  "----------------------------------------------------
*  " 1. ALV에서 현재 수정 중인 값 GT_070_DETAIL에 반영
*  "----------------------------------------------------
*  go_grid2->check_changed_data( ).
*
*
*  "----------------------------------------------------
*  " 2. 검수 항목에서 선택한 행 가져오기
*  "----------------------------------------------------
*  go_grid2->get_selected_rows(
*    IMPORTING
*      et_index_rows = lt_selected_rows
*  ).
*
*  IF lt_selected_rows IS INITIAL.
*    MESSAGE i000(oo) WITH '입고할 검수 항목을 선택해주세요'.
*    RETURN.
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 3. 입고 처리 확인
*  "----------------------------------------------------
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      titlebar              = '입고 처리'
*      text_question         = '선택한 항목을 입고 처리하시겠습니까?'
*      text_button_1         = '예'
*      text_button_2         = '아니오'
*      default_button        = '1'
*      display_cancel_button = space
*    IMPORTING
*      answer                = lv_answer.
*
*  IF lv_answer <> '1'.
*    RETURN.
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 4. 선택한 검수 항목 입고 처리
*  "----------------------------------------------------
*  LOOP AT lt_selected_rows
*    ASSIGNING FIELD-SYMBOL(<ls_selected_row>).
*
*    " 선택된 검수 항목 읽기
*    READ TABLE gt_070_detail
*      ASSIGNING FIELD-SYMBOL(<ls_070>)
*      INDEX <ls_selected_row>-index.
*
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*
*    " 수량 체크
*    IF <ls_070>-menge <= 0.
*
*      ROLLBACK WORK.
*
*      MESSAGE i000(oo) WITH
*        '입고 수량은 0보다 커야 합니다'.
*
*      RETURN.
*
*    ENDIF.
*
*
*    " 자재 / 플랜트 / 저장위치 체크
*    IF <ls_070>-matnr IS INITIAL
*       OR <ls_070>-werks IS INITIAL
*       OR <ls_070>-lgort IS INITIAL.
*
*      ROLLBACK WORK.
*
*      MESSAGE i000(oo) WITH
*        '자재, 플랜트, 저장위치를 확인해주세요'.
*
*      RETURN.
*
*    ENDIF.
*
*
*    "--------------------------------------------------
*    " 5. 현재 창고 재고 조회
*    " MATNR + WERKS + LGORT
*    "--------------------------------------------------
*    CLEAR ls_040.
*
*    SELECT SINGLE *
*      FROM ztmmg00040
*      INTO @ls_040
*      WHERE matnr = @<ls_070>-matnr
*        AND werks = @<ls_070>-werks
*        AND lgort = @<ls_070>-lgort.
*
*
*    IF sy-subrc = 0.
*
*      "------------------------------------------------
*      " 기존 재고가 있으면 가용재고 증가
*      "------------------------------------------------
*      ls_040-labst = ls_040-labst + <ls_070>-menge.
*
*      MODIFY ztmmg00040 FROM @ls_040.
*
*      IF sy-subrc <> 0.
*
*        ROLLBACK WORK.
*
*        MESSAGE i000(oo) WITH
*          '재고 변경 중 오류가 발생했습니다'.
*
*        RETURN.
*
*      ENDIF.
*
*
*    ELSE.
*
*      "------------------------------------------------
*      " 해당 저장위치 재고가 없으면 신규 생성
*      "------------------------------------------------
*      CLEAR ls_040.
*
*      ls_040-matnr = <ls_070>-matnr.
*      ls_040-werks = <ls_070>-werks.
*      ls_040-lgort = <ls_070>-lgort.
*
*      " 입고 수량 → 가용재고
*      ls_040-labst = <ls_070>-menge.
*
*      " 단위
*      ls_040-meins = <ls_070>-meins.
*
*      " 현재 연도 / 월
*      ls_040-lfgja = sy-datum(4).
*      ls_040-lfmon = sy-datum+4(2).
*
*
*      INSERT ztmmg00040 FROM @ls_040.
*
*      IF sy-subrc <> 0.
*
*        ROLLBACK WORK.
*
*        MESSAGE i000(oo) WITH
*          '신규 재고 생성 중 오류가 발생했습니다'.
*
*        RETURN.
*
*      ENDIF.
*
*    ENDIF.
*
*
*    "--------------------------------------------------
*    " 6. 검수에서 입력한 수량도 DB에 저장
*    "--------------------------------------------------
*    UPDATE ztmmg00070
*      SET menge = @<ls_070>-menge
*      WHERE banfn = @<ls_070>-banfn
*        AND bnfpo = @<ls_070>-bnfpo.
*
*    IF sy-subrc <> 0.
*
*      ROLLBACK WORK.
*
*      MESSAGE i000(oo) WITH
*        '검수 데이터 저장 중 오류가 발생했습니다'.
*
*      RETURN.
*
*    ENDIF.
*
*  ENDLOOP.
*
*
*  "----------------------------------------------------
*  " 7. 전체 성공 시 COMMIT
*  "----------------------------------------------------
*  COMMIT WORK.
*
*
*  "----------------------------------------------------
*  " 8. 현재 검수 항목 다시 조회
*  "----------------------------------------------------
*  IF gv_banfn IS NOT INITIAL.
*    PERFORM zz_get_inspection_data USING gv_banfn.
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 9. 오른쪽 재고현황도 현재 검색조건으로 다시 조회
*  "----------------------------------------------------
*  IF gv_matnr IS NOT INITIAL
*     OR gv_lgort IS NOT INITIAL.
*
*    PERFORM zz_exe_search_stock.
*
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 10. ALV Refresh
*  "----------------------------------------------------
*  ls_stable-row = abap_true.
*  ls_stable-col = abap_true.
*
*
*  " 검수 항목
*  IF go_grid2 IS BOUND.
*
*    go_grid2->refresh_table_display(
*      EXPORTING
*        is_stable = ls_stable
*    ).
*
*  ENDIF.
*
*
*  MESSAGE s000(oo) WITH '입고 처리가 완료되었습니다'.
*
*ENDFORM.
