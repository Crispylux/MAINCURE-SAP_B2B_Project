*&---------------------------------------------------------------------*
*& Include          ZLSDSMC020_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 100 (메인 스크린)
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

 SET PF-STATUS 'STATUS_0100'.
 SET TITLEBAR 'TITLE_0100'.


*======================================
* ALV GRID 컨테이너 생성 - 출고문서 헤더
*======================================
 IF go_container1 IS INITIAL.
   CREATE OBJECT go_container1
    EXPORTING container_name = 'CC_BOX1'.

   CREATE OBJECT go_alv1
    EXPORTING i_parent = go_container1.

   PERFORM set_ccbox1_fieldcat. "필드카탈로그 세팅

   gs_layo1-grid_title = '출고문서 헤더'. "제목
   gs_layo1-stylefname = 'CELLTAB'.    "대금청구서 버튼
   gs_layo1-zebra       = 'X'.

   "컬럼명 설정, 데이터 표시
   go_alv1->set_table_for_first_display(
    EXPORTING is_layout       = gs_layo1
    CHANGING  it_fieldcatalog  = gt_fcat1       "필드카탈로그로 컬럼명 설정
              it_outtab        = gt_do_head ).  "데이터

   "버튼 관련
   CREATE OBJECT go_event_handler.
   SET HANDLER go_event_handler->handle_double_click FOR go_alv1.
   SET HANDLER go_event_handler->handle_button_click FOR go_alv1.

 ENDIF.


*======================================
* ALV GRID 컨테이너 생성 - 출고문서 세부정보
*======================================
  IF go_container2 IS INITIAL.
   CREATE OBJECT go_container2
    EXPORTING container_name = 'CC_BOX2'.

   CREATE OBJECT go_alv2
    EXPORTING i_parent = go_container2.

   PERFORM set_ccbox2_fieldcat. "필드카탈로그 세팅
   PERFORM search_quotation2.   "데이터 조회

   gs_layo2-grid_title = '출고문서 세부정보'. "제목
   gs_layo2-zebra       = 'X'.

   "컬럼명 설정, 데이터 표시
   go_alv2->set_table_for_first_display(
    EXPORTING is_layout      = gs_layo2
    CHANGING  it_fieldcatalog = gt_fcat2     "필드카탈로그로 컬럼명 설정
              it_outtab       = gt_do_item ).  "데이터
 ENDIF.


*======================================
* ALV GRID 컨테이너 생성 - 대금청구서 조회
*======================================
  IF go_container3 IS INITIAL.
   CREATE OBJECT go_container3
    EXPORTING container_name = 'CC_BOX3'.

   CREATE OBJECT go_alv3
    EXPORTING i_parent = go_container3.

   gs_layo3-grid_title = '대금청구서 조회'. "제목
   gs_layo2-zebra       = 'X'.

   PERFORM set_ccbox3_fieldcat. "필드카탈로그 세팅
*   PERFORM search_quotation3.   "데이터 조회

   "컬럼명 설정, 데이터 표시
   go_alv3->set_table_for_first_display(
    EXPORTING is_layout      = gs_layo3
    CHANGING  it_fieldcatalog = gt_fcat3     "필드카탈로그로 컬럼명 설정
              it_outtab       = gt_bill ).  "데이터

 ENDIF.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module SET_ICON OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 100 - 아이콘
*&---------------------------------------------------------------------*
MODULE set_icon OUTPUT.
  CALL FUNCTION 'ICON_CREATE'
    EXPORTING
      NAME         = 'ICON_INFORMATION'
    IMPORTING
      RESULT       = B2_ICON1.

 IF sy-subrc <> 0.
 ENDIF.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 200
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
   SET PF-STATUS 'STATUS_0200'.
   SET TITLEBAR 'TITLE_0200'.

   IF field1 IS INITIAL OR
      field1 <> gv_popup_vbeln.
     PERFORM get_bill_popup_data USING gv_popup_vbeln.
   ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module SET_SCREEN_ATTR_0200 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 200 - 배송비/할인만 입력 가능, 나머지는 수정 불가
*&---------------------------------------------------------------------*
MODULE set_screen_attr_0200 OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'B2_FIELD4' OR      "배송비
       screen-name = 'B2_FIELD5'.        "할인금액
       screen-input = '1'.
    ELSE.
      screen-input = '0'.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDMODULE.
