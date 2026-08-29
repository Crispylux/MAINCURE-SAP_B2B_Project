FUNCTION ZZ_MM_MISTAKE5 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MATNR) TYPE  ZTMMG00010-MATNR
*"     REFERENCE(I_WERKS) TYPE  ZTMMG00030-WERKS
*"  EXPORTING
*"     REFERENCE(E_MAKTX) TYPE  ZTMMG00020-MAKTX
*"     REFERENCE(E_LGORT) TYPE  ZTMMG00040-LGORT
*"     REFERENCE(STATUS) TYPE  STATU
*"     REFERENCE(MESSAGE) TYPE  CHAR255
*"     REFERENCE(E_WERKS) TYPE  ZTMMG00030-WERKS
*"----------------------------------------------------------------------


  CLEAR:
    e_maktx,
    e_werks,
    e_lgort,
    status,
    message.

  status = 'E'.


  "------------------------------------------------------------
  " 1. 필수값 검사
  "------------------------------------------------------------
  IF i_matnr IS INITIAL.
    message = '필수 입력 항목(자재 번호)이 누락되었습니다.'.
    RETURN.
  ENDIF.


  "------------------------------------------------------------
  " 2. 플랜트가 넘어온 경우
  "------------------------------------------------------------
  IF i_werks IS NOT INITIAL.

    SELECT SINGLE
           b~maktx,
           c~werks,
           d~lgort

      FROM ztmmg00010 AS a          "ZMARA

      INNER JOIN ztmmg00020 AS b    "ZMAKT
        ON  b~matnr = a~matnr
        AND b~spras = @sy-langu

      INNER JOIN ztmmg00030 AS c    "ZMARC
        ON c~matnr = a~matnr

      LEFT OUTER JOIN ztmmg00040 AS d "ZMARD
        ON  d~matnr = c~matnr
        AND d~werks = c~werks

      WHERE a~matnr = @i_matnr
        AND c~werks = @i_werks

      INTO (@e_maktx,
            @e_werks,
            @e_lgort).

    IF sy-subrc <> 0.

      "자재 자체가 없는지 확인
      SELECT SINGLE matnr
        FROM ztmmg00010
        WHERE matnr = @i_matnr
        INTO @DATA(lv_matnr).

      IF sy-subrc <> 0.
        message = '자재 마스터에 존재하지 않는 자재 번호입니다.'.

      ELSE.
        message =
          |해당 플랜트({ i_werks })에 등록되지 않은 자재 번호입니다.|.
      ENDIF.

      RETURN.
    ENDIF.


  "------------------------------------------------------------
  " 3. 플랜트가 안 넘어온 경우
  "------------------------------------------------------------
  ELSE.

    SELECT SINGLE
           b~maktx,
           c~werks,
           d~lgort

      FROM ztmmg00010 AS a

      INNER JOIN ztmmg00020 AS b
        ON  b~matnr = a~matnr
        AND b~spras = @sy-langu

      INNER JOIN ztmmg00030 AS c
        ON c~matnr = a~matnr

      LEFT OUTER JOIN ztmmg00040 AS d
        ON  d~matnr = c~matnr
        AND d~werks = c~werks

      WHERE a~matnr = @i_matnr

      INTO (@e_maktx,
            @e_werks,
            @e_lgort).

    IF sy-subrc <> 0.
      message = '자재 마스터에 존재하지 않는 자재 번호입니다.'.
      RETURN.
    ENDIF.

  ENDIF.


  "------------------------------------------------------------
  " 4. 성공
  "------------------------------------------------------------
  status  = 'S'.
  message = '자재 마스터 정보가 성공적으로 조회되었습니다.'.

ENDFUNCTION.
