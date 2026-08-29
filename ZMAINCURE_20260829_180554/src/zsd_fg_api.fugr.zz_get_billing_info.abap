FUNCTION zz_get_billing_info.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_VBELN) TYPE  VBELN_VF OPTIONAL
*"  EXPORTING
*"     VALUE(EV_VBELN) TYPE  VBELN_VF
*"     VALUE(EV_KUNNR) TYPE  KUNNR
*"     VALUE(EV_BILL_AMT) TYPE  NETWR
*"     VALUE(EV_WAERS) TYPE  WAERK
*"     VALUE(EV_BILL_DATE) TYPE  FKDAT
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"     VALUE(EV_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------

  " 1. 출력 데이터 초기화
  CLEAR: ev_vbeln, ev_kunnr, ev_bill_amt, ev_waers,
         ev_bill_date, ev_status, ev_message.

  " 2. 입력값 검증 (Billing 번호 필수 입력 체크)
  IF iv_vbeln IS INITIAL.
    ev_status  = 'E'.
    ev_message = 'Billing 번호는 필수 입력입니다.'.
    RETURN.
  ENDIF.

  " 3. 알파 변환 (대금청구 번호 앞자리 zero-padding 처리)
  DATA: lv_vbeln TYPE vbeln_vf.
  lv_vbeln = iv_vbeln.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_vbeln
    IMPORTING
      output = lv_vbeln.

  " 4. 대금 청구 헤더 테이블(ZTSDS00030) 단건 조회
  SELECT SINGLE vbeln, kunrg, netwr, waerk, fkdat
    FROM ztsds00030
   WHERE vbeln = @lv_vbeln
    INTO ( @ev_vbeln, @ev_kunnr, @ev_bill_amt, @ev_waers, @ev_bill_date ).

  " 5. 결과 판별 및 출력 메시지/상태 세팅
  IF sy-subrc = 0.

    " 정상 조회 및 완료로 간주 시 성공 세팅
    ev_status  = 'S'.
    ev_message = 'Billing 정보가 조회되었습니다.'.

  ELSE.
    ev_status  = 'E'.
    ev_message = '존재하지 않는 Billing 번호입니다.'.
    ev_vbeln   = iv_vbeln. " 입력받은 원본 번호 반환
  ENDIF.

ENDFUNCTION.
