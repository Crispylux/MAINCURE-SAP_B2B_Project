*&---------------------------------------------------------------------*
*& Include          ZLMMGMC010_O01
*&---------------------------------------------------------------------*

MODULE status_2000 OUTPUT.
CASE sy-tcode.
  WHEN 'ZLMMGMC013'.
    SET PF-STATUS '2000'.
    SET TITLEBAR  '2000' WITH '구매요청 조회'.

    IF go_grid IS INITIAL.
      PERFORM zz_exe_create_alv.
    ENDIF.

  WHEN 'ZLMMGMC011'.
" ZLMMGMC040으로 이동.
" 다른 화면을 사용하는 코드도 한 곳에 넣기에는 너무 지저분해짐.
*    SET PF-STATUS '3000'.
*    SET TITLEBAR  '3000' WITH '구매요청 생성'.
*    IF go_grid IS INITIAL. "여러 줄 생성 가능 alv 만들어야함.
*      PERFORM zz_exe_create_alv.
*    ENDIF.
  WHEN 'ZLMMGMC012'.
    SET PF-STATUS '2000_CHNG'.
    SET TITLEBAR  '2000' WITH '구매요청 수정'.
    IF go_grid IS INITIAL. "한 줄씩 수정 가능한 alv 만들어야함.
      PERFORM zz_exe_create_alv.
    ENDIF.
  WHEN OTHERS.
    SET PF-STATUS '2000'.
    SET TITLEBAR  '2000' WITH '구매요청 조회'.
    IF go_grid IS INITIAL.
      PERFORM zz_exe_create_alv.
    ENDIF.
  ENDCASE.


ENDMODULE.
