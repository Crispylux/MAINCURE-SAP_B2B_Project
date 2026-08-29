*&---------------------------------------------------------------------*
*& Include          ZLPPJMC030_TOP
*&---------------------------------------------------------------------*
*-----클래스 객체(alv를 위한 컨트롤러들---*
DATA: go_container   TYPE REF TO cl_gui_custom_container, "화면 CostumerContainer(CC) 연결용
      go_splitter    TYPE REF TO cl_gui_splitter_container, "화면 분할기
      go_container_1 TYPE REF TO cl_gui_container, "분할된 화면 1 컨테이너
      go_container_2 TYPE REF TO cl_gui_container, "분할된 화면 2 컨테이너
      go_grid_1      TYPE REF TO cl_gui_alv_grid, "화면 1 alv grid
      go_grid_2      TYPE REF TO cl_gui_alv_grid. "화면 2 alv grid


*-----인터널 테이블 (본인 Z테이블 구조에 맞게 변경)-----*
DATA: gt_order_header TYPE TABLE OF zsppjmc010,
      gs_order_header TYPE zsppjmc010.

DATA: gt_order_process TYPE TABLE OF zsppjmc020,
      gs_order_process TYPE zsppjmc020.


*-------필드카탈로그-----*
DATA: gt_fieldcat_1 TYPE lvc_t_fcat,
      gt_fieldcat_2 TYPE lvc_t_fcat,
      gs_fieldcat   TYPE lvc_s_fcat.
*---------------------------------------------------------------------*
* 불량수량 조회용
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_xmnga,
         aufnr TYPE ztppj00070-aufnr,
         xmnga TYPE ztppj00070-xmnga,
       END OF ty_xmnga.

DATA: gt_xmnga TYPE TABLE OF ty_xmnga,
      gs_xmnga TYPE ty_xmnga.
