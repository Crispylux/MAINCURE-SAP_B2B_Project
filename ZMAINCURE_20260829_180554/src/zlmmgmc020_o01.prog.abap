*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_O01
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.

    SET PF-STATUS '2000'.
    SET TITLEBAR  '2000' WITH '송장 검증'.
    IF go_grid IS INITIAL.
      PERFORM zz_exe_create_alv.
    ENDIF.


ENDMODULE.
