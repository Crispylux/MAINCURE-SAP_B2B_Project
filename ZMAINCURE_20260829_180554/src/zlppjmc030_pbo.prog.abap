
*&---------------------------------------------------------------------*
*& Include          ZLPPJMC030_PBO
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module CREATE_OBJ OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_obj OUTPUT.
  IF go_container IS NOT BOUND.
    " 바탕 컨테이너 생성.
    CREATE OBJECT go_container
      EXPORTING
        container_name = 'CC0100_1'.

    " 바탕 컨테이너 안에 스플리터 생성 (2행 1열 구조)
    CREATE OBJECT go_splitter
      EXPORTING
        parent  = go_container
        rows    = 2
        columns = 1.

    " 스플리터의 각 셀(컨테이너) 핸들 가져오기
    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = go_container_1.

    CALL METHOD go_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = go_container_2.

    " alv grid 1 생성
    CREATE OBJECT go_grid_1
      EXPORTING
        i_parent          = go_container_1
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    SET HANDLER lcl_event_handler=>on_double_click
      FOR go_grid_1.
    " alv grid 2 생성
    CREATE OBJECT go_grid_2
      EXPORTING
        i_parent          = go_container_2
      EXCEPTIONS
        error_cntl_create = 1
        error_cntl_init   = 2
        error_cntl_link   = 3
        error_dp_create   = 4
        OTHERS            = 5.
    IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  PERFORM set_alv_first.


ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.
