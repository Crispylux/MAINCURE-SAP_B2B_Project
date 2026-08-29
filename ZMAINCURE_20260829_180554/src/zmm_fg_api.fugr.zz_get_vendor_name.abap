*FUNCTION ZZ_GET_VENDOR_NAME.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LIFNR) TYPE  LIFNR
*"  EXPORTING
*"     REFERENCE(EV_LIFNR) TYPE  LIFNR
*"     REFERENCE(EV_NAME1) TYPE  NAME1_GP
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------
FUNCTION zz_get_vendor_name.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_LIFNR) TYPE  LIFNR
*"  EXPORTING
*"     REFERENCE(EV_LIFNR) TYPE  LIFNR
*"     REFERENCE(EV_NAME1) TYPE  NAME1_GP
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------

  CLEAR: ev_lifnr, ev_name1, ev_status, ev_message.

  " 1. 필수 입력값 체크
  IF iv_lifnr IS INITIAL.
    ev_status  = 'E'.
    ev_message = '공급업체번호는 필수 입력입니다.'.
    RETURN.
  ENDIF.

  " 2. 공급업체 마스터 조회
  SELECT SINGLE lifnr, name1
    FROM ztmmg00150
    INTO (@ev_lifnr, @ev_name1)
    WHERE lifnr = @iv_lifnr.

  IF sy-subrc <> 0.
    ev_status  = 'E'.
    ev_message = '존재하지 않는 공급업체번호입니다.'.
    RETURN.
  ENDIF.

  " 3. 성공
  ev_status  = 'S'.
  ev_message = '공급업체 정보가 조회되었습니다.'.

ENDFUNCTION.




*ENDFUNCTION.
