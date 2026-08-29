*&---------------------------------------------------------------------*
*& Include          ZLFIDMC030_F01
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

  so_gjahr = sy-datum+0(4).

  CLEAR so_bukrs.
  so_bukrs-sign = 'I'.
  so_bukrs-option = 'EQ'.
  so_bukrs-low    = '1000'.
  APPEND so_bukrs.

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

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.

  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
      i_save          = 'A'
    CHANGING
      it_outtab       = gt_list
      it_fieldcatalog = gt_fcat.

  CALL METHOD go_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

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

  DEFINE _add_fcat.
    CLEAR gs_fcat.
    gs_fcat-fieldname = &1.
    gs_fcat-coltext   = &2.
    gs_fcat-outputlen = &3.
    gs_fcat-key       = &4.
    APPEND gs_fcat TO gt_fcat.

  END-OF-DEFINITION.

  _add_fcat 'VBELN'      'Billing번호'     12 'X'.
  _add_fcat 'FKDAT'      '청구일자'          10 ''.
  _add_fcat 'KUNNR'      '고객번호'          10 ''.
  _add_fcat 'NAME1'      '고객명'           20 ''.
  _add_fcat 'STCEG'      '사업자번호'         16 ''.
  _add_fcat 'NET_AMT'    '공급가액'          15 ''.
  _add_fcat 'TAX_AMT'    '부가세'           15 ''.
  _add_fcat 'TOT_AMT'    '합계금액'          15 ''.
  _add_fcat 'WAERS'      '통화'             5 ''.
  _add_fcat 'ISSUE_STAT' '발행상태'          10 ''.
  _add_fcat 'TAX_NO'     '세금계산서번호'      18 ''.
  _add_fcat 'ISSUE_DT'   '발행일자'          10 ''.
  _add_fcat 'ISSUE_BY'   '발행자'           12 ''.


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

  CLEAR : gs_layout.

  gs_layout-zebra      = abap_true.       " 줄무늬
  gs_layout-cwidth_opt = abap_true.       " 컬럼 너비 자동 조절
  gs_layout-sel_mode   = 'A'.             " 행 선택 가능

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& 더미 데이터
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

* 1. 미발행 건
  CLEAR gs_list.

  gs_list-vbeln      = '8000000101'.
  gs_list-fkdat      = sy-datum.
  gs_list-kunnr      = 'C000000001'.
  gs_list-name1      = '가나다상사'.
  gs_list-stceg      = '123-45-67890'.
  gs_list-net_amt    = '5000000'.
  gs_list-tax_amt    = '500000'.
  gs_list-tot_amt    = '5500000'.
  gs_list-waers      = 'KRW'.
  gs_list-issue_stat = '0'.
  gs_list-tax_no     = space.
  gs_list-issue_dt   = space.
  gs_list-issue_by   = space.

  APPEND gs_list TO gt_list.


* 2. 미발행 건
  CLEAR gs_list.

  gs_list-vbeln      = '8000000102'.
  gs_list-fkdat      = sy-datum - 3.
  gs_list-kunnr      = 'C000000002'.
  gs_list-name1      = 'ABC상사'.
  gs_list-stceg      = '234-56-78901'.
  gs_list-net_amt    = '3000000'.
  gs_list-tax_amt    = '300000'.
  gs_list-tot_amt    = '3300000'.
  gs_list-waers      = 'KRW'.
  gs_list-issue_stat = '0'.
  gs_list-tax_no     = space.
  gs_list-issue_dt   = space.
  gs_list-issue_by   = space.

  APPEND gs_list TO gt_list.


* 3. 발행완료 건
  CLEAR gs_list.

  gs_list-vbeln      = '8000000099'.
  gs_list-fkdat      = sy-datum - 10.
  gs_list-kunnr      = 'C000000003'.
  gs_list-name1      = 'XYZ코리아'.
  gs_list-stceg      = '345-67-89012'.
  gs_list-net_amt    = '2000000'.
  gs_list-tax_amt    = '200000'.
  gs_list-tot_amt    = '2200000'.
  gs_list-waers      = 'KRW'.
  gs_list-issue_stat = '1'.
  gs_list-tax_no     = 'TAX2026000001'.
  gs_list-issue_dt   = sy-datum - 8.
  gs_list-issue_by   = sy-uname.

  APPEND gs_list TO gt_list.


* 4. 발행완료 건
  CLEAR gs_list.

  gs_list-vbeln      = '8000000098'.
  gs_list-fkdat      = sy-datum - 15.
  gs_list-kunnr      = 'C000000004'.
  gs_list-name1      = '대한유통'.
  gs_list-stceg      = '456-78-90123'.
  gs_list-net_amt    = '7000000'.
  gs_list-tax_amt    = '700000'.
  gs_list-tot_amt    = '7700000'.
  gs_list-waers      = 'KRW'.
  gs_list-issue_stat = '1'.
  gs_list-tax_no     = 'TAX2026000002'.
  gs_list-issue_dt   = sy-datum - 13.
  gs_list-issue_by   = sy-uname.

  APPEND gs_list TO gt_list.

ENDFORM.
