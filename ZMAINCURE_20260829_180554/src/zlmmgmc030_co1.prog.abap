*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_C01
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

    METHODS handle_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column.

ENDCLASS.


CLASS lcl_event_receiver IMPLEMENTATION.

  METHOD handle_double_click.

    DATA: ls_070    TYPE ztmmg00070,
          ls_stable TYPE lvc_s_stbl.


    "----------------------------------------------------
    " 1. BANFN(구매요청번호) 더블클릭일 때만 실행
    "----------------------------------------------------
    IF e_column-fieldname <> 'BANFN'.
      RETURN.
    ENDIF.


    "----------------------------------------------------
    " 2. 상단 입고 리스트에서 더블클릭한 행 읽기
    "----------------------------------------------------
    READ TABLE gt_070 INTO ls_070
      INDEX e_row-index.

    IF sy-subrc <> 0.
      MESSAGE i000(oo) WITH '선택한 행을 읽을 수 없습니다'.
      RETURN.
    ENDIF.


    IF ls_070-banfn IS INITIAL.
      MESSAGE i000(oo) WITH '구매요청 번호가 없습니다'.
      RETURN.
    ENDIF.


    "----------------------------------------------------
    " 3. 현재 선택한 구매요청번호 기억
    "----------------------------------------------------
    gv_banfn = ls_070-banfn.


    "----------------------------------------------------
    " 4. 해당 구매요청번호의 검수 항목 조회
    "----------------------------------------------------
    PERFORM zz_get_inspection_data
      USING gv_banfn.


    "----------------------------------------------------
    " 5. 하단 검수 항목 ALV Refresh
    "----------------------------------------------------
    ls_stable-row = abap_true.
    ls_stable-col = abap_true.

    IF go_grid2 IS BOUND.

      CALL METHOD go_grid2->refresh_table_display
        EXPORTING
          is_stable = ls_stable.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
