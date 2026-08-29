FUNCTION ZZ_GET_CUSTOMER_NAME.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_KUNNR) TYPE  KUNNR
*"  EXPORTING
*"     REFERENCE(EV_KUNNR) TYPE  KUNNR
*"     REFERENCE(EV_NAME1) TYPE  NAME1_GP
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------


  " 1. 출력 데이터 초기화
  CLEAR: ev_kunnr, ev_name1, ev_status, ev_message.

  " 2. 입력값 검증 (고객번호 필수 입력 체크)
  IF iv_kunnr IS INITIAL.
    ev_status  = 'E'.
    ev_message = '고객번호는 필수 입력입니다.'.
    RETURN. " 로직 즉시 종료
  ENDIF.

  " 3. 알파 변환 (KUNNR 앞자리 zero-padding 처리)
  "    - 화면에서 '100'을 입력받더라도 마스터 테이블 데이터 형태인 '0000000100'으로 채워서 조회해야 정확히 검색됩니다.
  DATA: lv_kunnr TYPE kunnr.
  lv_kunnr = iv_kunnr.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_kunnr
    IMPORTING
      output = lv_kunnr.

  " 4. 고객 마스터 테이블(ZTSDS00070) 단건 조회
  SELECT SINGLE kunnr, name1
    FROM ztsds00070
   WHERE kunnr = @lv_kunnr
    INTO ( @ev_kunnr, @ev_name1 ).

  " 5. 결과 판별 및 출력 메시지 세팅
  IF sy-subrc = 0.
    ev_status  = 'S'.
    ev_message = '고객 정보가 조회되었습니다.'.
  ELSE.
    ev_status  = 'E'.
    ev_message = '존재하지 않는 고객번호입니다.'.
    ev_kunnr   = iv_kunnr.
  ENDIF.


ENDFUNCTION.
