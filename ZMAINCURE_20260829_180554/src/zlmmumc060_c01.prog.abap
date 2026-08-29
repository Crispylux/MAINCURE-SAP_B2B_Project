*&---------------------------------------------------------------------*
*& Include          ZLMMUMC060_C01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.28    양윤서              최초작성
*&---------------------------------------------------------------------*

*CLASS lcl_event_receiver DEFINITION.
*  PUBLIC SECTION.
*    METHODS handle_data_changed
*      FOR EVENT data_changed OF cl_gui_alv_grid
*      IMPORTING er_data_changed.
*
*    METHODS handle_after_user_command
*      FOR EVENT after_user_command OF cl_gui_alv_grid
*      IMPORTING e_ucomm.
*
*ENDCLASS.
*
*CLASS lcl_event_receiver IMPLEMENTATION.
*
*  METHOD handle_data_changed.
*    " 추후 구현
*  ENDMETHOD.
*
*  METHOD handle_after_user_command.
*    " 추후 구현
*  ENDMETHOD.
*
*ENDCLASS.
