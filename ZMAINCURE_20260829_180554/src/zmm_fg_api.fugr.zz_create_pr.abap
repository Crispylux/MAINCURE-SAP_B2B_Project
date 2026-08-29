*FUNCTION ZZ_CREATE_PR.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EV_BANFN) TYPE  BANFN
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"  TABLES
*"      T_PR_REQ TYPE  ZLMM_TT_PR_REQ
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(EV_BANFN) TYPE  BANFN
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"  TABLES
*"      T_PR_REQ TYPE  ZLMM_TT_PR_REQ
  FUNCTION zz_create_pr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     VALUE(EV_BANFN) TYPE BANFN
*"     VALUE(EV_STATUS) TYPE CHAR1
*"     VALUE(EV_MESSAGE) TYPE STRING
*"  TABLES
*"      T_PR_REQ STRUCTURE ZLMM_S_PR_REQ
*"----------------------------------------------------------------------

  DATA: lv_banfn  TYPE banfn,
        lv_bnfpo  TYPE bnfpo,
        lt_insert TYPE TABLE OF ztmmg00070,
        ls_insert TYPE ztmmg00070.

  CLEAR: ev_banfn, ev_status, ev_message.

  " 1. 입력 테이블 존재 여부 체크
  IF t_pr_req[] IS INITIAL.
    ev_status  = 'E'.
    ev_message = '전달된 아이템이 없습니다.'.
    RETURN.
  ENDIF.

  " 2. 필수값 / 자재마스터 검증
  LOOP AT t_pr_req INTO DATA(ls_req).

    IF ls_req-matnr IS INITIAL OR ls_req-menge IS INITIAL
    OR ls_req-meins IS INITIAL OR ls_req-werks IS INITIAL
    OR ls_req-lfdat IS INITIAL OR ls_req-bsart IS INITIAL.
      ev_status  = 'E'.
      ev_message = '필수 파라미터(단위/수량 등)가 누락되었습니다.'.
      RETURN.
    ENDIF.

    IF ls_req-menge <= 0.
      ev_status  = 'E'.
      ev_message = '필수 파라미터(단위/수량 등)가 누락되었습니다.'.
      RETURN.
    ENDIF.

    SELECT SINGLE matnr FROM mara INTO @DATA(lv_matnr_chk)
      WHERE matnr = @ls_req-matnr.
    IF sy-subrc <> 0.
      ev_status  = 'E'.
      ev_message = '자재 마스터에 존재하지 않는 자재입니다.'.
      RETURN.
    ENDIF.

  ENDLOOP.

  " 3. PR 번호 채번 (넘버레인지 오브젝트명은 실제 SNRO 등록값으로 교체 필요)
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZMM_PR'
    IMPORTING
      number      = lv_banfn
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc <> 0.
    ev_status  = 'E'.
    ev_message = 'PR 번호 채번에 실패했습니다.'.
    RETURN.
  ENDIF.

  " 4. 아이템 번호 부여 + INSERT 대상 구성
  lv_bnfpo = 0.
  LOOP AT t_pr_req INTO ls_req.
    lv_bnfpo = lv_bnfpo + 10.

    CLEAR ls_insert.
    ls_insert-banfn = lv_banfn.
    ls_insert-bnfpo = lv_bnfpo.
    ls_insert-bsart = ls_req-bsart.
    ls_insert-matnr = ls_req-matnr.
    ls_insert-menge = ls_req-menge.
    ls_insert-meins = ls_req-meins.
    ls_insert-werks = ls_req-werks.
    ls_insert-badat = sy-datum.
    ls_insert-lfdat = ls_req-lfdat.
    ls_insert-statu = 'N'.
    ls_insert-erdat = sy-datum.
    ls_insert-erzet = sy-uzeit.
    ls_insert-ernam = sy-uname.

    APPEND ls_insert TO lt_insert.
  ENDLOOP.

  " 5. DB INSERT
  INSERT ztmmg00070 FROM TABLE lt_insert.

  IF sy-subrc = 0.
    COMMIT WORK AND WAIT.
    ev_banfn   = lv_banfn.
    ev_status  = 'S'.
    ev_message = '구매요청이 성공적으로 생성되었습니다.'.
  ELSE.
    ROLLBACK WORK.
    ev_status  = 'E'.
    ev_message = 'DB 저장 중 오류가 발생했습니다.'.
  ENDIF.

ENDFUNCTION.
*"----------------------------------------------------------------------





*ENDFUNCTION.
