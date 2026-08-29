FUNCTION ZZ_MM_GET_MATERIAL_DETAIL .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MATNR) TYPE  ZTMMG00010-MATNR
*"  EXPORTING
*"     REFERENCE(E_MAKTX) TYPE  ZTMMG00020-MAKTX
*"     REFERENCE(E_MATKL) TYPE  ZTMMG00010-MATKL
*"     REFERENCE(E_WGBEZ) TYPE  T023T-WGBEZ
*"     REFERENCE(E_STATUS) TYPE  STATU
*"     REFERENCE(E_MESSAGE) TYPE  CHAR255
*"--------------------------------------------------------------------

  CLEAR:
    e_maktx,
    e_matkl,
    e_wgbez,
    e_status,
    e_message.

  "필수값 검사
  IF i_matnr IS INITIAL.
    e_status  = 'E'.
    e_message = '자재 번호는 필수 입력 항목입니다.'.
    RETURN.
  ENDIF.

*====SD에서 추가======
  DATA: lv_spras TYPE spras VALUE '3'.
*==================

  "자재 기본정보 + 자재명 + 자재그룹명 조회
  SELECT SINGLE
         a~matkl,
         b~maktx,
         c~wgbez
    FROM ztmmg00010 AS a

    LEFT OUTER JOIN ztmmg00020 AS b
      ON  b~matnr = a~matnr
      AND b~spras = @sy-langu

    LEFT OUTER JOIN t023t AS c
      ON  c~matkl = a~matkl
      AND c~spras = @sy-langu

    WHERE a~matnr = @i_matnr

    INTO ( @e_matkl,
           @e_maktx,
           @e_wgbez ).

  IF sy-subrc <> 0.
    e_status  = 'E'.
    e_message = |존재하지 않는 자재 번호({ i_matnr })입니다.|.
    RETURN.
  ENDIF.

*====SD에서 추가: 로그인 언어로 텍스트를 못 찾았을 때 한국어로 재조회======
  IF e_maktx IS INITIAL.
    SELECT SINGLE maktx
      FROM ztmmg00020
      WHERE matnr = @i_matnr
        AND spras = @lv_spras
      INTO @e_maktx.
  ENDIF.

  IF e_wgbez IS INITIAL.
    SELECT SINGLE wgbez
      FROM t023t
      WHERE matkl = @e_matkl
        AND spras = @lv_spras
      INTO @e_wgbez.
  ENDIF.
*=====================================================

  e_status  = 'S'.
  e_message = '자재 마스터 정보가 정상적으로 조회되었습니다.'.

ENDFUNCTION.
