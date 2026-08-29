*FUNCTION ZZ_GET_STOCK_QTY.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_MATNR) TYPE  MATNR
*"     REFERENCE(IV_WERKS) TYPE  WERKS_D
*"  EXPORTING
*"     REFERENCE(EV_LABST) TYPE  LABST
*"     REFERENCE(EV_MEINS) TYPE  MEINS
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------
FUNCTION zz_get_stock_qty.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MATNR) TYPE MATNR
*"     VALUE(IV_WERKS) TYPE WERKS_D
*"  EXPORTING
*"     VALUE(EV_LABST) TYPE LABST
*"     VALUE(EV_MEINS) TYPE MEINS
*"     VALUE(EV_STATUS) TYPE CHAR1
*"     VALUE(EV_MESSAGE) TYPE STRING
*"----------------------------------------------------------------------

  DATA: lv_count TYPE i.

  CLEAR: ev_labst, ev_meins, ev_status, ev_message.

  " 1. 필수 입력값 체크
  IF iv_matnr IS INITIAL OR iv_werks IS INITIAL.
    ev_status  = 'E'.
    ev_message = '자재번호 또는 플랜트가 누락되었습니다.'.
    RETURN.
  ENDIF.

  " 2. 자재/플랜트 조합 존재 여부 확인
  SELECT COUNT(*)
    FROM ztmmg00040
    INTO @lv_count
    WHERE matnr = @iv_matnr
      AND werks = @iv_werks.

  IF lv_count = 0.
    ev_labst   = 0.
    ev_status  = 'E'.
    ev_message = '존재하지 않는 자재/플랜트 조합입니다.'.
    RETURN.
  ENDIF.

  " 3. 저장위치 전체 합산 재고 + 단위 조회
  SELECT SUM( labst ) AS labst
    FROM ztmmg00040
    INTO @ev_labst
    WHERE matnr = @iv_matnr
      AND werks = @iv_werks.

  SELECT SINGLE meins
    FROM ztmmg00040
    INTO @ev_meins
    WHERE matnr = @iv_matnr
      AND werks = @iv_werks.

  " 4. 성공
  ev_status  = 'S'.
  ev_message = '재고 조회가 완료되었습니다.'.

ENDFUNCTION.




*ENDFUNCTION.
