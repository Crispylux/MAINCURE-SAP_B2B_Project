*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_F01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.16    류재열              최초작성
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*& Form zz_exe_get_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_get_data.

  DATA: lt_180 TYPE TABLE OF ztmmg00180,
        lt_200 TYPE TABLE OF ztmmg00200.

  REFRESH: gt_170,
           lt_180,
           lt_200.

  SELECT *
    FROM ztmmg00170
    INTO CORRESPONDING FIELDS OF TABLE @gt_170
    WHERE ebeln IN @so_ebeln
      AND bedat IN @so_bedat.

  IF gt_170 IS INITIAL.
    RETURN.
  ENDIF.

  SELECT *
    FROM ztmmg00180
    INTO TABLE @lt_180
    FOR ALL ENTRIES IN @gt_170
    WHERE ebeln = @gt_170-ebeln.

  SELECT *
    FROM ztmmg00200
    INTO TABLE @lt_200
    FOR ALL ENTRIES IN @gt_170
    WHERE ebeln = @gt_170-ebeln.


  LOOP AT gt_170 ASSIGNING FIELD-SYMBOL(<ls_170>).

    " 아직 변경 안 한 구매오더
    IF <ls_170>-statu IS INITIAL.
      <ls_170>-light = '2'.       " 노랑
      CONTINUE.
    ENDIF.


    DATA(lv_check)   = abap_true.
    DATA(lv_cnt_180) = 0.
    DATA(lv_cnt_200) = 0.


    " 검수 항목 건수
    LOOP AT lt_180 ASSIGNING FIELD-SYMBOL(<ls_180_cnt>)
      WHERE ebeln = <ls_170>-ebeln.

      lv_cnt_180 = lv_cnt_180 + 1.

    ENDLOOP.


    " 송장 항목 건수
    LOOP AT lt_200 ASSIGNING FIELD-SYMBOL(<ls_200_cnt>)
      WHERE ebeln = <ls_170>-ebeln.

      lv_cnt_200 = lv_cnt_200 + 1.

    ENDLOOP.


    " 건수 불일치
    IF lv_cnt_180 <> lv_cnt_200.

      <ls_170>-light = '1'.       " 빨강
      CONTINUE.

    ENDIF.


    " 품목별 수량 비교
    LOOP AT lt_180 ASSIGNING FIELD-SYMBOL(<ls_180>)
      WHERE ebeln = <ls_170>-ebeln.

      READ TABLE lt_200 ASSIGNING FIELD-SYMBOL(<ls_200>)
        WITH KEY ebeln = <ls_180>-ebeln
                 ebelp = <ls_180>-ebelp.

      IF sy-subrc <> 0.
        lv_check = abap_false.
        EXIT.
      ENDIF.

      IF <ls_180>-menge <> <ls_200>-menge.
        lv_check = abap_false.
        EXIT.
      ENDIF.

    ENDLOOP.


    IF lv_check = abap_true.
      <ls_170>-light = '3'.       " 초록
    ELSE.
      <ls_170>-light = '1'.       " 빨강
    ENDIF.

  ENDLOOP.

ENDFORM.
*FORM zz_exe_get_data.
*  REFRESH gt_170.
*  SELECT mandt, ebeln, bsart, bedat, bukrs,
*       ekorg, ekgrp, lifnr, waers, zterm
*  FROM ztmmg00170
*  INTO CORRESPONDING FIELDS OF TABLE @gt_170
*  WHERE ebeln IN @so_ebeln
*    AND bedat IN @so_bedat.
*ENDFORM.
*FORM zz_exe_get_data.
*
*  DATA: lt_180 TYPE TABLE OF ztmmg00180,
*        lt_200 TYPE TABLE OF ztmmg00200.
*
*  REFRESH: gt_170,
*           lt_180,
*           lt_200.
*
*
*  ----------------------------------------------------
*   1. 구매오더 헤더 조회
*  ----------------------------------------------------
*  SELECT mandt,
*         ebeln,
*         bsart,
*         bedat,
*         bukrs,
*         ekorg,
*         ekgrp,
*         lifnr,
*         waers,
*         zterm
*    FROM ztmmg00170
*    INTO CORRESPONDING FIELDS OF TABLE @gt_170
*    WHERE ebeln IN @so_ebeln
*      AND bedat IN @so_bedat.
*
*  IF gt_170 IS INITIAL.
*    RETURN.
*  ENDIF.
*
*
*  ----------------------------------------------------
*   2. 해당 구매오더의 검수 항목 전체 조회
*  ----------------------------------------------------
*  SELECT *
*    FROM ztmmg00180
*    INTO TABLE @lt_180
*    FOR ALL ENTRIES IN @gt_170
*    WHERE ebeln = @gt_170-ebeln.
*
*
*  ----------------------------------------------------
*   3. 해당 구매오더의 송장 항목 전체 조회
*  ----------------------------------------------------
*  SELECT *
*    FROM ztmmg00200
*    INTO TABLE @lt_200
*    FOR ALL ENTRIES IN @gt_170
*    WHERE ebeln = @gt_170-ebeln.
*
*
*  ----------------------------------------------------
*   4. 구매오더별 신호등 판단
*  ----------------------------------------------------
*  LOOP AT gt_170 ASSIGNING FIELD-SYMBOL(<ls_170>).
*
*    DATA(lv_check)   = abap_true.
*    DATA(lv_cnt_180) = 0.
*    DATA(lv_cnt_200) = 0.
*
*
*    --------------------------------------------------
*     검수 항목 건수
*    --------------------------------------------------
*    LOOP AT lt_180 ASSIGNING FIELD-SYMBOL(<ls_180_cnt>)
*      WHERE ebeln = <ls_170>-ebeln.
*
*      lv_cnt_180 = lv_cnt_180 + 1.
*
*    ENDLOOP.
*
*
*    --------------------------------------------------
*     송장 항목 건수
*    --------------------------------------------------
*    LOOP AT lt_200 ASSIGNING FIELD-SYMBOL(<ls_200_cnt>)
*      WHERE ebeln = <ls_170>-ebeln.
*
*      lv_cnt_200 = lv_cnt_200 + 1.
*
*    ENDLOOP.
*
*
*    --------------------------------------------------
*     송장 자체가 아직 없으면 노랑
*    --------------------------------------------------
*    IF lv_cnt_200 = 0.
*
*      <ls_170>-light = '2'.       " 노랑 : 미진행
*      CONTINUE.
*
*    ENDIF.
*
*
*    --------------------------------------------------
*     건수가 다르면 바로 빨강
*    --------------------------------------------------
*    IF lv_cnt_180 <> lv_cnt_200.
*
*      <ls_170>-light = '1'.       " 빨강 : 불일치
*      CONTINUE.
*
*    ENDIF.
*
*
*    --------------------------------------------------
*     건수가 같으면 Item별 수량 비교
*    --------------------------------------------------
*    LOOP AT lt_180 ASSIGNING FIELD-SYMBOL(<ls_180>)
*      WHERE ebeln = <ls_170>-ebeln.
*
*      READ TABLE lt_200 ASSIGNING FIELD-SYMBOL(<ls_200>)
*        WITH KEY ebeln = <ls_180>-ebeln
*                 ebelp = <ls_180>-ebelp.
*
*       대응되는 송장 Item 없음
*      IF sy-subrc <> 0.
*        lv_check = abap_false.
*        EXIT.
*      ENDIF.
*
*
*       수량 불일치
*      IF <ls_180>-menge <> <ls_200>-menge.
*        lv_check = abap_false.
*        EXIT.
*      ENDIF.
*
*    ENDLOOP.
*
*
*    --------------------------------------------------
*     최종 결과
*    --------------------------------------------------
*    IF lv_check = abap_true.
*      <ls_170>-light = '3'.       " 초록 : 완전 일치
*    ELSE.
*      <ls_170>-light = '1'.       " 빨강 : 불일치
*    ENDIF.
*
*  ENDLOOP.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_exe_free_objects
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_free_objects .
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
*& Form zz_exe_create_alv
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_create_alv .

  PERFORM zz_set_toolbar_exclude.
  PERFORM zz_set_fieldcatalog.
  "오브젝트 생성
  "제일 위에 오브젝트
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.
  "왼쪽 아래
  CREATE OBJECT go_container2
    EXPORTING
      container_name = 'CC_ALV_002'.


  CREATE OBJECT go_grid2
    EXPORTING
      i_parent = go_container2.
  "오른쪽 아래
  CREATE OBJECT go_container3
    EXPORTING
      container_name = 'CC_ALV_003'.

  CREATE OBJECT go_grid3
    EXPORTING
      i_parent = go_container3.
  "클래스 추가
  CREATE OBJECT go_event_receiver.
  SET HANDLER go_event_receiver->handle_double_click FOR go_grid.

  PERFORM zz_set_alv_grid1.
  PERFORM zz_set_alv_grid2.
  PERFORM zz_set_alv_grid3.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu1 .

  CLEAR gs_layout1.
  gs_layout1-excp_fname = 'LIGHT'.
  gs_layout1-excp_led   = abap_true.
  gs_layout1-grid_title = '송장 리스트'.
  gs_layout1-zebra      = abap_true.       " 행 색상을 번갈아 표시
  gs_layout1-cwidth_opt = abap_true.       " 컬럼 너비 자동 조절
*  gs_layout-sel_mode   = 'A'.             " 여러 행 선택 허용
  gs_layout1-info_fname = 'ROW_COLOR'.     " 행 색상을 저장한 필드 지정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu2 .

  CLEAR gs_layout2.
  gs_layout2-grid_title = '검수 항목'.
  gs_layout2-zebra      = abap_true.       " 행 색상을 번갈아 표시
  gs_layout2-cwidth_opt = abap_true.       " 컬럼 너비 자동 조절
*  gs_layout-sel_mode   = 'A'.             " 여러 행 선택 허용
  gs_layout2-info_fname = 'ROW_COLOR'.     " 행 색상을 저장한 필드 지정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu3 .

  CLEAR gs_layout3.
  gs_layout3-grid_title = '송장 항목'.
  gs_layout3-zebra      = abap_true.       " 행 색상을 번갈아 표시
  gs_layout3-cwidth_opt = abap_true.       " 컬럼 너비 자동 조절
*  gs_layout-sel_mode   = 'A'.             " 여러 행 선택 허용
  gs_layout3-info_fname = 'ROW_COLOR'.     " 행 색상을 저장한 필드 지정

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_toolbar_exclude
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_toolbar_exclude.
  REFRESH gt_exclude.

  " 행 추가/삭제/복사/붙여넣기 같은 편집 관련 버튼 제거
  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row   TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_cut        TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_paste      TO gt_exclude.
  APPEND cl_gui_alv_grid=>mc_fc_loc_undo       TO gt_exclude.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_alv_grid1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_alv_grid1 .
  " 값 변경 이벤트 감지 코드
  PERFORM zz_set_layout_statu1. "공통
  CALL METHOD go_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.

  LOOP AT gt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>).

    IF <ls_fcat>-fieldname = 'STATU'.
      <ls_fcat>-no_out = abap_true.
    ENDIF.

  ENDLOOP.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout1
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00170'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_170
      it_fieldcatalog      = gt_fcat.

  " ALV를 입력 가능한 상태로 바꾸는 코드 ( 조회 / 생성 )
  CALL METHOD go_grid->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_alv_grid2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_alv_grid2 .
  PERFORM zz_set_layout_statu2. "공통
  " 값 변경 이벤트 감지 코드
  CALL METHOD go_grid2->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


  CALL METHOD go_grid2->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout2
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00180'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_180
      it_fieldcatalog      = gt_fcat2.

  " ALV를 입력 가능한 상태로 바꾸는 코드 ( 조회 / 생성 )
  CALL METHOD go_grid2->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_alv_grid1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_set_alv_grid3 .
  " 값 변경 이벤트 감지 코드
  PERFORM zz_set_layout_statu3. "공통
  CALL METHOD go_grid3->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.


  CALL METHOD go_grid3->set_table_for_first_display
    EXPORTING
      is_layout            = gs_layout3
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00200'
      it_toolbar_excluding = gt_exclude
    CHANGING
      it_outtab            = gt_200
      it_fieldcatalog      = gt_fcat.

  " ALV를 입력 가능한 상태로 바꾸는 코드 ( 조회 / 생성 )
  CALL METHOD go_grid3->set_ready_for_input
    EXPORTING
      i_ready_for_input = 1.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_set_fieldcatalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_TCODE
*&---------------------------------------------------------------------*
FORM zz_set_fieldcatalog.
  REFRESH gt_fcat2.
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTMMG00180'
    CHANGING
      ct_fieldcat      = gt_fcat2.

  LOOP AT gt_fcat2 INTO gs_fcat2.

    "기본은 전부 입력 불가
    gs_fcat2-edit = abap_false.

    "티코드별 입력 가능 필드만 열기

    "시스템 관리 필드는 무조건 입력 불가
    CASE gs_fcat2-fieldname.
      WHEN 'MENGE'.
        gs_fcat2-edit = abap_true.
    ENDCASE.

    MODIFY gt_fcat2 FROM gs_fcat2.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_exe_data_appr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM zz_exe_data_appr .

  DATA: lv_answer TYPE c,
        ls_stable TYPE lvc_s_stbl.

  IF gv_ebeln IS INITIAL.
    MESSAGE i000(oo) WITH '구매오더를 선택해주세요'.
    RETURN.
  ENDIF.


  " 화면 수정값 GT_180 반영
  go_grid2->check_changed_data( ).


  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '저장 확인'
      text_question         = '현재 구매오더의 검수 항목을 저장하시겠습니까?'
      text_button_1         = '예'
      text_button_2         = '아니오'
      default_button        = '1'
      display_cancel_button = space
    IMPORTING
      answer                = lv_answer.

  IF lv_answer <> '1'.
    RETURN.
  ENDIF.


  "----------------------------------------------------
  " 1. 현재 구매오더의 검수 항목 전체 저장
  "----------------------------------------------------
  MODIFY ztmmg00180 FROM TABLE @gt_180.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    MESSAGE i000(oo) WITH '검수 항목 저장 중 오류가 발생했습니다'.
    RETURN.
  ENDIF.


  "----------------------------------------------------
  " 2. 구매오더 헤더 상태 변경
  "----------------------------------------------------
  UPDATE ztmmg00170
    SET statu = 'X'
    WHERE ebeln = @gv_ebeln.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    MESSAGE i000(oo) WITH '상태 변경 중 오류가 발생했습니다'.
    RETURN.
  ENDIF.


  COMMIT WORK.


  "----------------------------------------------------
  " 3. 다시 조회 → STATU X이므로 신호등 재판정
  "----------------------------------------------------
  PERFORM zz_exe_get_data.

  PERFORM zz_get_item_data USING gv_ebeln.


  "----------------------------------------------------
  " 4. Refresh
  "----------------------------------------------------
  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  IF go_grid IS BOUND.
    go_grid->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).
  ENDIF.

  IF go_grid2 IS BOUND.
    go_grid2->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).
  ENDIF.

  IF go_grid3 IS BOUND.
    go_grid3->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).
  ENDIF.

  MESSAGE s000(oo) WITH '저장되었습니다'.

ENDFORM.
*FORM zz_exe_data_appr .
*
*  DATA: lv_answer TYPE c,
*        ls_stable TYPE lvc_s_stbl.
*
*  "----------------------------------------------------
*  " 1. 현재 열어둔 구매오더 확인
*  "----------------------------------------------------
*  IF gv_ebeln IS INITIAL.
*    MESSAGE i000(oo) WITH '구매오더를 선택해주세요'.
*    RETURN.
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 2. ALV에서 수정 중인 값을 GT_180에 반영
*  "    DATA_CHANGED 이벤트가 등록되어 있으면 검증도 실행됨
*  "----------------------------------------------------
*  go_grid2->check_changed_data( ).
*
*
*  "----------------------------------------------------
*  " 3. 저장 확인
*  "----------------------------------------------------
*  CALL FUNCTION 'POPUP_TO_CONFIRM'
*    EXPORTING
*      titlebar              = '저장 확인'
*      text_question         = '현재 구매오더의 검수 항목을 저장하시겠습니까?'
*      text_button_1         = '예'
*      text_button_2         = '아니오'
*      default_button        = '1'
*      display_cancel_button = space
*    IMPORTING
*      answer                = lv_answer.
*
*  IF lv_answer <> '1'.
*    RETURN.
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 4. 현재 EBELN의 검수항목 전체 저장
*  "
*  " GT_180 자체가 현재 더블클릭한 EBELN 데이터만 가지고 있음
*  "----------------------------------------------------
*  MODIFY ztmmg00180 FROM TABLE @gt_180.
*
*  IF sy-subrc <> 0.
*    ROLLBACK WORK.
*    MESSAGE i000(oo) WITH '저장 중 오류가 발생했습니다'.
*    RETURN.
*  ENDIF.
*
*  COMMIT WORK.
*
*
*  "----------------------------------------------------
*  " 5. 상단 데이터 재조회
*  "    → 180 / 200 다시 비교
*  "    → 신호등도 다시 계산
*  "----------------------------------------------------
*  PERFORM zz_exe_get_data.
*
*
*  "----------------------------------------------------
*  " 6. 현재 구매오더 상세 다시 조회
*  "----------------------------------------------------
*  PERFORM zz_get_item_data USING gv_ebeln.
*
*
*  "----------------------------------------------------
*  " 7. ALV 전체 Refresh
*  "----------------------------------------------------
*  ls_stable-row = abap_true.
*  ls_stable-col = abap_true.
*
*  IF go_grid IS BOUND.
*    go_grid->refresh_table_display(
*      EXPORTING
*        is_stable = ls_stable
*    ).
*  ENDIF.
*
*  IF go_grid2 IS BOUND.
*    go_grid2->refresh_table_display(
*      EXPORTING
*        is_stable = ls_stable
*    ).
*  ENDIF.
*
*  IF go_grid3 IS BOUND.
*    go_grid3->refresh_table_display(
*      EXPORTING
*        is_stable = ls_stable
*    ).
*  ENDIF.
*
*  MESSAGE s000(oo) WITH '저장되었습니다'.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_get_item_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_170_EBELN
*&---------------------------------------------------------------------*
FORM zz_get_item_data  USING    pv_ebeln.

  " ALV2 구매오더 아이템
  REFRESH gt_180.

  SELECT *
    FROM ztmmg00180
    INTO CORRESPONDING FIELDS OF TABLE @gt_180
    WHERE ebeln = @pv_ebeln.


  " ALV3 송장 아이템
  REFRESH gt_200.

  SELECT *
    FROM ztmmg00200
    INTO CORRESPONDING FIELDS OF TABLE @gt_200
    WHERE ebeln = @pv_ebeln.
ENDFORM.
FORM zz_exe_invoice_check .

  DATA: lv_check TYPE abap_bool VALUE abap_true.

  "----------------------------------------------------
  " 1. 현재 선택된 구매오더 확인
  "----------------------------------------------------
  IF so_ebeln IS INITIAL.
    MESSAGE i000(oo) WITH '구매오더를 선택해주세요'.
    RETURN.
  ENDIF.


  "----------------------------------------------------
  " 2. 좌/우 데이터 존재 여부 확인
  "----------------------------------------------------
  IF gt_180 IS INITIAL OR gt_200 IS INITIAL.
    lv_check = abap_false.

  ELSE.

    "--------------------------------------------------
    " 3. 건수 비교
    "--------------------------------------------------
    IF lines( gt_180 ) <> lines( gt_200 ).

      lv_check = abap_false.

    ELSE.

      "------------------------------------------------
      " 4. 품목별 수량 비교
      "------------------------------------------------
      LOOP AT gt_180 ASSIGNING FIELD-SYMBOL(<ls_180>).

        " 같은 구매오더 + 같은 구매오더 품목 찾기
        READ TABLE gt_200 ASSIGNING FIELD-SYMBOL(<ls_200>)
          WITH KEY ebeln = <ls_180>-ebeln
                   ebelp = <ls_180>-ebelp.

        " 대응되는 송장 ITEM이 없음
        IF sy-subrc <> 0.
          lv_check = abap_false.
          EXIT.
        ENDIF.

        " 수량 불일치
        IF <ls_180>-menge <> <ls_200>-menge.
          lv_check = abap_false.
          EXIT.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDIF.


  "----------------------------------------------------
  " 5. 상단 구매오더의 신호등 변경
  "----------------------------------------------------
  READ TABLE gt_170 ASSIGNING FIELD-SYMBOL(<ls_170>)
    WITH KEY ebeln = so_ebeln.

  IF sy-subrc = 0.

    IF lv_check = abap_true.

      <ls_170>-light = '3'.   " 초록 : 검증 성공

      MESSAGE s000(oo) WITH
        '송장 검증이 완료되었습니다. 수량이 일치합니다.'.

    ELSE.

      <ls_170>-light = '1'.   " 빨강 : 검증 실패

      MESSAGE i000(oo) WITH
        '송장 검증에 실패했습니다. 항목 또는 수량을 확인해주세요.'.

    ENDIF.

  ENDIF.


  "----------------------------------------------------
  " 6. 상단 ALV Refresh
  "----------------------------------------------------
  DATA ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.

  go_grid->refresh_table_display(
    EXPORTING
      is_stable = ls_stable
  ).

ENDFORM.
