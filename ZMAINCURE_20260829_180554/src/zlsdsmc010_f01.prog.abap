*&---------------------------------------------------------------------*
*& Include          ZLSDSMC010_F01
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& DB 조회
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_DATA .
*===테스트===
  SELECT * INTO TABLE GT_DATA FROM SPFLI.
*==========
ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
*& ALV 필드 카탈로그 설정
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat .
*====테스트=====
  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'CARRID'.
  GS_FIELDCAT-COLTEXT   = '항공사'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.

  CLEAR GS_FIELDCAT.
  GS_FIELDCAT-FIELDNAME = 'CONNID'.
  GS_FIELDCAT-COLTEXT   = '편명'.
  APPEND GS_FIELDCAT TO GT_FIELDCAT.
*=============
ENDFORM.
*&---------------------------------------------------------------------*
*& Form load_quot_data
*&---------------------------------------------------------------------*
*& 견적정보 불러오기(팝업창) 테이블 데이터 조회
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM load_quot_data .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_quot_fieldcat
*&---------------------------------------------------------------------*
*& 견적정보 불러오기
*&---------------------------------------------------------------------*
*&      <-- IT_OUTTAB
*&      <-- =
*&      <-- GT_QUOT
*&      <-- )
*&---------------------------------------------------------------------*
FORM set_quot_fieldcat.
  CLEAR gt_quot_fcat.

  DEFINE add_fcat.
    CLEAR gs_quot_fcat.
    gs_quot_fcat-fieldname = &1.
    gs_quot_fcat-coltext   = &2.
    gs_quot_fcat-outputlen = &3.
    gs_quot_fcat-emphasize = &4.
    APPEND gs_quot_fcat TO gt_quot_fcat.
  END-OF-DEFINITION.

  add_fcat 'VBELN'      '견적서 ID' 10 'C110'.
  add_fcat 'BSTNK'      '고객문의 번호' 15 ''.
  add_fcat 'VKBUR'      '계약 영업장' 12 ''.
  add_fcat 'KUNNR'      '고객 ID' 10 ''.
  add_fcat 'NAME1'      '고객명' 20 ''.
  add_fcat 'VDATU'      '배송 요청일' 12 ''.
  add_fcat 'STREET'     '배송지' 40 ''.
  add_fcat 'CONT_NAME'  '담당자명' 15 ''.
  add_fcat 'SMTP_ADDR'  '담당자 이메일' 30 ''.
  add_fcat 'TEL_NUMBER' '담당자 전화번호' 15 ''.
*  add_fcat 'STATUS'     '계약'            10.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form search_quotation
*&---------------------------------------------------------------------*
*& 견적정보 불러오기 데이터 가지고 오기
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_quotation .
  CLEAR gt_quot.

  DATA: lv_name1          TYPE name1_gp,
        lv_name1_pattern  TYPE name1_gp.

  CLEAR gt_quot.

  "고객명 검색조건 - 부분일치해도 검색되게!
  IF iofield2 IS NOT INITIAL.
    lv_name1 = iofield2.
    TRANSLATE lv_name1 TO UPPER CASE. "대문자 변환해서 검색
    lv_name1_pattern = |%{ lv_name1 }%|.
  ENDIF.

  "데이터를 테이블에서 가져옴.
  SELECT  a~vbeln,
          a~bstnk,
          a~vkbur,
          a~kunnr,
          b~name1 AS name1,
          a~vdatu,
          c~street,
          c~name1 AS cont_name,
          d~smtp_addr,
          e~tel_number
  FROM ztsds00010 AS a
    JOIN ztsds00070 AS b ON b~kunnr = a~kunnr
    LEFT OUTER JOIN ztsds00170 AS c ON c~addrnumber = b~adrnr
    LEFT OUTER JOIN ztsds00090 AS d ON d~addrnumber = b~adrnr
    LEFT OUTER JOIN ztsds00180 AS e ON e~addrnumber = b~adrnr
  WHERE a~vbeln BETWEEN '0000000000' AND '0999999999'   "0번대(견적서)만 조회하게!
    AND a~faksk = ' '                                   "임시보류는 제외!
    AND ( @iofield1 IS INITIAL OR a~kunnr = @iofield1 )                               "고객ID 조건
    AND ( @lv_name1_pattern IS INITIAL OR UPPER( b~name1 ) LIKE @lv_name1_pattern )   "고객명 조건
    INTO TABLE @gt_quot.
  IF sy-subrc <> 0.
    MESSAGE '데이터가 없습니다.' TYPE 'S'.
  ELSE.
    MESSAGE |{ lines( gt_quot ) }건 조회되었습니다.| TYPE 'S'.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form fill_order_fields
*&---------------------------------------------------------------------*
*& 견적정보 불러오기(견적서 정보 조회 팝업창)에서 행 더블클릭 시, 0100에 채워넣을 데이터 가지고 오기!
*&---------------------------------------------------------------------*
*&      --> GS_QUOT
*&---------------------------------------------------------------------*
FORM fill_order_fields  USING    p_gs_quot LIKE gs_quot.

  "고정값
  CONSTANTS: lc_vtweg TYPE vtweg VALUE '10',      "유통채널
             lc_parvw TYPE parvw VALUE 'SY',      "담당자 파트너기능 코드(190에 데이터 채울 때 SY로 해야 함~)
             lc_lovfi TYPE netwr VALUE '10.00',   "배송비 (10$ 고정)
             lc_disc  TYPE netwr VALUE '0.00'.    "할인금액 (고정)

  "우리 회사 정보
  CONSTANTS:  lc_name_sup       TYPE name1 VALUE '(주)MAINCURE',
              lc_bukrs_sup      TYPE bukrs VALUE '0036',
              lc_land1_sup      TYPE land1 VALUE 'KR',
              lc_stcd1_sup      TYPE stcd1 VALUE '123-45-67890',
              lc_vkbur_sup      TYPE vkbur VALUE 'BU',
              lc_street_sup     TYPE ad_street VALUE '서울특별시 노원구 화랑로 123',
              lc_tel_sup        TYPE ad_tlnmbr1 VALUE '02-1234-5678',
              lc_email_sup      TYPE ad_smtpadr VALUE 'TEST_MAINCURE@INNO.CO.KR',
              lc_bankn_sup      TYPE bankn VALUE '110-234-567890'.

  DATA: lv_kunnr          TYPE kunnr,
        lv_vbeln          TYPE vbeln_va,
        lv_adrnr          TYPE ad_addrnum,
        lv_spart          TYPE spart,
        lv_werks          TYPE werks_d,
        lv_contact_adrnr  TYPE ad_addrnum,
        lv_bankn          TYPE bankn,
        lt_item           TYPE TABLE OF ztsds00020,
        lv_vat            TYPE netwr,   "부가세 (계산)
        lv_total          TYPE netwr,   "총 청구금액 (계산)
        lv_disc_txt       TYPE char15.   "할인금액 표시용 문자열

"팝업창 띄울 때 가지고 왔던 컬럼들은 거기서 가지고 오면 됨
"이걸 기반으로 데이터를 가지고 온다!
  lv_vbeln = p_gs_quot-vbeln. "견적서 ID
  lv_kunnr = p_gs_quot-kunnr. "고객 ID

*===============================
* SQL
*===============================
  "----------
  " SO 헤더
  "----------
  CLEAR gs_head.
  SELECT SINGLE vbeln, kunnr, auart, vkorg, vkbur, waerk, zterm, faksk, vdatu, netwr
    FROM ztsds00010
    WHERE vbeln = @lv_vbeln
    INTO (@gs_head-vbeln, @gs_head-kunnr, @gs_head-auart, @gs_head-vkorg,
          @gs_head-vkbur, @gs_head-waerk, @gs_head-zterm, @gs_head-faksk, @gs_head-vdatu,
          @gs_head-netwr).
  "----------
  " 첫 번째 품목(POSNR 최솟값) 기준 SPART, WERKS
  "----------
  CLEAR: lv_spart, lv_werks, lt_item.
  SELECT spart, werks
    FROM ztsds00020
    WHERE vbeln = @lv_vbeln
    ORDER BY posnr ASCENDING
    INTO CORRESPONDING FIELDS OF TABLE @lt_item
    UP TO 1 ROWS.
  IF lt_item IS NOT INITIAL.
    lv_spart = lt_item[ 1 ]-spart.
    lv_werks = lt_item[ 1 ]-werks.
  ENDIF.

  "----------
  " 고객 일반 데이터
  "----------
  CLEAR gs_cust.
  SELECT SINGLE kunnr, name1, land1, stceg, adrnr
    FROM ztsds00070
    WHERE kunnr = @lv_kunnr
    INTO (@gs_cust-kunnr, @gs_cust-name1, @gs_cust-land1, @gs_cust-stceg, @gs_cust-adrnr).

  lv_adrnr = gs_cust-adrnr.

  "----------
  " 고객 영업데이터
  "----------
  SELECT SINGLE waers, zterm
    FROM ztsds00080
    WHERE kunnr = @lv_kunnr
      AND vkorg = @gs_head-vkorg
      AND vtweg = @lc_vtweg
      AND spart = @lv_spart
    INTO (@gs_cust-waers, @gs_cust-zterm).

  "----------
  " 배송지
  "----------
  SELECT SINGLE street
    FROM ztsds00170
    WHERE addrnumber = @lv_adrnr
    INTO @gs_cust-street.

  "----------
  " 담당자 (PARVW='SY')
  "----------
  CLEAR lv_contact_adrnr.
  SELECT SINGLE adrnr
    FROM ztsds00190
    WHERE vbeln = @lv_vbeln
      AND posnr = '000010'
      AND parvw = @lc_parvw
    INTO @lv_contact_adrnr.

  "----------
  " 담당자 이름/전화번호/이메일
  "----------
  IF lv_contact_adrnr IS NOT INITIAL.
    SELECT SINGLE name1
      FROM ztsds00170
      WHERE addrnumber = @lv_contact_adrnr
      INTO @gs_cust-name_contact.

    SELECT SINGLE tel_number
      FROM ztsds00180
      WHERE addrnumber = @lv_contact_adrnr
      INTO @gs_cust-tel_number.

    SELECT SINGLE smtp_addr
      FROM ztsds00090
      WHERE addrnumber = @lv_contact_adrnr
      INTO @gs_cust-smtp_addr.
  ENDIF.

  "----------
  " 은행계좌 (1건 가정)
  "----------
  CLEAR lv_bankn.
  SELECT SINGLE bankn
    FROM ztsds00130
    WHERE kunnr = @lv_kunnr
    INTO @lv_bankn.

*===============================
* 스크린 layout 필드 반영
*===============================

  "----------
  " 0100
  "----------
  B1_FIELD1 = gs_cust-kunnr. "고객코드
  B1_FIELD2 = gs_cust-name1. "고객명
  B1_FIELD3 = gs_head-auart. "주문유형
  B1_FIELD4 = gs_head-vdatu. "배송 요청일

  B1_FIELD5 = gs_head-vbeln. "주문번호

  "----------
  " 0101
  "----------
  S1_B1_FIELD1 = gs_cust-street.  "배송지
  S1_B1_FIELD2 = gs_cust-land1.   "국가코드
  S1_B1_FIELD3 = lv_werks.        "출하플랜트
  S1_B1_FIELD4 = lv_bankn.        "계좌번호
  S1_B1_FIELD5 = gs_cust-waers.   "통화
  S1_B1_FIELD6 = gs_cust-stceg.   "사업자번호

  S1_B2_FIELD1 = gs_cust-name_contact.  "담당자 이름
  S1_B2_FIELD2 = gs_cust-tel_number.    "담당자 전화번호
  S1_B2_FIELD3 = gs_cust-smtp_addr.     "이메일

  S1_B3_FIELD1 = gs_head-vkbur.         "판매 영업장
  S1_B3_FIELD2 = gs_cust-zterm.         "지불조건
  S1_B3_FIELD3 = gs_head-faksk.         "지불 차단 여부

  "----------
  " 0103
  "----------
  S3_B1_F1 = lc_name_sup.     "공급자
  S3_B1_F2 = lc_bukrs_sup.    "회사코드
  S3_B1_F3 = lc_land1_sup.    "국가코드
  S3_B1_F4 = lc_stcd1_sup.    "사업자등록번호
  S3_B1_F5 = lc_vkbur_sup.    "영업장
  S3_B1_F6 = lc_street_sup.   "주소
  S3_B1_F7 = lc_tel_sup.      "전화번호
  S3_B1_F8 = lc_email_sup.    "메일
  S3_B1_F9 = lc_bankn_sup.    "은행계좌

  S3_B2_F1 = gs_cust-land1.        "국가코드
  S3_B2_F2 = gs_cust-waers.        "통화코드
  S3_B2_F3 = gs_cust-stceg.        "사업자번호
  S3_B2_F4 = lv_bankn.             "계좌번호
  S3_B2_F5 = lv_werks.             "출하 플랜트
  S3_B2_F6 = gs_cust-street.       "배송지
  S3_B2_F7 = gs_cust-name_contact. "담당자
  S3_B2_F8 = gs_cust-tel_number.   "전화번호
  S3_B2_F9 = gs_cust-smtp_addr.    "이메일 주소

  lv_vat   = gs_head-netwr * '0.1'.                        "부가세 (순금액의 10% 가정)
  lv_total = gs_head-netwr + lv_vat + lc_lovfi - lc_disc.   "총 청구금액

  lv_disc_txt = |{ lc_disc NUMBER = USER }|.     "할인금액 문자열 변환

  S3_B4_F1 = gs_head-netwr.   "총 순금액
  S3_B4_F2 = lv_vat.          "부가세
  S3_B4_F3 = lc_lovfi.        "배송비 (고정 10$)
  S3_B4_F4 = lc_disc.         "할인금액 (고정 0.00)
  S3_B4_F5 = gs_head-waerk.   "통화
  S3_B4_F6 = lv_total.        "총 청구금액

ENDFORM.


*&---------------------------------------------------------------------*
*& Form set_cc_confirm_fieldcat
*&---------------------------------------------------------------------*
*& 스크린 103 주문정보확인
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_cc_confirm_fieldcat .
  CLEAR gt_fcat1.
  DEFINE add_fcat.
    CLEAR gs_fcat1.
    gs_fcat1-fieldname = &1.
    gs_fcat1-coltext   = &2.
    gs_fcat1-outputlen = &3.
    gs_fcat1-emphasize = &4.
    APPEND gs_fcat1 TO gt_fcat1.
  END-OF-DEFINITION.

  add_fcat 'POSNR'  '품목 번호'   6 ''.   " POSNR_VA
  add_fcat 'MATNR'  '자재 번호'  16 'C110'.   " MATNR

*-- MM: 자재명(텍스트) ZMAKT 에서 가져옴
  add_fcat 'MAKTX'  '자재명'     30 ''.   " MAKTX

  add_fcat 'KWMENG' '주문 수량'  13 ''.   " KWMENG (QUAN)
  add_fcat 'VRKME'  '판매 단위'   5 ''.   " VRKME (UNIT)
  add_fcat 'NETPR'  '순 단가'    11 ''.   " NETPR (CURR)
  add_fcat 'WERKS'  '플랜트'      6 ''.   " WERKS_D
  add_fcat 'SPART'  '제품군'      4 ''.   " SPART
  add_fcat 'NETWR'  '순금액'     13 ''.   " NETWR
  add_fcat 'WAERK'  '통화 단위'   5 ''.   " WAERK (CUKY)
ENDFORM.

*&---------------------------------------------------------------------*
*& Form search_quotation1
*&---------------------------------------------------------------------*
*& 스크린 103의 제품정보 및 규격 설정
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_quotation1 .
  DATA: lv_status  TYPE statu,
        lv_message TYPE char255,
        lv_matnr   TYPE matnr.   "변환된 자재번호 담음

  CLEAR gt_data1.

*-- SO 아이템(ZTSDS00020) + 자재명(ZMAKT) 조인 조회
  SELECT a~posnr
         a~matnr
*         b~maktx
         a~spart
         a~kwmeng
         a~vrkme
         a~netpr
         a~waerk
    INTO CORRESPONDING FIELDS OF TABLE gt_data1
    FROM ztsds00020 AS a
*    LEFT JOIN zmakt AS b
*      ON  b~matnr = a~matnr
*      AND b~spras = sy-langu
    WHERE a~vbeln = gs_head-vbeln.   "선택된 견적서 ID(fill_order_fields에서 세팅됨)

*-- 데이터 넣기
  LOOP AT gt_data1 INTO gs_data1.
    "라인별 순금액 계산 (단가 × 수량)
    gs_data1-netwr = gs_data1-netpr * gs_data1-kwmeng.

    "MATNR 포맷 변환 (앞자리 0 채움 등, MM 테이블 저장 포맷에 맞춤)
    CLEAR lv_matnr.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = gs_data1-matnr
      IMPORTING
        output = lv_matnr.


    "FM으로 자재명 조회(ZMAKT)
    CLEAR: lv_status, lv_message, gs_data1-maktx.
    CALL FUNCTION 'ZZ_MM_GET_MATERIAL_DETAIL'
    EXPORTING
      i_matnr = gs_data1-matnr
    IMPORTING
      e_maktx = gs_data1-maktx
      e_status  = lv_status
      e_message = lv_message.

    MODIFY gt_data1 FROM gs_data1.
  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form fill_tree
*&---------------------------------------------------------------------*
*& screen 102 왼쪽 트리 (제품군 폴더 + 하위의 자재)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_tree.

  DATA: lt_matkl_group TYPE TABLE OF t023t,
        ls_group       TYPE t023t,
        lt_list        TYPE TABLE OF ty_mat_list,
        ls_mat         TYPE ty_mat_list,
        lv_status      TYPE statu,
        lv_message     TYPE char255,
        lv_root_key    TYPE lvc_nkey,
        lv_folder_key  TYPE lvc_nkey,
        lv_new_key     TYPE lvc_nkey,
        ls_outtab      TYPE ty_mat_list,
        lt_outtab      TYPE TABLE OF ty_mat_list,
        ls_hhdr        TYPE treev_hhdr,
        lt_fieldcat    TYPE lvc_t_fcat,
        ls_node_layout TYPE lvc_s_layn, "폴더인지아닌지
        ls_fieldcat    TYPE lvc_s_fcat.

  "-----------------------------------------------------------
  " 1) 트리 첫 컬럼(계층) 헤더
  "-----------------------------------------------------------
  ls_hhdr-heading = '제품 리스트'.
  ls_hhdr-width   = 30.

  "-----------------------------------------------------------
  " 2) 컬럼 정의 (it_outtab=ty_mat_list의 4개 필드 전부 등록)
  "-----------------------------------------------------------

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'MAKTX'.
  ls_fieldcat-coltext   = '제품명'.
  ls_fieldcat-outputlen = 30.
  APPEND ls_fieldcat TO lt_fieldcat.

  "-----------------------------------------------------------
  " 3) 트리 최초 세팅
  "-----------------------------------------------------------
  CALL METHOD go_tree->set_table_for_first_display
    EXPORTING
      is_hierarchy_header = ls_hhdr
    CHANGING
      it_outtab       = gt_tree_outtab "전역
      it_fieldcatalog = lt_fieldcat.

  "-----------------------------------------------------------
  " 4) 루트 노드
  "-----------------------------------------------------------
  CLEAR ls_outtab.
  CLEAR ls_node_layout.
  ls_node_layout-isfolder = abap_true.

  CALL METHOD go_tree->add_node
    EXPORTING
      i_relat_node_key = ''
      i_relationship   = cl_gui_column_tree=>relat_last_child "(CL_GUI_ALV_TREE->add_model_node에서 cl_gui_column_tree 이름 찾음
      is_outtab_line   = ls_outtab
      is_node_layout   = ls_node_layout "폴더임
      i_node_text      = '제품'
    IMPORTING
      e_new_node_key   = lv_root_key.

  "-----------------------------------------------------------
  " 5) 제품군: 표준 테이블에서 조회
  "-----------------------------------------------------------
  SELECT matkl, wgbez
    FROM t023t
    WHERE spras = @sy-langu
    INTO CORRESPONDING FIELDS OF TABLE @lt_matkl_group.

  LOOP AT lt_matkl_group INTO ls_group.

    " 먼저 FM으로 이 그룹에 실제 자재가 있는지 확인
    CLEAR lt_list.
    CALL FUNCTION 'ZZ_MM_GET_MATERIAL_LIST'
      EXPORTING
        i_matkl   = ls_group-matkl
      IMPORTING
        e_status  = lv_status
        e_message = lv_message
        et_list   = lt_list.

    " 자재가 없는 그룹은 폴더 자체를 만들지 않고 건너뜀
    IF lv_status = 'E'.
      CONTINUE.
    ENDIF.

    " 자재가 있는 그룹만 폴더 노드 생성
    CLEAR ls_outtab.
    ls_outtab-matkl = ls_group-matkl.
    ls_outtab-wgbez = ls_group-wgbez.

    CLEAR ls_node_layout.
    ls_node_layout-isfolder = abap_true.

    CALL METHOD go_tree->add_node
      EXPORTING
        i_relat_node_key = lv_root_key
        i_relationship   = cl_gui_column_tree=>relat_last_child
        is_outtab_line   = ls_outtab
        is_node_layout   = ls_node_layout "폴더임
        i_node_text      = CONV lvc_value( ls_group-wgbez )
      IMPORTING
        e_new_node_key   = lv_folder_key.

    " 그 아래 자재 리프 노드 추가
    LOOP AT lt_list INTO ls_mat.
      ls_outtab = ls_mat.
      CALL METHOD go_tree->add_node
        EXPORTING
          i_relat_node_key = lv_folder_key
          i_relationship   = cl_gui_column_tree=>relat_last_child
          is_outtab_line   = ls_outtab
          i_node_text      = CONV lvc_value( ls_mat-matnr )
        IMPORTING
          e_new_node_key   = lv_new_key.
    ENDLOOP.

  ENDLOOP.
  CALL METHOD go_tree->frontend_update.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form init_alv_layout
*&---------------------------------------------------------------------*
*& screen 102 오른쪽 자재 로딩
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM init_alv_layout.

  DATA: ls_layout TYPE lvc_s_layo.
*  ls_layout-cwidth_opt = abap_true.

  PERFORM set_cc_confirm_fieldcat.
  PERFORM search_quotation1.

  go_grid->set_table_for_first_display(
    EXPORTING
      is_layout       = ls_layout
    CHANGING
      it_outtab       = gt_data1
      it_fieldcatalog = gt_fcat1 ).

ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_order
*&---------------------------------------------------------------------*
*& 주문정보(SO)생성 버튼 클릭 시 : 지불차단여부(FAKSK) 값에 따라 분기, VBELN 0번대->1번대 발급
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_order.
  DATA: lv_new_vbeln TYPE vbeln_va,   "새 vbeln(1번대)
        lv_old_vbeln TYPE vbeln_va,   "기존 vbeln(0번대)
        lv_answer    TYPE c.          "체크박스 확인용!

  lv_old_vbeln = gs_head-vbeln. "현재 화면에 로딩된 견적서 VBELN(0번대)

  "-------------------
  " 견적서가 로딩되어 있는지 체크
  "-------------------
  IF lv_old_vbeln IS INITIAL.
    MESSAGE '견적정보를 먼저 불러와주세요.' TYPE 'I'.
    EXIT.
  ENDIF.

  "------------------
  " 체크박스 체크
  "------------------
  IF S3_CHECKBUTTON <> 'X'.
    MESSAGE '주문정보확인 하단의 체크박스는 필수입니다.' TYPE 'I'.
    EXIT.
  ENDIF.

  "-------------------
  " 주문정보를 생성하시겠습니까? 확인 팝업창
  "-------------------
  CALL FUNCTION 'POPUP_TO_CONFIRM'
  EXPORTING
    titlebar                = '주문정보 생성'
    text_question           = '주문정보를 생성하시겠습니까?'
    text_button_1           = '예'
    text_button_2           = '아니오'
    default_button          = '1'
    display_cancel_button   = space "cancel 버튼이 나타나지 않게 함
  IMPORTING
    answer          = lv_answer.

  IF lv_answer <> '1'. "아니오면
    EXIT.
  ENDIF.

  "------------------
  " 지불차단여부(FAKSK) 체크
  "------------------
  IF s1_b3_field3 IS NOT INITIAL.
    UPDATE ZTSDS00010 SET faksk = s1_b3_field3
    WHERE vbeln = lv_old_vbeln.

    COMMIT WORK.

    MESSAGE '지불차단 사유가 있어 승인 임시 반려 상태로 저장되었습니다. 주문 승인/반려에서 확정할 수 있습니다.' TYPE 'I'.
    EXIT.
  ENDIF.

  "----------------------------------------
  " Number Range로 신규 VBELN(1번대) 발급
  "----------------------------------------
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'              " SNRO 구간번호
      object      = 'ZSD_VBELN'       " SNRO 오브젝트 이름
    IMPORTING
      number      = lv_new_vbeln.


  "----------------------------------------
  " 관련 테이블 UPDATE (VBELN 0번대 → 1번대)
  "----------------------------------------
  UPDATE ztsds00010 SET vbeln = lv_new_vbeln
    WHERE vbeln = lv_old_vbeln.

  UPDATE ztsds00020 SET vbeln = lv_new_vbeln
    WHERE vbeln = lv_old_vbeln.

  UPDATE ztsds00190 SET vbeln = lv_new_vbeln
    WHERE vbeln = lv_old_vbeln.

  COMMIT WORK.


  "----------------------------------------
  " 4. 화면 갱신 (SO번호 표시)
  "----------------------------------------
  gs_head-vbeln = lv_new_vbeln.
  B1_FIELD5     = lv_new_vbeln.

  MESSAGE |주문번호 { lv_new_vbeln }로 생성되었습니다.| TYPE 'S'.

ENDFORM.



*&---------------------------------------------------------------------*
*& Form set_appr_fieldcat
*&---------------------------------------------------------------------*
*& 스크린 201 - 필드카탈로그 세팅
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_appr_fieldcat .
  CLEAR gt_appr_fcat.
  DEFINE add_fcat.
    CLEAR gs_appr_fcat.
    gs_appr_fcat-fieldname = &1.
    gs_appr_fcat-coltext   = &2.
    gs_appr_fcat-outputlen = &3.
    APPEND gs_appr_fcat TO gt_appr_fcat.
  END-OF-DEFINITION.

  "상태 컬럼!
  CLEAR gs_appr_fcat.
  gs_appr_fcat-fieldname = 'STATUS'.
  gs_appr_fcat-coltext   = '상태'.
  gs_appr_fcat-outputlen = 4.
  gs_appr_fcat-icon      = 'X'.      "★아이콘 컬럼임을 표시
  APPEND gs_appr_fcat TO gt_appr_fcat.


  add_fcat 'VBELN'  '문서번호'  15.
  add_fcat 'KUNNR'  '고객 ID'   10.
  add_fcat 'NAME1'  '고객명'    20.
  add_fcat 'NETWR'  '순금액'    13.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form search_approval_list
*&---------------------------------------------------------------------*
*& 스크린 201 - 주문 승인/반려 데이터 조회
*& (승인된 것(1번대) + 반려된 것(0번대, fstnk가 비지 않음))
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_approval_list .
  DATA: lt_rej TYPE TABLE OF ty_appr.

  CLEAR gt_appr.

  "-------승인---------
  SELECT a~vbeln, a~kunnr, b~name1, a~faksk, a~netwr
    INTO CORRESPONDING FIELDS OF TABLE @gt_appr
    FROM ztsds00010 as a JOIN ztsds00070 as b ON a~kunnr = b~kunnr
    WHERE a~vbeln BETWEEN '1000000000' AND '1999999999'.

  LOOP AT gt_appr INTO gs_appr.
    gs_appr-status = ICON_LED_GREEN. "초록 네모 아이콘
    MODIFY gt_appr FROM gs_appr.
  ENDLOOP.


  "-------반려---------
  SELECT a~vbeln, a~kunnr, b~name1, a~faksk, a~netwr
    INTO CORRESPONDING FIELDS OF TABLE @lt_rej
    FROM ztsds00010 AS a
    JOIN ztsds00070 AS b ON b~kunnr = a~kunnr
    WHERE a~vbeln BETWEEN '0000000000' AND '0999999999'
      AND a~faksk <> ' '.

  LOOP AT lt_rej INTO gs_appr.
    gs_appr-status = ICON_LED_YELLOW. "노란 세모 아이콘
    APPEND gs_appr TO gt_appr.
  ENDLOOP.

  IF gt_appr IS INITIAL.
    MESSAGE '승인/반려 대상 건이 없습니다.' TYPE 'I'.
  ENDIF.

  gt_appr_all = gt_appr. "원본 백업(전체데이터 다시 불러와야 하니까)

ENDFORM.

*&---------------------------------------------------------------------*
*& Form final_reject
*&---------------------------------------------------------------------*
*& 스크린 201 - 최종 반려 버튼을 눌렀을 때 실행
*& (faksk를 공백으로 업데이트, 다시 견적정보 불러오기로 들어갈 수 있게)
*&---------------------------------------------------------------------*
*&      --> LV_VBELN
*&---------------------------------------------------------------------*
FORM final_reject  USING    p_vbeln.
  UPDATE ztsds00010 SET faksk = space
    WHERE vbeln = p_vbeln.

  COMMIT WORK.

  MESSAGE '최종 반려 처리되었습니다.' TYPE 'S'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form approve_order
*&---------------------------------------------------------------------*
*& 스크린 201 - 승인 버튼 눌렀을 때 실행
*& (faksk를 공백으로 업데이트, so생성(vbeln 1번대 채번. 발급한다))
*&---------------------------------------------------------------------*
*&      --> LV_VBELN
*&---------------------------------------------------------------------*
FORM approve_order  USING    p_vbeln.
  DATA: lv_new_vbeln TYPE vbeln_va.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZSD_VBELN'
    IMPORTING
      number      = lv_new_vbeln.

  UPDATE ztsds00010 SET vbeln = lv_new_vbeln faksk = space
    WHERE vbeln = p_vbeln.

  UPDATE ztsds00020 SET vbeln = lv_new_vbeln
    WHERE vbeln = p_vbeln.

  UPDATE ztsds00190 SET vbeln = lv_new_vbeln
    WHERE vbeln = p_vbeln.

  COMMIT WORK.

  MESSAGE |주문번호 { lv_new_vbeln }로 승인 처리되었습니다.| TYPE 'S'.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form search_quot_by_customer
*&---------------------------------------------------------------------*
*& 스크린 100 - 검색 기능(고객코드/고객명으로 검색한다)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_quot_by_customer .
  DATA: lv_kunnr      TYPE kunnr,
        lv_name1     TYPE name1_gp, "고객명 대문자 변환해서 비교하기 위해 상요!
        ls_cust       TYPE ZTSDS00070,
        lt_cust       TYPE TABLE OF ztsds00070,
        lt_quot_cand  TYPE TABLE OF ztsds00010,
        ls_quot_cand  TYPE ztsds00010,
        ls_quot_in    LIKE gs_quot.

  CLEAR lv_kunnr.


  "================
  " 고객코드/고객명으로 고객 특정
  "================
  IF radio1 = 'X'.            "고객코드
    IF b1_field1 IS INITIAL.
      EXIT.
    ENDIF.

    SELECT SINGLE *
      FROM ztsds00070
      WHERE kunnr = @b1_field1
      INTO @ls_cust.

    IF sy-subrc <> 0.
      MESSAGE '해당 고객코드가 존재하지 않습니다.' TYPE 'I'.
      EXIT.
    ENDIF.

    lv_kunnr = ls_cust-kunnr.

  ELSEIF radio2 = 'X'.      "고객명
    IF b1_field2 IS INITIAL.
      EXIT.
    ENDIF.

    lv_name1 = b1_field2.
    TRANSLATE lv_name1 TO UPPER CASE.       "입력값을 대문자로 변환

    SELECT *
      FROM ztsds00070
      WHERE UPPER( name1 ) = @lv_name1      "DB 컬럼값도 대문자로 변환해서 비교
      INTO TABLE @lt_cust.

    IF lines( lt_cust ) = 0.          "고객명 x
      MESSAGE '해당 고객명이 존재하지 않습니다.' TYPE 'I'.
      EXIT.
    ELSEIF lines( lt_cust ) > 1.      "고객명 여러개 있을땐 견적정보 불러오기 쓰기~
      MESSAGE '동일한 고객명이 여러 건 존재합니다. 고객코드로 검색하거나 견적정보 불러오기를 이용해주세요.' TYPE 'I'.
      EXIT.
    ENDIF.

    ls_cust   = lt_cust[ 1 ].
    lv_kunnr  = ls_cust-kunnr.
    b1_field1 = lv_kunnr.       "고객코드

  ELSE.
    EXIT.
  ENDIF.


  "================
  " 고객 견적서 조회
  "================
  SELECT * FROM ztsds00010
    WHERE kunnr = @lv_kunnr
      AND vbeln BETWEEN '0000000000' AND '0999999999'
      AND faksk = ' '
    INTO TABLE @lt_quot_cand.

  IF lines( lt_quot_cand ) = 0.
    MESSAGE '해당 고객의 미확정 견적서가 없습니다. 견적정보 불러오기를 이용해주세요.' TYPE 'I'.
    EXIT.
  ELSEIF lines( lt_quot_cand ) > 1.
    MESSAGE '해당 고객의 미확정 견적서가 여러 건입니다. 견적정보 불러오기를 이용해 직접 선택해주세요.' TYPE 'I'.
    EXIT.
  ENDIF.

  ls_quot_cand = lt_quot_cand[ 1 ].


  "================
  " 화면에 데이터 채우기
  "================
  CLEAR ls_quot_in.
  ls_quot_in-vbeln = ls_quot_cand-vbeln.
  ls_quot_in-kunnr = ls_quot_cand-kunnr.

  PERFORM fill_order_fields USING ls_quot_in.

ENDFORM.
