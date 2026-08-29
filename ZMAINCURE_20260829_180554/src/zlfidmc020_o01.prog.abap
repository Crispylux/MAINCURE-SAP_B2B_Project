*&---------------------------------------------------------------------*
*& Include          ZLFIDMC020_O01
*&---------------------------------------------------------------------*
*& Screen PBO
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.
  SET PF-STATUS '2000'.
  SET TITLEBAR  '2000'.
ENDMODULE.

MODULE init_2000 OUTPUT.

  IF go_container IS INITIAL.

    PERFORM create_container.
    PERFORM create_splitter.
    PERFORM set_layout.
    PERFORM build_fcat_top.
    PERFORM build_fcat_bot.
    PERFORM display_alv_top.
    PERFORM display_alv_bot.

  ELSE.

    PERFORM refresh_alv.

  ENDIF.

ENDMODULE.
