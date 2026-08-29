*&---------------------------------------------------------------------*
*& Include          ZLFICMC040_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form set_initial_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_initial_value .

  pa_gjahr = sy-datum+0(4).

  CLEAR so_bukrs.
  so_bukrs-sign = 'I'.
  so_bukrs-option = 'EQ'.
  so_bukrs-low = '1000'.
  APPEND so_bukrs.

  CLEAR so_monat.
  so_monat-sign = 'I'.
  so_monat-option = 'EQ'.
  so_monat-low = sy-datum+4(2).
  APPEND so_monat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_alv .

  PERFORM build_field_catalog.
  PERFORM set_layout.

  gt_tree = gt_list.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_tree
    EXPORTING
      parent              = go_container
      node_selection_mode = cl_gui_column_tree=>node_sel_mode_single
      item_selection      = abap_true
      no_html_header      = abap_true
      no_toolbar          = space.

  CALL METHOD go_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = gs_hierarchy_header
    CHANGING
      it_outtab           = gt_list
      it_fieldcatalog     = gt_fcat.

  PERFORM build_tree_nodes.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_field_catalog .

  CLEAR gt_fcat.

* 항목코드
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'GRP_CD'.
  gs_fcat-coltext     = '항목코드'.
  gs_fcat-outputlen   = 12.
  APPEND gs_fcat TO gt_fcat.

* 당기금액
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'CURR_AMT'.
  gs_fcat-coltext     = '당기금액'.
  gs_fcat-outputlen   = 20.
  gs_fcat-just        = 'R'.
  gs_fcat-do_sum      = abap_true.
  gs_fcat-cfieldname  = 'WAERS'.
  APPEND gs_fcat TO gt_fcat.

* 전기금액
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'PREV_AMT'.
  gs_fcat-coltext     = '전기금액'.
  gs_fcat-outputlen   = 20.
  gs_fcat-just        = 'R'.
  gs_fcat-do_sum      = abap_true.
  gs_fcat-cfieldname  = 'WAERS'.
  IF pa_no = abap_true.
    gs_fcat-no_out    = abap_true.
  ENDIF.
  APPEND gs_fcat TO gt_fcat.

* 증감액
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'DIFF_AMT'.
  gs_fcat-coltext     = '증감액'.
  gs_fcat-outputlen   = 20.
  gs_fcat-just        = 'R'.
  gs_fcat-do_sum      = abap_true.
  gs_fcat-cfieldname  = 'WAERS'.
  IF pa_no = abap_true.
    gs_fcat-no_out    = abap_true.
  ENDIF.
  APPEND gs_fcat TO gt_fcat.

* 통화
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'WAERS'.
  gs_fcat-coltext     = '통화'.
  gs_fcat-outputlen   = 5.
  APPEND gs_fcat TO gt_fcat.

* 계정 시작
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'HKONT_FROM'.
  gs_fcat-coltext     = '시작계정'.
  gs_fcat-outputlen   = 10.
  gs_fcat-no_out      = abap_true.
  APPEND gs_fcat TO gt_fcat.

* 계정 종료
  CLEAR gs_fcat.
  gs_fcat-fieldname   = 'HKONT_TO'.
  gs_fcat-coltext     = '종료계정'.
  gs_fcat-outputlen   = 10.
  gs_fcat-no_out      = abap_true.
  APPEND gs_fcat TO gt_fcat.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout .

  CLEAR gs_layout.
  gs_layout-zebra                 = abap_true.
  gs_layout-cwidth_opt            = abap_true.

  CLEAR gs_hierarchy_header.
  gs_hierarchy_header-heading     = '재무제표 항목'.
  gs_hierarchy_header-width       = 40.
  gs_hierarchy_header-width_pix   = ''.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form rebuild_tree
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM rebuild_tree.

  CHECK go_tree IS BOUND.

  CALL METHOD go_tree->delete_all_nodes.

  PERFORM build_tree_nodes.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form free_objects
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_objects .

  IF go_tree IS BOUND.
    CALL METHOD go_tree->free.
    FREE go_tree.
  ENDIF.

  IF go_container IS BOUND.
    CALL METHOD go_container->free.
    FREE go_container.
  ENDIF.

  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_acct_type
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_acct_type CHANGING cv_acct_type TYPE ztfic00110-acct_type .

  IF pa_bs = abap_true.
    cv_acct_type = gc_acct_bs.
  ELSEIF pa_pl = abap_true.
    cv_acct_type = gc_acct_pl.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: lv_acct_type TYPE ztfic00110-acct_type.

  CLEAR gt_list.

  PERFORM get_acct_type CHANGING lv_acct_type.

  SELECT
      acct_type,
      sortno,
      grp_cd,
      grp_nm,
      hkont_from,
      hkont_to,
      sign,
      indent,
      is_total
    FROM ztfic00110
    INTO CORRESPONDING FIELDS OF TABLE @gt_list
   WHERE acct_type = @lv_acct_type
   ORDER BY sortno.

  IF gt_list IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM set_amount_data.

  gt_tree = gt_list.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form download_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM download_excel .

  MESSAGE i014 WITH 'download_excel 로직 추가 예정'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form print_excel
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM print_excel .

  MESSAGE i014 WITH 'print_excel 로직 추가 예정'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_amount_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_amount_data .

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_list>).
    PERFORM get_amount
      USING
        <fs_list>-hkont_from
        <fs_list>-hkont_to
        <fs_list>-sign
        pa_gjahr
      CHANGING
        <fs_list>-curr_amt
        <fs_list>-waers.

    IF pa_yes = abap_true.
      PERFORM get_prev_amount
        USING
          <fs_list>-hkont_from
          <fs_list>-hkont_to
          <fs_list>-sign
        CHANGING
          <fs_list>-prev_amt.
    ENDIF.

    <fs_list>-diff_amt = <fs_list>-curr_amt - <fs_list>-prev_amt.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_amount
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_LIST>_HKONT_FROM
*&      --> <FS_LIST>_HKONT_TO
*&      --> <FS_LIST>_SIGN
*&      --> PA_GJAHR
*&      <-- <FS_LIST>_CURR_AMT
*&      <-- <FS_LIST>_WAERS
*&---------------------------------------------------------------------*
FORM get_amount
  USING
    pv_hkont_from TYPE ztfic00110-hkont_from
    pv_hkont_to   TYPE ztfic00110-hkont_to
    pv_sign       TYPE ztfic00110-sign
    pv_gjahr      TYPE ztfic00010-gjahr
  CHANGING
    cv_amount     TYPE ztfic00020-dmbtr
    cv_waers      TYPE ztfic00020-waers.

  TYPES: BEGIN OF ty_amount_line,
           dmbtr TYPE ztfic00020-dmbtr,
           waers TYPE ztfic00020-waers,
           shkzg TYPE ztfic00020-shkzg,
         END OF ty_amount_line.

  DATA:
    lt_amount_line TYPE STANDARD TABLE OF ty_amount_line,
    ls_amount_line TYPE ty_amount_line.

  CLEAR:
    cv_amount,
    cv_waers,
    lt_amount_line.

  SELECT
      b~dmbtr,
      b~waers,
      b~shkzg
    FROM ztfic00020 AS b
    INNER JOIN ztfic00010 AS h
      ON  h~bukrs = b~bukrs
      AND h~belnr = b~belnr
      AND h~gjahr = b~gjahr
    INTO TABLE @lt_amount_line
   WHERE b~bukrs IN @so_bukrs
     AND b~gjahr = @pv_gjahr
     AND h~monat IN @so_monat
     AND b~hkont BETWEEN @pv_hkont_from AND @pv_hkont_to.

  LOOP AT lt_amount_line INTO ls_amount_line.

    cv_waers = ls_amount_line-waers.

    CASE ls_amount_line-shkzg.
      WHEN 'S'.
        cv_amount = cv_amount + ls_amount_line-dmbtr.

      WHEN 'H'.
        cv_amount = cv_amount - ls_amount_line-dmbtr.
    ENDCASE.

  ENDLOOP.

  IF pv_sign = '-'.
    cv_amount = cv_amount * -1.
  ENDIF.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_prev_amount
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_LIST>_HKONT_FROM
*&      --> <FS_LIST>_HKONT_TO
*&      --> <FS_LIST>_SIGN
*&      <-- <FS_LIST>_PREV_AMT
*&---------------------------------------------------------------------*
FORM get_prev_amount
  USING
    pv_hkont_from     TYPE ztfic00110-hkont_from
    pv_hkont_to       TYPE ztfic00110-hkont_to
    pv_sign           TYPE ztfic00110-sign
  CHANGING
    cv_amount         TYPE ztfic00020-dmbtr.

  DATA: lv_prev_gjahr TYPE ztfic00010-gjahr,
        lv_waers      TYPE ztfic00020-waers.

  lv_prev_gjahr = pa_gjahr - 1.

  PERFORM get_amount
    USING
      pv_hkont_from
      pv_hkont_to
      pv_sign
      lv_prev_gjahr
    CHANGING
      cv_amount
      lv_waers.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_tree_nodes
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_tree_nodes .

  DATA:
    lv_node_key   TYPE lvc_nkey,
    lv_parent_key TYPE lvc_nkey,
    lt_level_key  TYPE STANDARD TABLE OF lvc_nkey WITH DEFAULT KEY,
    lv_indent_i   TYPE i,
    lv_text       TYPE lvc_value.

  FIELD-SYMBOLS:
    <fs_list> TYPE ty_list.

  CHECK go_tree IS BOUND.

  IF gt_tree IS INITIAL.
    MESSAGE 'Tree에 출력할 데이터가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SORT gt_tree BY sortno.

  LOOP AT gt_tree ASSIGNING <fs_list>.

    CLEAR:
      lv_node_key,
      lv_parent_key,
      lv_text.

    lv_indent_i = <fs_list>-indent.

    IF lv_indent_i IS INITIAL.
      lv_indent_i = 1.
    ENDIF.

    IF lv_indent_i <= 1.
      CLEAR lv_parent_key.
    ELSE.
      READ TABLE lt_level_key INTO lv_parent_key INDEX lv_indent_i - 1.
      IF sy-subrc <> 0.
        CLEAR lv_parent_key.
      ENDIF.
    ENDIF.

    IF <fs_list>-grp_nm IS INITIAL.
      lv_text = <fs_list>-grp_cd.
    ELSE.
      lv_text = <fs_list>-grp_nm.
    ENDIF.

    CALL METHOD go_tree->add_node
      EXPORTING
        i_relat_node_key  = lv_parent_key
        i_relationship    = cl_gui_column_tree=>relat_last_child
        i_node_text       = lv_text
        is_outtab_line    = <fs_list>
      IMPORTING
        e_new_node_key    = lv_node_key
      EXCEPTIONS
        OTHERS            = 1.

    IF sy-subrc <> 0.
      MESSAGE 'Tree 노드 생성 중 오류가 발생했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.

    <fs_list>-node_key   = lv_node_key.
    <fs_list>-parent_key = lv_parent_key.

    READ TABLE lt_level_key INDEX lv_indent_i TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.
      MODIFY lt_level_key FROM lv_node_key INDEX lv_indent_i.
    ELSE.
      WHILE lines( lt_level_key ) < lv_indent_i - 1.
        APPEND space TO lt_level_key.
      ENDWHILE.

      APPEND lv_node_key TO lt_level_key.
    ENDIF.

  ENDLOOP.

  CALL METHOD go_tree->frontend_update.

ENDFORM.
