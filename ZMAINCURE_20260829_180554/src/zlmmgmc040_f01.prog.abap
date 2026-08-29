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
*& 최초 화면 데이터 초기화
*&---------------------------------------------------------------------*
FORM zz_exe_get_data .

  REFRESH: gt_070,
           gt_150.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_free_objects
*&---------------------------------------------------------------------*
FORM zz_exe_free_objects .

  IF go_grid1 IS BOUND.
    go_grid1->free( ).
    FREE go_grid1.
  ENDIF.

  IF go_grid2 IS BOUND.
    go_grid2->free( ).
    FREE go_grid2.
  ENDIF.

  IF go_container1 IS BOUND.
    go_container1->free( ).
    FREE go_container1.
  ENDIF.

  IF go_container2 IS BOUND.
    go_container2->free( ).
    FREE go_container2.
  ENDIF.

  cl_gui_cfw=>flush( ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_create_alv
*&---------------------------------------------------------------------*
FORM zz_exe_create_alv .

  PERFORM zz_set_layout_statu1.
  PERFORM zz_set_layout_statu2.
  PERFORM zz_set_toolbar_exclude.
  PERFORM zz_set_fieldcatalog.
  PERFORM zz_exe_get_data.


  "----------------------------------------------------
  " 구매요청 생성 ALV
  "----------------------------------------------------
  CREATE OBJECT go_container1
    EXPORTING
      container_name = 'CC_ALV_001'.

  CREATE OBJECT go_grid1
    EXPORTING
      i_parent = go_container1.


  "----------------------------------------------------
  " 업체 확인 ALV
  "----------------------------------------------------
  CREATE OBJECT go_container2
    EXPORTING
      container_name = 'CC_ALV_002'.

  CREATE OBJECT go_grid2
    EXPORTING
      i_parent = go_container2.


  "----------------------------------------------------
  " 구매요청 생성 ALV 입력 가능
  "----------------------------------------------------
  go_grid1->register_edit_event(
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified
  ).

  go_grid1->set_ready_for_input(
    EXPORTING
      i_ready_for_input = 1
  ).


  "----------------------------------------------------
  " ALV 1
  "----------------------------------------------------
  go_grid1->set_table_for_first_display(
    EXPORTING
      is_layout            = gs_layout1
      i_save               = 'A'
      i_structure_name     = 'ZTMMG00070'
      it_toolbar_excluding = gt_exclude1
    CHANGING
      it_outtab            = gt_070
      it_fieldcatalog      = gt_fcat1
  ).


  "----------------------------------------------------
  " ALV 2
  "----------------------------------------------------
  go_grid2->set_table_for_first_display(
    EXPORTING
      is_layout            = gs_layout2
      i_save               = 'A'
      i_structure_name     = 'ZSMMGMC010'
      it_toolbar_excluding = gt_exclude2
    CHANGING
      it_outtab            = gt_150
      it_fieldcatalog      = gt_fcat2
  ).

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_layout_statu1
*& 구매요청 생성
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu1 .

  CLEAR gs_layout1.

  gs_layout1-grid_title = '구매요청 생성'.
  gs_layout1-zebra      = abap_true.
  gs_layout1-cwidth_opt = abap_true.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_layout_statu2
*& 업체 확인
*&---------------------------------------------------------------------*
FORM zz_set_layout_statu2 .

  CLEAR gs_layout2.

  gs_layout2-grid_title = '업체 확인'.
  gs_layout2-zebra      = abap_true.
  gs_layout2-cwidth_opt = abap_true.
  gs_layout2-sel_mode   = 'A'.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_toolbar_exclude
*&---------------------------------------------------------------------*
FORM zz_set_toolbar_exclude .

  "====================================================
  " 구매요청 생성 ALV
  "====================================================
  REFRESH gt_exclude1.

  " ALV 자체 행 추가/삽입은 사용하지 않음
*  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row
*    TO gt_exclude1.
*
*  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row
*    TO gt_exclude1.


  "====================================================
  " 업체 확인 ALV
  "====================================================
  REFRESH gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_append_row
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_insert_row
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_delete_row
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_copy
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_copy_row
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_cut
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_paste
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_paste_new_row
    TO gt_exclude2.

  APPEND cl_gui_alv_grid=>mc_fc_loc_undo
    TO gt_exclude2.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_set_fieldcatalog
*&---------------------------------------------------------------------*
FORM zz_set_fieldcatalog .

  "====================================================
  " ALV 1 : 구매요청 생성
  "====================================================
  REFRESH gt_fcat1.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZTMMG00070'
    CHANGING
      ct_fieldcat      = gt_fcat1.


  LOOP AT gt_fcat1 INTO gs_fcat1.

    gs_fcat1-edit   = abap_false.
    gs_fcat1-no_out = abap_false.


    "--------------------------------------------------
    " 사용자 입력 가능 필드
    "--------------------------------------------------
    CASE gs_fcat1-fieldname.

      WHEN 'BSART'
        OR 'MATNR'
        OR 'MENGE'
        OR 'MEINS'
        OR 'WERKS'
        OR 'LGORT'
        OR 'BADAT'.

        gs_fcat1-edit = abap_true.

    ENDCASE.


    "--------------------------------------------------
    " 시스템 관리 필드
    "--------------------------------------------------
    CASE gs_fcat1-fieldname.

      WHEN 'BANFN'
        OR 'BNFPO'
        OR 'EBELN'
        OR 'STATU'
        OR 'ERDAT'
        OR 'ERZET'
        OR 'ERNAM'
        OR 'AEDAT'
        OR 'AEZET'
        OR 'AENAM'.

        gs_fcat1-edit = abap_false.

    ENDCASE.


    "--------------------------------------------------
    " 화면에서 숨길 필드
    "--------------------------------------------------
    CASE gs_fcat1-fieldname.

      WHEN 'STATU'
        OR 'LFDAT'.

        gs_fcat1-no_out = abap_true.

    ENDCASE.


    MODIFY gt_fcat1 FROM gs_fcat1.

  ENDLOOP.


  "====================================================
  " ALV 2 : 업체 확인
  "====================================================
  REFRESH gt_fcat2.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZSMMGMC010'
    CHANGING
      ct_fieldcat      = gt_fcat2.


  LOOP AT gt_fcat2 INTO gs_fcat2.

    gs_fcat2-edit = abap_false.

    MODIFY gt_fcat2 FROM gs_fcat2.

  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_search_stock
*& 자재번호 / 업체번호 검색
*&---------------------------------------------------------------------*
FORM zz_exe_search_stock .

  REFRESH gt_150.


  "----------------------------------------------------
  " 검색조건 검사
  "----------------------------------------------------
  IF gv_matnr IS INITIAL
     AND gv_lifnr IS INITIAL.

    MESSAGE i000(oo) WITH
      '자재번호 또는 업체번호를 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 자재 + 업체
  "----------------------------------------------------
  IF gv_matnr IS NOT INITIAL
     AND gv_lifnr IS NOT INITIAL.

    SELECT a~lifnr,
           c~name1,
           a~matnr,
           d~maktx,
           b~werks,
           b~ekorg,
           b~netpr,
           b~waers,
           b~aplfz
      FROM ztmmg00120 AS a

      INNER JOIN ztmmg00130 AS b
        ON b~infnr = a~infnr

      LEFT JOIN ztmmg00150 AS c
        ON c~lifnr = a~lifnr

      LEFT JOIN ztmmg00020 AS d
        ON d~matnr = a~matnr
       AND d~spras = @sy-langu

      INTO CORRESPONDING FIELDS OF TABLE @gt_150

      WHERE a~matnr = @gv_matnr
        AND a~lifnr = @gv_lifnr.


  "----------------------------------------------------
  " 자재만
  "----------------------------------------------------
  ELSEIF gv_matnr IS NOT INITIAL.

    SELECT a~lifnr,
           c~name1,
           a~matnr,
           d~maktx,
           b~werks,
           b~ekorg,
           b~netpr,
           b~waers,
           b~aplfz
      FROM ztmmg00120 AS a

      INNER JOIN ztmmg00130 AS b
        ON b~infnr = a~infnr

      LEFT JOIN ztmmg00150 AS c
        ON c~lifnr = a~lifnr

      LEFT JOIN ztmmg00020 AS d
        ON d~matnr = a~matnr
       AND d~spras = @sy-langu

      INTO CORRESPONDING FIELDS OF TABLE @gt_150

      WHERE a~matnr = @gv_matnr.


  "----------------------------------------------------
  " 업체만
  "----------------------------------------------------
  ELSEIF gv_lifnr IS NOT INITIAL.

    SELECT a~lifnr,
           c~name1,
           a~matnr,
           d~maktx,
           b~werks,
           b~ekorg,
           b~netpr,
           b~waers,
           b~aplfz
      FROM ztmmg00120 AS a

      INNER JOIN ztmmg00130 AS b
        ON b~infnr = a~infnr

      LEFT JOIN ztmmg00150 AS c
        ON c~lifnr = a~lifnr

      LEFT JOIN ztmmg00020 AS d
        ON d~matnr = a~matnr
       AND d~spras = @sy-langu

      INTO CORRESPONDING FIELDS OF TABLE @gt_150

      WHERE a~lifnr = @gv_lifnr.

  ENDIF.


  IF gt_150 IS INITIAL.

    MESSAGE i000(oo) WITH
      '조건에 맞는 업체 정보가 없습니다'.

  ENDIF.


  PERFORM zz_refresh_grid2.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_data_appr
*& 업체 확인 선택행 → 구매요청 생성 목록에 추가
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form zz_exe_data_appr
*& 구매요청 물품 추가 + DB 저장
*&---------------------------------------------------------------------*
FORM zz_exe_data_appr .

  DATA: lt_selected_rows TYPE lvc_t_row,
        lt_save          TYPE TABLE OF ztmmg00070,
        ls_save          TYPE ztmmg00070,
        lv_ok            TYPE abap_bool,
        lv_answer        TYPE c,
        lv_banfn         TYPE ztmmg00070-banfn,
        lv_bnfpo         TYPE n LENGTH 5.


  "----------------------------------------------------
  " 1. 현재 ALV 입력값을 GT_070에 반영
  "----------------------------------------------------
  IF go_grid1 IS BOUND.
    go_grid1->check_changed_data( ).
  ENDIF.


  "----------------------------------------------------
  " 2. 구매요청 ALV 선택행 가져오기
  "----------------------------------------------------
  go_grid1->get_selected_rows(
    IMPORTING
      et_index_rows = lt_selected_rows
  ).


  IF lt_selected_rows IS INITIAL.

    MESSAGE i000(oo) WITH
      '추가할 물품을 선택해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 3. 선택된 행 검사
  "----------------------------------------------------
  LOOP AT lt_selected_rows
    ASSIGNING FIELD-SYMBOL(<ls_selected_row>).


    READ TABLE gt_070
      ASSIGNING FIELD-SYMBOL(<ls_070>)
      INDEX <ls_selected_row>-index.


    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.


    "--------------------------------------------------
    " 필수 입력값 체크
    "--------------------------------------------------
    PERFORM zz_check_item_input
      USING    <ls_070>
      CHANGING lv_ok.


    IF lv_ok = abap_false.
      RETURN.
    ENDIF.


    "--------------------------------------------------
    " DB Master Data 존재 여부 체크
    "--------------------------------------------------
    PERFORM zz_check_master_data
      USING    <ls_070>
      CHANGING lv_ok.


    IF lv_ok = abap_false.
      RETURN.
    ENDIF.

  ENDLOOP.


  "----------------------------------------------------
  " 4. 저장 확인 팝업
  "----------------------------------------------------
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '구매요청 생성'
      text_question         = '선택한 물품으로 구매요청을 생성하시겠습니까?'
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
  " 5. 구매요청 번호 생성
  "----------------------------------------------------
  PERFORM zz_get_new_banfn
    CHANGING lv_banfn.


  IF lv_banfn IS INITIAL.

    MESSAGE i000(oo) WITH
      '구매요청 번호 생성에 실패했습니다'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 6. 저장용 Internal Table 생성
  "----------------------------------------------------
  CLEAR lv_bnfpo.
  REFRESH lt_save.


  LOOP AT lt_selected_rows
    ASSIGNING <ls_selected_row>.


    READ TABLE gt_070
      ASSIGNING <ls_070>
      INDEX <ls_selected_row>-index.


    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.


    CLEAR ls_save.


    " 현재 ALV 데이터 복사
    MOVE-CORRESPONDING <ls_070> TO ls_save.


    "--------------------------------------------------
    " Item 번호
    "--------------------------------------------------
    lv_bnfpo = lv_bnfpo + 10.


    "--------------------------------------------------
    " 시스템 관리값
    "--------------------------------------------------
    ls_save-banfn = lv_banfn.
    ls_save-bnfpo = lv_bnfpo.

    ls_save-statu = 'A'.


    " 요청일 없으면 오늘
    IF ls_save-badat IS INITIAL.
      ls_save-badat = sy-datum.
    ENDIF.


    " 생성정보
    ls_save-erdat = sy-datum.
    ls_save-erzet = sy-uzeit.
    ls_save-ernam = sy-uname.


    " 변경정보
    ls_save-aedat = sy-datum.
    ls_save-aezet = sy-uzeit.
    ls_save-aenam = sy-uname.


    APPEND ls_save TO lt_save.

  ENDLOOP.


  "----------------------------------------------------
  " 7. 구매요청 DB 저장
  "----------------------------------------------------
  INSERT ztmmg00070
    FROM TABLE @lt_save.


  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE i000(oo) WITH
      '구매요청 저장 중 오류가 발생했습니다'.

    RETURN.

  ENDIF.


  COMMIT WORK.


  "----------------------------------------------------
  " 8. 성공 메시지
  "----------------------------------------------------
  MESSAGE s000(oo) WITH
    '구매요청'
    lv_banfn
    '이 생성되었습니다'.


  "----------------------------------------------------
  " 9. 구매요청 생성 ALV 초기화
  "----------------------------------------------------
  REFRESH gt_070.


  PERFORM zz_refresh_grid1.

ENDFORM.
*FORM zz_exe_data_appr .
*
*  DATA: lt_selected_rows TYPE lvc_t_row,
*        ls_070           TYPE ztmmg00070,
*        lv_bnfpo         TYPE n LENGTH 5,
*        lv_ok            TYPE abap_bool.
*
*
*  "----------------------------------------------------
*  " 기존 입력행 검증
*  "----------------------------------------------------
*  PERFORM zz_check_input_data
*    CHANGING lv_ok.
*
*
*  IF lv_ok = abap_false.
*    RETURN.
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 업체 확인 ALV 선택행 조회
*  "----------------------------------------------------
*  go_grid1->get_selected_rows(
*    IMPORTING
*      et_index_rows = lt_selected_rows
*  ).
*
*
*  IF lt_selected_rows IS INITIAL.
*
*    MESSAGE i000(oo) WITH
*      '추가할 물품을 선택해주세요'.
*
*    RETURN.
*
*  ENDIF.
*
*
*  "----------------------------------------------------
*  " 현재 마지막 ITEM 번호 계산
*  "----------------------------------------------------
*  lv_bnfpo = lines( gt_070 ) * 10.
*
*
*  "----------------------------------------------------
*  " 선택한 물품 추가
*  "----------------------------------------------------
*  LOOP AT lt_selected_rows
*    ASSIGNING FIELD-SYMBOL(<ls_selected_row>).
*
*
*    READ TABLE gt_150
*      ASSIGNING FIELD-SYMBOL(<ls_150>)
*      INDEX <ls_selected_row>-index.
*
*
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*
*    "--------------------------------------------------
*    " 동일 자재 + 플랜트 중복 방지
*    "--------------------------------------------------
*    READ TABLE gt_070
*      TRANSPORTING NO FIELDS
*      WITH KEY matnr = <ls_150>-matnr
*               werks = <ls_150>-werks.
*
*
*    IF sy-subrc = 0.
*
*      MESSAGE i000(oo) WITH
*        <ls_150>-matnr
*        '이미 추가된 자재입니다'.
*
*      CONTINUE.
*
*    ENDIF.
*
*
*    CLEAR ls_070.
*
*
*    "--------------------------------------------------
*    " Item 번호
*    "--------------------------------------------------
*    lv_bnfpo = lv_bnfpo + 10.
*
*    ls_070-bnfpo = lv_bnfpo.
*
*
*    "--------------------------------------------------
*    " 자동 입력
*    "--------------------------------------------------
*    ls_070-bsart = 'NB'.
*    ls_070-matnr = <ls_150>-matnr.
*    ls_070-werks = <ls_150>-werks.
*
*    ls_070-badat = sy-datum.
*
*    " 화면에서는 숨기지만 DB 저장용으로 계산
*
*
*    "--------------------------------------------------
*    " 자재 기본단위
*    "--------------------------------------------------
*    PERFORM zz_get_material_unit
*      USING    <ls_150>-matnr
*      CHANGING ls_070-meins.
*
*
*    IF ls_070-meins IS INITIAL.
*      CONTINUE.
*    ENDIF.
*
*
*    "--------------------------------------------------
*    " 사용자가 직접 입력할 값
*    "--------------------------------------------------
*    CLEAR:
*      ls_070-menge,
*      ls_070-lgort.
*
*
*    "--------------------------------------------------
*    " 시스템값
*    "--------------------------------------------------
*    CLEAR ls_070-ebeln.
*
*    ls_070-statu = 'A'.
*
*
*    APPEND ls_070 TO gt_070.
*
*  ENDLOOP.
*
*
*  PERFORM zz_refresh_grid1.
*
*ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_check_input_data
*& 기존 구매요청 행의 필수 입력값 검사
*&---------------------------------------------------------------------*
FORM zz_check_input_data
  CHANGING pv_ok TYPE abap_bool.

  pv_ok = abap_false.


  "----------------------------------------------------
  " 현재 ALV 입력값을 GT_070에 반영
  "----------------------------------------------------
  IF go_grid1 IS BOUND.

    go_grid1->check_changed_data( ).

  ENDIF.


  "----------------------------------------------------
  " 첫 물품 추가
  "----------------------------------------------------
  IF gt_070 IS INITIAL.

    pv_ok = abap_true.
    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 입력값 검증
  "----------------------------------------------------
  LOOP AT gt_070
    ASSIGNING FIELD-SYMBOL(<ls_070>).


    IF <ls_070>-bsart IS INITIAL.

      MESSAGE i000(oo) WITH
        <ls_070>-bnfpo
        '구매문서 유형을 입력해주세요'.

      RETURN.

    ENDIF.


    IF <ls_070>-matnr IS INITIAL.

      MESSAGE i000(oo) WITH
        <ls_070>-bnfpo
        '자재를 입력해주세요'.

      RETURN.

    ENDIF.


    IF <ls_070>-menge IS INITIAL
       OR <ls_070>-menge <= 0.

      MESSAGE i000(oo) WITH
        <ls_070>-matnr
        '수량을 입력해주세요'.

      RETURN.

    ENDIF.


    IF <ls_070>-meins IS INITIAL.

      MESSAGE i000(oo) WITH
        <ls_070>-matnr
        '단위를 입력해주세요'.

      RETURN.

    ENDIF.


    IF <ls_070>-werks IS INITIAL.

      MESSAGE i000(oo) WITH
        <ls_070>-matnr
        '플랜트를 입력해주세요'.

      RETURN.

    ENDIF.


    IF <ls_070>-lgort IS INITIAL.

      MESSAGE i000(oo) WITH
        <ls_070>-matnr
        '저장위치를 입력해주세요'.

      RETURN.

    ENDIF.


    IF <ls_070>-badat IS INITIAL.

      MESSAGE i000(oo) WITH
        <ls_070>-matnr
        '구매요청일을 입력해주세요'.

      RETURN.

    ENDIF.


  ENDLOOP.


  pv_ok = abap_true.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_get_material_unit
*& 자재 기본 단위 조회
*&---------------------------------------------------------------------*
FORM zz_get_material_unit
  USING    pv_matnr TYPE ztmmg00010-matnr
  CHANGING pv_meins TYPE ztmmg00010-meins.

  CLEAR pv_meins.


  SELECT SINGLE meins
    FROM ztmmg00010
    INTO @pv_meins
    WHERE matnr = @pv_matnr.


  IF sy-subrc <> 0.

    MESSAGE i000(oo) WITH
      pv_matnr
      '자재 기본단위를 찾을 수 없습니다'.

    RETURN.

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_exe_save_data
*& 구매요청 저장
*&---------------------------------------------------------------------*
FORM zz_exe_save_data .

  DATA: lv_answer     TYPE c,
        lv_last_banfn TYPE ztmmg00070-banfn,
        lv_banfn      TYPE ztmmg00070-banfn,
        lv_number     TYPE n LENGTH 8,
        lv_bnfpo      TYPE n LENGTH 5,
        lv_ok         TYPE abap_bool.


  "----------------------------------------------------
  " 1. ALV 수정값 반영 + 필수값 검증
  "----------------------------------------------------
  PERFORM zz_check_input_data
    CHANGING lv_ok.


  IF lv_ok = abap_false.
    RETURN.
  ENDIF.


  "----------------------------------------------------
  " 2. 데이터 존재 여부
  "----------------------------------------------------
  IF gt_070 IS INITIAL.

    MESSAGE i000(oo) WITH
      '생성할 구매요청 항목이 없습니다'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 3. 저장 확인
  "----------------------------------------------------
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '구매요청 생성'
      text_question         = '구매요청을 생성하시겠습니까?'
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
  " 4. 신규 구매요청 번호
  "----------------------------------------------------
  SELECT MAX( banfn )
    FROM ztmmg00070
    INTO @lv_last_banfn.


  IF lv_last_banfn IS INITIAL.

    lv_number = '00000001'.

  ELSE.

    lv_number = lv_last_banfn+2(8).
    lv_number = lv_number + 1.

  ENDIF.


  CONCATENATE 'PR'
              lv_number
         INTO lv_banfn.


  "----------------------------------------------------
  " 5. 시스템 관리값 세팅
  "----------------------------------------------------
  CLEAR lv_bnfpo.


  LOOP AT gt_070
    ASSIGNING FIELD-SYMBOL(<ls_070>).


    lv_bnfpo = lv_bnfpo + 10.


    <ls_070>-banfn = lv_banfn.
    <ls_070>-bnfpo = lv_bnfpo.


    IF <ls_070>-badat IS INITIAL.
      <ls_070>-badat = sy-datum.
    ENDIF.


    <ls_070>-statu = 'A'.


    "--------------------------------------------------
    " 생성정보
    "--------------------------------------------------
    <ls_070>-erdat = sy-datum.
    <ls_070>-erzet = sy-uzeit.
    <ls_070>-ernam = sy-uname.


    "--------------------------------------------------
    " 변경정보도 최초 생성 시 동일값 세팅
    "--------------------------------------------------
    <ls_070>-aedat = sy-datum.
    <ls_070>-aezet = sy-uzeit.
    <ls_070>-aenam = sy-uname.

  ENDLOOP.


  "----------------------------------------------------
  " 6. DB 저장
  "----------------------------------------------------
  INSERT ztmmg00070
    FROM TABLE @gt_070.


  IF sy-subrc <> 0.

    ROLLBACK WORK.

    MESSAGE i000(oo) WITH
      '구매요청 생성 중 오류가 발생했습니다'.

    RETURN.

  ENDIF.


  COMMIT WORK.


  "----------------------------------------------------
  " 7. 완료
  "----------------------------------------------------
  MESSAGE s000(oo) WITH
    '구매요청'
    lv_banfn
    '이 생성되었습니다'.


  REFRESH gt_070.

  PERFORM zz_refresh_grid1.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_refresh_grid1
*& 구매요청 생성 ALV Refresh
*&---------------------------------------------------------------------*
FORM zz_refresh_grid1 .

  DATA ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.


  IF go_grid1 IS BOUND.

    go_grid1->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).

  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form zz_refresh_grid2
*& 업체 확인 ALV Refresh
*&---------------------------------------------------------------------*
FORM zz_refresh_grid2 .

  DATA ls_stable TYPE lvc_s_stbl.

  ls_stable-row = abap_true.
  ls_stable-col = abap_true.


  IF go_grid2 IS BOUND.

    go_grid2->refresh_table_display(
      EXPORTING
        is_stable = ls_stable
    ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_check_item_input
*& 구매요청 필수 입력값 확인
*&---------------------------------------------------------------------*
FORM zz_check_item_input
  USING    ps_070 TYPE ztmmg00070
  CHANGING pv_ok TYPE abap_bool.


  pv_ok = abap_false.


  "----------------------------------------------------
  " 구매문서 유형
  "----------------------------------------------------
  IF ps_070-bsart IS INITIAL.

    MESSAGE i000(oo) WITH
      '구매문서 유형을 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 자재번호
  "----------------------------------------------------
  IF ps_070-matnr IS INITIAL.

    MESSAGE i000(oo) WITH
      '자재번호를 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 수량
  "----------------------------------------------------
  IF ps_070-menge IS INITIAL
     OR ps_070-menge <= 0.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      '수량을 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 단위
  "----------------------------------------------------
  IF ps_070-meins IS INITIAL.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      '단위를 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 플랜트
  "----------------------------------------------------
  IF ps_070-werks IS INITIAL.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      '플랜트를 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 저장위치
  "----------------------------------------------------
  IF ps_070-lgort IS INITIAL.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      '저장위치를 입력해주세요'.

    RETURN.

  ENDIF.


  "----------------------------------------------------
  " 구매요청일
  "----------------------------------------------------
  IF ps_070-badat IS INITIAL.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      '구매요청일을 입력해주세요'.

    RETURN.

  ENDIF.


  pv_ok = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_check_master_data
*& 자재 / 플랜트 / 저장위치 존재 여부 확인
*&---------------------------------------------------------------------*
FORM zz_check_master_data
  USING    ps_070 TYPE ztmmg00070
  CHANGING pv_ok TYPE abap_bool.


  DATA lv_exists TYPE abap_bool.


  pv_ok = abap_false.


  "====================================================
  " 1. 자재 존재 여부
  " ZTMMG00010 : 자재 기본정보
  "====================================================
  CLEAR lv_exists.


  SELECT SINGLE @abap_true
    FROM ztmmg00010
    WHERE matnr = @ps_070-matnr
    INTO @lv_exists.


  IF sy-subrc <> 0.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      '존재하지 않는 자재입니다'.

    RETURN.

  ENDIF.


  "====================================================
  " 2. 플랜트 존재 여부
  " ZTMMG00160 : 플랜트 마스터
  "====================================================
  CLEAR lv_exists.


  SELECT SINGLE @abap_true
    FROM ztmmg00160
    WHERE werks = @ps_070-werks
    INTO @lv_exists.


  IF sy-subrc <> 0.

    MESSAGE i000(oo) WITH
      ps_070-werks
      '존재하지 않는 플랜트입니다'.

    RETURN.

  ENDIF.


  "====================================================
  " 3. 저장위치 존재 여부
  " ZTMMG00220 : 저장위치 정보
  "
  " 같은 LGORT라도 다른 플랜트일 수 있으므로
  " WERKS + LGORT 조합으로 확인
  "====================================================
  CLEAR lv_exists.


  SELECT SINGLE @abap_true
    FROM ztmmg00220
    WHERE werks = @ps_070-werks
      AND lgort = @ps_070-lgort
    INTO @lv_exists.


  IF sy-subrc <> 0.

    MESSAGE i000(oo) WITH
      ps_070-werks
      ps_070-lgort
      '플랜트에 존재하지 않는 저장위치입니다'.

    RETURN.

  ENDIF.


  "====================================================
  " 4. 해당 자재가 해당 플랜트에 존재하는지 확인
  " ZTMMG00030 : 플랜트별 자재정보
  "====================================================
  CLEAR lv_exists.


  SELECT SINGLE @abap_true
    FROM ztmmg00030
    WHERE matnr = @ps_070-matnr
      AND werks = @ps_070-werks
    INTO @lv_exists.


  IF sy-subrc <> 0.

    MESSAGE i000(oo) WITH
      ps_070-matnr
      ps_070-werks
      '해당 플랜트에 등록되지 않은 자재입니다'.

    RETURN.

  ENDIF.


  pv_ok = abap_true.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form zz_get_new_banfn
*& 신규 구매요청번호 생성
*&---------------------------------------------------------------------*
FORM zz_get_new_banfn
  CHANGING pv_banfn TYPE ztmmg00070-banfn.


  DATA: lv_last_banfn TYPE ztmmg00070-banfn,
        lv_number     TYPE n LENGTH 8.


  CLEAR:
    pv_banfn,
    lv_last_banfn,
    lv_number.


  SELECT MAX( banfn )
    FROM ztmmg00070
    INTO @lv_last_banfn.


  IF lv_last_banfn IS INITIAL.

    lv_number = '00000001'.

  ELSE.

    lv_number = lv_last_banfn+2(8).
    lv_number = lv_number + 1.

  ENDIF.


  CONCATENATE 'PR'
              lv_number
         INTO pv_banfn.

ENDFORM.
