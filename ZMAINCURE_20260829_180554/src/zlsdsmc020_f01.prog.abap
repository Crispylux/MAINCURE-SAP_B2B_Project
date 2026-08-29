*&---------------------------------------------------------------------*
*& Include          ZLSDSMC020_F01
*&---------------------------------------------------------------------*


CLASS lcl_alv_handler IMPLEMENTATION.
  METHOD handle_double_click.
    " 더블클릭된 행의 출고문서번호(VBELN)를 읽어서 우측 아이템 ALV(go_alv2)를 다시 채우는 로직
    READ TABLE gt_do_head INTO DATA(ls_head) INDEX e_row-index.

    IF sy-subrc = 0.
      gv_selected_vbeln = ls_head-vbeln.

      PERFORM get_do_item USING gv_selected_vbeln.
    ENDIF.
  ENDMETHOD.

"========================
"대금청구서 생성 팝업창 띄우기
"========================
  METHOD handle_button_click.
    CHECK es_col_id-fieldname = 'B_BILL'. "B_BILL 버튼만!

    READ TABLE gt_do_head INTO DATA(ls_head) INDEX es_row_no-row_id.

    IF sy-subrc = 0.
      gv_popup_vbeln = ls_head-vbeln.
      CALL SCREEN 200 STARTING AT 30 5
                      ENDING AT   120 30.
    ENDIF.
  ENDMETHOD.
ENDCLASS.


*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_data .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_fieldcat .

ENDFORM.



*&---------------------------------------------------------------------*
*& Form set_ccbox1_fieldcat
*&---------------------------------------------------------------------*
*& 출고문서헤더 필드카탈로그
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ccbox1_fieldcat .
  CLEAR gt_fcat1.

  DEFINE add_fcat.
    CLEAR gs_fcat1.
    gs_fcat1-fieldname  = &1.
    gs_fcat1-coltext    = &2.
    gs_fcat1-outputlen  = &3.
    gs_fcat1-emphasize = &4.
    APPEND gs_fcat1 TO gt_fcat1.
  END-OF-DEFINITION.

  add_fcat 'VBELN'      '출고문서번호' 10 'C110'.
  add_fcat 'VGBEL'      '참조 판매오더번호' 10 ''.
  add_fcat 'KUNNR'      '고객코드' 10 ''.
  add_fcat 'NAME1'      '고객명' 15 ''.
  add_fcat 'LAND1'      '국가코드' 5 ''.
  add_fcat 'WADAT_IST'  '출하일' 10 ''.
  add_fcat 'B_BILL'     '대금 청구서' 10 ''. "대금 청구서는 버튼으로 만들기
ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_ccbox2_fieldcat
*&---------------------------------------------------------------------*
*& 출고문서 세부정보 필드카탈로그
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ccbox2_fieldcat .
  CLEAR gt_fcat2.

  DEFINE add_fcat.
    CLEAR gs_fcat2.
    gs_fcat2-fieldname  = &1.
    gs_fcat2-coltext    = &2.
    gs_fcat2-outputlen  = &3.
    gs_fcat2-emphasize = &4.
    APPEND gs_fcat2 TO gt_fcat2.
  END-OF-DEFINITION.

  add_fcat 'VBELN'  '출고문서' 10 'C110'.
  add_fcat 'POSNR'  '항목번호' 4 ''.
  add_fcat 'MATNR'  '자재번호' 10 ''.
  add_fcat 'ARKTX'  '자재명' 20 ''.
  add_fcat 'LFIMG'  '납품수량' 10 ''.
  add_fcat 'VRKME'  '단위' 3 ''.
  add_fcat 'NETPR'  '개당 단가' 6 ''.
  add_fcat 'NETWR'  '공급가액(순금액)' 10 ''.
  add_fcat 'WAERK'  '통화' 3 ''.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_ccbox3_fieldcat
*&---------------------------------------------------------------------*
*& 대금청구서 조회 필드카탈로그
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_ccbox3_fieldcat .
  CLEAR gt_fcat3.

  DEFINE add_fcat.
    CLEAR gs_fcat3.
    gs_fcat3-fieldname  = &1.
    gs_fcat3-coltext    = &2.
    gs_fcat3-outputlen  = &3.
    gs_fcat3-emphasize = &4.
    APPEND gs_fcat3 TO gt_fcat3.
  END-OF-DEFINITION.

    add_fcat 'STATUS'    '지불여부' 4 ''.    "아이콘으로 표시되게 해야 함
    add_fcat 'VBELN'     '청구문서번호' 10 'C110'.
    add_fcat 'KUNRG'     '고객코드' 8 ''.
    add_fcat 'NAME1'     '고객명' 17 ''.
    add_fcat 'FKDAT'     '청구일자' 10 ''.
    add_fcat 'LAND1'     '국가코드' 5 ''.
    add_fcat 'NETWR'     '순청구금액' 10 ''.
    add_fcat 'MWSBK'     '총 부가세 금액' 10 ''.
*    add_fcat 'LOVFI'    '배송비' 8.
    add_fcat 'WAERK'     '통화' 3 ''.

  "지불여부 가운데 정렬
  READ TABLE gt_fcat3 INTO gs_fcat3 WITH KEY fieldname = 'STATUS'.
  IF sy-subrc = 0.
    gs_fcat3-just = 'C'.
    MODIFY gt_fcat3 FROM gs_fcat3 INDEX sy-tabix.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form search_quotation1
*&---------------------------------------------------------------------*
*& 출고문서조회 클릭 - 헤더 데이터 가지고 오기
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_quotation1 .
  CLEAR gt_do_head.

  DATA: lt_vbeln_by_item TYPE TABLE OF ztsds00140-vbeln.

  " 검색조건 - 판매오더번호(VGBEL) 조건이 있으면 아이템에서 먼저 대상 출고문서번호를 추려낸다
  IF b1_field4_1 IS NOT INITIAL OR b1_field4_2 IS NOT INITIAL.
    SELECT DISTINCT vbeln
      FROM ztsds00150
      WHERE ( @b1_field4_1 IS INITIAL OR vgbel >= @b1_field4_1 )
        AND ( @b1_field4_2 IS INITIAL OR vgbel <= @b1_field4_2 )
      INTO TABLE @lt_vbeln_by_item.

    IF lt_vbeln_by_item IS INITIAL.
      RETURN.   "조건에 맞는 출고문서가 없음
    ENDIF.
  ENDIF.

  "출고문서 헤더 조회 (검색조건 반영)
  SELECT lk~vbeln, lk~kunnr, lk~wadat_ist,
         kn~name1, kn~land1
    FROM ztsds00140 AS lk
    INNER JOIN ztsds00070 AS kn
      ON kn~kunnr = lk~kunnr
    WHERE ( @b1_field1_100_1 IS INITIAL OR lk~vbeln     >= @b1_field1_100_1 )
      AND ( @b1_field1_100_2 IS INITIAL OR lk~vbeln     <= @b1_field1_100_2 )
      AND ( @b1_field2_1     IS INITIAL OR lk~kunnr     >= @b1_field2_1 )
      AND ( @b1_field2_2     IS INITIAL OR lk~kunnr     <= @b1_field2_2 )
      AND ( @b1_field3_1     IS INITIAL OR lk~wadat_ist >= @b1_field3_1 )
      AND ( @b1_field3_2     IS INITIAL OR lk~wadat_ist <= @b1_field3_2 )
    INTO TABLE @DATA(lt_base).

  IF lt_base IS INITIAL.
    RETURN.
  ENDIF.

  "VGBEL 조건이 있었다면, (검색조건)결과와 교집합만 남긴다
  IF lt_vbeln_by_item IS NOT INITIAL.
    SORT lt_vbeln_by_item.
    LOOP AT lt_base INTO DATA(ls_check).
      READ TABLE lt_vbeln_by_item TRANSPORTING NO FIELDS
        WITH KEY table_line = ls_check-vbeln BINARY SEARCH.
      IF sy-subrc <> 0.
        DELETE lt_base.
      ENDIF.
    ENDLOOP.

    IF lt_base IS INITIAL.
      RETURN.
    ENDIF.
  ENDIF.

  "참조 SO번호/청구상태는 do 아이템에서 조회하기
  SELECT vbeln, vgbel, fksta
  FROM ztsds00150
    INTO TABLE @DATA(lt_item_ref)
    FOR ALL ENTRIES IN @lt_base
  WHERE vbeln = @lt_base-vbeln.

  LOOP AT lt_base INTO DATA(ls_base).
    DATA(ls_head) = VALUE ty_do_head(
                            vbeln     = ls_base-vbeln
                            kunnr     = ls_base-kunnr
                            name1     = ls_base-name1
                            land1     = ls_base-land1
                            wadat_ist = ls_base-wadat_ist ).

    READ TABLE lt_item_ref INTO DATA(ls_ref)
      WITH KEY vbeln = ls_base-vbeln.
    IF sy-subrc = 0.
      ls_head-vgbel  = ls_ref-vgbel.
      ls_head-fksta  = ls_ref-fksta.
    ENDIF.

    ls_head-b_bill = '대금청구서 생성'.

    CLEAR ls_head-celltab.
    APPEND VALUE lvc_s_styl(
      fieldname  = 'B_BILL'
      style      = cl_gui_alv_grid=>mc_style_button )
    TO ls_head-celltab.

    APPEND ls_head TO gt_do_head.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form search_quotation2
*&---------------------------------------------------------------------*
*& 출고문서 세부정보 데이터 (헤더 더블클릭할 때 호출됨!)
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_quotation2 .
  CLEAR gt_do_item.

  IF gv_selected_vbeln IS INITIAL.
    RETURN.
  ENDIF.

  PERFORM get_do_item USING gv_selected_vbeln.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form search_quotation3
*&---------------------------------------------------------------------*
*& 대금청구서 조회 데이터 가져오기!
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM search_quotation3 .
  CLEAR gt_bill.

  SELECT bk~vbeln, bk~kunrg, bk~fkdat, bk~land1,
         bk~netwr, bk~mwsbk, bk~waerk,
         kn~name1
    FROM ztsds00030 AS bk
    INNER JOIN ztsds00070 AS kn
      ON kn~kunnr = bk~kunrg
    INTO TABLE @DATA(lt_bill).

  LOOP AT lt_bill INTO DATA(ls_bill).
    APPEND VALUE ty_bill(
             status = icon_led_yellow "bi가 만들어질 순간에는 당연히 yellow여야!(아직 지불x이므로)
             vbeln  = ls_bill-vbeln
             kunnr  = ls_bill-kunrg
             name1  = ls_bill-name1
             fkdat  = ls_bill-fkdat
             land1  = ls_bill-land1
             netwr  = ls_bill-netwr
             mwsbk  = ls_bill-mwsbk
             waerk  = ls_bill-waerk )
           TO gt_bill.
  ENDLOOP.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form get_do_item
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GV_SELECTED_VBELN
*&---------------------------------------------------------------------*
FORM get_do_item  USING    p_gv_selected_vbeln.
  CLEAR gt_do_item.

  SELECT SINGLE waerk FROM ztsds00140
    INTO @DATA(lv_waerk)
    WHERE vbeln = @p_gv_selected_vbeln.

  SELECT li~vbeln, li~posnr, li~matnr, li~arktx,
         li~lfimg, li~vrkme,
         va~netpr
    FROM ztsds00150 AS li
    LEFT JOIN ztsds00020 AS va
      ON va~vbeln = li~vgbel
     AND va~posnr = li~vgpos
    INTO TABLE @DATA(lt_item)
    WHERE li~vbeln = @p_gv_selected_vbeln.

  LOOP AT lt_item INTO DATA(ls_item).
    APPEND VALUE ty_do_item(
             vbeln = ls_item-vbeln
             posnr = ls_item-posnr
             matnr = ls_item-matnr
             arktx = ls_item-arktx
             lfimg = ls_item-lfimg
             vrkme = ls_item-vrkme
             netpr = ls_item-netpr
             netwr = ls_item-netpr * ls_item-lfimg   "계산값
             waerk = lv_waerk )
           TO gt_do_item.
  ENDLOOP.

  " 화면이 이미 떠 있는 상태에서 더블클릭된 경우 그리드 갱신
  IF go_alv2 IS BOUND.
    go_alv2->refresh_table_display( ).
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form get_bill_popup_data
*&---------------------------------------------------------------------*
*& 스크린 200 - 대금청구서 생성 팝업창 데이터 가져오기
*&---------------------------------------------------------------------*
*&      --> GV_POPUP_VBELN
*&---------------------------------------------------------------------*
FORM get_bill_popup_data  USING    p_gv_popup_vbeln.
  CONSTANTS:
    gc_domestic_country  TYPE land1 VALUE 'KR',
    gc_tax_rate_domestic TYPE p DECIMALS 4 VALUE '0.10',
    gc_tax_rate_export   TYPE p DECIMALS 4 VALUE '0.00',
    gc_mwskz_domestic    TYPE mwskz VALUE 'A1',
    gc_mwskz_export      TYPE mwskz VALUE 'A0'.

  CLEAR: field1, field2, b1_field1_1, b1_field1_2, b1_field2, b1_field3,
         b1_field4, b1_field5, b2_field1, b2_field2, b2_field3,
         b2_field4, b2_field5, b2_field6_1, b2_field6_2.

  field1 = p_gv_popup_vbeln.


  SELECT SINGLE vgbel
    FROM ztsds00150
    INTO @field2
    WHERE vbeln = @p_gv_popup_vbeln.

  SELECT SINGLE kunnr
    FROM ztsds00140
    INTO @DATA(lv_kunnr)
    WHERE vbeln = @p_gv_popup_vbeln.

  b1_field1_1 = lv_kunnr.

  DATA: lv_name1 TYPE ztsds00070-name1,
        lv_land1 TYPE ztsds00070-land1.

  SELECT SINGLE name1, land1
    FROM ztsds00070
    INTO (@lv_name1, @lv_land1)
    WHERE kunnr = @lv_kunnr.

  b1_field1_2 = lv_name1.
  b1_field3   = lv_land1.

  " 배송지 - 이름+주소 합쳐서 한 칸에
  DATA: lv_addr_name TYPE ztsds00170-name1,
        lv_addr_str  TYPE ztsds00170-street.

  SELECT SINGLE t170~name1, t170~street
    FROM ztsds00190 AS t190
    INNER JOIN ztsds00170 AS t170
      ON t170~addrnumber = t190~adrnr
    INTO (@lv_addr_name, @lv_addr_str)
    WHERE t190~kunnr = @lv_kunnr.

  CONCATENATE lv_addr_name lv_addr_str INTO b1_field2 SEPARATED BY ', '.

  SELECT SINGLE bankn
    FROM ztsds00130
    INTO @b1_field4
    WHERE kunnr = @lv_kunnr.

  SELECT SINGLE smtp_addr
    FROM ztsds00090
    INTO @b1_field5
    WHERE addrnumber = ( SELECT adrnr FROM ztsds00190
                           WHERE kunnr = @lv_kunnr ).
  "순금액(계산한다!)
  SELECT li~lfimg, va~netpr
    FROM ztsds00150 AS li
    LEFT JOIN ztsds00020 AS va
      ON va~vbeln = li~vgbel
     AND va~posnr = li~vgpos
    INTO TABLE @DATA(lt_calc)
    WHERE li~vbeln = @p_gv_popup_vbeln.

  LOOP AT lt_calc INTO DATA(ls_calc).
    b2_field1 = b2_field1 + ( ls_calc-netpr * ls_calc-lfimg ).
  ENDLOOP.


  " 세금코드/부가세 - 고정 세율 규칙
  IF lv_land1 = gc_domestic_country.
    b2_field2 = gc_mwskz_domestic.
    b2_field3 = b2_field1 * gc_tax_rate_domestic.
  ELSE.
    b2_field2 = gc_mwskz_export.
    b2_field3 = b2_field1 * gc_tax_rate_export.
  ENDIF.

  b2_field4 = 0.   "배송비 초기값
  b2_field5 = 0.   "할인 초기값

  " 통화 - 출고문서 헤더 기준
  SELECT SINGLE waerk
    FROM ztsds00140
    INTO @b2_field6_2
    WHERE vbeln = @p_gv_popup_vbeln.

  PERFORM recalc_total.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form recalc_total
*&---------------------------------------------------------------------*
*& 총 청구금액 재계산 (배송비/할인 반영)
*&---------------------------------------------------------------------*
FORM recalc_total.
  b2_field6_1 = b2_field1 + b2_field3 + b2_field4 - b2_field5.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form create_billing
*&---------------------------------------------------------------------*
*& BI 생성
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_billing .
  DATA: lv_vbeln    TYPE ztsds00030-vbeln,
        lv_posnr    TYPE ztsds00040-posnr,
        ls_bi_head  TYPE ztsds00030,
        ls_bi_item  TYPE ztsds00040,
        lt_bi_item  TYPE TABLE OF ztsds00040.

  "=========================
  " 청구서 번호(VBELN) 채번 (SNRO)
  "=========================
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr = '02'
      object      = 'ZSD_VBELN'
    IMPORTING
      number      = lv_vbeln.

  IF lv_vbeln IS INITIAL.
    MESSAGE 'BI 번호 채번에 실패했습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  "=========================
  " 청구 대상 아이템 재조회 (FIELD1 기준으로)
  "=========================
  SELECT li~vbeln, li~posnr, li~matnr, li~arktx,
         li~lfimg, li~vrkme,
         va~netpr
    FROM ztsds00150 AS li
    LEFT JOIN ztsds00020 AS va
      ON va~vbeln = li~vgbel
     AND va~posnr = li~vgpos
    INTO TABLE @DATA(lt_item)
    WHERE li~vbeln = @field1.

  IF lt_item IS INITIAL.
    MESSAGE '청구할 아이템이 없습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  "=========================
  " BI헤더 세팅(30) *할인 반영함!
  "=========================
  ls_bi_head-mandt = sy-mandt.
  ls_bi_head-vbeln = lv_vbeln.
  ls_bi_head-fkart = 'F2'.
  ls_bi_head-fkdat = sy-datum.
  ls_bi_head-kunrg = b1_field1_1.
  ls_bi_head-netwr = b2_field1 - b2_field5.   " 순금액 - 할인 (헤더에만 반영)
  ls_bi_head-mwsbk = b2_field3.
  ls_bi_head-waerk = b2_field6_2.
  ls_bi_head-land1 = b1_field3.
*  ls_bi_head-lovfi = b2_field4.     "배송비 관리 컬럼(나중에 추가해도 됨. 지금은 db에 이게 안들어감)

  INSERT ztsds00030 FROM ls_bi_head.
  IF sy-subrc <> 0.
    MESSAGE '청구서 헤더 생성에 실패했습니다.' TYPE 'E'.
    RETURN.
  ENDIF.

  "=========================
  " BI헤더 세팅(30) *할인 미반영함
  "=========================
  lv_posnr = 0.
  LOOP AT lt_item INTO DATA(ls_item).
    lv_posnr = lv_posnr + 10.

    CLEAR ls_bi_item.
    ls_bi_item-mandt = sy-mandt.
    ls_bi_item-vbeln = lv_vbeln.
    ls_bi_item-posnr = lv_posnr.
    ls_bi_item-fkimg = ls_item-lfimg.
    ls_bi_item-vrkme = ls_item-vrkme.
    ls_bi_item-netwr = ls_item-netpr * ls_item-lfimg.  " 할인 반영X
    ls_bi_item-matnr = ls_item-matnr.
    ls_bi_item-arktx = ls_item-arktx.
    ls_bi_item-vgbel = ls_item-vbeln.
    ls_bi_item-vgpos = ls_item-posnr.

    APPEND ls_bi_item TO lt_bi_item.
  ENDLOOP.

  INSERT ztsds00040 FROM TABLE lt_bi_item.
  IF sy-subrc <> 0.
    MESSAGE '청구서 아이템 생성에 실패했습니다.' TYPE 'E'.
    DELETE ztsds00030 FROM ls_bi_head.   " 헤더 롤백함
    RETURN.
  ENDIF.

  "=========================
  " DO 아이템 청구상태 업데이트(fksta)
  "=========================
  UPDATE ztsds00150
  SET fksta = 'C'
  WHERE vbeln = field1.

  "=========================
  " 마무리 작업 - 화면 갱신, 팝업 닫기
  "=========================
  MESSAGE '대금청구서가 생성되었습니다.' TYPE 'S'.

  PERFORM search_quotation1.   " 상단 출고문서헤더 재조회 (청구상태 반영)
  PERFORM search_quotation3.   " 하단 대금청구서 조회 재조회

  IF go_alv1 IS BOUND.
    go_alv1->refresh_table_display( ).
  ENDIF.
  IF go_alv3 IS BOUND.
    go_alv3->refresh_table_display( ).
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.
