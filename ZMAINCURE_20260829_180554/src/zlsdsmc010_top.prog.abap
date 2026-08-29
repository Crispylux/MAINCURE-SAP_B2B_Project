*&---------------------------------------------------------------------*
*& Include ZMANI_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: icon.
DATA: B1_ICON1 TYPE ICONS-TEXT.
DATA: gs_layout TYPE lvc_s_layo.

*====================================
* 스크린 200 - ALV상단 툴바 제거, 행 더블클릭 시 데이터 조회 관련
*====================================
CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    METHODS: on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object,
      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.
ENDCLASS.

DATA: go_handler TYPE REF TO lcl_handler,
      go_event_handler TYPE REF TO lcl_alv_handler.



"0100 라디오버튼
DATA: RADIO1    TYPE c,
      RADIO2    TYPE c,
      gv_first_0100 TYPE c.


*====================================
* 스크린 200 - 견적정보 불러오기 관련
*====================================
" 팝업 ALV 관련 (견적정보 팝업)
DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_alv       TYPE REF TO cl_gui_alv_grid.

"검색 조건
DATA: iofield1 TYPE kunnr,    "고객id
      iofield2 TYPE name1_gp. "고객명

"0200 팝업창에 뜨는 견적 리스트 구조
TYPES: BEGIN OF ty_quot,
  vbeln       TYPE ztsds00010-vbeln,       "견적서 id
  bstnk       TYPE ztsds00010-bstnk,       "고객문의 번호
  vkbur       TYPE ztsds00010-vkbur,       "계약영업장
  kunnr       TYPE ztsds00010-kunnr,       "고객 id
  name1       TYPE ztsds00070-name1,       "고객명
  vdatu       TYPE ztsds00010-vdatu,       "배송 요청일
  street      TYPE ztsds00170-street,      "배송지
  cont_name   TYPE ztsds00170-name1,       "담당자명
  smtp_addr   TYPE ztsds00090-smtp_addr,   "담당자 이메일
  tel_number  TYPE ztsds00180-tel_number,  "담당자 전화번호
*  status      TYPE ztsds00010-status,      "계약 상태
END OF ty_quot.

"인터널테이블
DATA: gt_quot TYPE TABLE OF ty_quot,
      gs_quot TYPE ty_quot.

"field catalog
DATA: gt_quot_fcat TYPE lvc_t_fcat,
      gs_quot_fcat TYPE lvc_s_fcat.


*====================================
* 스크린 103 - 제품정보 및 규격 관련 (주문정보확인 아이템 그리드)
*====================================
" 아이템 ALV 관련
DATA: go_container1 TYPE REF TO cl_gui_custom_container,
      go_alv1       TYPE REF TO cl_gui_alv_grid.

"제품정보 및 규격 그리드 구조
TYPES: BEGIN OF ty_data1,
  posnr       TYPE ztsds00020-posnr,       "항목 번호
  matnr       TYPE ztsds00020-matnr,       "자재 번호
  maktx       TYPE maktx,                 "자재명 (MM 조인)
  spart       TYPE ztsds00020-spart,       "제품군
  kwmeng      TYPE ztsds00020-kwmeng,      "주문 수량
  vrkme       TYPE ztsds00020-vrkme,       "판매 단위
  netpr       TYPE ztsds00020-netpr,       "단가
  netwr       TYPE netwr,                  "순금액 (라인 = 단가×수량, 계산)
  waerk       TYPE ztsds00020-waerk,       "통화 단위
END OF ty_data1.

"인터널테이블
DATA: gt_data1 TYPE TABLE OF ty_data1,
      gs_data1 TYPE ty_data1.

"field catalog
DATA: gt_fcat1 TYPE lvc_t_fcat,
      gs_fcat1 TYPE lvc_s_fcat.

*====================================
* 메인 화면 채우기 관련
*====================================
"팝업창에서 더블클릭한 데이터를 100대 스크린에 채우기 위한 구조
DATA: BEGIN OF gs_head,
  vbeln   TYPE vbeln_va,
  kunnr   TYPE kunnr,
  auart   TYPE auart,
  vdatu   TYPE edatu_vbak,
  waerk   TYPE waerk,
  vkorg   TYPE vkorg,
  vkbur   TYPE vkbur,
  zterm   TYPE dzterm,
  faksk   TYPE faksk,
  netwr   TYPE netwr, "총 순금액
END OF gs_head.

DATA: BEGIN OF gs_cust,
  kunnr        TYPE kunnr,
  name1        TYPE name1_gp,
  land1        TYPE land1,
  stceg        TYPE stceg,
  adrnr        TYPE ad_addrnum,
  waers        TYPE waers,
  zterm        TYPE dzterm,
  street       TYPE ad_street,
  tel_number   TYPE ad_tlnmbr,
  smtp_addr    TYPE ad_smtpadr,
  name_contact TYPE ad_name1,
END OF gs_cust.


DATA: B1_FIELD1 TYPE kunnr,      " 고객코드
      B1_FIELD2 TYPE name1_gp,   " 고객명
      B1_FIELD3 TYPE auart,      " 주문유형
      B1_FIELD4 TYPE edatu_vbak, " 배송요청일

      B1_FIELD5 TYPE vbeln,      "주문번호

      S1_B1_FIELD1 TYPE ad_street,   " 배송지
      S1_B1_FIELD2 TYPE land1,       " 국가코드
      S1_B1_FIELD3 TYPE werks_d,     " 출하플랜트
      S1_B1_FIELD4 TYPE bankn,       " 계좌번호
      S1_B1_FIELD5 TYPE waers,       " 통화
      S1_B1_FIELD6 TYPE stceg,       " 사업자번호
      S1_B2_FIELD1 TYPE ad_name1,    " 담당자이름
      S1_B2_FIELD2 TYPE ad_tlnmbr,   " 담당자전화번호
      S1_B2_FIELD3 TYPE ad_smtpadr,  " 이메일
      S1_B3_FIELD1 TYPE vkbur,       " 판매영업장
      S1_B3_FIELD2 TYPE dzterm,      " 지불조건
      S1_B3_FIELD3 TYPE faksk,       " 지불차단여부

      S3_B2_F1 TYPE land1,        " 국가코드
      S3_B2_F2 TYPE waers,        " 통화코드
      S3_B2_F3 TYPE stceg,        " 사업자번호
      S3_B2_F4 TYPE bankn,        " 계좌번호
      S3_B2_F5 TYPE werks_d,      " 출하 플랜트
      S3_B2_F6 TYPE ad_street,    " 배송지
      S3_B2_F7 TYPE ad_name1,     " 담당자
      S3_B2_F8 TYPE ad_tlnmbr,    " 전화번호
      S3_B2_F9 TYPE ad_smtpadr,   " 이메일 주소

      "-- 공급자(갑) 정보 - 하드코딩 값 담을 자리
      S3_B1_F1 TYPE name1,      "공급자
      S3_B1_F2 TYPE bukrs,      "회사코드
      S3_B1_F3 TYPE land1,      "국가코드
      S3_B1_F4 TYPE stcd1,      "사업자등록번호
      S3_B1_F5 TYPE vkbur,      "영업장
      S3_B1_F6 TYPE ad_street,  "주소
      S3_B1_F7 TYPE ad_tlnmbr1, "전화번호
      S3_B1_F8 TYPE ad_smtpadr, "메일
      S3_B1_F9 TYPE bankn,      "은행계좌

      S3_B4_F1 TYPE netwr,     "총 순금액
      S3_B4_F2 TYPE netwr,     "부가세
      S3_B4_F3 TYPE netwr,     "배송비
      S3_B4_F4 TYPE netwr,    "할인금액
      S3_B4_F5 TYPE waerk,     "통화
      S3_B4_F6 TYPE netwr,     "총 청구금액

      S3_CHECKBUTTON TYPE flag."확인 체크박스





*====================================
* 아이템정보입력
* (screen 102)
*====================================
" 트리 관련 (왼쪽)
DATA: go_container_tree TYPE ref TO cl_gui_custom_container,
      go_tree           TYPE REF TO cl_gui_alv_tree.

" ALV 관련 (오른쪽)
DATA: go_container_alv TYPE REF TO cl_gui_custom_container,
      go_grid          TYPE REF TO cl_gui_alv_grid.

" 인터널 테이블
DATA: gt_data TYPE TABLE OF spfli,
      gs_data TYPE spfli.

" 필드 카탈로그
DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat.

" 탭스트립
CONTROLS: down_tabstrip TYPE TABSTRIP.
DATA: g_subscreen       TYPE sy-dynnr.


" 오른쪽 ALV용 - 견적 아이템 구조 (ZTSDS00020 기반)
TYPES: BEGIN OF ty_order_item,
         posnr  TYPE ztsds00020-posnr,
         matnr  TYPE ztsds00020-matnr,
         maktx  TYPE ztmmg00020-maktx,   " 자재명 표시용
         kwmeng TYPE ztsds00020-kwmeng,
         vrkme  TYPE ztsds00020-vrkme,
         netpr  TYPE ztsds00020-netpr,
         netwr  TYPE ztsds00020-netpr,   " 공급가액 = netpr * kwmeng (계산)
         waers  TYPE vbak-waerk,
       END OF ty_order_item.

DATA: gt_order_items TYPE TABLE OF ty_order_item.


"왼쪽 tree
TYPES: BEGIN OF ty_mat_list,
          matnr TYPE matnr,
          maktx TYPE maktx,
          matkl TYPE matkl,
          wgbez TYPE wgbez,
       END OF ty_mat_list.

DATA: gt_tree_outtab TYPE TABLE OF ty_mat_list.


*====================================
* 스크린 201 - 주문 승인/반려 팝업창 관련
*====================================
DATA: go_container3 TYPE REF TO cl_gui_custom_container,
      go_alv3       TYPE REF TO cl_gui_alv_grid.

TYPES: BEGIN OF ty_appr,
  vbeln TYPE ZTSDS00010-vbeln,
  kunnr TYPE ztsds00010-kunnr,
  name1 TYPE ztsds00070-name1,
  faksk TYPE ztsds00010-faksk,
  netwr TYPE ztsds00010-netwr,
  status TYPE icon_d,             "승인/반려 표시용!
END OF ty_appr.

"인터널 테이블
DATA: gt_appr TYPE TABLE OF ty_appr,
      gs_appr TYPE ty_appr.

"필드 카탈로그
DATA: gt_appr_fcat TYPE lvc_t_fcat,
      gs_appr_fcat TYPE lvc_s_fcat.

"원본 전체 데이터
DATA: gt_appr_all TYPE TABLE OF ty_appr.
