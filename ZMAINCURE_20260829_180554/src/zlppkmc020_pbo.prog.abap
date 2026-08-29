*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.


  IF go_event_receiver IS INITIAL.
    CREATE OBJECT go_event_receiver.
  ENDIF.

  IF gv_scr_mode = '1'.
    gv_dynnr = '0101'.
    PERFORM create_alv_mode1.
  ELSE.
    gv_dynnr = '0102'.
    PERFORM create_alv_mode2.
  ENDIF.

ENDMODULE.
