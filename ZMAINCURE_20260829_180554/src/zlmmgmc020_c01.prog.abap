**&---------------------------------------------------------------------*
**& Include          ZLMMGMC010_C01
**&---------------------------------------------------------------------*

CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.

    METHODS:
      handle_double_click
        FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING e_row e_column.

ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.

  METHOD handle_double_click.

    DATA: ls_170  TYPE ztmmg00170,
          ls_stbl TYPE lvc_s_stbl.

    " EBELN 컬럼 더블클릭일 때만 실행
    IF e_column-fieldname <> 'EBELN'.
      RETURN.
    ENDIF.


    " 더블클릭한 ALV 1번 행 읽기
    READ TABLE gt_170 INTO ls_170 INDEX e_row-index.
    IF sy-subrc <> 0.
      MESSAGE '선택한 행을 읽을 수 없습니다.' TYPE 'I'.
      RETURN.
    ENDIF.

    IF ls_170-ebeln IS INITIAL.
      MESSAGE '구매오더 번호가 없습니다.' TYPE 'I'.
      RETURN.
    ENDIF.
    gv_ebeln = ls_170-ebeln.
    " 해당 구매오더 아이템 조회
    PERFORM zz_get_item_data USING ls_170-ebeln.

    " ALV 2, 3 새로고침
    ls_stbl-row = abap_true.
    ls_stbl-col = abap_true.

    IF go_grid2 IS BOUND.
      CALL METHOD go_grid2->refresh_table_display
        EXPORTING
          is_stable = ls_stbl.
    ENDIF.

    IF go_grid3 IS BOUND.
      CALL METHOD go_grid3->refresh_table_display
        EXPORTING
          is_stable = ls_stbl.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
