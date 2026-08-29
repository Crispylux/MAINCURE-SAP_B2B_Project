*&---------------------------------------------------------------------*
*& Include          ZLMMGMC050_F01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.27    [이름]              최초작성
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
    WHEN 'ZLMMGMC051'. gv_mode = 'C'.
    WHEN 'ZLMMGMC052'. gv_mode = 'U'.
    WHEN 'ZLMMGMC053'. gv_mode = 'D'.
    WHEN OTHERS.       gv_mode = 'D'.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_exe_get_data
*&---------------------------------------------------------------------*
FORM zz_exe_get_data.
  REFRESH gt_050.

  SELECT k~ebeln, k~bukrs, k~bsart, k~lifnr,
         k~ekgrp, k~bedat, k~waers,
         p~ebelp, p~matnr, p~werks, p~lgort,
         p~menge, p~meins, p~netpr, p~netwr,
         p~eildt AS eindt,    " ← 별칭으로 매핑
         p~loekz
    FROM ekko AS k
    INNER JOIN ekpo AS p ON p~ebeln = k~ebeln
    INTO CORRESPONDING FIELDS OF TABLE @gt_050
    WHERE k~ebeln IN @so_ebeln
      AND k~bedat IN @so_bedat
      AND k~lifnr IN @so_lifnr
      AND k~bukrs IN @so_bukrs
      AND k~bsart IN @so_bsart
      AND p~werks IN @so_werks
      AND p~loekz = ''.

  LOOP AT gt_050 INTO gs_050.
    SELECT SINGLE maktx INTO gs_050-maktx
      FROM makt
      WHERE matnr = gs_050-matnr
        AND spras = sy-langu.
    MODIFY gt_050 FROM gs_050.
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

  " 이벤트 클래스 (추후 구현)
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
      it_outtab            = gt_050
      it_fieldcatalog      = gt_fcat.

  " 조회는 입력 불가, 생성/수정은 입력 가능
  IF sy-tcode = 'ZLMMGMC053'.
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
*& Form zz_set_layout_statu
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu.
  CLEAR gs_layout.
  gs_layout-zebra      = abap_true.
  gs_layout-cwidth_opt = abap_true.
*  gs_layout-sel_mode   = 'A'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_set_toolbar_exclude
*&---------------------------------------------------------------------*
FORM zz_set_toolbar_exclude USING pv_tcode.
  REFRESH gt_exclude.

  CASE pv_tcode.
    WHEN 'ZLMMGMC053'.                         " 조회: 편집 버튼 전부 제거
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.
    WHEN 'ZLMMGMC051'.                         " 생성: 행추가/삽입 허용, 나머지 제거
      APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.
    WHEN 'ZLMMGMC052'.                         " 수정: 편집 버튼 전부 제거
      APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
      APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.
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
FORM zz_set_fieldcatalog USING pv_tcode.
  REFRESH gt_fcat.

  " fcat 수동 생성 (Z구조 없으므로)
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
  _fc 'LGORT' '저장위치'  4.
  _fc 'MENGE' '수량'     13.
  _fc 'MEINS' '단위'      3.
  _fc 'NETPR' '단가'     13.
  _fc 'NETWR' '순가액'   13.
  _fc 'WAERS' '통화'      5.
  _fc 'EINDT' '납기일'   10.

  " tcode별 편집 가능 필드 오픈
  LOOP AT gt_fcat INTO gs_fcat.
    CASE pv_tcode.
      WHEN 'ZLMMGMC051'.                       " 생성
        CASE gs_fcat-fieldname.
          WHEN 'BSART' OR 'LIFNR' OR 'EKGRP'
            OR 'BEDAT' OR 'MATNR' OR 'WERKS'
            OR 'LGORT' OR 'MENGE' OR 'MEINS'
            OR 'NETPR' OR 'EINDT'.
            gs_fcat-edit = abap_true.
        ENDCASE.
      WHEN 'ZLMMGMC052'.                       " 수정
        CASE gs_fcat-fieldname.
          WHEN 'MENGE' OR 'LGORT'
            OR 'NETPR' OR 'EINDT'.
            gs_fcat-edit = abap_true.
        ENDCASE.
      WHEN 'ZLMMGMC053'.                       " 조회
        gs_fcat-edit = abap_false.
    ENDCASE.

    " 시스템 관리 필드 무조건 입력 불가
    CASE gs_fcat-fieldname.
      WHEN 'EBELN' OR 'EBELP' OR 'NETWR' OR 'WAERS'.
        gs_fcat-edit = abap_false.
    ENDCASE.

    MODIFY gt_fcat FROM gs_fcat.
  ENDLOOP.
ENDFORM.
