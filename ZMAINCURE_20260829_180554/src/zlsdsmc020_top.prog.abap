*&---------------------------------------------------------------------*
*& Include          ZLSDSMC020_TOP
*&---------------------------------------------------------------------*

DATA: B2_ICON1 TYPE ICONS-TEXT.

*========구조=========
TYPES: BEGIN OF ty_data1,
  dummy1 TYPE c LENGTH 1, "구조 나중에 채우기~(임시구조)
END OF ty_data1.

TYPES: BEGIN OF ty_data2,
  dummy2 TYPE c LENGTH 1, "구조 나중에 채우기~(임시구조)
END OF ty_data2.

TYPES: BEGIN OF ty_data3,
  dummy3 TYPE c LENGTH 1, "구조 나중에 채우기~(임시구조)
END OF ty_data3.
*====================


** Custom Container 객체 (CC_BOX1/2/3)
DATA:  go_container1 TYPE REF TO cl_gui_custom_container
      ,go_container2 TYPE REF TO cl_gui_custom_container
      ,go_container3 TYPE REF TO cl_gui_custom_container.


** ALV Grid 객체
DATA:  go_alv1 TYPE REF TO cl_gui_alv_grid
      ,go_alv2 TYPE REF TO cl_gui_alv_grid
      ,go_alv3 TYPE REF TO cl_gui_alv_grid.

** layout 구조체 변수
DATA:  gs_layo1 TYPE lvc_s_layo
      ,gs_layo2 TYPE lvc_s_layo
      ,gs_layo3 TYPE lvc_s_layo.


** 필드카탈로그
DATA:  gt_fcat1 TYPE lvc_t_fcat
      ,gs_fcat1 TYPE lvc_s_fcat
      ,gt_fcat2 TYPE lvc_t_fcat
      ,gs_fcat2 TYPE lvc_s_fcat
      ,gt_fcat3 TYPE lvc_t_fcat
      ,gs_fcat3 TYPE lvc_s_fcat.

** 인터널 테이블
DATA:  gt_data1 TYPE TABLE OF ty_data1
      ,gt_data2 TYPE TABLE OF ty_data2
      ,gt_data3 TYPE TABLE OF ty_data3.

*==================
* 출고문서헤더
*==================
TYPES: BEGIN OF ty_do_head,
         vbeln     TYPE ztsds00140-vbeln,     "출고문서번호
         vgbel     TYPE ztsds00150-vgbel,     "참조 판매오더번호
         kunnr     TYPE ztsds00140-kunnr,     "고객코드
         name1     TYPE ztsds00070-name1,     "고객명
         land1     TYPE ztsds00070-land1,     "국가코드
         wadat_ist TYPE ztsds00140-wadat_ist, "출하일
         fksta     TYPE ztsds00150-fksta,     "대금청구 상태
         b_bill    TYPE char20,               "대금청구서 생성 (텍스트)
         celltab   TYPE lvc_t_styl,           "대금청구서 생성 (버튼)
       END OF ty_do_head.

*==================
* 출고문서 아이템
*==================
TYPES: BEGIN OF ty_do_item,
         vbeln  TYPE ztsds00150-vbeln,   "출고문서
         posnr  TYPE ztsds00150-posnr,   "항목
         matnr  TYPE ztsds00150-matnr,   "자재번호
         arktx  TYPE ztsds00150-arktx,   "자재명
         lfimg  TYPE ztsds00150-lfimg,   "납품수량
         vrkme  TYPE ztsds00150-vrkme,   "단위
         netpr  TYPE ztsds00020-netpr,   "개당단가
         netwr  TYPE netwr,              "공급가액(순금액) = netpr * lfimg (계산값)
         waerk  TYPE ztsds00140-waerk,   "통화
       END OF ty_do_item.

DATA: gt_do_head TYPE TABLE OF ty_do_head,
      gt_do_item TYPE TABLE OF ty_do_item.


*==================
* 대금청구서 조회 (하단 ALV)
*==================
TYPES: BEGIN OF ty_bill,
         status TYPE icon_d,             "지불여부 (아이콘)
         vbeln  TYPE ztsds00030-vbeln,   "청구문서번호
         kunnr  TYPE ztsds00030-kunrg,   "고객코드(지급인)
         name1  TYPE ztsds00070-name1,   "고객명
         fkdat  TYPE ztsds00030-fkdat,   "청구일자
         land1  TYPE ztsds00030-land1,   "국가코드
         netwr  TYPE ztsds00030-netwr,   "순청구금액
         mwsbk  TYPE ztsds00030-mwsbk,   "총 부가세 금액
         waerk  TYPE ztsds00030-waerk,   "통화
       END OF ty_bill.

DATA: gt_bill TYPE TABLE OF ty_bill,
      gs_bill TYPE ty_bill.


*==================
* 범위 검색!(SELECT-OPTIONS 대응용)
*==================
DATA: gv_vbeln_lo TYPE ztsds00140-vbeln,     "출고문서 번호 from
      gv_vbeln_hi TYPE ztsds00140-vbeln,     "출고문서 번호 to
      gv_kunnr_lo TYPE ztsds00140-kunnr,     "고객 코드 from
      gv_kunnr_hi TYPE ztsds00140-kunnr,     "고객 코드 to
      gv_wadat_lo TYPE ztsds00140-wadat_ist, "출고일 from
      gv_wadat_hi TYPE ztsds00140-wadat_ist, "출고일 to
      gv_vgbel_lo TYPE ztsds00150-vgbel,     "판매오더 번호 from
      gv_vgbel_hi TYPE ztsds00150-vgbel.     "판매오더 번호 to


*==================
* 클릭 시 이벤트 핸들러 (헤더 -> 아이템 상세)
*==================
CLASS lcl_alv_handler DEFINITION.
  PUBLIC SECTION.
"----------
" 더블클릭
"----------
    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING e_row e_column.

"----------
" 그냥 클릭
"----------
    METHODS handle_button_click
      FOR EVENT button_click OF cl_gui_alv_grid
      IMPORTING es_row_no es_col_id.

ENDCLASS.

DATA: go_event_handler TYPE REF TO lcl_alv_handler.
DATA: gv_selected_vbeln TYPE ztsds00140-vbeln,  "현재 선택된 출고문서번호(더블클릭 대상)
      gv_popup_vbeln    TYPE ztsds00140-vbeln.



*==================
* 스크린 200 - 대금청구서 생성 (팝업창) 데이터 관련
*==================
DATA:
  field1       TYPE ztsds00140-vbeln,      "출고 문서 번호
  field2       TYPE ztsds00150-vgbel,      "판매 오더 번호

  b1_field1_1  TYPE ztsds00070-kunnr,      "지급인 코드
  b1_field1_2  TYPE ztsds00070-name1,      "지급인명
  b1_field2    TYPE char100,               "배송지 (이름+주소 합침)
  b1_field3    TYPE ztsds00070-land1,      "국가코드
  b1_field4    TYPE ztsds00130-bankn,      "계좌번호
  b1_field5    TYPE ztsds00090-smtp_addr,  "이메일 주소

  b2_field1    TYPE p LENGTH 9 DECIMALS 2, "총 순금액
  b2_field2    TYPE mwskz,                 "세금 코드
  b2_field3    TYPE p LENGTH 9 DECIMALS 2, "부가세 금액
  b2_field4    TYPE p LENGTH 9 DECIMALS 2, "배송비 (입력)
  b2_field5    TYPE p LENGTH 9 DECIMALS 2, "할인 금액 (입력)
  b2_field6_1  TYPE p LENGTH 9 DECIMALS 2, "총 청구금액
  b2_field6_2  TYPE ztsds00030-waerk.      "통화


*==================
* 스크린 100 - 범위 검색 (검색 기능)
*==================
DATA: b1_field1_100_1 TYPE ztsds00140-vbeln,     "출고문서 번호 from
      b1_field1_100_2 TYPE ztsds00140-vbeln,     "출고문서 번호 to

      b1_field2_1     TYPE ztsds00140-kunnr,     "고객 코드 from
      b1_field2_2     TYPE ztsds00140-kunnr,     "고객 코드 to

      b1_field3_1     TYPE ztsds00140-wadat_ist, "출고일 from
      b1_field3_2     TYPE ztsds00140-wadat_ist, "출고일 to

      b1_field4_1     TYPE ztsds00150-vgbel,     "판매오더 번호 from
      b1_field4_2     TYPE ztsds00150-vgbel.     "판매오더 번호 to
