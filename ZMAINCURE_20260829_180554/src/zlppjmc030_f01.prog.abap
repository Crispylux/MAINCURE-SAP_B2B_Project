*&---------------------------------------------------------------------*
*& Include          ZLPPJMC030_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form set_fieldcat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat.
  """" 아래 ser_alv_first의 LVC_FIELDCATALOG_MERGE를 사용 할 거라면 필요x """"

  " 컬럼 하나 추가할 때마다 아래 블록 반복
*  CLEAR GS_FIELDCAT.
*  GS_FIELDCAT-FIELDNAME = 'BUKRS'.      " Z테이블의 필드명
*  GS_FIELDCAT-COLTEXT   = '회사코드'.   " 화면에 보일 컬럼 제목
*  APPEND GS_FIELDCAT TO GT_FIELDCAT.
*
*  CLEAR GS_FIELDCAT.
*  GS_FIELDCAT-FIELDNAME = 'AMOUNT'.
*  GS_FIELDCAT-COLTEXT   = '금액'.
*  APPEND GS_FIELDCAT TO GT_FIELDCAT.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_alv_first
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_alv_first .

*------------zsppjmc010의 구조를 확인하고 자동으로 필드 카탈로그(gt_fieldcat_1) 생성
CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZSPPJMC010'
    CHANGING
      ct_fieldcat            = gt_fieldcat_1
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    " 예외 처리 필요 시 구현
  ENDIF.

  LOOP AT gt_fieldcat_1 ASSIGNING FIELD-SYMBOL(<ls_fcat>).
    CASE <ls_fcat>-fieldname.
      " [숨김 필드]
      WHEN 'MEINH' OR 'WERKS' OR 'NAME1'.
        <ls_fcat>-no_out = 'X'.

      " [화면 텍스트 설정]
      WHEN 'STATUS_ICON'.
        <ls_fcat>-coltext   = '생산 상태'.
        <ls_fcat>-scrtext_s = '생산 상태'.
        <ls_fcat>-scrtext_m = '생산 상태'.
        <ls_fcat>-scrtext_l = '생산 상태'.
      WHEN 'AUFNR'.
        <ls_fcat>-coltext   = '생산오더 번호'.
        <ls_fcat>-scrtext_s = '생산오더 번호'.
        <ls_fcat>-scrtext_m = '생산오더 번호'.
        <ls_fcat>-scrtext_l = '생산오더 번호'.
      WHEN 'PLNUM'.
        <ls_fcat>-coltext   = '생산계획 번호'.
        <ls_fcat>-scrtext_s = '생산계획 번호'.
        <ls_fcat>-scrtext_m = '생산계획 번호'.
        <ls_fcat>-scrtext_l = '생산계획 번호'.
      WHEN 'MATNR'.
        <ls_fcat>-coltext   = '자재 번호'.
        <ls_fcat>-scrtext_s = '자재 번호'.
        <ls_fcat>-scrtext_m = '자재 번호'.
        <ls_fcat>-scrtext_l = '자재 번호'.
      WHEN 'MAKTX'.
        <ls_fcat>-coltext   = '자재명'.
        <ls_fcat>-scrtext_s = '자재명'.
        <ls_fcat>-scrtext_m = '자재명'.
        <ls_fcat>-scrtext_l = '자재명'.
      WHEN 'GAMNG'.
        <ls_fcat>-coltext   = '생산 수량'.
        <ls_fcat>-scrtext_s = '생산 수량'.
        <ls_fcat>-scrtext_m = '생산 수량'.
        <ls_fcat>-scrtext_l = '생산 수량'.
      WHEN 'XMNGA'.
        <ls_fcat>-coltext   = '불량 수량'.
        <ls_fcat>-scrtext_s = '불량 수량'.
        <ls_fcat>-scrtext_m = '불량 수량'.
        <ls_fcat>-scrtext_l = '불량 수량'.
      WHEN 'GMEIN'.
        <ls_fcat>-coltext   = '단위'.
        <ls_fcat>-scrtext_s = '단위'.
        <ls_fcat>-scrtext_m = '단위'.
        <ls_fcat>-scrtext_l = '단위'.
      WHEN 'GSTRP'.
        <ls_fcat>-coltext   = '계획 시작일'.
        <ls_fcat>-scrtext_s = '계획 시작일'.
        <ls_fcat>-scrtext_m = '계획 시작일'.
        <ls_fcat>-scrtext_l = '계획 시작일'.
      WHEN 'GLTRP'.
        <ls_fcat>-coltext   = '계획 종료일'.
        <ls_fcat>-scrtext_s = '계획 종료일'.
        <ls_fcat>-scrtext_m = '계획 종료일'.
        <ls_fcat>-scrtext_l = '계획 종료일'.
      WHEN 'PLNNR'.
        <ls_fcat>-coltext   = '라우팅 번호'.
        <ls_fcat>-scrtext_s = '라우팅 번호'.
        <ls_fcat>-scrtext_m = '라우팅 번호'.
        <ls_fcat>-scrtext_l = '라우팅 번호'.
    ENDCASE.
  ENDLOOP.

CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = 'ZSPPJMC020'
    CHANGING
      ct_fieldcat            = gt_fieldcat_2
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    " 예외 처리 필요 시 구현
  ENDIF.

  LOOP AT gt_fieldcat_2 ASSIGNING FIELD-SYMBOL(<ls_fcat_2>).
    CASE <ls_fcat_2>-fieldname.
      " [숨김 필드]
      WHEN 'AUFNR' OR 'AUFPL' OR 'APLZL'.
        <ls_fcat_2>-no_out = 'X'.

      " [화면 텍스트 설정]
      WHEN 'PROC_STATU'.
        <ls_fcat_2>-coltext   = '작업 상태'.
        <ls_fcat_2>-scrtext_s = '작업 상태'.
        <ls_fcat_2>-scrtext_m = '작업 상태'.
        <ls_fcat_2>-scrtext_l = '작업 상태'.
      WHEN 'LTXA1'.
        <ls_fcat_2>-coltext   = '작업명'.
        <ls_fcat_2>-scrtext_s = '작업명'.
        <ls_fcat_2>-scrtext_m = '작업명'.
        <ls_fcat_2>-scrtext_l = '작업명'.
      WHEN 'VORNR'.
        <ls_fcat_2>-coltext   = '작업 순서'.
        <ls_fcat_2>-scrtext_s = '작업 순서'.
        <ls_fcat_2>-scrtext_m = '작업 순서'.
        <ls_fcat_2>-scrtext_l = '작업 순서'.
      WHEN 'FSODT'.
        <ls_fcat_2>-coltext   = '작업 시작일'.
        <ls_fcat_2>-scrtext_s = '작업 시작일'.
        <ls_fcat_2>-scrtext_m = '작업 시작일'.
        <ls_fcat_2>-scrtext_l = '작업 시작일'.
      WHEN 'FEODT'.
        <ls_fcat_2>-coltext   = '작업 종료일'.
        <ls_fcat_2>-scrtext_s = '작업 종료일'.
        <ls_fcat_2>-scrtext_m = '작업 종료일'.
        <ls_fcat_2>-scrtext_l = '작업 종료일'.
      WHEN 'ARBID'.
        <ls_fcat_2>-coltext   = '작업 수행 버튼'.
        <ls_fcat_2>-scrtext_s = '작업 수행 버튼'.
        <ls_fcat_2>-scrtext_m = '작업 수행 버튼'.
        <ls_fcat_2>-scrtext_l = '작업 수행 버튼'.
    ENDCASE.
  ENDLOOP.

*-----------------------------------------------------------------------

*------------alv 그리드 출력 설정 및 출력 명령-------------
  CALL METHOD go_grid_1->set_table_for_first_display
    EXPORTING
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
    i_structure_name              = 'ZSPPJMC010'
*      is_variant                    =
*      i_save                        =
*      i_default                     = 'X'
*      is_layout                     =
*      is_print                      =
*      it_special_groups             =
*      it_toolbar_excluding          =
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
  CHANGING
    it_outtab                     = gt_order_header
    it_fieldcatalog               = gt_fieldcat_1
*      it_sort                       =
*      it_filter                     =
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      others                        = 4
        .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.

  CALL METHOD go_grid_2->set_table_for_first_display
    EXPORTING
*      i_buffer_active               =
*      i_bypassing_buffer            =
*      i_consistency_check           =
    i_structure_name              = 'ZSPPJMC020'
*      is_variant                    =
*      i_save                        =
*      i_default                     = 'X'
*      is_layout                     =
*      is_print                      =
*      it_special_groups             =
*      it_toolbar_excluding          =
*      it_hyperlink                  =
*      it_alv_graphics               =
*      it_except_qinfo               =
*      ir_salv_adapter               =
  CHANGING
    it_outtab                     = gt_order_process
    it_fieldcatalog               = gt_fieldcat_2
*      it_sort                       =
*      it_filter                     =
*    EXCEPTIONS
*      invalid_parameter_combination = 1
*      program_error                 = 2
*      too_many_lines                = 3
*      others                        = 4
        .
  IF sy-subrc <> 0.
*   Implement suitable error handling here
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM get_data .

  CLEAR: gt_order_header,
         gt_xmnga.

*---------------------------------------------------------------------*
* 생산오더 조회
*---------------------------------------------------------------------*
  SELECT
      a~aufnr,                  " 생산오더 번호
      b~plnum,                  " 참조 생산계획 번호
      b~matnr,                  " 자재번호
      c~maktx,                  " 자재명
      a~gamng,                  " 생산오더 수량
      b~meins AS gmein,         " 생산단위
      a~gstrp,                  " 계획 시작일
      a~gltrp,                  " 계획 종료일
      a~plnnr,                  " 라우팅 번호
      a~aufpl,                  " 공정계획 번호
      b~dwerk AS werks,         " 생산 플랜트
      d~name1                   " 플랜트명

    FROM ztppk00050 AS a

    INNER JOIN ztppk00060 AS b
      ON b~aufnr = a~aufnr

    LEFT OUTER JOIN ztmmg00020 AS c
      ON c~matnr = b~matnr
     AND c~spras = @sy-langu

    LEFT OUTER JOIN ztmmg00160 AS d
      ON d~werks = b~dwerk

    WHERE a~aufnr IN @s_aufnr
      AND b~plnum IN @s_plnum
      AND b~matnr IN @s_matnr
      AND b~dwerk = @p_werks
      AND a~gstrp IN @s_gstrp

    INTO CORRESPONDING FIELDS OF TABLE @gt_order_header.


*---------------------------------------------------------------------*
* 조회 결과 없음
*---------------------------------------------------------------------*
  IF gt_order_header IS INITIAL.
    MESSAGE '조회된 생산오더가 없습니다.'
      TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.


*---------------------------------------------------------------------*
* 불량수량 조회
*---------------------------------------------------------------------*
  SELECT
      aufnr,
      xmnga
    FROM ztppj00070
    FOR ALL ENTRIES IN @gt_order_header
    WHERE aufnr = @gt_order_header-aufnr
    INTO TABLE @gt_xmnga.


*---------------------------------------------------------------------*
* 불량수량 합산 + 상태 아이콘
*---------------------------------------------------------------------*
  LOOP AT gt_order_header ASSIGNING FIELD-SYMBOL(<ls_order>).

    CLEAR <ls_order>-xmnga.

    LOOP AT gt_xmnga INTO gs_xmnga
      WHERE aufnr = <ls_order>-aufnr.

      <ls_order>-xmnga =
        <ls_order>-xmnga + gs_xmnga-xmnga.

    ENDLOOP.

    " 상태값은 추후 공정 상태에 맞게 변경
    <ls_order>-status_icon = icon_led_yellow.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_process_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_process_data .

ENDFORM.
