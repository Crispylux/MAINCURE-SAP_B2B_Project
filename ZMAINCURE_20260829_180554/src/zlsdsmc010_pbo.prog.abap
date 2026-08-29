*&---------------------------------------------------------------------*
*& Include          ZLSDSMC010_PBO
*&---------------------------------------------------------------------*

*===========================
*상단 툴바 제거 구현
*===========================
CLASS lcl_handler IMPLEMENTATION.
  METHOD on_toolbar.
    DATA: ls_toolbar TYPE stb_button.

  "구분선
    CLEAR ls_toolbar.
    ls_toolbar-butn_type = 3.      "separator
    APPEND ls_toolbar TO e_object->mt_toolbar.

    "SO생성완료 필터 버튼
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'FILT_OK'.
    ls_toolbar-icon       = icon_led_green.
    ls_toolbar-quickinfo  = 'SO생성완료'.
    ls_toolbar-text       = 'SO생성완료'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    "임시반려 필터 버튼
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'FILT_REJ'.
    ls_toolbar-icon       = icon_led_yellow.
    ls_toolbar-quickinfo  = '임시반려'.
    ls_toolbar-text       = '임시반려'.
    APPEND ls_toolbar TO e_object->mt_toolbar.

    "전체보기 버튼
    CLEAR ls_toolbar.
    ls_toolbar-function  = 'FILT_ALL'.
    ls_toolbar-icon       = icon_refresh.
    ls_toolbar-quickinfo  = '전체보기'.
    ls_toolbar-text       = '전체보기'.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.

  "사용자 커맨드 처리 로직!
  METHOD on_user_command.
    CASE e_ucomm.
      WHEN 'FILT_OK'.
        CLEAR gt_appr.
        LOOP AT gt_appr_all INTO gs_appr WHERE status = icon_led_green.
          APPEND gs_appr TO gt_appr.
        ENDLOOP.
        go_alv3->refresh_table_display( ).

      WHEN 'FILT_REJ'.
        CLEAR gt_appr.
        LOOP AT gt_appr_all INTO gs_appr WHERE status = icon_led_yellow.
          APPEND gs_appr TO gt_appr.
        ENDLOOP.
        go_alv3->refresh_table_display( ).

      WHEN 'FILT_ALL'.
        gt_appr = gt_appr_all.
        go_alv3->refresh_table_display( ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

*===========================ㅁ
*alv 더블클릭 전용 클래스
*===========================
CLASS lcl_alv_handler IMPLEMENTATION.
  METHOD handle_double_click.
    IF e_row IS INITIAL OR e_row <= 0.
      RETURN.
    ENDIF.
    READ TABLE gt_quot into gs_quot INDEX e_row.

    IF sy-subrc = 0.
      PERFORM fill_order_fields USING gs_quot.      "데이터 채운다!
      LEAVE TO SCREEN 0.
    ENDIF.
  ENDMETHOD.
ENDCLASS.



*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 0100(메인)
*&---------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.
  SET PF-STATUS 'STATUS_0100'.
  SET TITLEBAR 'TITLE_0100'.

*===========
*검색
*===========
"라디오버튼 초기설정
IF gv_first_0100 IS INITIAL.
  RADIO1 = 'X'.
  CLEAR RADIO2.
  gv_first_0100 = 'X'.
ENDIF.

*===========
*활성/비활성 (막기)
*===========
LOOP AT SCREEN.
  IF SCREEN-name = 'B1_FIELD1'.
    IF RADIO1 = 'X'.
      screen-input = 1.
    ELSE.
      SCREEN-input = 0.
    ENDIF.
    MODIFY SCREEN.
  ENDIF.

  IF screen-name = 'B1_FIELD2'.
      IF RADIO2 = 'X'.
        screen-input = 1.
      ELSE.
        screen-input = 0.
      ENDIF.
      MODIFY SCREEN.
  ENDIF.

  IF screen-name = 'B1_FIELD3' OR screen-name = 'B1_FIELD4'.
    screen-input = 0.
    MODIFY SCREEN.
  ENDIF.
ENDLOOP.

ENDMODULE.



*&---------------------------------------------------------------------*
*& Module STATUS_0102 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 0102(아이템 정보 입력 쪽!)
*&---------------------------------------------------------------------*
MODULE status_0102 OUTPUT.
  IF go_container_tree IS INITIAL.

    "왼쪽 트리 컨테이너
    CREATE OBJECT go_container_tree
      EXPORTING container_name = 'CC_TREE'.

    "트리 컨트롤 생성
    CREATE OBJECT go_tree
      EXPORTING parent = go_container_tree.


    "오른쪽 alv 컨테이너
    CREATE OBJECT go_container_alv
      EXPORTING container_name = 'CC_ALV'.

    "ALV GRID 생성
    CREATE OBJECT go_grid
      EXPORTING i_parent = go_container_alv.



    "트리 데이터 채우기(왼쪽)
    PERFORM FILL_TREE.
    "ALV 레이아웃, 필드카탈로그 세팅
    PERFORM init_alv_layout.

  ELSE.
      "이미 생성된 상태라면, 탭 재진입 시마다 데이터만 새로 조회해서 갱신!!
      PERFORM search_quotation1.
      go_grid->refresh_table_display( ).
  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 200 (견적정보 불러오기 팝업창!)
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'STATUS_0200'.
  SET TITLEBAR 'TITLE_0200'.


  " ALV Grid 컨테이너 생성
  IF go_container IS INITIAL.
    CREATE OBJECT go_container
      EXPORTING container_name = 'CC_QUOT_LIST'.  " Custom Control 이름

    CREATE OBJECT go_alv
      EXPORTING i_parent = go_container.

    PERFORM set_quot_fieldcat. "필드카탈로그 세팅
    PERFORM search_quotation.  "데이터 조회

    DATA(ls_layout_200) = VALUE lvc_s_layo( sel_mode = 'A' "행 단일 선택할 수 있게 만들기
                                            zebra = 'X' ). "테이블 줄무늬

    " 컬럼명 설정, 데이터 표시
    go_alv->set_table_for_first_display(
      EXPORTING is_layout       = ls_layout_200
      CHANGING  it_fieldcatalog = gt_quot_fcat  "필드카탈로그로 컬럼명 설정
                it_outtab       = gt_quot ).    "실제 테이블 데이터 넣기

  ENDIF.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0103 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 103 (주문정보확인 서브스크린)
*&---------------------------------------------------------------------*
MODULE status_0103 OUTPUT.
* SET PF-STATUS 'xxxxxxxx'.
* SET TITLEBAR 'xxx'.

 IF go_container1 IS INITIAL.
   CREATE OBJECT go_container1
    EXPORTING container_name = 'CC_CONFIRM'. "layout에서 확인

   CREATE OBJECT go_alv1
    EXPORTING i_parent = go_container1.

   PERFORM set_cc_confirm_fieldcat. "필드카탈로그 세팅
   PERFORM search_quotation1.   "데이터 조회


   "컬럼명 설정, 데이터 표시
   go_alv1->set_table_for_first_display(
    CHANGING  it_fieldcatalog  = gt_fcat1     "필드카탈로그로 컬럼명 설정
              it_outtab        = gt_data1 ).  "실제 테이블 데이터 넣기
 ELSE.
    "이미 생성된 상태라면, 탭 재진입 시마다 데이터만 새로 조회해서 갱신
    PERFORM search_quotation1.

    go_alv1->refresh_table_display( ).

 ENDIF.

 "총금액 계산
 S3_B4_F6 = S3_B4_F1 + S3_B4_F2 + S3_B4_F3 - S3_B4_F4.

*===========
*활성/비활성 (막기)
*===========
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'S3_B1_F1' OR 'S3_B1_F2' OR 'S3_B1_F3' OR 'S3_B1_F4' OR
           'S3_B1_F5' OR 'S3_B1_F6' OR 'S3_B1_F7' OR 'S3_B1_F8' OR
           'S3_B1_F9' OR 'S3_B4_F3' OR 'S3_B4_F4'.
        screen-input = 1.
      WHEN 'S3_B2_F1' OR 'S3_B2_F2' OR 'S3_B2_F3' OR 'S3_B2_F4' OR
           'S3_B2_F5' OR 'S3_B2_F6' OR 'S3_B2_F7' OR 'S3_B2_F8' OR
           'S3_B2_F9' OR
           'S3_B4_F1' OR 'S3_B4_F2' OR 'S3_B4_F5' OR 'S3_B4_F6'.
        screen-input = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_0201 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 201(주문승인/반려 팝업창)
*&---------------------------------------------------------------------*
MODULE status_0201 OUTPUT.
  SET PF-STATUS 'STATUS_0201'.
  SET TITLEBAR 'TITLE_0201'.

  IF go_container3 IS INITIAL.
    CREATE OBJECT go_container3
      EXPORTING container_name = 'CC_APPR_LIST'. "이름과 동일하게

    CREATE OBJECT go_alv3
      EXPORTING i_parent = go_container3.

     PERFORM set_appr_fieldcat.     "필드카탈로그 세팅
     PERFORM search_approval_list.   "데이터 조회

     DATA(ls_layout_201) = VALUE lvc_s_layo( sel_mode = 'A'
                                             zebra = 'X' ).

     "이벤트 핸들러
     CREATE OBJECT go_handler.
     SET HANDLER go_handler->on_toolbar      FOR go_alv3.
     SET HANDLER go_handler->on_user_command FOR go_alv3.

     "컬럼명 설정, 데이터 표시
     go_alv3->set_table_for_first_display(
      EXPORTING is_layout       = ls_layout_201
      CHANGING  it_fieldcatalog  = gt_appr_fcat     "필드카탈로그로 컬럼명 설정
                it_outtab        = gt_appr ).  "실제 테이블 데이터 넣기

     "아이콘 세팅
     CALL FUNCTION 'ICON_CREATE'
      EXPORTING
        NAME         = 'ICON_INFORMATION'
      IMPORTING
        RESULT       = B1_ICON1.

 IF sy-subrc <> 0.
 ENDIF.
 ELSE.
    "이미 생성된 상태라면, 탭 재진입 시마다 데이터만 새로 조회해서 갱신
    PERFORM search_approval_list.
    go_alv3->refresh_table_display( ).
 ENDIF.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Module STATUS_0101 OUTPUT
*&---------------------------------------------------------------------*
*& 스크린 101
*&---------------------------------------------------------------------*
MODULE status_0101 OUTPUT.

*===========
*활성/비활성 (막기)
*===========
  LOOP AT SCREEN.
    IF screen-name = 'S1_B3_FIELD3'.
      screen-input = 1.
    ELSE.
      CASE screen-name.
        WHEN 'S1_B1_FIELD1' OR 'S1_B1_FIELD2' OR 'S1_B1_FIELD3' OR
             'S1_B1_FIELD4' OR 'S1_B1_FIELD5' OR 'S1_B1_FIELD6' OR
             'S1_B2_FIELD1' OR 'S1_B2_FIELD2' OR 'S1_B2_FIELD3' OR
             'S1_B3_FIELD1' OR 'S1_B3_FIELD2'.
          screen-input = 0.
      ENDCASE.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

ENDMODULE.
