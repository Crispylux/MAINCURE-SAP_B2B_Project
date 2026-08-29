FUNCTION ZZ_SET_GR .
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_AUFNR) TYPE  ZTPPK00060-AUFNR
*"     REFERENCE(I_MATNR) TYPE  ZTMMG00010-MATNR
*"     REFERENCE(I_WERKS) TYPE  ZTMMG00040-WERKS
*"     REFERENCE(I_LGORT) TYPE  ZTMMG00040-LGORT
*"     REFERENCE(I_LM_MNG) TYPE  ZTMMG00090-MENGE
*"     REFERENCE(I_MEINS) TYPE  ZTMMG00010-MEINS
*"     REFERENCE(I_BUDAT) TYPE  ZTMMG00080-BUDAT
*"  EXPORTING
*"     REFERENCE(E_MBLNR) TYPE  ZTMMG00080-MBLNR
*"     REFERENCE(STATUS) TYPE  STATU
*"     REFERENCE(MESSAGE) TYPE  CHAR255
*"--------------------------------------------------------------------

  "=========================================================
  " 생산오더 + 구성품 + 재고 조회용
  "=========================================================
  TYPES:
    BEGIN OF ty_data,
      aufnr     TYPE ztppk00060-aufnr,
      fg_matnr  TYPE ztppk00060-matnr,
      werks     TYPE ztppk00060-dwerk,
      psmng     TYPE ztppk00060-psmng,
      fg_meins  TYPE ztppk00060-meins,

      rsnum     TYPE ztppj00060-rsnum,
      rspos     TYPE ztppj00060-rspos,
      comp_matnr TYPE ztppj00060-matnr,
      bdmng     TYPE ztppj00060-bdmng,
      kzear     TYPE ztppj00060-kzear,

      comp_meins TYPE ztmmg00010-meins,
      labst      TYPE ztmmg00040-labst,

      gi_qty     TYPE ztmmg00090-menge,
    END OF ty_data.

  DATA:
    lt_data  TYPE STANDARD TABLE OF ty_data,
    ls_data  TYPE ty_data,

    ls_mkpf  TYPE ztmmg00080,
    lt_mseg  TYPE STANDARD TABLE OF ztmmg00090,
    ls_mseg  TYPE ztmmg00090,
    ls_mard  TYPE ztmmg00040,

    lv_mblnr TYPE ztmmg00080-mblnr,
    lv_mjahr TYPE ztmmg00080-mjahr,
    lv_zeile TYPE ztmmg00090-zeile,
    lv_number TYPE n LENGTH 10.


  CLEAR:
    e_mblnr,
    status,
    message.

  status = 'E'.


  "=========================================================
  " 1. 필수값 검사
  "=========================================================
  IF i_aufnr  IS INITIAL OR
     i_matnr  IS INITIAL OR
     i_werks  IS INITIAL OR
     i_lgort  IS INITIAL OR
     i_lm_mng IS INITIAL OR
     i_meins  IS INITIAL OR
     i_budat  IS INITIAL.

    message = '필수 파라미터가 누락되었습니다.'.
    RETURN.

  ENDIF.


  "=========================================================
  " 2. 플랜트 / 저장위치 검사
  "=========================================================
  SELECT SINGLE werks
    FROM ztmmg00160
    WHERE werks = @i_werks
    INTO @DATA(lv_werks).

  IF sy-subrc <> 0.
    message = '존재하지 않는 플랜트입니다.'.
    RETURN.
  ENDIF.


  SELECT SINGLE lgort
    FROM ztmmg00220
    WHERE werks = @i_werks
      AND lgort = @i_lgort
    INTO @DATA(lv_lgort).

  IF sy-subrc <> 0.
    message = '존재하지 않는 저장위치입니다.'.
    RETURN.
  ENDIF.


  "=========================================================
  " 3. 생산오더 + 구성품 + 자재 + 현재재고 한 번에 조회
  "
  " ZTPPK00060 = ZAFPO
  " ZTPPJ00060 = ZRESB
  " ZTMMG00010 = ZMARA
  " ZTMMG00040 = ZMARD
  "=========================================================
  SELECT
         a~aufnr,
         a~matnr AS fg_matnr,
         a~dwerk AS werks,
         a~psmng,
         a~meins AS fg_meins,

         b~rsnum,
         b~rspos,
         b~matnr AS comp_matnr,
         b~bdmng,
         b~kzear,

         c~meins AS comp_meins,

         d~labst

    FROM ztppk00060 AS a

    INNER JOIN ztppj00060 AS b
      ON b~aufnr = a~aufnr

    INNER JOIN ztmmg00010 AS c
      ON c~matnr = b~matnr

    LEFT OUTER JOIN ztmmg00040 AS d
      ON  d~matnr = b~matnr
      AND d~werks = b~werks
      AND d~lgort = @i_lgort

    WHERE a~aufnr = @i_aufnr
      AND b~kzear = @space

    INTO CORRESPONDING FIELDS OF TABLE @lt_data.


  IF lt_data IS INITIAL.
    message = 'BOM 마스터 또는 생산오더 구성품 정보가 존재하지 않습니다.'.
    RETURN.
  ENDIF.


  "=========================================================
  " 4. 전달받은 완제품 정보 검증
  "=========================================================
  READ TABLE lt_data INTO ls_data INDEX 1.

  IF ls_data-fg_matnr <> i_matnr OR
     ls_data-werks    <> i_werks.

    message = '생산오더의 자재 또는 플랜트 정보가 일치하지 않습니다.'.
    RETURN.

  ENDIF.


  "=========================================================
  " 5. 구성품 GI 수량 계산 + 재고 검사
  "
  " BDMNG = 생산오더 전체 구성품 소요량
  "=========================================================
  LOOP AT lt_data INTO ls_data.

    ls_data-gi_qty =
        ls_data-bdmng
      * i_lm_mng
      / ls_data-psmng.

    IF ls_data-labst < ls_data-gi_qty.

      message =
        |자재 { ls_data-comp_matnr } 재고가 부족합니다.|.

      RETURN.

    ENDIF.

    MODIFY lt_data FROM ls_data.

  ENDLOOP.


  "=========================================================
  " 6. 자재문서 번호 채번
  "=========================================================
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '01'
      object      = 'ZMM_MBLN'
    IMPORTING
      number      = lv_number
    EXCEPTIONS
      OTHERS      = 1.

  IF sy-subrc <> 0.
    message = '자재문서 번호 채번에 실패했습니다.'.
    RETURN.
  ENDIF.


  lv_mblnr = lv_number.
  lv_mjahr = i_budat+0(4).


  "=========================================================
  " 7. 자재문서 헤더 생성
  " ZTMMG00080 = ZMKPF
  "=========================================================
  CLEAR ls_mkpf.

  ls_mkpf-mblnr = lv_mblnr.
  ls_mkpf-mjahr = lv_mjahr.
  ls_mkpf-vgart = 'WF'.
  ls_mkpf-blart = 'WA'.
  ls_mkpf-bldat = i_budat.
  ls_mkpf-budat = i_budat.
  ls_mkpf-cpudt = sy-datum.
  ls_mkpf-cputm = sy-uzeit.
  ls_mkpf-usnam = sy-uname.

  "생산오더 추적
  ls_mkpf-xblnr = i_aufnr.


  INSERT ztmmg00080 FROM @ls_mkpf.

  IF sy-subrc <> 0.
    ROLLBACK WORK.

    message = '자재문서 헤더 생성에 실패했습니다.'.
    RETURN.
  ENDIF.


  "=========================================================
  " 8. 완제품 101 입고
  "=========================================================
  CLEAR ls_mseg.

  lv_zeile = 1.

  ls_mseg-mblnr = lv_mblnr.
  ls_mseg-mjahr = lv_mjahr.
  ls_mseg-zeile = lv_zeile.

  ls_mseg-bwart = '101'.
  ls_mseg-matnr = i_matnr.
  ls_mseg-werks = i_werks.
  ls_mseg-lgort = i_lgort.

  ls_mseg-shkzg = 'S'.
  ls_mseg-menge = i_lm_mng.
  ls_mseg-meins = i_meins.

  APPEND ls_mseg TO lt_mseg.


  "=========================================================
  " 9. 구성품 261 자동 출고
  "=========================================================
  LOOP AT lt_data INTO ls_data.

    lv_zeile = lv_zeile + 1.

    CLEAR ls_mseg.

    ls_mseg-mblnr = lv_mblnr.
    ls_mseg-mjahr = lv_mjahr.
    ls_mseg-zeile = lv_zeile.

    ls_mseg-bwart = '261'.
    ls_mseg-matnr = ls_data-comp_matnr.
    ls_mseg-werks = i_werks.
    ls_mseg-lgort = i_lgort.

    ls_mseg-shkzg = 'H'.
    ls_mseg-menge = ls_data-gi_qty.
    ls_mseg-meins = ls_data-comp_meins.

    ls_mseg-rsnum = ls_data-rsnum.

    APPEND ls_mseg TO lt_mseg.

  ENDLOOP.


  INSERT ztmmg00090 FROM TABLE @lt_mseg.

  IF sy-subrc <> 0.
    ROLLBACK WORK.

    message = '자재문서 품목 생성에 실패했습니다.'.
    RETURN.
  ENDIF.


  "=========================================================
  " 10. 완제품 재고 증가
  "=========================================================
  SELECT SINGLE *
    FROM ztmmg00040
    WHERE matnr = @i_matnr
      AND werks = @i_werks
      AND lgort = @i_lgort
    INTO @ls_mard.


  IF sy-subrc = 0.

    ls_mard-labst =
      ls_mard-labst + i_lm_mng.

    UPDATE ztmmg00040 FROM @ls_mard.

  ELSE.

    CLEAR ls_mard.

    ls_mard-matnr = i_matnr.
    ls_mard-werks = i_werks.
    ls_mard-lgort = i_lgort.
    ls_mard-labst = i_lm_mng.

    INSERT ztmmg00040 FROM @ls_mard.

  ENDIF.


  IF sy-subrc <> 0.
    ROLLBACK WORK.

    message = '완제품 재고 반영에 실패했습니다.'.
    RETURN.
  ENDIF.


  "=========================================================
  " 11. 원자재 / 부품 재고 차감
  "=========================================================
  LOOP AT lt_data INTO ls_data.

    UPDATE ztmmg00040
       SET labst = labst - @ls_data-gi_qty
     WHERE matnr = @ls_data-comp_matnr
       AND werks = @i_werks
       AND lgort = @i_lgort.

    IF sy-subrc <> 0.

      ROLLBACK WORK.

      message =
        |자재 { ls_data-comp_matnr } 출고 처리에 실패했습니다.|.

      RETURN.

    ENDIF.

  ENDLOOP.


  "=========================================================
  " 12. 성공
  "=========================================================
  COMMIT WORK AND WAIT.

  e_mblnr = lv_mblnr.
  status   = 'S'.

  message =
    |생산 실적에 따른 완제품 입고 처리가 완료되었습니다. (자재문서: { lv_mblnr })|.


ENDFUNCTION.
