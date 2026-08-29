*&---------------------------------------------------------------------*
*& Include          ZLFIDMC020_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form set_initial_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_initial_value.

  pa_gjahr = sy-datum+0(4).

  CLEAR so_bukrs.
  so_bukrs-sign   = 'I'.
  so_bukrs-option = 'EQ'.
  so_bukrs-low    = '1000'.
  APPEND so_bukrs.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& 더미 데이터 생성 - 추후 SELECT 로직으로 변경 예정
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data.

  CLEAR : gt_ar_open,
          gt_ar_rcpt.

* 상단 ALV 더미 데이터 - 미수금 채권 리스트
  CLEAR gs_ar_open.
  gs_ar_open-belnr      = '2000000011'.
  gs_ar_open-gjahr      = pa_gjahr.
  gs_ar_open-kunnr      = 'C000000001'.
  gs_ar_open-name1      = '가나다상사'.
  gs_ar_open-vbeln      = '9000000011'.
  gs_ar_open-bldat      = sy-datum.
  gs_ar_open-zfbdt      = sy-datum + 10.
  gs_ar_open-netwr      = '1000000'.
  gs_ar_open-wrbtr      = '1000000'.
  gs_ar_open-waers      = 'KRW'.
  gs_ar_open-status     = '10'.
  gs_ar_open-status_txt = '미수'.
  gs_ar_open-zterm      = 'Z001'.
  APPEND gs_ar_open TO gt_ar_open.

  CLEAR gs_ar_open.
  gs_ar_open-belnr      = '2000000012'.
  gs_ar_open-gjahr      = pa_gjahr.
  gs_ar_open-kunnr      = 'C000000002'.
  gs_ar_open-name1      = 'ABC상사'.
  gs_ar_open-vbeln      = '9000000012'.
  gs_ar_open-bldat      = sy-datum.
  gs_ar_open-zfbdt      = sy-datum + 15.
  gs_ar_open-netwr      = '5000000'.
  gs_ar_open-wrbtr      = '2000000'.
  gs_ar_open-waers      = 'KRW'.
  gs_ar_open-status     = '20'.
  gs_ar_open-status_txt = '부분수금'.
  gs_ar_open-zterm      = 'Z002'.
  APPEND gs_ar_open TO gt_ar_open.

  CLEAR gs_ar_open.
  gs_ar_open-belnr      = '2000000013'.
  gs_ar_open-gjahr      = pa_gjahr.
  gs_ar_open-kunnr      = 'C000000003'.
  gs_ar_open-name1      = 'XYZ코리아'.
  gs_ar_open-vbeln      = '9000000013'.
  gs_ar_open-bldat      = sy-datum.
  gs_ar_open-zfbdt      = sy-datum + 20.
  gs_ar_open-netwr      = '3000000'.
  gs_ar_open-wrbtr      = '0'.
  gs_ar_open-waers      = 'KRW'.
  gs_ar_open-status     = '30'.
  gs_ar_open-status_txt = '수금완료'.
  gs_ar_open-zterm      = 'Z003'.
  APPEND gs_ar_open TO gt_ar_open.

* 하단 ALV 더미 데이터 - 수금 이력
  CLEAR gs_ar_rcpt.
  gs_ar_rcpt-rcpt_no   = 'RCPT000001'.
  gs_ar_rcpt-rcpt_dt   = sy-datum.
  gs_ar_rcpt-rcpt_amt  = '3000000'.
  gs_ar_rcpt-waers     = 'KRW'.
  gs_ar_rcpt-clear_dt  = sy-datum.
  gs_ar_rcpt-clear_amt = '3000000'.
  gs_ar_rcpt-note      = '1차 수금'.
  gs_ar_rcpt-ernam     = sy-uname.
  APPEND gs_ar_rcpt TO gt_ar_rcpt.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_container
*&---------------------------------------------------------------------*
*& Container 생성
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_container.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_MAIN'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_splitter
*&---------------------------------------------------------------------*
*& Splitter 생성
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_splitter.

  CREATE OBJECT go_splitter
    EXPORTING
      parent  = go_container
      rows    = 2
      columns = 1.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 1
      column    = 1
    RECEIVING
      container = go_cont_top.

  CALL METHOD go_splitter->get_container
    EXPORTING
      row       = 2
      column    = 1
    RECEIVING
      container = go_cont_bot.

  CALL METHOD go_splitter->set_row_height
    EXPORTING
      id     = 1
      height = 35.

  CALL METHOD go_splitter->set_row_height
    EXPORTING
      id     = 2
      height = 80.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& Layout 설정
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_layout.

  CLEAR : gs_layout_top,
          gs_layout_bot.

  gs_layout_top-zebra        = abap_true.   "줄무늬
  gs_layout_top-cwidth_opt   = abap_true.   "컬럼 너비 자동 조절
  gs_layout_top-sel_mode     = 'A'.         "행 선택 가능

  gs_layout_bot-zebra        = abap_true.
  gs_layout_bot-cwidth_opt   = abap_true.
  gs_layout_bot-sel_mode     = 'A'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_fcat_top
*&---------------------------------------------------------------------*
*& 상단 Field Catalog
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fcat_top.

  CLEAR gt_fcat_top.

  DEFINE _add_fcat_top.
    CLEAR gs_fcat_top.
    gs_fcat_top-fieldname = &1.
    gs_fcat_top-coltext   = &2.
    gs_fcat_top-outputlen = &3.
    gs_fcat_top-key       = &4.
    gs_fcat_top-just      = &5.
    APPEND gs_fcat_top TO gt_fcat_top.
  END-OF-DEFINITION.

  _add_fcat_top 'BELNR'      '전표번호'       12 'X' 'C'.
  _add_fcat_top 'GJAHR'      '회계연도'       6  ''  'C'.
  _add_fcat_top 'KUNNR'      '고객번호'       10 ''  'C'.
  _add_fcat_top 'NAME1'      '고객명'        20 ''  ''.
  _add_fcat_top 'VBELN'      'Billing번호'  12 ''  'C'.
  _add_fcat_top 'BLDAT'      '전표일자'       10 ''  'C'.
  _add_fcat_top 'ZFBDT'      '만기일'        10 ''  'C'.
  _add_fcat_top 'NETWR'      '원금'         15 ''  'R'.
  _add_fcat_top 'WRBTR'      '미수잔액'       15 ''  'R'.
  _add_fcat_top 'WAERS'      '통화'         5  ''  'C'.
  _add_fcat_top 'STATUS'     '상태'         6  ''  'C'.
  _add_fcat_top 'STATUS_TXT' '상태명'        10 ''  'C'.
  _add_fcat_top 'ZTERM'      '지급조건'       8  ''  'C'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_fcat_bot
*&---------------------------------------------------------------------*
*& 하단 Field Catalog
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fcat_bot.

  CLEAR gt_fcat_bot.

  DEFINE _add_fcat_bot.
    CLEAR gs_fcat_bot.
    gs_fcat_bot-fieldname = &1.
    gs_fcat_bot-coltext   = &2.
    gs_fcat_bot-outputlen = &3.
    gs_fcat_bot-key       = &4.
    gs_fcat_bot-just      = &5.
    APPEND gs_fcat_bot TO gt_fcat_bot.
  END-OF-DEFINITION.

  _add_fcat_bot 'RCPT_NO'   '수금번호'   12 'X' 'C'.
  _add_fcat_bot 'RCPT_DT'   '수금일자'   10 ''  'C'.
  _add_fcat_bot 'RCPT_AMT'  '수금금액'   15 ''  'R'.
  _add_fcat_bot 'WAERS'     '통화'     5  ''  'C'.
  _add_fcat_bot 'CLEAR_DT'  '반제일'    10 ''  'C'.
  _add_fcat_bot 'CLEAR_AMT' '반제금액'   15 ''  'R'.
  _add_fcat_bot 'NOTE'      '비고'     30 ''  ''.
  _add_fcat_bot 'ERNAM'     '등록자'    12 ''  'C'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_alv_top
*&---------------------------------------------------------------------*
*& 상단 ALV 출력
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_top.

  CREATE OBJECT go_grid_top
    EXPORTING
      i_parent = go_cont_top.

  CALL METHOD go_grid_top->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout_top
    CHANGING
      it_outtab       = gt_ar_open
      it_fieldcatalog = gt_fcat_top.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_alv_bot
*&---------------------------------------------------------------------*
*& 하단 ALV 출력
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM display_alv_bot.

  CREATE OBJECT go_grid_bot
    EXPORTING
      i_parent = go_cont_bot.

  CALL METHOD go_grid_bot->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout_bot
    CHANGING
      it_outtab       = gt_ar_rcpt
      it_fieldcatalog = gt_fcat_bot.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
*& Refresh
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv.

  IF go_grid_top IS BOUND.
    CALL METHOD go_grid_top->refresh_table_display.
  ENDIF.

  IF go_grid_bot IS BOUND.
    CALL METHOD go_grid_bot->refresh_table_display.
  ENDIF.

ENDFORM.
