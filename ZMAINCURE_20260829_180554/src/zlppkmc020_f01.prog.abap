*&---------------------------------------------------------------------*
*& Include          ZLPPKMC020_F01
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver IMPLEMENTATION.
  METHOD handle_double_click_plan.
    READ TABLE gt_plan_hdr INTO gs_plan_hdr INDEX e_row-index.
    IF sy-subrc = 0.
      PERFORM get_plan_item_data USING gs_plan_hdr-plnum.
      PERFORM refresh_alv.
    ENDIF.
  ENDMETHOD.

  METHOD handle_double_click_mrp.
    READ TABLE gt_mrp_hdr INTO gs_mrp_hdr INDEX e_row-index.
    IF sy-subrc = 0.
      PERFORM get_mrp_item_data USING gs_mrp_hdr-mrp_no.
      PERFORM refresh_alv.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

FORM set_initial_value.
  CREATE OBJECT go_event_receiver.
  gv_scr_mode = '1'.
ENDFORM.

FORM set_layout USING pv_title.
  CLEAR gs_layo.
  gs_layo-zebra      = abap_true.
  gs_layo-cwidth_opt = abap_true.
  gs_layo-grid_title = pv_title.
ENDFORM.

DEFINE _make_fcat.
  CLEAR gs_fcat.
  gs_fcat-fieldname = &1.
  gs_fcat-coltext   = &2.
  APPEND gs_fcat TO gt_fcat.
END-OF-DEFINITION.

FORM create_alv_mode1.
  IF go_container IS BOUND. RETURN. ENDIF.

  CREATE OBJECT go_container EXPORTING container_name = 'CC_MAIN'.
  CREATE OBJECT go_splitter EXPORTING parent = go_container rows = 1 columns = 2.
  go_splitter->set_column_width( id = 1 width = 50 ).

  go_con_left  = go_splitter->get_container( row = 1 column = 1 ).
  go_con_right = go_splitter->get_container( row = 1 column = 2 ).

  CREATE OBJECT go_grid_plan_hdr EXPORTING i_parent = go_con_left.
  CREATE OBJECT go_grid_plan_itm EXPORTING i_parent = go_con_right.

  IF go_event_receiver IS INITIAL.
    CREATE OBJECT go_event_receiver.
  ENDIF.

  SET HANDLER go_event_receiver->handle_double_click_plan FOR go_grid_plan_hdr.


  CLEAR gt_fcat.
  _make_fcat 'STATUS_ICON' 'MRP 상태'.
  _make_fcat 'PLNUM'       '생산계획 번호'.
  _make_fcat 'PLAN_TYPE'   '계획 유형'.
  _make_fcat 'PSTTR'       '계획 시작일'.
  _make_fcat 'PEDTR'       '계획 종료일'.
  PERFORM set_layout USING '생산계획 헤더 목록'.
  CALL METHOD go_grid_plan_hdr->set_table_for_first_display
    EXPORTING is_layout = gs_layo CHANGING it_outtab = gt_plan_hdr it_fieldcatalog = gt_fcat.


  CLEAR gt_fcat.
  _make_fcat 'PLNUM' '생산계획 번호'.
  _make_fcat 'POSNR' '항목 번호'.
  _make_fcat 'MATNR' '자재 번호'.
  _make_fcat 'MAKTX' '자재명'.
  _make_fcat 'WERKS' '플랜트'.
  _make_fcat 'NAME1' '플랜트 명'.
  _make_fcat 'GSMNG' '총 수량'.
  _make_fcat 'MEINS' '단위'.
  PERFORM set_layout USING '생산계획 자재 목록'.
  CALL METHOD go_grid_plan_itm->set_table_for_first_display
    EXPORTING is_layout = gs_layo CHANGING it_outtab = gt_plan_itm it_fieldcatalog = gt_fcat.
ENDFORM.

FORM create_alv_mode2.
  IF go_container IS BOUND. RETURN. ENDIF.

  CREATE OBJECT go_container EXPORTING container_name = 'CC_MAIN'.
  CREATE OBJECT go_splitter
    EXPORTING
      parent                  = go_container
      rows                    = 1
      columns                 = 2
      no_autodef_progid_dynnr = abap_true.

  go_con_left  = go_splitter->get_container( row = 1 column = 1 ).
  go_con_right = go_splitter->get_container( row = 1 column = 2 ).

  CREATE OBJECT go_split_lft
    EXPORTING
      parent                  = go_con_left
      rows                    = 2
      columns                 = 1
      no_autodef_progid_dynnr = abap_true.

  go_split_lft->set_row_mode( mode = cl_gui_splitter_container=>mode_relative ).
  go_split_lft->set_row_height( id = 1 height = 50 ).
  go_split_lft->set_row_height( id = 2 height = 50 ).

  go_con_ltop = go_split_lft->get_container( row = 1 column = 1 ).
  go_con_lbot = go_split_lft->get_container( row = 2 column = 1 ).

  CREATE OBJECT go_grid_mrp_hdr EXPORTING i_parent = go_con_ltop.
  CREATE OBJECT go_grid_mrp_itm EXPORTING i_parent = go_con_lbot.
  CREATE OBJECT go_grid_pr      EXPORTING i_parent = go_con_right.

  IF go_event_receiver IS INITIAL.
    CREATE OBJECT go_event_receiver.
  ENDIF.

  SET HANDLER go_event_receiver->handle_double_click_mrp FOR go_grid_mrp_hdr.

  CLEAR gt_fcat.
  _make_fcat 'MRP_NO'    'MRP 번호'.
  _make_fcat 'PLNUM'     '생산계획 번호'.
  _make_fcat 'PLAN_TYPE' '계획 유형'.
  _make_fcat 'PSTTR'     '계획 시작일'.
  _make_fcat 'PEDTR'     '계획 종료일'.
  PERFORM set_layout USING 'MRP 헤더 목록'.
  CALL METHOD go_grid_mrp_hdr->set_table_for_first_display
    EXPORTING is_layout = gs_layo CHANGING it_outtab = gt_mrp_hdr it_fieldcatalog = gt_fcat.

  CLEAR gt_fcat.
  _make_fcat 'BOM_MATNR' 'BOM 구성품'.
  _make_fcat 'BOM_MAKTX' 'BOM 자재명'.
  _make_fcat 'POSNR'     '아이템'.
  _make_fcat 'REQ_QTY'   '소요수량'.
  _make_fcat 'AVL_QTY'   '가용재고'.
  _make_fcat 'NEED_QTY'  '필요수량'.
  _make_fcat 'MEINS'     '단위'.
  _make_fcat 'WERKS'     '플랜트'.
  PERFORM set_layout USING 'MRP 아이템 목록'.
  CALL METHOD go_grid_mrp_itm->set_table_for_first_display
    EXPORTING is_layout = gs_layo CHANGING it_outtab = gt_mrp_itm it_fieldcatalog = gt_fcat.

  CLEAR gt_fcat.
  _make_fcat 'PR_NO' '구매요청번호'.
  _make_fcat 'MATNR' '자재 번호'.
  _make_fcat 'MAKTX' '자재명'.
  _make_fcat 'WERKS' '플랜트'.
  _make_fcat 'LGORT' '저장위치'.
  _make_fcat 'MENGE' '수량'.
  _make_fcat 'MEINS' '단위'.
  _make_fcat 'LFDAT' '납품 요청일'.
  PERFORM set_layout USING '구매요청 목록'.
  CALL METHOD go_grid_pr->set_table_for_first_display
    EXPORTING is_layout = gs_layo CHANGING it_outtab = gt_pr_list it_fieldcatalog = gt_fcat.
ENDFORM.

FORM get_data_mode1.
  CLEAR: gt_plan_hdr, gt_plan_itm.

  SELECT plnum, paart AS plan_type, psttr, pedtr
    INTO CORRESPONDING FIELDS OF TABLE @gt_plan_hdr
    FROM ztppk00030
   WHERE plnum IN @so_plnum.

  LOOP AT gt_plan_hdr ASSIGNING FIELD-SYMBOL(<fs_hdr>).
    DATA: lv_mrp_exist TYPE ztmmg00050-dtnum.

    SELECT SINGLE dtnum INTO @lv_mrp_exist
      FROM ztmmg00050
     WHERE dtnum = @<fs_hdr>-plnum.

    IF sy-subrc = 0.
      <fs_hdr>-status_icon = '@08@'.
    ELSE.
      <fs_hdr>-status_icon = '@09@'.
    ENDIF.
  ENDLOOP.

  IF gt_plan_hdr[] IS INITIAL.
    MESSAGE s000 WITH '조회된 생산계획 데이터가 없습니다.' DISPLAY LIKE 'W'.
  ENDIF.
ENDFORM.

FORM get_plan_item_data USING pv_plnum.
  CLEAR gt_plan_itm.

  SELECT a~plnum, a~kdpos AS posnr, a~matnr, b~maktx, a~plwrk AS werks, a~gsmng, a~meins
    INTO CORRESPONDING FIELDS OF TABLE @gt_plan_itm
    FROM ztppk00030 AS a
    LEFT JOIN ztmmg00020 AS b ON a~matnr = b~matnr AND b~spras = @sy-langu
   WHERE a~plnum = @pv_plnum.
ENDFORM.

FORM get_data_mode2.
  CLEAR: gt_mrp_hdr, gt_mrp_itm, gt_pr_list.

  SELECT plnum, paart AS plan_type, psttr, pedtr
    INTO CORRESPONDING FIELDS OF TABLE @gt_mrp_hdr
    FROM ztppk00030
   WHERE plnum IN @so_mrpno.

  LOOP AT gt_mrp_hdr ASSIGNING FIELD-SYMBOL(<fs_hdr>).
    <fs_hdr>-mrp_no = <fs_hdr>-plnum.
  ENDLOOP.
ENDFORM.

FORM get_mrp_item_data USING pv_mrp_no.
  DATA: lv_stlnr    TYPE ztppk00070-stlnr,
        lv_bmeng    TYPE ztppj00010-bmeng,
        lv_plan_qty TYPE ztppk00030-gsmng,
        lv_matnr    TYPE ztmmg00010-matnr,
        lv_werks    TYPE ztmmg00030-werks.

  CLEAR: gt_mrp_itm, gt_pr_list.

  SELECT SINGLE matnr, plwrk, gsmng
    INTO (@lv_matnr, @lv_werks, @lv_plan_qty)
    FROM ztppk00030
   WHERE plnum = @pv_mrp_no.

  CHECK sy-subrc = 0.

  SELECT SINGLE stlnr INTO @lv_stlnr
    FROM ztppk00070
   WHERE matnr = @lv_matnr
     AND werks = @lv_werks.

  IF sy-subrc <> 0.
    MESSAGE s000 WITH '해당 자재에 등록된 BOM이 없습니다.' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  SELECT SINGLE bmeng INTO @lv_bmeng
    FROM ztppj00010
   WHERE stlnr = @lv_stlnr.

  IF lv_bmeng IS INITIAL.
    lv_bmeng = 1.
  ENDIF.

  SELECT * INTO TABLE @DATA(lt_bom_item)
    FROM ztppj00020
   WHERE stlnr = @lv_stlnr.

  LOOP AT lt_bom_item INTO DATA(ls_bom_item).
    CLEAR gs_mrp_itm.
    gs_mrp_itm-bom_matnr = ls_bom_item-idnrk.
    gs_mrp_itm-posnr     = ls_bom_item-stlkn.
    SELECT SINGLE meins INTO gs_mrp_itm-meins
      FROM ztmmg00010
     WHERE matnr = ls_bom_item-idnrk.
      IF gs_mrp_itm-meins IS INITIAL.
      gs_mrp_itm-meins = 'EA'.
    ENDIF.
    gs_mrp_itm-werks     = lv_werks.

    SELECT SINGLE maktx INTO gs_mrp_itm-bom_maktx
      FROM ztmmg00020
     WHERE matnr = ls_bom_item-idnrk.

    "총 소요 수량 = (생산계획수량 / BOM기준수량) * 아이템소요량
    gs_mrp_itm-req_qty = ( lv_plan_qty / lv_bmeng ) * ls_bom_item-menge.

    "창고 가용 재고 확인
    SELECT SINGLE labst INTO gs_mrp_itm-avl_qty
      FROM ztmmg00040
     WHERE matnr = ls_bom_item-idnrk
       AND werks = lv_werks.

    "부족 수량(필요 수량) 도출 = 소요 수량 - 가용 재고
    gs_mrp_itm-need_qty = gs_mrp_itm-req_qty - gs_mrp_itm-avl_qty.
    IF gs_mrp_itm-need_qty < 0.
      gs_mrp_itm-need_qty = 0.
    ENDIF.

    APPEND gs_mrp_itm TO gt_mrp_itm.

    IF gs_mrp_itm-need_qty > 0.
      CLEAR gs_pr_list.
      gs_pr_list-pr_no = 'AUTO_PR'.
      gs_pr_list-matnr = gs_mrp_itm-bom_matnr.
      gs_pr_list-maktx = gs_mrp_itm-bom_maktx.
      gs_pr_list-werks = gs_mrp_itm-werks.
      gs_pr_list-lgort = 'S111'.
      gs_pr_list-menge = gs_mrp_itm-need_qty.
      gs_pr_list-meins = gs_mrp_itm-meins.
      gs_pr_list-lfdat = sy-datum + 7.
      APPEND gs_pr_list TO gt_pr_list.
    ENDIF.
  ENDLOOP.
ENDFORM.

FORM run_mrp_and_send_to_mm.
  DATA: lt_mrp_hdr TYPE TABLE OF ztmmg00050,
        ls_mrp_hdr TYPE ztmmg00050,
        lt_mrp_itm TYPE TABLE OF ztmmg00060,
        ls_mrp_itm TYPE ztmmg00060,
        lt_zeban    TYPE TABLE OF ztmmg00070,
        ls_zeban    TYPE ztmmg00070.

  DATA: lv_mrp_no TYPE c LENGTH 10,
        lv_pr_no  TYPE c LENGTH 10,
        lv_seq    TYPE n LENGTH 4,
        lv_subrc  TYPE sy-subrc.

  IF gt_mrp_itm[] IS INITIAL.
    MESSAGE s000 WITH 'MRP 실행 대상 데이터가 없습니다. 생산계획 선택 후 진행하세요.' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  lv_mrp_no = gs_mrp_hdr-plnum.
  lv_pr_no  = |PR{ sy-datum+4(4) }{ sy-uzeit+0(4) }|.

  CLEAR ls_mrp_hdr.
  ls_mrp_hdr-mandt = sy-mandt.
  ls_mrp_hdr-dtnum = lv_mrp_no.
  APPEND ls_mrp_hdr TO lt_mrp_hdr.

  LOOP AT gt_mrp_itm INTO gs_mrp_itm.
    ADD 1 TO lv_seq.

    CLEAR ls_mrp_itm.
    ls_mrp_itm-mandt = sy-mandt.
    ls_mrp_itm-dtnum = lv_mrp_no.
    ls_mrp_itm-dtpos = lv_seq.
    ls_mrp_itm-mpnmt = gs_mrp_itm-bom_matnr.
    ls_mrp_itm-wrk02 = gs_mrp_itm-werks.
    ls_mrp_itm-mng01 = gs_mrp_itm-need_qty.
    ls_mrp_itm-meins = gs_mrp_itm-meins.
    APPEND ls_mrp_itm TO lt_mrp_itm.

    IF gs_mrp_itm-need_qty > 0.
      CLEAR ls_zeban.
      ls_zeban-mandt = sy-mandt.
      ls_zeban-banfn = lv_pr_no.
      ls_zeban-bnfpo = lv_seq * 10.
      ls_zeban-bsart = 'NB'.
      ls_zeban-matnr = gs_mrp_itm-bom_matnr.
      ls_zeban-werks = gs_mrp_itm-werks.
      ls_zeban-menge = gs_mrp_itm-need_qty.
      ls_zeban-meins = gs_mrp_itm-meins.
      ls_zeban-lfdat = sy-datum + 7.
      APPEND ls_zeban TO lt_zeban.
    ENDIF.
  ENDLOOP.

  MODIFY ztmmg00050 FROM TABLE lt_mrp_hdr.
  MODIFY ztmmg00060 FROM TABLE lt_mrp_itm.

  IF lt_zeban[] IS NOT INITIAL.
    MODIFY ztmmg00070 FROM TABLE lt_zeban.
  ENDIF.

  IF sy-subrc = 0.
    COMMIT WORK.

    LOOP AT gt_pr_list ASSIGNING FIELD-SYMBOL(<fs_pr>).
      <fs_pr>-pr_no = lv_pr_no.
    ENDLOOP.

    MESSAGE s000 WITH 'MRP 실행 완료'.
  ELSE.
    ROLLBACK WORK.
    MESSAGE s000 WITH 'MRP 실행 중 저장 오류가 발생했습니다.' DISPLAY LIKE 'E'.
  ENDIF.

  PERFORM refresh_alv.
ENDFORM.


FORM free_objects.
  IF go_grid_plan_hdr IS BOUND. go_grid_plan_hdr->free( ). FREE go_grid_plan_hdr. ENDIF.
  IF go_grid_plan_itm IS BOUND. go_grid_plan_itm->free( ). FREE go_grid_plan_itm. ENDIF.
  IF go_grid_mrp_hdr IS BOUND. go_grid_mrp_hdr->free( ). FREE go_grid_mrp_hdr. ENDIF.
  IF go_grid_mrp_itm IS BOUND. go_grid_mrp_itm->free( ). FREE go_grid_mrp_itm. ENDIF.
  IF go_grid_pr IS BOUND. go_grid_pr->free( ). FREE go_grid_pr. ENDIF.
  IF go_split_lft IS BOUND. go_split_lft->free( ). FREE go_split_lft. ENDIF.
  IF go_splitter IS BOUND. go_splitter->free( ). FREE go_splitter. ENDIF.
  IF go_container IS BOUND. go_container->free( ). FREE go_container. ENDIF.
  cl_gui_cfw=>flush( ).
ENDFORM.

FORM refresh_alv.
  DATA: ls_stbl TYPE lvc_s_stbl VALUE 'XX'.
  IF go_grid_plan_hdr IS BOUND. go_grid_plan_hdr->refresh_table_display( is_stable = ls_stbl ). ENDIF.
  IF go_grid_plan_itm IS BOUND. go_grid_plan_itm->refresh_table_display( is_stable = ls_stbl ). ENDIF.
  IF go_grid_mrp_hdr IS BOUND. go_grid_mrp_hdr->refresh_table_display( is_stable = ls_stbl ). ENDIF.
  IF go_grid_mrp_itm IS BOUND. go_grid_mrp_itm->refresh_table_display( is_stable = ls_stbl ). ENDIF.
  IF go_grid_pr IS BOUND. go_grid_pr->refresh_table_display( is_stable = ls_stbl ).
  ENDIF.
ENDFORM.
