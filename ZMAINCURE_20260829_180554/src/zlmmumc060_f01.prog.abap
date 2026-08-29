*&---------------------------------------------------------------------*
*& Include          ZLMMUMC060_F01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form zz_set_initial_value
*&---------------------------------------------------------------------*
FORM zz_set_initial_value.
  REFRESH so_bedat.
  APPEND INITIAL LINE TO so_bedat ASSIGNING FIELD-SYMBOL(<fs_bedat>).
  <fs_bedat>-sign   = 'I'.
  <fs_bedat>-option = 'BT'.
  <fs_bedat>-low    = sy-datum - 500.
  <fs_bedat>-high   = sy-datum.

  CASE sy-tcode.
    WHEN 'ZLMMUMC061'. gv_mode = 'A'.
    WHEN 'ZLMMUMC062'. gv_mode = 'R'.
    WHEN OTHERS.       gv_mode = 'A'.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_exe_get_data
*&---------------------------------------------------------------------*
FORM zz_exe_get_data.
  REFRESH gt_060.

  SELECT k~ebeln, k~bukrs, k~bsart, k~lifnr,
         k~ekgrp, k~bedat, k~waers,
         p~ebelp, p~matnr, p~werks,
         p~menge, p~meins, p~netpr, p~netwr,
         p~eildt AS eindt
    FROM ekko AS k
    INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_060
    WHERE k~ebeln IN @so_ebeln
      AND k~bedat IN @so_bedat
      AND k~lifnr IN @so_lifnr
      AND k~bukrs IN @so_bukrs
      AND k~bsart IN @so_bsart
      AND p~werks IN @so_werks
      AND p~loekz = ''.

  LOOP AT gt_060 INTO gs_060.
    SELECT SINGLE maktx INTO gs_060-maktx
      FROM makt
      WHERE matnr = gs_060-matnr
        AND spras = sy-langu.
    MODIFY gt_060 FROM gs_060.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_exe_free_objects
*&---------------------------------------------------------------------*
FORM zz_exe_free_objects.
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
FORM zz_exe_create_alv.
  DATA lv_tcode TYPE sy-tcode.
  lv_tcode = sy-tcode.

  PERFORM zz_set_layout_statu.
  PERFORM zz_set_toolbar_exclude USING lv_tcode.
  PERFORM zz_set_fieldcatalog    USING lv_tcode.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.

*  CREATE OBJECT go_event_receiver.
*  SET HANDLER go_event_receiver->handle_data_changed FOR go_grid.
*  SET HANDLER go_event_receiver->handle_after_user_command FOR go_grid.

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout
      i_save               = 'A'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_060
      it_fieldcatalog      = gt_fcat.

  CALL METHOD go_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 0.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_set_layout_statu
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu.
  CLEAR gs_layout.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
  gs_layout-sel_mode   = 'A'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_set_toolbar_exclude
*&---------------------------------------------------------------------*
FORM zz_set_toolbar_exclude USING pv_tcode.
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
*& Form zz_set_fieldcatalog
*&---------------------------------------------------------------------*
FORM zz_set_fieldcatalog USING pv_tcode.
  REFRESH gt_fcat.

  DEFINE _fc.
    CLEAR gs_fcat.
    gs_fcat-fieldname = &1.
    gs_fcat-coltext   = &2.
    gs_fcat-outputlen = &3.
    gs_fcat-edit      = abap_false.
    APPEND gs_fcat TO gt_fcat.
  END-OF-DEFINITION.

  _fc 'EBELN' 'PO번호'   10.
  _fc 'EBELP' '라인'      5.
  _fc 'BUKRS' '회사코드'  4.
  _fc 'BSART' 'PO유형'    4.
  _fc 'LIFNR' '공급업체' 10.
  _fc 'EKGRP' '구매그룹'  3.
  _fc 'BEDAT' 'PO일자'   10.
  _fc 'MATNR' '자재번호' 18.
  _fc 'MAKTX' '자재명'   30.
  _fc 'WERKS' '플랜트'    4.
  _fc 'MENGE' '수량'     13.
  _fc 'MEINS' '단위'      3.
  _fc 'NETPR' '단가'     13.
  _fc 'NETWR' '순가액'   13.
  _fc 'WAERS' '통화'      5.
  _fc 'EINDT' '납기일'   10.
ENDFORM.
