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

  CLEAR so_bukrs .
  so_bukrs-sign   = 'I'.
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
*& Form refresh_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv .

ENDFORM.


*&---------------------------------------------------------------------*
*& Form build_field_catalog
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

  _add_fcat 'ZBELNR'    'Z전표번호'       12 'X'.
  _add_fcat 'GJAHR'     '회계연도'         8  ''.
  _add_fcat 'MONAT'     '회계기간'         8  ''.
  _add_fcat 'CLOSE_TP'  '결산유형'        10  ''.
  _add_fcat 'BLDAT'     '전표일자'        10  ''.

* 총금액 필드
  CLEAR gs_fcat.
  gs_fcat-fieldname  = 'TOTAL_AMT'.
  gs_fcat-coltext    = '총금액'.
  gs_fcat-outputlen  = 15.
  gs_fcat-cfieldname = 'WAERS'.
  gs_fcat-just       = 'R'.
  gs_fcat-do_sum     = abap_true.
  APPEND gs_fcat TO gt_fcat.

  _add_fcat 'WAERS'     '통화'             5  ''.
  _add_fcat 'STATUS'    '처리상태'        10  ''.
  _add_fcat 'BELNR'     '회계전표번호'     12  ''.
  _add_fcat 'NOTE'      '결산메모'        30  ''.
  _add_fcat 'ERNAM'     '생성자'          12  ''.
  _add_fcat 'ERDAT'     '생성일'          10  ''.

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
*& Include          ZLFIDMC050_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
*& 더미 데이터 생성 - 추후 SELECT 로직으로 변경 예정
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

  CLEAR gt_list.

*---------------------------------------------------------------------*
* 1. 감가상각 - 전기완료
*---------------------------------------------------------------------*
  CLEAR gs_list.

  gs_list-zbelnr    = 'ZCLOSE001'.
  gs_list-gjahr     = pa_gjahr.
  gs_list-monat     = '07'.
  gs_list-close_tp  = 'DEP'.
  gs_list-bldat     = sy-datum - 10.
  gs_list-total_amt = '5000000'.
  gs_list-waers     = 'KRW'.
  gs_list-status    = '1'.
  gs_list-belnr     = '1900000001'.
  gs_list-note      = '유형자산 월 감가상각 반영'.
  gs_list-ernam     = sy-uname.
  gs_list-erdat     = sy-datum - 10.

  APPEND gs_list TO gt_list.

*---------------------------------------------------------------------*
* 2. 미지급비용 - 임시저장
*---------------------------------------------------------------------*
  CLEAR gs_list.

  gs_list-zbelnr    = 'ZCLOSE002'.
  gs_list-gjahr     = pa_gjahr.
  gs_list-monat     = '07'.
  gs_list-close_tp  = 'ACC'.
  gs_list-bldat     = sy-datum.
  gs_list-total_amt = '1200000'.
  gs_list-waers     = 'KRW'.
  gs_list-status    = '0'.
  gs_list-belnr     = space.
  gs_list-note      = '당월 미청구 용역비 인식'.
  gs_list-ernam     = sy-uname.
  gs_list-erdat     = sy-datum.

  APPEND gs_list TO gt_list.

*---------------------------------------------------------------------*
* 3. 선급비용 - 역전표
*---------------------------------------------------------------------*
  CLEAR gs_list.

  gs_list-zbelnr    = 'ZCLOSE003'.
  gs_list-gjahr     = pa_gjahr.
  gs_list-monat     = '06'.
  gs_list-close_tp  = 'PRE'.
  gs_list-bldat     = sy-datum - 20.
  gs_list-total_amt = '800000'.
  gs_list-waers     = 'KRW'.
  gs_list-status    = '2'.
  gs_list-belnr     = '1900000002'.
  gs_list-note      = '보험료 기간 배분 전표 취소'.
  gs_list-ernam     = sy-uname.
  gs_list-erdat     = sy-datum - 20.

  APPEND gs_list TO gt_list.

*---------------------------------------------------------------------*
* 4. 충당부채 - 전기완료
*---------------------------------------------------------------------*
  CLEAR gs_list.

  gs_list-zbelnr    = 'ZCLOSE004'.
  gs_list-gjahr     = pa_gjahr.
  gs_list-monat     = '07'.
  gs_list-close_tp  = 'PRV'.
  gs_list-bldat     = sy-datum - 5.
  gs_list-total_amt = '3500000'.
  gs_list-waers     = 'KRW'.
  gs_list-status    = '1'.
  gs_list-belnr     = '1900000003'.
  gs_list-note      = '제품보증 충당부채 설정'.
  gs_list-ernam     = sy-uname.
  gs_list-erdat     = sy-datum - 5.

  APPEND gs_list TO gt_list.

*---------------------------------------------------------------------*
* 5. 기타 조정 - 임시저장
*---------------------------------------------------------------------*
  CLEAR gs_list.

  gs_list-zbelnr    = 'ZCLOSE005'.
  gs_list-gjahr     = pa_gjahr.
  gs_list-monat     = '07'.
  gs_list-close_tp  = 'ADJ'.
  gs_list-bldat     = sy-datum.
  gs_list-total_amt = '250000'.
  gs_list-waers     = 'KRW'.
  gs_list-status    = '0'.
  gs_list-belnr     = space.
  gs_list-note      = '계정 분류 오류 조정 예정'.
  gs_list-ernam     = sy-uname.
  gs_list-erdat     = sy-datum.

  APPEND gs_list TO gt_list.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_close_type_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_close_type_list .

  DATA : lt_values TYPE vrm_values,
         ls_value  TYPE vrm_value.

  CLEAR lt_values.

  CLEAR ls_value.
  ls_value-key  = 'DEP'.
  ls_value-text = '감가상각'.
  APPEND ls_value TO lt_values.

  CLEAR ls_value.
  ls_value-key  = 'PRE'.
  ls_value-text = '선급비용'.
  APPEND ls_value TO lt_values.

  CLEAR ls_value.
  ls_value-key  = 'ACC'.
  ls_value-text = '미지급비용'.
  APPEND ls_value TO lt_values.

  CLEAR ls_value.
  ls_value-key  = 'PRV'.
  ls_value-text = '충당부채'.
  APPEND ls_value TO lt_values.

  CLEAR ls_value.
  ls_value-key  = 'ADJ'.
  ls_value-text = '기타 조정'.
  APPEND ls_value TO lt_values.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'GS_HEADER-CLOSE_TP'
      values = lt_values.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_new_document
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_new_document .

  CLEAR : gs_header,
          gt_item,
          gv_debit,
          gv_credit,
          gv_diff.

* 헤더 기본값
  gs_header-gjahr    = pa_gjahr.
  gs_header-close_tp = 'DEP'.
  gs_header-bldat    = sy-datum.
  gs_header-monat    = sy-datum+4(2).
  gs_header-waers    = 'KRW'.
  gs_header-status   = '0'.

*---------------------------------------------------------------------*
* 차변 기본 행
*---------------------------------------------------------------------*
  CLEAR gs_item.

  gs_item-buzei = '001'.
  gs_item-hkont = '61000000'.
  gs_item-hkont_txt = '감가상각비'.
  gs_item-shkzg = 'S'.
  gs_item-dmbtr = '5000000'.
  gs_item-waers = 'KRW'.
  gs_item-kostl = 'CC1000'.
  gs_item-sgtxt = '감가상각비 인식'.

  APPEND gs_item TO gt_item.

*---------------------------------------------------------------------*
* 대변 기본 행
*---------------------------------------------------------------------*
  CLEAR gs_item.

  gs_item-buzei = '002'.
  gs_item-hkont = '18000000'.
  gs_item-hkont_txt = '감가상각누계액'.
  gs_item-shkzg = 'H'.
  gs_item-dmbtr = '5000000'.
  gs_item-waers = 'KRW'.
  gs_item-kostl = space.
  gs_item-sgtxt = '감가상각누계액 반영'.

  APPEND gs_item TO gt_item.

* 화면 하단 합계
  gv_debit  = '5000000'.
  gv_credit = '5000000'.
  gv_diff   = 0.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_item_alv
*&---------------------------------------------------------------------*
*& 3000번 항목 Editable ALV 생성
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_item_alv .

  PERFORM build_item_field_catalog.
  PERFORM set_item_layout.

  CREATE OBJECT go_item_container
    EXPORTING
      container_name = 'CC_ALV_ITEM'.

  CREATE OBJECT go_item_grid
    EXPORTING
      i_parent = go_item_container.

  CALL METHOD go_item_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  CALL METHOD go_item_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_item_layo
      i_save          = 'A'
    CHANGING
      it_outtab       = gt_item
      it_fieldcatalog = gt_item_fcat.

  CALL METHOD go_item_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form build_item_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_item_field_catalog .

  CLEAR gt_item_fcat.

  DEFINE _add_item_fcat.
    CLEAR gs_item_fcat.
    gs_item_fcat-fieldname = &1.
    gs_item_fcat-coltext   = &2.
    gs_item_fcat-outputlen = &3.
    gs_item_fcat-edit      = &4.
    APPEND gs_item_fcat TO gt_item_fcat.
  END-OF-DEFINITION.

* 항목번호 - 수정 불가
  _add_item_fcat 'BUZEI'     '항목'          5 ''.

* G/L 계정 - 수정 가능
  _add_item_fcat 'HKONT'     'G/L계정'      12 'X'.

* 계정명 - 수정 불가
  _add_item_fcat 'HKONT_TXT' '계정명'       20 ''.

* 차/대변 - 수정 가능
  _add_item_fcat 'SHKZG'     '차/대변'       8 'X'.

* 금액
  CLEAR gs_item_fcat.
  gs_item_fcat-fieldname  = 'DMBTR'.
  gs_item_fcat-coltext    = '금액'.
  gs_item_fcat-outputlen  = 15.
  gs_item_fcat-edit       = abap_true.
  gs_item_fcat-cfieldname = 'WAERS'.
  gs_item_fcat-just       = 'R'.
  APPEND gs_item_fcat TO gt_item_fcat.

* 통화 - 화면 설계에 없으면 숨김
  CLEAR gs_item_fcat.
  gs_item_fcat-fieldname = 'WAERS'.
  gs_item_fcat-coltext   = '통화'.
  gs_item_fcat-outputlen = 5.
  gs_item_fcat-no_out    = abap_true.
  APPEND gs_item_fcat TO gt_item_fcat.

* 코스트센터
  _add_item_fcat 'KOSTL' '코스트센터' 12 'X'.

* 항목텍스트
  _add_item_fcat 'SGTXT' '항목텍스트' 30 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_item_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_item_layout .

  CLEAR gs_item_layo.

  gs_item_layo-zebra      = abap_true.
  gs_item_layo-cwidth_opt = abap_true.
  gs_item_layo-sel_mode   = 'A'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form free_item_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM free_item_alv .

  IF go_item_grid IS BOUND.
    CALL METHOD go_item_grid->free.
  ENDIF.

  IF go_item_container IS BOUND.
    CALL METHOD go_item_container->free.
  ENDIF.

  CLEAR : go_item_grid,
          go_item_container.

ENDFORM.
