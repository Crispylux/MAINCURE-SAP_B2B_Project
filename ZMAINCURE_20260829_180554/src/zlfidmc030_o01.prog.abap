*&---------------------------------------------------------------------*
*& Include          ZLFIDMC030_O01
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.
  set PF-STATUS '2000'.
  set TITLEBAR '2000'.

  IF go_grid IS INITIAL.
    PERFORM create_alv.
  ENDIF.
ENDMODULE.
