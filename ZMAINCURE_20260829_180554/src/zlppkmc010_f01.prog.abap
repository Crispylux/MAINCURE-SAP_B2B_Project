*&---------------------------------------------------------------------*
*& Include          ZLPPKMC010_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Form set_initial_value
*&---------------------------------------------------------------------*
FORM set_initial_value.
  "CLEAR so_vdatu.

  "so_vdatu-sign   = 'I'.
  "so_vdatu-option = 'BT'.

  "so_vdatu-low    = sy-datum - 30.
  "so_vdatu-high   = sy-datum + 14.

  "APPEND so_vdatu.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_alv
*&---------------------------------------------------------------------*
FORM create_alv.

  IF go_container IS BOUND.
    RETURN.
  ENDIF.

  PERFORM build_field_catalog.
  PERFORM build_field_catalog_mid.
  PERFORM build_field_catalog_rgt.
  PERFORM set_layout.

  CREATE OBJECT go_container EXPORTING container_name = 'CC_MAIN'.
  CREATE OBJECT go_splitter
    EXPORTING parent = go_container rows = 1 columns = 3.

  go_con_left = go_splitter->get_container( row = 1 column = 1 ).
  go_con_mid  = go_splitter->get_container( row = 1 column = 2 ).
  go_con_rgt  = go_splitter->get_container( row = 1 column = 3 ).

  go_splitter->set_column_width( id = 1 width = 36 ).
  go_splitter->set_column_width( id = 2 width = 32 ).
  go_splitter->set_column_width( id = 3 width = 32 ).

  CREATE OBJECT go_splitter_left
    EXPORTING parent = go_con_left rows = 2 columns = 1.

  go_splitter_left->set_row_height( id = 1 height = 8 ).

  go_con_left_top = go_splitter_left->get_container( row = 1 column = 1 ).
  go_con_left_alv = go_splitter_left->get_container( row = 2 column = 1 ).

  PERFORM create_top_of_page.

  CREATE OBJECT go_grid_left EXPORTING i_parent = go_con_left_alv.
  CREATE OBJECT go_grid_mid  EXPORTING i_parent = go_con_mid.
  CREATE OBJECT go_grid_rgt  EXPORTING i_parent = go_con_rgt.

  CALL METHOD go_grid_left->register_edit_event
    EXPORTING i_event_id = cl_gui_alv_grid=>mc_evt_modified.
  CALL METHOD go_grid_left->set_table_for_first_display
    EXPORTING is_layout = gs_layout  i_save = 'A'
    CHANGING  it_outtab = gt_list    it_fieldcatalog = gt_fcat.

  CALL METHOD go_grid_mid->set_table_for_first_display
    EXPORTING is_layout = gs_layout_mid i_save = 'A'
    CHANGING  it_outtab = gt_list_mid   it_fieldcatalog = gt_fcat_mid.

  CALL METHOD go_grid_rgt->register_edit_event
    EXPORTING i_event_id = cl_gui_alv_grid=>mc_evt_modified.
  CALL METHOD go_grid_rgt->set_table_for_first_display
    EXPORTING is_layout = gs_layout_rgt i_save = 'A'
    CHANGING  it_outtab = gt_list_rgt   it_fieldcatalog = gt_fcat_rgt.
  CALL METHOD go_grid_rgt->set_ready_for_input
    EXPORTING i_ready_for_input = 1.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_field_catalog
*&---------------------------------------------------------------------*
FORM build_field_catalog.
  CLEAR gt_fcat.

  DEFINE _make_fcat.
    CLEAR gs_fcat.
    gs_fcat-fieldname = &1.
    gs_fcat-coltext   = &2.
    APPEND gs_fcat TO gt_fcat.
  END-OF-DEFINITION.

  _make_fcat 'STATUS_ICON' '생산계획 전환 여부'.
  _make_fcat 'VBELN'       '판매오더 번호'.
  _make_fcat 'MATNR'       '자재 번호'.
  _make_fcat 'MAKTX'       '자재명'.
  _make_fcat 'KWMENG'      '수량'.
  _make_fcat 'VRKME'       '단위'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_field_catalog_mid
*&---------------------------------------------------------------------*
FORM build_field_catalog_mid.
  CLEAR gt_fcat_mid.

  DEFINE _make_fcat_mid.
    CLEAR gs_fcat_mid.
    gs_fcat_mid-fieldname = &1.
    gs_fcat_mid-coltext   = &2.
    APPEND gs_fcat_mid TO gt_fcat_mid.
  END-OF-DEFINITION.

  _make_fcat_mid 'PLNUM' '생산계획 번호'.
  _make_fcat_mid 'GUBUN' '판매계획/오더 구분'.
  _make_fcat_mid 'PSTTR' '계획 시작일'.
  _make_fcat_mid 'PEDTR' '계획 종료일'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
FORM set_layout.
  CLEAR gs_layout.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-grid_title = '판매계획/오더 조회 결과'.
  gs_layout-sel_mode   = 'D'.

  CLEAR gs_layout_mid.
  gs_layout_mid-zebra      = abap_true.
  gs_layout_mid-cwidth_opt = abap_true.
  gs_layout_mid-grid_title = '생산계획 테이블'.

  CLEAR gs_layout_rgt.
  gs_layout_rgt-zebra      = abap_true.
  gs_layout_rgt-cwidth_opt = abap_true.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data.
  DATA: lv_exist_plnum TYPE ztppk00030-plnum.
  CLEAR gt_list.


  SELECT a~vbeln b~posnr b~matnr c~maktx b~kwmeng b~vrkme a~vdatu AS edatu
    INTO CORRESPONDING FIELDS OF TABLE gt_list
    FROM ZTSDS00010 AS a
    INNER JOIN ZTSDS00020 AS b ON a~vbeln = b~vbeln
    LEFT JOIN ZTMMG00020 AS c  ON b~matnr = c~matnr AND c~spras = sy-langu
   WHERE a~vbeln IN so_vbeln
     AND b~matnr IN so_matnr
     AND a~kunnr IN so_kunnr
     AND a~vdatu IN so_vdatu.

  LOOP AT gt_list ASSIGNING <fs_list>.
    SELECT SINGLE labst INTO <fs_list>-labst
      FROM ZTMMG00040
     WHERE matnr = <fs_list>-matnr.

    <fs_list>-plan_qty = <fs_list>-kwmeng - <fs_list>-labst.
    IF <fs_list>-plan_qty < 0.
      <fs_list>-plan_qty = 0.
    ENDIF.

    <fs_list>-plan_date      = sy-datum.
    <fs_list>-pldord_profile = 'LA'.

    SELECT SINGLE plnum INTO lv_exist_plnum
      FROM ztppk00030
     WHERE kdauf = <fs_list>-vbeln
       AND kdpos = <fs_list>-posnr.

    IF sy-subrc = 0.
      <fs_list>-status_icon = '@08@'.
      <fs_list>-plan_qty    = 0.
    ELSE.
      <fs_list>-status_icon = '@09@'.
    ENDIF.
  ENDLOOP.

  PERFORM set_display_data.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_display_data
*&---------------------------------------------------------------------*
FORM set_display_data.
  LOOP AT gt_list ASSIGNING <fs_list>.
    IF <fs_list>-plan_qty = 0.
      <fs_list>-row_color = 'C010'.
    ELSE.
      CLEAR <fs_list>-row_color.
    ENDIF.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
FORM refresh_alv.
  DATA: ls_stable TYPE lvc_s_stbl.
  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  IF go_grid_left IS BOUND.
    CALL METHOD go_grid_left->refresh_table_display
      EXPORTING is_stable = ls_stable.
  ENDIF.

  IF go_grid_mid IS BOUND.
    CALL METHOD go_grid_mid->refresh_table_display EXPORTING is_stable = ls_stable.
  ENDIF.
  IF go_grid_rgt IS BOUND.
    CALL METHOD go_grid_rgt->refresh_table_display EXPORTING is_stable = ls_stable.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form free_objects
*&---------------------------------------------------------------------*
FORM free_objects.
  IF go_grid_left IS BOUND.
    CALL METHOD go_grid_left->free.
    FREE go_grid_left.
  ENDIF.
  IF go_grid_mid IS BOUND.
    CALL METHOD go_grid_mid->free.
    FREE go_grid_mid.
  ENDIF.
  IF go_grid_rgt IS BOUND.
    CALL METHOD go_grid_rgt->free.
    FREE go_grid_rgt.
  ENDIF.
  IF go_splitter IS BOUND.
    CALL METHOD go_splitter->free.
    FREE go_splitter.
  ENDIF.
  IF go_container IS BOUND.
    CALL METHOD go_container->free.
    FREE go_container.
  ENDIF.
  CALL METHOD cl_gui_cfw=>flush.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_field_catalog_rgt
*&---------------------------------------------------------------------*
*& 우측 하단  ALV용 컬럼 헤더 정의 (생산 수량 편집 활성화)
*&---------------------------------------------------------------------*
FORM build_field_catalog_rgt.
  CLEAR gt_fcat_rgt.

  DEFINE _make_fcat_rgt.
    CLEAR gs_fcat_rgt.
    gs_fcat_rgt-fieldname = &1.
    gs_fcat_rgt-coltext   = &2.
    APPEND gs_fcat_rgt TO gt_fcat_rgt.
  END-OF-DEFINITION.

  _make_fcat_rgt 'MATNR'    '자재번호'.
  _make_fcat_rgt 'PLNUM'    '생산계획 번호'.
  _make_fcat_rgt 'POSNR'    '아이템 번호'.
  _make_fcat_rgt 'WERKS'    '플랜트 번호'.

  CLEAR gs_fcat_rgt.
  gs_fcat_rgt-fieldname = 'PLAN_QTY'.
  gs_fcat_rgt-coltext   = '생산 수량'.
  gs_fcat_rgt-edit      = abap_true.
  gs_fcat_rgt-qfieldname = 'VRKME'.
  APPEND gs_fcat_rgt TO gt_fcat_rgt.

  _make_fcat_rgt 'VRKME'   '단위'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_temp_plan
*&---------------------------------------------------------------------*
FORM create_temp_plan.
  DATA: lt_rows  TYPE lvc_t_row,
        ls_row   TYPE lvc_s_row,
        lv_seq_str TYPE n LENGTH 4,
        lv_plnum TYPE ztppk00030-plnum.

  DATA: lv_prefix    TYPE c LENGTH 6,
        lv_max_plnum TYPE ztppk00030-plnum.

  CALL METHOD go_grid_left->get_selected_rows
    IMPORTING et_index_rows = lt_rows.

  IF lt_rows[] IS INITIAL.
    MESSAGE s000 WITH '생산계획을 생성할 대상을 선택하세요.' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gv_tmp_seq IS INITIAL.
    lv_prefix = |T{ sy-datum+4(4) }%|.

    SELECT MAX( plnum ) INTO lv_max_plnum
      FROM ztppk00030
     WHERE plnum LIKE lv_prefix.

    IF lv_max_plnum IS NOT INITIAL.
      gv_tmp_seq = lv_max_plnum+5(4).
    ENDIF.
  ENDIF.

  LOOP AT lt_rows INTO ls_row.
    READ TABLE gt_list ASSIGNING <fs_list> INDEX ls_row-index.
    CHECK sy-subrc = 0.

    IF <fs_list>-plan_qty <= 0.
      CONTINUE.
    ENDIF.

    ADD 1 TO gv_tmp_seq.
    lv_seq_str = gv_tmp_seq.
    lv_plnum = |T{ sy-datum+4(4) }{ lv_seq_str }|.

    CLEAR gs_list_mid.
    gs_list_mid-plnum = lv_plnum.
    gs_list_mid-gubun = '판매오더'.
    gs_list_mid-psttr = sy-datum.
    gs_list_mid-pedtr = sy-datum + 7.
    APPEND gs_list_mid TO gt_list_mid.

    CLEAR gs_list_rgt.
    gs_list_rgt-vbeln    = <fs_list>-vbeln.
    gs_list_rgt-matnr    = <fs_list>-matnr.
    gs_list_rgt-plnum    = lv_plnum.
    gs_list_rgt-posnr    = <fs_list>-posnr.
    gs_list_rgt-werks    = '1010'.
    gs_list_rgt-plan_qty = <fs_list>-plan_qty.
    gs_list_rgt-vrkme    = <fs_list>-vrkme.
    APPEND gs_list_rgt TO gt_list_rgt.
  ENDLOOP.

  PERFORM refresh_alv.
  MESSAGE s000 WITH '임시 생산계획이 테이블에 추가되었습니다.'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form save_plan
*&---------------------------------------------------------------------*
FORM save_plan.
  DATA: lt_save TYPE TABLE OF ztppk00030,
        ls_save TYPE ztppk00030.
  DATA: lv_subrc TYPE sy-subrc,
        lv_count TYPE i.

  IF gt_list_mid[] IS INITIAL.
    MESSAGE s000 WITH '저장할 임시 생산계획 데이터가 없습니다.' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  LOOP AT gt_list_rgt INTO gs_list_rgt.
    CLEAR ls_save.

    ls_save-mandt = sy-mandt.
    ls_save-plnum = gs_list_rgt-plnum.
    ls_save-matnr = gs_list_rgt-matnr.
    ls_save-plwrk = gs_list_rgt-werks.
    ls_save-gsmng = gs_list_rgt-plan_qty.
    ls_save-meins = gs_list_rgt-vrkme.
    ls_save-kdauf = gs_list_rgt-vbeln.
    ls_save-kdpos = gs_list_rgt-posnr.

    READ TABLE gt_list_mid INTO gs_list_mid WITH KEY plnum = gs_list_rgt-plnum.
    IF sy-subrc = 0.
      ls_save-psttr = gs_list_mid-psttr.
      ls_save-pedtr = gs_list_mid-pedtr.
    ENDIF.

    ls_save-paart = 'LA'.

    APPEND ls_save TO lt_save.
  ENDLOOP.

  IF lt_save[] IS NOT INITIAL.
    MODIFY ztppk00030 FROM TABLE lt_save.
    lv_subrc = sy-subrc.
  ENDIF.

  IF lv_subrc = 0.
    COMMIT WORK.
    lv_count = lines( lt_save ).

    LOOP AT gt_list ASSIGNING <fs_list>.
      READ TABLE gt_list_rgt WITH KEY vbeln = <fs_list>-vbeln
                                      matnr = <fs_list>-matnr
                                      posnr = <fs_list>-posnr
                                      TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        <fs_list>-status_icon = '@08@'.
        <fs_list>-plan_qty    = 0.
        <fs_list>-row_color   = 'C010'.
      ENDIF.
    ENDLOOP.

    CLEAR: gt_list_mid, gt_list_rgt.

    MESSAGE s000 WITH |총 { lv_count }건의 생산계획이 성공적으로 저장되었습니다.|.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s000 WITH '저장 중 오류가 발생했습니다.' DISPLAY LIKE 'E'.
  ENDIF.

  PERFORM refresh_alv.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form init_data
*&---------------------------------------------------------------------*
FORM init_data.
  CLEAR: gt_list_mid, gt_list_rgt, gv_tmp_seq.

  PERFORM get_data.

  PERFORM refresh_alv.
  MESSAGE s000 WITH '저장 직후 상태로 화면이 초기화되었습니다.'.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form create_top_of_page
*&---------------------------------------------------------------------*
FORM create_top_of_page.
  DATA: lv_text TYPE sdydo_text_element.

  CREATE OBJECT go_dyndoc
    EXPORTING style = 'ALV_GRID'.

  lv_text = '▲ 생산계획으로 전환되지 않은 판매계획/오더      '.
  CALL METHOD go_dyndoc->add_text EXPORTING text = lv_text.

  lv_text = '■ 생산계획으로 전환된 판매계획/오더'.
  CALL METHOD go_dyndoc->add_text EXPORTING text = lv_text.

  CALL METHOD go_dyndoc->new_line.

  lv_text = '* 임시 생성된 생산계획도 ■ 해당 아이콘으로 변환됩니다.'.
  CALL METHOD go_dyndoc->add_text EXPORTING text = lv_text.

  CALL METHOD go_dyndoc->display_document
    EXPORTING parent = go_con_left_top.
ENDFORM.
