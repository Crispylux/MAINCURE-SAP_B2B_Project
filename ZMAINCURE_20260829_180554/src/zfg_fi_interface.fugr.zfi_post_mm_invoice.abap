FUNCTION zfi_post_mm_invoice.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_MM_BELNR) TYPE  ZTMMG00190-BELNR
*"     VALUE(IV_GJAHR) TYPE  ZTMMG00190-GJAHR
*"  EXPORTING
*"     VALUE(EV_STATUS) TYPE  CHAR1
*"     VALUE(EV_MESSAGE) TYPE  BAPI_MSG
*"     VALUE(EV_BELNR) TYPE  BELNR_D
*"     VALUE(EV_GJAHR) TYPE  GJAHR
*"----------------------------------------------------------------------
  CONSTANTS:
    gc_blart         TYPE blart VALUE 'KR',
    gc_status_wait   TYPE char2 VALUE '10',
    gc_koart_gl      TYPE koart VALUE 'S',
    gc_koart_vendor  TYPE koart VALUE 'K',
    gc_debit         TYPE shkzg VALUE 'S',
    gc_credit        TYPE shkzg VALUE 'H',
    gc_hkont_asset   TYPE hkont VALUE '1500000000',
    gc_hkont_payable TYPE hkont VALUE '2000000000'.

  DATA:
    ls_rbkp       TYPE ztmmg00190,
    lt_rseg       TYPE TABLE OF ztmmg00200,
    ls_first_rseg TYPE ztmmg00200,
    ls_ekko       TYPE ztmmg00170,

    ls_bkpf       TYPE ztfic00010,
    lt_bseg       TYPE TABLE OF ztfic00020,
    ls_bseg       TYPE ztfic00020,
    ls_bsik       TYPE ztfic00030,

    lv_fi_belnr   TYPE belnr_d,
    lv_fi_gjahr   TYPE gjahr,
    lv_monat      TYPE monat,
    lv_number     TYPE nrlevel,
    lv_item_total TYPE ztmmg00190-rmwwr.

  CLEAR:
     ev_status,
     ev_message,
     ev_belnr,
     ev_gjahr.


  "입력값 검증
  IF iv_mm_belnr IS INITIAL OR
   iv_gjahr    IS INITIAL.

    ev_status  = 'E'.
    ev_message = 'MM 송장번호 또는 회계연도가 누락되었습니다.'.
    RETURN.
  ENDIF.

  " MM 송장 헤더 조회
  SELECT SINGLE *
FROM ztmmg00190
WHERE belnr = @iv_mm_belnr
  AND gjahr = @iv_gjahr
INTO @ls_rbkp.

  IF sy-subrc <> 0.
    ev_status  = 'E'.
    ev_message = '존재하지 않는 MM 송장입니다.'.
    RETURN.
  ENDIF.

  " MM 송장 아이템 조회

  SELECT *
  FROM ztmmg00200
  WHERE belnr = @iv_mm_belnr
    AND gjahr = @iv_gjahr
  INTO TABLE @lt_rseg.

  IF lt_rseg IS INITIAL.
    ev_status  = 'E'.
    ev_message = 'MM 송장 아이템이 존재하지 않습니다.'.
    RETURN.
  ENDIF.

  READ TABLE lt_rseg INTO ls_first_rseg INDEX 1.

  IF sy-subrc <> 0 OR
     ls_first_rseg-ebeln IS INITIAL.

    ev_status  = 'E'.
    ev_message = '송장과 연결된 구매오더번호가 없습니다.'.
    RETURN.
  ENDIF.

    LOOP AT lt_rseg INTO DATA(ls_check_rseg).

    IF ls_check_rseg-ebeln <> ls_first_rseg-ebeln.
      ev_status  = 'E'.
      ev_message = '하나의 송장에 여러 구매오더가 포함되어 있습니다.'.
      RETURN.
    ENDIF.

  ENDLOOP.

  " 구매오더 헤더 조회
  SELECT SINGLE *
    FROM ztmmg00170
    WHERE ebeln = @ls_first_rseg-ebeln
    INTO @ls_ekko.

  IF sy-subrc <> 0.
    ev_status  = 'E'.
    ev_message = '존재하지 않는 구매오더입니다.'.
    RETURN.
  ENDIF.

  " 송장과 구매오더의 회사코드 및 공급업체 확인
  IF ls_ekko-bukrs <> ls_rbkp-bukrs OR
     ls_ekko-lifnr <> ls_rbkp-lifnr.

    ev_status  = 'E'.
    ev_message = '송장과 구매오더 정보가 일치하지 않습니다.'.
    RETURN.
  ENDIF.

  " MM 송장 필수값 검사
  IF ls_rbkp-bukrs IS INITIAL OR
   ls_rbkp-lifnr IS INITIAL OR
   ls_rbkp-bldat IS INITIAL OR
   ls_rbkp-budat IS INITIAL OR
   ls_rbkp-waers IS INITIAL OR
   ls_rbkp-rmwwr IS INITIAL.

    ev_status  = 'E'.
    ev_message = 'MM 송장의 필수 정보가 누락되었습니다.'.
    RETURN.
  ENDIF.

  IF ls_rbkp-rmwwr <= 0.
    ev_status  = 'E'.
    ev_message = '송장금액은 0보다 커야 합니다.'.
    RETURN.
  ENDIF.

  "송장 품목 합계 검사
  CLEAR lv_item_total.

  LOOP AT lt_rseg INTO DATA(ls_amount_item).
    lv_item_total = lv_item_total + ls_amount_item-wrbtr.
  ENDLOOP.

  IF lv_item_total <> ls_rbkp-rmwwr.
    ev_status  = 'E'.
    ev_message = '송장 헤더금액과 품목금액 합계가 일치하지 않습니다.'.
    RETURN.
  ENDIF.

  " 중복 반영 검사
  IF ls_rbkp-xblnr IS INITIAL.
    ev_status  = 'E'.
    ev_message = '송장 참조번호가 누락되었습니다.'.
    RETURN.
  ENDIF.

  SELECT SINGLE
         a~belnr,
         a~gjahr
    FROM ztfic00010 AS a
    INNER JOIN ztfic00020 AS b
      ON  b~bukrs = a~bukrs
      AND b~belnr = a~belnr
      AND b~gjahr = a~gjahr
    WHERE a~bukrs = @ls_rbkp-bukrs
      AND a~blart = @gc_blart
      AND a~xblnr = @ls_rbkp-xblnr
      AND b~koart = @gc_koart_vendor
      AND b~lifnr = @ls_rbkp-lifnr
    INTO @DATA(ls_duplicate).

  IF sy-subrc = 0.
    ev_status  = 'E'.
    ev_message = '이미 FI 회계 반영된 송장입니다.'.
    ev_belnr   = ls_duplicate-belnr.
    ev_gjahr   = ls_duplicate-gjahr.
    RETURN.
  ENDIF.

  " 회계연도 및 회계기간 산출
  lv_fi_gjahr = ls_rbkp-budat(4).
  lv_monat    = ls_rbkp-budat+4(2).

  " FI 전표번호 채번
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZFI_BELNR'
      quantity                = 1
    IMPORTING
      number                  = lv_number
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  IF sy-subrc <> 0.
    ev_status  = 'E'.
    ev_message = 'FI 전표번호 채번에 실패했습니다.'.
    RETURN.
  ENDIF.

  lv_fi_belnr = lv_number.
  " FI 헤더 구성
  CLEAR ls_bkpf.

  ls_bkpf-bukrs = ls_rbkp-bukrs.
  ls_bkpf-belnr = lv_fi_belnr.
  ls_bkpf-gjahr = lv_fi_gjahr.
  ls_bkpf-blart = gc_blart.
  ls_bkpf-bldat = ls_rbkp-bldat.
  ls_bkpf-budat = ls_rbkp-budat.
  ls_bkpf-monat = lv_monat.
  ls_bkpf-waers = ls_rbkp-waers.
  ls_bkpf-xblnr = ls_rbkp-xblnr.
  ls_bkpf-usnam = sy-uname.
  ls_bkpf-erdat = sy-datum.
  ls_bkpf-erzet = sy-uzeit.
  ls_bkpf-ernam = sy-uname.

  " FI 차변 라인
  CLEAR ls_bseg.

  ls_bseg-bukrs = ls_rbkp-bukrs.
  ls_bseg-belnr = lv_fi_belnr.
  ls_bseg-gjahr = lv_fi_gjahr.
  ls_bseg-buzei = '001'.
  ls_bseg-koart = gc_koart_gl.
  ls_bseg-hkont = gc_hkont_asset.
  ls_bseg-dmbtr = ls_rbkp-rmwwr.
  ls_bseg-wrbtr = ls_rbkp-rmwwr.
  ls_bseg-waers = ls_rbkp-waers.
  ls_bseg-shkzg = gc_debit.
  ls_bseg-sgtxt = '비품 및 자산 취득'.
  ls_bseg-ebeln = ls_first_rseg-ebeln.
  ls_bseg-erdat = sy-datum.
  ls_bseg-erzet = sy-uzeit.
  ls_bseg-ernam = sy-uname.

  APPEND ls_bseg TO lt_bseg.

  " 공급업체 대변 라인

  CLEAR ls_bseg.

  ls_bseg-bukrs = ls_rbkp-bukrs.
  ls_bseg-belnr = lv_fi_belnr.
  ls_bseg-gjahr = lv_fi_gjahr.
  ls_bseg-buzei = '002'.
  ls_bseg-koart = gc_koart_vendor.
  ls_bseg-hkont = gc_hkont_payable.
  ls_bseg-lifnr = ls_rbkp-lifnr.
  ls_bseg-dmbtr = ls_rbkp-rmwwr.
  ls_bseg-wrbtr = ls_rbkp-rmwwr.
  ls_bseg-waers = ls_rbkp-waers.
  ls_bseg-shkzg = gc_credit.
  ls_bseg-sgtxt = '공급업체 미지급금'.
  ls_bseg-ebeln = ls_first_rseg-ebeln.
  ls_bseg-erdat = sy-datum.
  ls_bseg-erzet = sy-uzeit.
  ls_bseg-ernam = sy-uname.

  APPEND ls_bseg TO lt_bseg.

  " 공급업체 미결 항목

  CLEAR ls_bsik.

  ls_bsik-bukrs  = ls_rbkp-bukrs.
  ls_bsik-belnr  = lv_fi_belnr.
  ls_bsik-gjahr  = lv_fi_gjahr.
  ls_bsik-buzei  = '002'.
  ls_bsik-lifnr  = ls_rbkp-lifnr.
  ls_bsik-bldat  = ls_rbkp-bldat.
  ls_bsik-budat  = ls_rbkp-budat.
  ls_bsik-wrbtr  = ls_rbkp-rmwwr.
  ls_bsik-waers  = ls_rbkp-waers.
  ls_bsik-zfbdt  = ls_rbkp-budat.
  ls_bsik-zterm  = ls_ekko-zterm.
  ls_bsik-ebeln  = ls_first_rseg-ebeln.
  ls_bsik-status = gc_status_wait.

  CLEAR:
    ls_bsik-apprnm,
    ls_bsik-apprdt,
    ls_bsik-paymdt.

  ls_bsik-erdat = sy-datum.
  ls_bsik-erzet = sy-uzeit.
  ls_bsik-ernam = sy-uname.

  " DB 저장
  INSERT ztfic00010 FROM @ls_bkpf.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    ev_status  = 'E'.
    ev_message = 'FI 전표 헤더 생성에 실패했습니다.'.
    RETURN.
  ENDIF.

  INSERT ztfic00020 FROM TABLE @lt_bseg.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    ev_status  = 'E'.
    ev_message = 'FI 전표 라인 생성에 실패했습니다.'.
    RETURN.
  ENDIF.

  INSERT ztfic00030 FROM @ls_bsik.

  IF sy-subrc <> 0.
    ROLLBACK WORK.
    ev_status  = 'E'.
    ev_message = '공급업체 미결 항목 생성에 실패했습니다.'.
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT. " test용 mm에서 commit 하세용

  " 성공 값 반환
  ev_status  = 'S'.
  ev_message = 'FI 회계 반영이 완료되었습니다.'.
  ev_belnr   = lv_fi_belnr.
  ev_gjahr   = lv_fi_gjahr.


ENDFUNCTION.
