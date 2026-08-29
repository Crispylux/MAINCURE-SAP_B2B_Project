FUNCTION ZZ_GET_SO_INFO.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(S_VBELN) TYPE  RANGE_C10_T
*"     REFERENCE(S_MATNR) TYPE  RANGE_T_MATNR OPTIONAL
*"     REFERENCE(S_KUNNR) TYPE  RANGE_C10_T OPTIONAL
*"     REFERENCE(S_VDATU) TYPE  RANGE_DATE_T OPTIONAL
*"  EXPORTING
*"     REFERENCE(ET_SD_INFO) TYPE  ZTSDFGAPI1
*"     REFERENCE(EV_STATUS) TYPE  CHAR1
*"     REFERENCE(EV_MESSAGE) TYPE  BAPI_MSG
*"----------------------------------------------------------------------

  " 1. 결과 데이터 초기화
  CLEAR: et_sd_info, ev_status, ev_message.

  " 2. 순수 SD 데이터만 조회 (ZTSDS00010, ZTSDS00020, ZTSDS00060, ZTSDS00070)
  SELECT a~vbeln,
         b~posnr,
         b~matnr,
         a~kunnr,
         d~name1,
         b~kwmeng,
         b~vrkme,
         c~edatu
    FROM ztsds00010 AS a
   INNER JOIN ztsds00020 AS b
      ON a~vbeln = b~vbeln
   INNER JOIN ztsds00060 AS c
      ON b~vbeln = c~vbeln
     AND b~posnr = c~posnr
    LEFT OUTER JOIN ztsds00070 AS d
      ON a~kunnr = d~kunnr
   WHERE a~vbeln IN @s_vbeln
     AND b~matnr IN @s_matnr
     AND a~kunnr IN @s_kunnr
     AND c~edatu IN @s_vdatu
    INTO CORRESPONDING FIELDS OF TABLE @et_sd_info.

  " 3. 성공 여부 판별
  IF sy-subrc = 0.
    ev_status  = 'S'.
    ev_message = '판매오더 연계 정보가 성공적으로 조회되었습니다.'.
  ELSE.
    ev_status  = 'E'.
    ev_message = '조건에 해당하는 판매오더 데이터가 없습니다.'.
  ENDIF.
ENDFUNCTION.
