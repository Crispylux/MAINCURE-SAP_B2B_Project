FUNCTION ZZ_MM_GET_MATERIAL_LIST .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_MATKL) TYPE  ZTMMG00010-MATKL
*"  EXPORTING
*"     REFERENCE(E_STATUS) TYPE  STATU
*"     REFERENCE(E_MESSAGE) TYPE  CHAR255
*"     REFERENCE(ET_LIST) TYPE  ZTTMMG00030
*"--------------------------------------------------------------------

  CLEAR:
    et_list,
    e_status,
    e_message.

  "필수값 검사
  IF i_matkl IS INITIAL.
    e_status  = 'E'.
    e_message = '자재 그룹은 필수 입력 항목입니다.'.
    RETURN.
  ENDIF.


  "자재 그룹별 자재 리스트 조회
  SELECT
         a~matnr,
         b~maktx,
         a~matkl,
         c~wgbez
    FROM ztmmg00010 AS a

    LEFT OUTER JOIN ztmmg00020 AS b
      ON  b~matnr = a~matnr
      AND b~spras = @sy-langu

    LEFT OUTER JOIN t023t AS c
      ON  c~matkl = a~matkl
      AND c~spras = @sy-langu

    WHERE a~matkl = @i_matkl

    INTO CORRESPONDING FIELDS OF TABLE @et_list.


*========================
 "sy-langu로 자재명을 못 찾은 건 한글('3')로 재조회함 (SD에서 이 부분만 추가했습니다)
*========================
  LOOP AT et_list ASSIGNING FIELD-SYMBOL(<ls_list>) WHERE maktx IS INITIAL.
    SELECT SINGLE maktx
      FROM ztmmg00020
      INTO @<ls_list>-maktx
      WHERE matnr = @<ls_list>-matnr
        AND spras = '3'.
  ENDLOOP.
*==================



  IF et_list IS INITIAL.
    e_status  = 'E'.
    e_message = '선택하신 그룹에 등록된 자재가 존재하지 않습니다.'.
    RETURN.
  ENDIF.

  e_status = 'S'.
  e_message =
    |총 { lines( et_list ) }건의 자재 리스트가 정상적으로 조회되었습니다.|.

ENDFUNCTION.
