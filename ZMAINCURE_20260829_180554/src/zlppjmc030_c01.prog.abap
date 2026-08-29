*&---------------------------------------------------------------------*
*& Include          ZLPPJMC030_C01
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* ALV Event Handler
*---------------------------------------------------------------------*
CLASS lcl_event_handler DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS on_double_click
      FOR EVENT double_click OF cl_gui_alv_grid
      IMPORTING
        e_row
        e_column
        es_row_no.

ENDCLASS.


CLASS lcl_event_handler IMPLEMENTATION.

  METHOD on_double_click.

    " 생산오더 번호를 더블클릭한 경우에만 상세 공정 조회
    IF e_column-fieldname <> 'AUFNR'.
      RETURN.
    ENDIF.

    " 선택한 생산오더 행 읽기
    READ TABLE gt_order_header
      INTO gs_order_header
      INDEX es_row_no-row_id.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    " 선택 생산오더의 공정 조회
    PERFORM get_process_data.

  ENDMETHOD.

ENDCLASS.
