*&---------------------------------------------------------------------*
*& Include          ZALVF
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form COMMON_ADD_FCAT
*&---------------------------------------------------------------------*
*& N01 : 필드 카탈로그에 속성을 하나씩 동적으로 추가하는 공통 엔진
*&---------------------------------------------------------------------*
*&  --> PV_MODE : 'S' (시작), ' ' (속성 추가), 'E' (마지막 속성 추가 및 반영)
*&  --> PV_NAME : 필드명 (시작일 때) 또는 LVC_S_FCAT의 구조체 필드명 (속성일 때)
*&  --> PV_VAL  : 속성에 대입할 값
*&  <-- CT_FCAT : 최종 반영할 필드 카탈로그 테이블
*&---------------------------------------------------------------------*
FORM zz_add_fcat USING pv_mode TYPE c
                           pv_name TYPE c
                           pv_val  TYPE any
                    CHANGING ct_fcat TYPE lvc_t_fcat.

  " 1) STATICS 변수는 서브루틴이 끝나도 이전 호출 때 채워둔 값이 그대로 보존됩니다!
  "    이 덕분에 글로벌 변수 선언 없이도 서브루틴 혼자서 값을 기억할 수 있습니다.
  STATICS: ls_fcat TYPE lvc_s_fcat.

  CASE pv_mode.
    WHEN 'S'. " 'S' (Start) : 새로운 컬럼 선언 시작
      CLEAR ls_fcat. " 새로운 컬럼을 시작하므로 이전 기억을 깨끗이 지웁니다.
      ls_fcat-fieldname = pv_name.

    WHEN ' ' OR 'E'. " ' ' / 'E' (End) : 현재 컬럼에 속성 부여
      " 정적으로 값이 살아있는 ls_fcat 구조체에서 동적으로 컴포넌트를 찾습니다.
      ASSIGN COMPONENT pv_name OF STRUCTURE ls_fcat TO FIELD-SYMBOL(<fsv_val>).
      IF sy-subrc = 0.
        <fsv_val> = pv_val.
      ENDIF.

      " 마지막 속성('E')일 때만 최종 조립 완료된 ls_fcat 한 줄을 테이블에 추가합니다.
      " (중복 데이터가 쌓이지 않고 정확히 1줄만 추가됩니다)
      IF pv_mode = 'E'.
        APPEND ls_fcat TO ct_fcat.
      ENDIF.
  ENDCASE.
ENDFORM.


*======================================================================*
* ALV 객체 동적 생성 엔진 (컨테이너 & 그리드)
*======================================================================*
" 영역 이름만 던져주면, 컨테이너와 그리드 객체를 알아서 메모리에 할당해 줍니다.
FORM zz_cre_alv USING pv_container_name TYPE c
                       CHANGING po_container TYPE REF TO cl_gui_custom_container
                                po_grid      TYPE REF TO cl_gui_alv_grid.
  " 컨테이너가 없을 때만 생성 (덤프 방지)
  IF po_container IS INITIAL.
    CREATE OBJECT po_container
      EXPORTING container_name = pv_container_name
      EXCEPTIONS OTHERS = 1.

    IF sy-subrc = 0.
      CREATE OBJECT po_grid
        EXPORTING i_parent = po_container
        EXCEPTIONS OTHERS = 1.
    ENDIF.
  ENDIF.
ENDFORM.


*======================================================================*
* 스크롤 고정 새로고침 엔진
*======================================================================*
" 그리드 변수가 1번이든 100번이든 던져만 주면 부드럽게 리프레시합니다.
FORM zz_chg_alv USING po_grid TYPE REF TO cl_gui_alv_grid.
  DATA: ls_stable TYPE lvc_s_stbl.

  IF po_grid IS BOUND.
    ls_stable-row = 'X'.
    ls_stable-col = 'X'.

    CALL METHOD po_grid->refresh_table_display
      EXPORTING
        is_stable      = ls_stable
        i_soft_refresh = 'X'
      EXCEPTIONS
        OTHERS         = 1.
  ENDIF.
ENDFORM.


*----------------------------------------------------------------------*
* 기본 exit.
* Function Type 이 'E' 인 사용자 명령은 0s_uc_exit 에서 처리한다.
*  이 모듈에서는 leave to screen 0을 통해 바로 나가게 되어 있는데
*  만일 변경 사항의 저장 여부 등을 확인해야 할 경우
*  sy_dynnr + '_' + sy_ucomm 서브루틴을 만들어서 처리한다.
*----------------------------------------------------------------------*
MODULE 0s_uc_exit INPUT.

  LEAVE TO SCREEN 0.

ENDMODULE.
