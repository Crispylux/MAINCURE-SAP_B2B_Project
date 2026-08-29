*&---------------------------------------------------------------------*
*& Include          ZLFICMC010_F01
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
      container_name  = 'CC_ALV_001'.

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

* 전표번호
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'BELNR'.
  gs_fcat-coltext   = '전표번호'.
  gs_fcat-hotspot   = abap_true.
  gs_fcat-key       = abap_true.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 회계연도
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'GJAHR'.
  gs_fcat-coltext   = '회계연도'.
  gs_fcat-key       = abap_true.
  gs_fcat-outputlen = 4.
  APPEND gs_fcat TO gt_fcat.

* 회사코드
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'BUKRS'.
  gs_fcat-coltext   = '회사코드'.
  gs_fcat-outputlen = 4.
  APPEND gs_fcat TO gt_fcat.

* 공급업체
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'LIFNR'.
  gs_fcat-coltext   = '공급업체'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 공급업체명
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'NAME1'.
  gs_fcat-coltext   = '공급업체명'.
  gs_fcat-outputlen = 25.
  APPEND gs_fcat TO gt_fcat.

* 전표일자
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'BLDAT'.
  gs_fcat-coltext   = '전표일자'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 전기일자
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'BUDAT'.
  gs_fcat-coltext   = '전기일자'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 지급기한
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'ZFBDT'.
  gs_fcat-coltext   = '지급기한'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 금액
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'WRBTR'.
  gs_fcat-coltext   = '금액'.
  gs_fcat-outputlen = 15.
  gs_fcat-just      = 'R'.
  gs_fcat-do_sum    = abap_true.
  gs_fcat-cfieldname = 'WAERS'.
  APPEND gs_fcat TO gt_fcat.

* 통화
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'WAERS'.
  gs_fcat-coltext   = '통화'.
  gs_fcat-outputlen = 5.
  APPEND gs_fcat TO gt_fcat.

* 상태 코드 - 화면에서는 숨김
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'STATUS'.
  gs_fcat-coltext   = '상태 코드'.
  gs_fcat-no_out    = abap_true.
  APPEND gs_fcat TO gt_fcat.

* 상태 텍스트
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'STATUS_TXT'.
  gs_fcat-coltext   = '상태'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 승인자
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'APPRNM'.
  gs_fcat-coltext   = '승인자'.
  gs_fcat-outputlen = 12.
  APPEND gs_fcat TO gt_fcat.

* 승인일
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'APPRDT'.
  gs_fcat-coltext   = '승인일'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 지급일
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'PAYMDT'.
  gs_fcat-coltext   = '지급일'.
  gs_fcat-outputlen = 10.
  APPEND gs_fcat TO gt_fcat.

* 적요
  CLEAR gs_fcat.
  gs_fcat-fieldname = 'SGTXT'.
  gs_fcat-coltext   = '적요'.
  gs_fcat-outputlen = 40.
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

  gs_layout-zebra      = abap_true.       " 행 색상을 번갈아 표시
  gs_layout-cwidth_opt = abap_true.       " 컬럼 너비 자동 조절
  gs_layout-sel_mode   = 'A'.             " 여러 행 선택 허용
  gs_layout-info_fname = 'ROW_COLOR'.     " 행 색상을 저장한 필드 지정

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

  CLEAR gt_list.

  "SELECT 로직 - ZTFIC00030 또는 ZTFIC00040 조회 => 일단 가라데이터 출력
  CLEAR gs_list.
  gs_list-belnr      = '1800000001'.
  gs_list-gjahr      = '2026'.
  gs_list-bukrs      = '1000'.
  gs_list-lifnr      = 'V000000001'.
  gs_list-name1      = '(주)ABC물산'.
  gs_list-bldat      = sy-datum.
  gs_list-budat      = sy-datum.
  gs_list-zfbdt      = sy-datum + 10.
  gs_list-wrbtr      = '5000000'.
  gs_list-waers      = 'KRW'.
  gs_list-status     = '10'.
  gs_list-status_txt = '대기'.
  gs_list-sgtxt      = '원자재 구매 미지급금'.
  APPEND gs_list TO gt_list.

  PERFORM set_display_data.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_display_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_display_data .

  CLEAR gv_total_amt.

  LOOP AT gt_list ASSIGNING FIELD-SYMBOL(<fs_list>).
    CASE <fs_list>-status.
      WHEN '10'.
        <fs_list>-status_txt = '대기'.

      WHEN '20'.
        <fs_list>-status_txt = '승인'.

      WHEN '30'.
        <fs_list>-status_txt = '지급완료'.

      WHEN OTHERS.
        <fs_list>-status_txt = '미정'.
    ENDCASE.

    IF <fs_list>-zfbdt < sy-datum AND <fs_list>-status <> '30'.
      <fs_list>-row_color = 'C610'.
    ELSE.
      CLEAR <fs_list>-row_color.
    ENDIF.

    gv_total_amt = gv_total_amt + <fs_list>-wrbtr.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form refresh_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM refresh_alv.

  DATA: ls_stable TYPE lvc_s_stbl.

  CHECK go_grid IS BOUND.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  CALL METHOD go_grid->refresh_table_display
    EXPORTING
      is_stable = ls_stable.

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
*& Form approve_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM approve_data .

  MESSAGE I014 WITH 'approve_data 로직 추가 예정'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form reject_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM reject_data .

  MESSAGE I014 WITH 'reject_data 로직 추가 예정'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form payment_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM payment_data .

  MESSAGE I014 WITH 'payment_data 로직 추가 예정'.

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

  MESSAGE I014 WITH 'download_excel 로직 추가 예정'.

ENDFORM.
