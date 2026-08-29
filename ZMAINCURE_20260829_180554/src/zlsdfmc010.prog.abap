*&---------------------------------------------------------------------*
* 모듈/서브모듈   : SD/SDF
* Program ID : ZLSDFMC010
* Desc       : 출고승인
* Transaction: ZLSDFMC010
* Creator    : SHAREDMAH64
* Create day  : 2026.05.20
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C?R Number
* New     2026.05.20    박규태              최초작성
* Mod01   2026.08.02    박규태(AI 보조)     출하/출고 로직 구현 (bludPrint.md 요청,
*                                          코드 상세 이유는 ZLSDFMC010_수정내역.md 참고)
*&---------------------------------------------------------------------*

REPORT zlsdfmc010.

INCLUDE zalvf. " 이건 ALV 그리기용이얌.

" 화면 PF-Status(2000/3000)에 등록된 함수코드와 반드시 동일해야 함 (zlsdfmc010.prog.xml의 CUA 참고)
CONSTANTS:
  zlef_seso TYPE syucomm VALUE 'SESO',  " 판매오더 조회
  zlef_rese TYPE syucomm VALUE 'RESE',  " 초기화
  zlef_crbi TYPE syucomm VALUE 'CRBI',  " 대금청구서 생성 (별도 화면으로 이동 - 이번 작업 범위 아님)
  zlef_crgi TYPE syucomm VALUE 'CRGI',  " 출하처리 (ALV 툴바 커스텀 버튼 - PF-Status에는 없음)
  zlef_crg2 TYPE syucomm VALUE 'CRG2'.  " 출하

TYPES: BEGIN OF ty_s_cond,
         vbeln_l TYPE vbak-vbeln, " 판매 오더 번호
         vbeln_h TYPE vbak-vbeln, " 판매 오더 번호

         kunnr_l TYPE vbak-kunnr, " 고객 코드
         kunnr_h TYPE vbak-kunnr, " 고객 코드

         vdatu_l TYPE ztsds00010-vdatu, " 배송 예정일
         vdatu_h TYPE ztsds00010-vdatu, " 배송 예정일

         c_no    TYPE xfeld,  " 일반 주문  "판매 오더 유형 auart
         c_qt    TYPE xfeld,  " 견적 주문
       END OF ty_s_cond.

TYPES: BEGIN OF ty_s_cond2,
         vbeln TYPE vbak-vbeln,     " 판매 오더 번호
         kunnr TYPE vbak-kunnr,     " 고객 코드
         name1 TYPE kna1-name1,     " 고객 이름
         adrnr TYPE kna1-adrnr,     " 배송지

         plant TYPE t001w-werks,    " 플랜트 코드
         vtext TYPE tvtwt-vtext,    " 플랜트명 (필드명은 VTEXT지만 화면 라벨은 '플랜트명')
         vdatu TYPE ztsds00010-vdatu, " 배송요청일
         bstdk TYPE vbak-bstdk,     " 출고일
       END OF ty_s_cond2.

DATA: gs_cond TYPE ty_s_cond.
DATA: gr_vbeln TYPE RANGE OF vbak-vbeln.
DATA: gr_kunnr TYPE RANGE OF vbak-kunnr.
DATA: gr_vdatu TYPE RANGE OF ztsds00010-vdatu.
DATA: gr_auart TYPE RANGE OF vbak-auart.

DATA: gv_all TYPE i.
DATA: gv_FIN TYPE i.
DATA: gv_POS TYPE i.
DATA: gv_YET TYPE i.

DATA: gs_cond2 TYPE ty_s_cond2.

" 판매오더 조회(2000) 화면에서 핫스팟으로 마지막으로 클릭한 판매오더 번호.
" '출하처리' 버튼(zz_exe_btn_crgi)이 어떤 오더를 대상으로 할지 이 값으로 판단한다.
DATA: gv_sel_vbeln TYPE vbak-vbeln.


" 인터널 테이블
DATA: gt_ALV010 TYPE TABLE OF zssdfmc011.
DATA: gt_ALV020 TYPE TABLE OF zssdfmc012.
DATA: gt_ALV020_t TYPE TABLE OF zssdfmc012
      WITH NON-UNIQUE SORTED KEY idx_vbeln COMPONENTS vbeln.
DATA: gt_ALV030 TYPE TABLE OF zssdfmc012.

" ALV 변수
DATA : go_cc2000_1 TYPE REF TO cl_gui_custom_container,
       go_av2000_1 TYPE REF TO cl_gui_alv_grid.
DATA : go_cc2000_2 TYPE REF TO cl_gui_custom_container,
       go_av2000_2 TYPE REF TO cl_gui_alv_grid.
DATA : go_cc3000_1 TYPE REF TO cl_gui_custom_container,
       go_av3000_1 TYPE REF TO cl_gui_alv_grid.

DATA: gs_layout_1 TYPE lvc_s_layo,  " layout
      gt_fcat_1   TYPE lvc_t_fcat.  " Field Catalog
DATA: gs_layout_2 TYPE lvc_s_layo,
      gt_fcat_2   TYPE lvc_t_fcat.
DATA: gs_layout_3 TYPE lvc_s_layo,
      gt_fcat_3   TYPE lvc_t_fcat.

" 3. 이벤트 핸들러 선언
CLASS lcl_event DEFINITION DEFERRED.
DATA: go_event TYPE REF TO lcl_event.

DATA: gv_flag_AV2000_1 TYPE char1.
DATA: gv_flag_AV2000_2 TYPE char1.
DATA: gv_flag_AV3000_1 TYPE char1.


*======================================================================*
* [3] 이벤트 핸들러 구현
*======================================================================*
CLASS lcl_event DEFINITION.
  PUBLIC SECTION.
    METHODS handle_hotspot_click
      FOR EVENT hotspot_click OF cl_gui_alv_grid
      IMPORTING e_row_id e_column_id es_row_no.

    " 1) 버튼을 툴바에 등록해 주는 메소드
    METHODS handle_toolbar
      FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING e_object e_interactive.

    " 2) 등록된 버튼의 클릭을 감지하는 메소드
    METHODS handle_user_command
      FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_event IMPLEMENTATION.
  METHOD handle_hotspot_click.
    " 핫스팟 클릭 시 특정 서브루틴으로 이동
    PERFORM zz_av2000_1_hotspot USING es_row_no-row_id e_column_id-fieldname.
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA: ls_button TYPE stb_button. " ALV 툴바 버튼용 표준 구조체

    " 1-1. 기존 버튼들과 내 버튼 사이에 구분선(Separator) 하나 넣기
    CLEAR ls_button.
    ls_button-butn_type = 3. " 3번은 구분선(세로선)을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.

    " 1-2. 나만의 커스텀 버튼 추가하기
    CLEAR ls_button.
    ls_button-function  = zlef_crgi. " 버튼의 고유 기능 코드 (PAI의 sy-ucomm 역할)
    ls_button-icon      = icon_transport.          " 버튼에 들어갈 아이콘 (예: @0Z@는 플러스/추가 모양)
    " ls_button-quickinfo = '송장 추가 등록'.   " 마우스 마우스오버 시 뜰 설명 문구
    ls_button-text      = '출하처리'.        " 버튼에 표기될 글자
    ls_button-disabled  = ''.              " 활성화 여부 (빈칸이면 활성화, 'X'이면 비활성화)
    ls_button-butn_type = 0.               " 0번은 일반적인 누르는 푸시 버튼을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-butn_type = 3. " 3번은 구분선(세로선)을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function  = 'X'. " 버튼의 고유 기능 코드 (PAI의 sy-ucomm 역할)
    "ls_button-icon      = ICON_TRANSPORT.          " 버튼에 들어갈 아이콘 (예: @0Z@는 플러스/추가 모양)
    " ls_button-quickinfo = '송장 추가 등록'.   " 마우스 마우스오버 시 뜰 설명 문구
    ls_button-text      = |전체 : { gv_all }개|.      " 버튼에 표기될 글자
    ls_button-disabled  = ''.              " 활성화 여부 (빈칸이면 활성화, 'X'이면 비활성화)
    ls_button-butn_type = 0.               " 0번은 일반적인 누르는 푸시 버튼을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function  = 'X'. " 버튼의 고유 기능 코드 (PAI의 sy-ucomm 역할)
    ls_button-icon      = icon_led_green.          " 버튼에 들어갈 아이콘 (예: @0Z@는 플러스/추가 모양)
    " ls_button-quickinfo = '송장 추가 등록'.   " 마우스 마우스오버 시 뜰 설명 문구
    ls_button-text      = |출고완료 : { gv_FIN }개|.      " 버튼에 표기될 글자
    ls_button-disabled  = ''.              " 활성화 여부 (빈칸이면 활성화, 'X'이면 비활성화)
    ls_button-butn_type = 0.               " 0번은 일반적인 누르는 푸시 버튼을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function  = 'X'. " 버튼의 고유 기능 코드 (PAI의 sy-ucomm 역할)
    ls_button-icon      = icon_led_yellow.          " 버튼에 들어갈 아이콘 (예: @0Z@는 플러스/추가 모양)
    " ls_button-quickinfo = '송장 추가 등록'.   " 마우스 마우스오버 시 뜰 설명 문구
    ls_button-text      = |출고가능 : { gv_POS }개|.      " 버튼에 표기될 글자
    ls_button-disabled  = ''.              " 활성화 여부 (빈칸이면 활성화, 'X'이면 비활성화)
    ls_button-butn_type = 0.               " 0번은 일반적인 누르는 푸시 버튼을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.

    CLEAR ls_button.
    ls_button-function  = 'X'. " 버튼의 고유 기능 코드 (PAI의 sy-ucomm 역할)
    ls_button-icon      = icon_led_inactive.          " 버튼에 들어갈 아이콘 (예: @0Z@는 플러스/추가 모양)
    " ls_button-quickinfo = '송장 추가 등록'.   " 마우스 마우스오버 시 뜰 설명 문구
    ls_button-text      = |자재이동전 : { gv_YET }개|.      " 버튼에 표기될 글자
    ls_button-disabled  = ''.              " 활성화 여부 (빈칸이면 활성화, 'X'이면 비활성화)
    ls_button-butn_type = 0.               " 0번은 일반적인 누르는 푸시 버튼을 의미합니다.
    APPEND ls_button TO e_object->mt_toolbar.
  ENDMETHOD.

  " 2) 버튼 클릭 제어 구현
  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN zlef_crgi.
        PERFORM zz_exe_btn_crgi.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  " 참고(SD 담당자 발표 영상, SYNC 6기 3반3조): 판매오더 유형 체크박스는
  " 기본값이 NO/QT 둘 다 체크(=전체 조회)된 상태로 시작함.
  gs_cond-c_no = 'X'.
  gs_cond-c_qt = 'X'.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  "  PERFORM 1000_onli.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM 1000_afte .


*&---------------------------------------------------------------------*
*& Form 1000_afte
*&---------------------------------------------------------------------*
FORM 1000_afte .

  CALL SCREEN 2000. " ALV가 있는 2000번 화면 호출

ENDFORM.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2000 INPUT.
  CASE sy-ucomm.
    WHEN zlef_seso.  " 판매오더 조회
      PERFORM zz_get_sel_so.
    WHEN zlef_rese.  " 초기화
      PERFORM zz_reset_selection.
    WHEN zlef_crbi.  " 대금청구서생성
      " '대금청구서 생성'은 별도 프로그램(ZLSDSMC020, [SD] 대금청구서 생성) 담당이라
      " 이 화면에서는 그 프로그램으로 이동만 시켜준다. ZLSDSMC020 자체 트랜잭션 코드는
      " 아직 없어 보여서(.tran.xml 미존재) SUBMIT으로 연결함.
      SUBMIT zlsdsmc020 AND RETURN.
  ENDCASE.
ENDMODULE.

*&---------------------------------------------------------------------*
*       2000_status
*----------------------------------------------------------------------*
MODULE 2000_status OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  '2000'.

  " 1. 객체 생성 및 이벤트 연결
  PERFORM zz_init_alv_2000.
  " 2. 카탈로그 및 레이아웃 설정
  PERFORM zz_set_alv_2000.
  " 3. 데이터 출력
  PERFORM zz_disp_alv_2000.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Form zz_init_alv_2000
*&---------------------------------------------------------------------*
FORM zz_init_alv_2000.
  " ★ 공통 엔진 사용: 영역 이름과 변수만 넘겨줍니다!
  PERFORM zz_cre_alv USING 'GV_CX2000_1'
                            CHANGING go_cc2000_1 go_av2000_1.
  PERFORM zz_cre_alv USING 'GV_CX2000_2'
                            CHANGING go_cc2000_2 go_av2000_2.

  " 이벤트 등록
  IF go_event IS INITIAL.
    CREATE OBJECT go_event.
  ENDIF.

  SET HANDLER go_event->handle_hotspot_click FOR go_av2000_1.

  SET HANDLER go_event->handle_toolbar FOR go_av2000_1.
  SET HANDLER go_event->handle_user_command FOR go_av2000_1.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_ALV_INFO
*&---------------------------------------------------------------------*
FORM zz_set_alv_2000.
  " 레이아웃 설정
  CLEAR gs_layout_1.
  gs_layout_1-zebra      = 'X'.
  gs_layout_1-grid_title = '판매오더 정보'.
  gs_layout_1-sel_mode   = 'A'.

  CLEAR gs_layout_2.
  gs_layout_2-zebra      = 'X'.
  gs_layout_2-grid_title = '판매오더 상세정보'.
  gs_layout_2-sel_mode   = 'A'.


  " ★ 공통 매크로 사용: 맨 뒤에 작업할 변수(gs_fcat, gt_fcat)를 지정합니다!
  CLEAR gt_fcat_1.
  " 1. 상태 아이콘 (SICON)
  PERFORM zz_add_fcat USING 'S' 'SICON'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '출고 상태'           CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 2. 총 릴리스 상태 텍스트 (WBSTK_TEXT)
  PERFORM zz_add_fcat USING 'S' 'WBSTK_TEXT' ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '출고상태내역'      CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 3. 판매 문서 번호 (VBELN) - HOTSPOT 추가
  PERFORM zz_add_fcat USING 'S' 'VBELN'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '판매오더 번호'   CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'HOTSPOT'    'X'              CHANGING gt_fcat_1. " 클릭 가능하게 설정
  PERFORM zz_add_fcat USING ' ' 'KEY'        'X'              CHANGING gt_fcat_1. " 파란색 강조 + 왼쪽 고정
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 4. 고객 번호 (KUNNR)
  PERFORM zz_add_fcat USING 'S' 'KUNNR'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '고객 코드'       CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 5. 고객명 (NAME1)
  PERFORM zz_add_fcat USING 'S' 'NAME1'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '고객명'         CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 6. 플랜트 (WERKS)
  PERFORM zz_add_fcat USING 'S' 'WERKS'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '플랜트 코드'         CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 7. 플랜트명 (WERKS_NAME1)
  PERFORM zz_add_fcat USING 'S' 'WERKS_NAME1' ''              CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '플랜트명'       CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 8. 판매 문서 유형 (AUART)
  PERFORM zz_add_fcat USING 'S' 'AUART'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '오더 유형'       CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 9. 납품처 (KUNNR_WE)
  PERFORM zz_add_fcat USING 'S' 'KUNNR_WE'   ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '배송지'         CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.

  " 10. 요청 납품일 (VDATU)
  PERFORM zz_add_fcat USING 'S' 'VDATU'      ''               CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '배송 요청일'     CHANGING gt_fcat_1.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_1.



  CLEAR gt_fcat_2.

  " 1. 판매 문서 번호 (VBELN)
  PERFORM zz_add_fcat USING 'S' 'VBELN'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '판매오더 번호'   CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 2. 항목 번호 (POSNR)
  PERFORM zz_add_fcat USING 'S' 'POSNR'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '아이템 번호'       CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 3. 자재 번호 (MATNR)
  PERFORM zz_add_fcat USING 'S' 'MATNR'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '자재번호'       CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 4. 자재 내역 (MAKTX)
  PERFORM zz_add_fcat USING 'S' 'MAKTX'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '자재명'       CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 5. 제품군 (SPART)
  PERFORM zz_add_fcat USING 'S' 'SPART'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '제품군'         CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 6. 제품군명 (VTEXT)
  PERFORM zz_add_fcat USING 'S' 'VTEXT'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '제품군명'       CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 7. 오더 수량 (KWMENG)
  PERFORM zz_add_fcat USING 'S' 'KWMENG'     ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '주문수량'       CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'QFIELDNAME' 'VRKME'          CHANGING gt_fcat_2. " 수량 단위 참조
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 8. 판매 단위 (VRKME)
  PERFORM zz_add_fcat USING 'S' 'VRKME'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '단위'           CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 9. 넷가 단가 (NETPR)
  PERFORM zz_add_fcat USING 'S' 'NETPR'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '단가'           CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'CFIELDNAME' 'WAERK'          CHANGING gt_fcat_2. " 통화 키 참조
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.

  " 10. 통화 (WAERK)
  PERFORM zz_add_fcat USING 'S' 'WAERK'      ''               CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '통화'           CHANGING gt_fcat_2.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_2.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM zz_disp_alv_2000.
  IF gv_flag_AV2000_1 IS INITIAL.
    CALL METHOD go_av2000_1->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout_1
      CHANGING
        it_outtab       = gt_ALV010
        it_fieldcatalog = gt_fcat_1
      EXCEPTIONS
        OTHERS          = 1.
    IF sy-subrc = 0.
      gv_flag_AV2000_1 = 'X'.
    ENDIF.
  ELSE.
    " ★ 공통 엔진 사용: 새로고침할 그리드 변수를 넘겨줍니다!
    PERFORM zz_chg_alv USING go_av2000_1.
  ENDIF.

  IF gv_flag_AV2000_2 IS INITIAL.
    CALL METHOD go_av2000_2->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout_2
      CHANGING
        it_outtab       = gt_ALV020
        it_fieldcatalog = gt_fcat_2
      EXCEPTIONS
        OTHERS          = 1.
    IF sy-subrc = 0.
      gv_flag_AV2000_2 = 'X'.
    ENDIF.
  ELSE.
    " ★ 공통 엔진 사용: 새로고침할 그리드 변수를 넘겨줍니다!
    PERFORM zz_chg_alv USING go_av2000_2.
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZZ_EXE_BTN_CRGI.
*&---------------------------------------------------------------------*
*& '출하처리' 툴바 버튼 처리: 아이템 정보를 먼저 확인(핫스팟 클릭)한
*& 판매오더만 대상으로, 이미 출고완료된 오더는 막고 3000 화면을 띄운다.
*& (2000 화면 안내문구 "이미 출고가 되었거나, 아이템 정보를 확인하지
*&  않은 경우 출고 불가합니다."에 대응하는 검증 로직)
*&---------------------------------------------------------------------*
FORM zz_exe_btn_crgi.

  DATA: lv_wbstk TYPE ztsds00140-wbstk,
        lv_found TYPE abap_bool.

  IF gv_sel_vbeln IS INITIAL.
    MESSAGE '판매오더 번호를 클릭하여 아이템 정보를 먼저 확인해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM zz_get_do_status USING gv_sel_vbeln CHANGING lv_wbstk lv_found.

  IF lv_found = abap_true AND lv_wbstk = 'C'.
    MESSAGE '이미 출고가 완료된 판매오더입니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM zz_fill_screen3000_data.

  CALL SCREEN 3000
      STARTING AT 10  5
      ENDING AT   137 25.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Module  3000_status  OUTPUT
*&---------------------------------------------------------------------*
MODULE 3000_status OUTPUT.

  SET PF-STATUS '3000'.
  SET TITLEBAR  '3000'.

  " 1. 객체 생성 및 이벤트 연결
  PERFORM zz_init_alv_3000.
  " 2. 카탈로그 및 레이아웃 설정
  PERFORM zz_set_alv_3000.
  " 3. 데이터 출력
  PERFORM zz_disp_alv_3000.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.
  CASE sy-ucomm.
    WHEN zlef_CRG2.  " 출하
      PERFORM zz_exe_shipment.
  ENDCASE.
ENDMODULE.


*&---------------------------------------------------------------------*
*& Form zz_init_alv_3000
*&---------------------------------------------------------------------*
FORM zz_init_alv_3000.
  PERFORM zz_cre_alv USING 'GV_CX3000_1'
                            CHANGING go_cc3000_1 go_av3000_1.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form SET_ALV_INFO
*&---------------------------------------------------------------------*
FORM zz_set_alv_3000.
  " 레이아웃 설정
  CLEAR gs_layout_3.
  gs_layout_3-zebra      = 'X'.
  gs_layout_3-grid_title = '판매오더 상세정보'.
  gs_layout_3-sel_mode   = 'A'.

  CLEAR gt_fcat_3.

  " 1. 판매 문서 번호 (VBELN)
  PERFORM zz_add_fcat USING 'S' 'VBELN'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '판매오더 번호'   CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 2. 항목 번호 (POSNR)
  PERFORM zz_add_fcat USING 'S' 'POSNR'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '아이템 번호'       CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 3. 자재 번호 (MATNR)
  PERFORM zz_add_fcat USING 'S' 'MATNR'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '자재번호'       CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 4. 자재 내역 (MAKTX)
  PERFORM zz_add_fcat USING 'S' 'MAKTX'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '자재명'       CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 5. 제품군 (SPART)
  PERFORM zz_add_fcat USING 'S' 'SPART'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '제품군'         CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 6. 제품군명 (VTEXT)
  PERFORM zz_add_fcat USING 'S' 'VTEXT'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '제품군명'       CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 7. 오더 수량 (KWMENG)
  PERFORM zz_add_fcat USING 'S' 'KWMENG'     ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '주문수량'       CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'QFIELDNAME' 'VRKME'          CHANGING gt_fcat_3. " 수량 단위 참조
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 8. 판매 단위 (VRKME)
  PERFORM zz_add_fcat USING 'S' 'VRKME'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '단위'           CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 9. 넷가 단가 (NETPR)
  PERFORM zz_add_fcat USING 'S' 'NETPR'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '단가'           CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'CFIELDNAME' 'WAERK'          CHANGING gt_fcat_3. " 통화 키 참조
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.

  " 10. 통화 (WAERK)
  PERFORM zz_add_fcat USING 'S' 'WAERK'      ''               CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING ' ' 'COLTEXT'    '통화'           CHANGING gt_fcat_3.
  PERFORM zz_add_fcat USING 'E' 'COL_OPT'    'A'              CHANGING gt_fcat_3.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
FORM zz_disp_alv_3000.

  IF gv_flag_AV3000_1 IS INITIAL.
    CALL METHOD go_av3000_1->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout_3
      CHANGING
        it_outtab       = gt_ALV030
        it_fieldcatalog = gt_fcat_3
      EXCEPTIONS
        OTHERS          = 1.
    IF sy-subrc = 0.
      gv_flag_AV3000_1 = 'X'.
    ENDIF.
  ELSE.
    " ★ 공통 엔진 사용: 새로고침할 그리드 변수를 넘겨줍니다!
    PERFORM zz_chg_alv USING go_av3000_1.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_av2000_1_hotspot
*&---------------------------------------------------------------------*
*& ALV 그리드 핫스팟 클릭 이벤트 처리
*&---------------------------------------------------------------------*
*& --> P_ROW_ID    : 클릭한 행 번호 (es_row_no-row_id)
*& --> P_FIELDNAME : 클릭한 필드명 (e_column_id-fieldname)
*&---------------------------------------------------------------------*
FORM zz_av2000_1_hotspot  USING pv_row_id    TYPE lvc_s_roid-row_id
                                pv_fieldname TYPE lvc_fname.

  READ TABLE gt_alv010 ASSIGNING FIELD-SYMBOL(<ls_alv010>) INDEX pv_row_id.
  IF sy-subrc = 0.
    CASE pv_fieldname.

    WHEN 'VBELN'.
      " '출하처리' 버튼이 이 오더를 대상으로 인식하도록 기억해둔다
      " (2000 화면 안내문구: "아이템 정보를 확인" = 이 핫스팟 클릭을 의미).
      gv_sel_vbeln = <ls_alv010>-vbeln.

      CLEAR gt_alv020.

      LOOP AT gt_alv020_t ASSIGNING FIELD-SYMBOL(<ls_alv020_t>)
        USING KEY idx_vbeln WHERE vbeln = <ls_alv010>-vbeln.

        APPEND INITIAL LINE TO gt_alv020
        ASSIGNING FIELD-SYMBOL(<LS_ALV020>).

        MOVE-CORRESPONDING <ls_alv020_t> TO <LS_ALV020>.

      ENDLOOP.

      PERFORM zz_chg_alv USING go_av2000_2.

    ENDCASE.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form ZZ_GET_SEL_SO
*&---------------------------------------------------------------------*
*& 조회 조건(gs_cond)을 판매오더 번호/고객코드/배송예정일 range와
*& 판매오더 유형(AUART) 필터로 변환한 뒤, SD 소관 테이블에서 직접
*& 조회하고 MM 마스터가 필요한 부분만 FM(ZZ_MM_GET_*)을 경유해서 채운다.
*&---------------------------------------------------------------------*
FORM ZZ_GET_SEL_SO.

  DATA: lt_head TYPE TABLE OF ztsds00010.

  PERFORM zz_build_ranges.

  CLEAR: gt_alv010, gt_alv020, gt_alv020_t, gt_alv030,
         gv_all, gv_FIN, gv_POS, gv_YET, gv_sel_vbeln.

  SELECT vbeln, kunnr, auart, vdatu
    FROM ztsds00010
    INTO CORRESPONDING FIELDS OF TABLE @lt_head
    WHERE vbeln IN @gr_vbeln
      AND kunnr IN @gr_kunnr
      AND vdatu IN @gr_vdatu
      AND auart IN @gr_auart.

  IF lt_head IS INITIAL.
    MESSAGE '조회된 판매오더가 없습니다.' TYPE 'S' DISPLAY LIKE 'W'.
    RETURN.
  ENDIF.

  MOVE-CORRESPONDING lt_head TO gt_alv010.

  SELECT vbeln, posnr, matnr, kwmeng, vrkme, netpr, spart, waerk
    FROM ztsds00020
    INTO CORRESPONDING FIELDS OF TABLE @gt_alv020_t
    FOR ALL ENTRIES IN @lt_head
    WHERE vbeln = @lt_head-vbeln.

  PERFORM zz_enrich_item.
  PERFORM zz_enrich_header.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_build_ranges
*&---------------------------------------------------------------------*
*& 2000 화면 조회조건(gs_cond) -> WHERE절용 range 테이블 변환.
*& 값을 안 채운 range는 비워두면 Open SQL "IN"이 아무 것도 매칭하지
*& 않으므로(=전체 조회가 아니라 0건 조회가 됨), 미입력 시에는 전체를
*& 매칭하는 와일드카드 행을 넣어준다.
*&---------------------------------------------------------------------*
FORM zz_build_ranges.
  CLEAR: gr_vbeln, gr_kunnr, gr_vdatu, gr_auart.

  IF gs_cond-vbeln_l IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                     option = COND #( WHEN gs_cond-vbeln_h IS NOT INITIAL THEN 'BT' ELSE 'EQ' )
                     low    = gs_cond-vbeln_l
                     high   = gs_cond-vbeln_h ) TO gr_vbeln.
  ELSE.
    APPEND VALUE #( sign = 'I' option = 'CP' low = '*' ) TO gr_vbeln.
  ENDIF.

  IF gs_cond-kunnr_l IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                     option = COND #( WHEN gs_cond-kunnr_h IS NOT INITIAL THEN 'BT' ELSE 'EQ' )
                     low    = gs_cond-kunnr_l
                     high   = gs_cond-kunnr_h ) TO gr_kunnr.
  ELSE.
    APPEND VALUE #( sign = 'I' option = 'CP' low = '*' ) TO gr_kunnr.
  ENDIF.

  IF gs_cond-vdatu_l IS NOT INITIAL.
    APPEND VALUE #( sign   = 'I'
                     option = COND #( WHEN gs_cond-vdatu_h IS NOT INITIAL THEN 'BT' ELSE 'EQ' )
                     low    = gs_cond-vdatu_l
                     high   = gs_cond-vdatu_h ) TO gr_vdatu.
  ELSE.
    APPEND VALUE #( sign = 'I' option = 'BT' low = '00000000' high = '99991231' ) TO gr_vdatu.
  ENDIF.

  " 판매오더 유형: NO(일반주문)/QT(견적주문) 중 하나만 체크했을 때만 필터링.
  " 둘 다 체크(기본값) 또는 둘 다 해제하면 전체 조회로 처리한다.
  IF gs_cond-c_no = 'X' AND gs_cond-c_qt IS INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'NO' ) TO gr_auart.
  ELSEIF gs_cond-c_qt = 'X' AND gs_cond-c_no IS INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = 'QT' ) TO gr_auart.
  ELSE.
    APPEND VALUE #( sign = 'I' option = 'CP' low = '*' ) TO gr_auart.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_get_do_status
*&---------------------------------------------------------------------*
*& 판매오더 번호(PV_SO_VBELN)를 기준으로 이미 연결된 출고문서(DO)가
*& 있는지/그 상태(WBSTK)가 뭔지 조회한다.
*& ZTSDS00140(DO 헤더)에는 원본 판매오더 참조 필드가 없고,
*& ZTSDS00150(DO 아이템)의 VGBEL에만 참조가 있어서 아이템 경유로 조인함.
*& (주의: ZTSDS00140-VBELN은 DO 자체 번호라서 판매오더 번호와 직접
*&  비교하면 안 됨 - 서로 다른 채번 체계라 우연히 겹치는 경우가 아니면
*&  절대 안 맞음. 처음엔 이걸 실수로 직접 비교해서 버그가 있었음.)
*&---------------------------------------------------------------------*
FORM zz_get_do_status USING    pv_so_vbeln TYPE vbak-vbeln
                       CHANGING pv_wbstk   TYPE ztsds00140-wbstk
                                pv_found   TYPE abap_bool.

  CLEAR: pv_wbstk, pv_found.

  SELECT SINGLE likp~wbstk
    FROM ztsds00150 AS lips
    INNER JOIN ztsds00140 AS likp ON likp~vbeln = lips~vbeln
    INTO @pv_wbstk
    WHERE lips~vgbel = @pv_so_vbeln.

  IF sy-subrc = 0.
    pv_found = abap_true.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_enrich_item
*&---------------------------------------------------------------------*
*& gt_alv020_t(아이템 리스트)에 화면 표시용 자재명/제품군명을 채운다.
*& 자재 마스터는 MM 소관이라 직접 SELECT 하지 않고 FM(ZZ_MM_GET_MATERIAL_DETAIL)
*& 경유 - '자재, 제품 정보 관련 FM' 요청서에 명시된 SD-MM 경계를 지킨다.
*& 제품군명은 SD 소관 테이블(ZTSDS00120)이라 직접 조회한다.
*&---------------------------------------------------------------------*
FORM zz_enrich_item.
  DATA: lv_status  TYPE statu,
        lv_message TYPE char255,
        lv_matkl   TYPE matkl,
        lv_wgbez   TYPE wgbez.

  LOOP AT gt_alv020_t ASSIGNING FIELD-SYMBOL(<ls_item>).

    CLEAR: lv_status, lv_message, lv_matkl, lv_wgbez.

    CALL FUNCTION 'ZZ_MM_GET_MATERIAL_DETAIL'
      EXPORTING
        i_matnr   = <ls_item>-matnr
      IMPORTING
        e_maktx   = <ls_item>-maktx
        e_matkl   = lv_matkl
        e_wgbez   = lv_wgbez
        e_status  = lv_status
        e_message = lv_message.

    IF <ls_item>-spart IS NOT INITIAL.
      SELECT SINGLE vtext
        FROM ztsds00120
        INTO @<ls_item>-vtext
        WHERE spras = @sy-langu
          AND spart = @<ls_item>-spart.
    ENDIF.

  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_enrich_header
*&---------------------------------------------------------------------*
*& gt_alv010(판매오더 헤더 리스트)에 고객명/배송지/플랜트(명)/출고상태
*& 아이콘텍스트를 채우고, 툴바 카운트(gv_all/FIN/POS/YET)를 집계한다.
*&---------------------------------------------------------------------*
FORM zz_enrich_header.
  DATA: lv_status   TYPE statu,
        lv_message  TYPE char255,
        lv_werks    TYPE werks_d,
        lt_werks    TYPE TABLE OF werks_d,
        lv_kunnr_we TYPE kunnr,
        lv_wbstk    TYPE ztsds00140-wbstk,
        lv_found    TYPE abap_bool.

  LOOP AT gt_alv010 ASSIGNING FIELD-SYMBOL(<ls_head>).

    " 1) 고객명 - SD 소관 테이블(ZTSDS00070)에서 직접 조회
    SELECT SINGLE name1
      FROM ztsds00070
      INTO @<ls_head>-name1
      WHERE kunnr = @<ls_head>-kunnr.

    " 2) 배송지(납품처) - Ship-to 파트너('WE') 우선, 없으면 매출처 그대로 사용
    CLEAR lv_kunnr_we.
    SELECT SINGLE kunnr
      FROM ztsds00190
      INTO @lv_kunnr_we
      WHERE vbeln = @<ls_head>-vbeln
        AND parvw = 'WE'.
    IF sy-subrc = 0.
      <ls_head>-kunnr_we = lv_kunnr_we.
    ELSE.
      <ls_head>-kunnr_we = <ls_head>-kunnr.
    ENDIF.

    " 3) 플랜트 - 오더의 최선순위(최소 아이템번호) 아이템 플랜트를 대표값으로 사용.
    "    (판매오더 헤더에는 플랜트가 없고 아이템 레벨에만 있음 - 테이블 정의서 참고)
    "    ※ SELECT SINGLE ... ORDER BY는 이 시스템에서 구문 오류가 나서
    "       내부테이블에 담아 첫 줄만 꺼내는 방식으로 대체함.
    CLEAR: lv_werks, lt_werks.
    SELECT werks
      FROM ztsds00020
      INTO TABLE @lt_werks
      WHERE vbeln = @<ls_head>-vbeln
      ORDER BY posnr ASCENDING.

    READ TABLE lt_werks INTO lv_werks INDEX 1.
    IF sy-subrc = 0.
      <ls_head>-werks = lv_werks.

      " 플랜트 마스터(T001W)는 MM 소관이라 직접 조회 금지 - FM 경유
      CALL FUNCTION 'ZZ_MM_GET_PLANT_INFO'
        EXPORTING
          i_werks   = lv_werks
        IMPORTING
          e_name1   = <ls_head>-werks_name1
          e_status  = lv_status
          e_message = lv_message.
    ENDIF.

    " 4) 출고 상태 - 이 판매오더에 연결된 DO(ZTSDS00150-VGBEL 경유)가 있는지/WBSTK로 판단
    PERFORM zz_get_do_status USING <ls_head>-vbeln CHANGING lv_wbstk lv_found.

    IF lv_found = abap_true AND lv_wbstk = 'C'.
      <ls_head>-sicon      = icon_led_green.
      <ls_head>-wbstk_text = '출고완료'.
      gv_FIN = gv_FIN + 1.
    ELSEIF lv_found = abap_true.
      <ls_head>-sicon      = icon_led_yellow.
      <ls_head>-wbstk_text = '출고가능'.
      gv_POS = gv_POS + 1.
    ELSE.
      <ls_head>-sicon      = icon_led_inactive.
      <ls_head>-wbstk_text = '자재이동전'.
      gv_YET = gv_YET + 1.
    ENDIF.

    gv_all = gv_all + 1.

  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_reset_selection
*&---------------------------------------------------------------------*
*& '초기화' 버튼: 조회조건과 조회 결과(양쪽 ALV)를 모두 비운다.
*&---------------------------------------------------------------------*
FORM zz_reset_selection.
  CLEAR: gs_cond, gt_alv010, gt_alv020, gt_alv020_t, gt_alv030,
         gv_all, gv_FIN, gv_POS, gv_YET, gv_sel_vbeln.

  gs_cond-c_no = 'X'.
  gs_cond-c_qt = 'X'.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_fill_screen3000_data
*&---------------------------------------------------------------------*
*& '출하처리' 버튼으로 3000 팝업을 열기 전, 선택된 판매오더(gv_sel_vbeln)
*& 하나에 대한 헤더 정보(gs_cond2)와 아이템 리스트(gt_alv030)를 채운다.
*& (기존 코드는 gt_alv020_t 전체를 그대로 gt_alv030에 복사해서 다른
*&  판매오더의 아이템까지 섞여버리는 문제가 있었음 - 이 FORM으로 교체)
*&---------------------------------------------------------------------*
FORM zz_fill_screen3000_data.
  DATA: lv_status  TYPE char1,
        lv_message TYPE bapi_msg.

  CLEAR: gs_cond2, gt_alv030.

  READ TABLE gt_alv010 ASSIGNING FIELD-SYMBOL(<ls_head>) WITH KEY vbeln = gv_sel_vbeln.
  IF sy-subrc <> 0.
    RETURN.
  ENDIF.

  gs_cond2-vbeln = <ls_head>-vbeln.
  gs_cond2-kunnr = <ls_head>-kunnr.
  gs_cond2-plant = <ls_head>-werks.
  gs_cond2-vtext = <ls_head>-werks_name1.  " 필드명은 VTEXT지만 화면상 '플랜트명' 라벨에 바인딩됨
  gs_cond2-vdatu = <ls_head>-vdatu.

  CALL FUNCTION 'ZZ_GET_CUSTOMER_NAME'
    EXPORTING
      iv_kunnr   = <ls_head>-kunnr
    IMPORTING
      ev_name1   = gs_cond2-name1
      ev_status  = lv_status
      ev_message = lv_message.

  " 배송지 주소번호 - Ship-to 파트너('WE') 우선, 없으면 고객 자신의 주소
  SELECT SINGLE adrnr
    FROM ztsds00190
    INTO @gs_cond2-adrnr
    WHERE vbeln = @gv_sel_vbeln
      AND parvw = 'WE'.
  IF sy-subrc <> 0.
    SELECT SINGLE adrnr
      FROM ztsds00070
      INTO @gs_cond2-adrnr
      WHERE kunnr = @<ls_head>-kunnr.
  ENDIF.

  LOOP AT gt_alv020_t ASSIGNING FIELD-SYMBOL(<ls_item>)
    USING KEY idx_vbeln WHERE vbeln = gv_sel_vbeln.

    APPEND INITIAL LINE TO gt_alv030 ASSIGNING FIELD-SYMBOL(<ls_new>).
    MOVE-CORRESPONDING <ls_item> TO <ls_new>.

  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form zz_exe_shipment
*&---------------------------------------------------------------------*
*& '출하'(CRG2) 버튼: 선택된 판매오더에 대해 출고문서(DO) 헤더/아이템
*& (ZTSDS00140/ZTSDS00150)을 생성한다.
*&
*& 범위 참고(레퍼런스 영상 "이때 여신점검이 이뤄지고, 출고문서, 자재문서,
*& 회계전표 데이터 생성"): 여신점검/자재문서(MM)/회계전표(FI) 생성은
*& 이번 작업 범위에서 제외했음 - 이유는 ZLSDFMC010_수정내역.md 참고.
*&---------------------------------------------------------------------*
FORM zz_exe_shipment.
  DATA: ls_head     TYPE ztsds00010,
        ls_likp     TYPE ztsds00140,
        ls_lips     TYPE ztsds00150,
        lt_lips     TYPE TABLE OF ztsds00150,
        lv_do_vbeln TYPE ztsds00140-vbeln,
        lv_wbstk    TYPE ztsds00140-wbstk,
        lv_number   TYPE nrlevel,
        lv_matkl    TYPE ztsds00150-matkl,
        lv_wgbez    TYPE wgbez,
        lv_status   TYPE statu,
        lv_message  TYPE char255,
        lv_found    TYPE abap_bool.

  IF gs_cond2-vbeln IS INITIAL.
    MESSAGE '먼저 출고할 판매오더를 선택해주세요.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 팝업이 떠 있는 동안 다른 세션에서 상태가 바뀌었을 가능성 대비, 재확인
  PERFORM zz_get_do_status USING gs_cond2-vbeln CHANGING lv_wbstk lv_found.

  IF lv_found = abap_true AND lv_wbstk = 'C'.
    MESSAGE '이미 출고가 완료된 판매오더입니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  IF gt_alv030 IS INITIAL.
    MESSAGE '출고할 아이템 정보가 없습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SELECT SINGLE *
    FROM ztsds00010
    INTO @ls_head
    WHERE vbeln = @gs_cond2-vbeln.

  " 출고문서 번호 채번 (SNRO에 번호범위 개체 ZSD_LIKP 생성 필요 - md 참고)
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZSD_LIKP'
      quantity    = 1
    IMPORTING
      number      = lv_number
    EXCEPTIONS
      OTHERS      = 8.

  IF sy-subrc <> 0.
    MESSAGE '출고문서 번호 채번에 실패했습니다. (SNRO에 ZSD_LIKP 번호범위를 먼저 생성해주세요)' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " NUMBER_GET_NEXT의 NUMBER는 CHAR20 통짜 필드에 번호가 오른쪽 정렬로 들어있음
  " (앞쪽은 0으로 채워진 padding). VBELN(10자리)은 뒤쪽 10자리만 잘라와야 함 -
  " 처음엔 그냥 통째로 대입해서 앞쪽 padding 0만 들어가는 버그가 있었음.
  lv_do_vbeln = lv_number+10(10).

  CLEAR ls_likp.
  ls_likp-vbeln     = lv_do_vbeln.
  ls_likp-ernam     = sy-uname.
  ls_likp-erdat     = sy-datum.
  ls_likp-kunnr     = gs_cond2-kunnr.
  ls_likp-wadat     = sy-datum.
  ls_likp-wadat_ist = sy-datum.
  ls_likp-lfdat     = gs_cond2-vdatu.
  ls_likp-kostk     = 'C'.  " 이번 화면에서는 피킹/패킹/GI를 '출하' 한 번의 조작으로 처리
  ls_likp-pkstk     = 'C'.
  ls_likp-wbstk     = 'C'.
  ls_likp-gbstk     = 'C'.
  ls_likp-waerk     = ls_head-waerk.

  CLEAR lt_lips.
  LOOP AT gt_alv030 ASSIGNING FIELD-SYMBOL(<ls_item>).

    CLEAR ls_lips.
    ls_lips-vbeln = lv_do_vbeln.
    ls_lips-posnr = <ls_item>-posnr.
    ls_lips-matnr = <ls_item>-matnr.
    ls_lips-arktx = <ls_item>-maktx.
    ls_lips-lfimg = <ls_item>-kwmeng.
    ls_lips-pikmg = <ls_item>-kwmeng.
    ls_lips-vrkme = <ls_item>-vrkme.
    ls_lips-meins = <ls_item>-vrkme.
    ls_lips-vgbel = gs_cond2-vbeln.
    ls_lips-vgpos = <ls_item>-posnr.
    ls_lips-vgtyp = 'C'.
    ls_lips-kosta = 'C'.
    ls_lips-wbsta = 'C'.
    ls_lips-fksta = 'A'.  " 대금청구는 별도 화면 담당이라 '미처리' 상태로 남겨둠
    ls_lips-netwr = <ls_item>-kwmeng * <ls_item>-netpr.
    ls_lips-waerk = <ls_item>-waerk.

    " 플랜트/저장위치는 판매오더 아이템 원본에서 다시 조회 (ALV 구조에는 없는 필드)
    SELECT SINGLE werks, lgort
      FROM ztsds00020
      INTO (@ls_lips-werks, @ls_lips-lgort)
      WHERE vbeln = @gs_cond2-vbeln
        AND posnr = @<ls_item>-posnr.

    " 자재그룹(MATKL)은 SPART(제품군)와 다른 값이라 MM 마스터에서 FM으로 다시 조회
    CLEAR: lv_matkl, lv_wgbez.
    CALL FUNCTION 'ZZ_MM_GET_MATERIAL_DETAIL'
      EXPORTING
        i_matnr   = <ls_item>-matnr
      IMPORTING
        e_matkl   = lv_matkl
        e_wgbez   = lv_wgbez
        e_status  = lv_status
        e_message = lv_message.
    ls_lips-matkl = lv_matkl.

    APPEND ls_lips TO lt_lips.

  ENDLOOP.

  INSERT ztsds00140 FROM @ls_likp.
  IF sy-subrc <> 0.
    ROLLBACK WORK.
    MESSAGE '출고문서 헤더 생성에 실패했습니다.' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 배열 INSERT는 키 중복 시 덤프(CX_SY_OPEN_SQL_DB)가 나서, 한 줄씩 넣어
  " sy-subrc로 제어 가능하게 처리한다.
  LOOP AT lt_lips INTO ls_lips.
    INSERT ztsds00150 FROM @ls_lips.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE |출고문서 아이템 생성에 실패했습니다. (판매오더 아이템 { ls_lips-posnr })| TYPE 'S' DISPLAY LIKE 'E'.
      RETURN.
    ENDIF.
  ENDLOOP.

  COMMIT WORK AND WAIT.

  MESSAGE |{ lv_do_vbeln }번 출고문서가 생성되었습니다.| TYPE 'S'.

  " 2000 화면 목록/카운트를 최신 상태로 갱신.
  " 3000 팝업(모달 다이얼로그)을 닫을 때 2000 화면 PBO가 다시 돌긴 하지만,
  " 그 시점에 ALV 컨트롤이 프론트엔드에 실제 리페인트를 안 보내는 경우가 있어서
  " (테스트로 확인됨: 수동 재조회하면 바뀌는데 자동으로는 안 바뀜) 팝업을 닫기
  " 전에 여기서 직접 그리드를 다시 그리고 강제로 화면에 반영(flush)시킨다.
  PERFORM zz_get_sel_so.

  IF go_av2000_1 IS BOUND.
    CALL METHOD go_av2000_1->set_table_for_first_display
      EXPORTING
        is_layout       = gs_layout_1
      CHANGING
        it_outtab       = gt_alv010
        it_fieldcatalog = gt_fcat_1
      EXCEPTIONS
        OTHERS          = 1.
    CALL METHOD cl_gui_cfw=>flush.
  ENDIF.

  LEAVE TO SCREEN 0.
ENDFORM.
