FUNCTION ZZ_MM_GET_PLANT_INFO .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_WERKS) TYPE  WERKS_D
*"  EXPORTING
*"     REFERENCE(E_NAME1) TYPE  NAME1
*"     REFERENCE(E_STATUS) TYPE  STATU
*"     REFERENCE(E_MESSAGE) TYPE  CHAR255
*"--------------------------------------------------------------------

  CLEAR: e_name1,
         e_status,
         e_message.

  IF i_werks IS INITIAL.
    e_status  = 'E'.
    e_message = '플랜트 코드는 필수 입력 항목입니다.'.
    RETURN.
  ENDIF.

  SELECT SINGLE name1
    FROM t001w
    INTO @e_name1
    WHERE werks = @i_werks.

  IF sy-subrc = 0.
    e_status  = 'S'.
    e_message = '플랜트 정보가 정상적으로 조회되었습니다.'.
  ELSE.
    e_status  = 'E'.
    e_message = |존재하지 않는 플랜트 코드({ i_werks })입니다.|.
  ENDIF.

ENDFUNCTION.
