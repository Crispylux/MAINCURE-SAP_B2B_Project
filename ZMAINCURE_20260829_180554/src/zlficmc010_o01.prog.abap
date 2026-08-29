*&---------------------------------------------------------------------*
*& Include          ZLFICMC010_O01
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.

  SET PF-STATUS '2000'.
  SET TITLEBAR  '2000'.

  IF go_grid IS INITIAL.
    PERFORM create_alv.
  ENDIF.

ENDMODULE.
