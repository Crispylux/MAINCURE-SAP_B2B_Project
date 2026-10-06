# SAP-B2B-Project
## SAP B2B Team Project - SD<br>
매니큐어 회사를 가정해 회사 전반의 B2B 프로세스를 SAP로 구현하는 것을 목표로 합니다.

### 😊팀원 : 7명<br>
#### [SD]: 박규태, 정세영<br>
#### [MM]: 조윤서, 류재열<br>
#### [PP]: 김태희, 정재희<br>
#### [FI]: 김윤진(PM)
<br>

### 😊프로젝트 기간: 2026.03 ~ 2026.08

<br><br><br><br>


## 💠프로젝트 전체 flow
<img width="2880" height="1616" alt="Flow" src="https://github.com/user-attachments/assets/d3f3e96e-fe2b-41a6-b3d1-de3cae4c63ff" />

<br><br>

## 💠모듈별 프로그램 flow
<img width="2983" height="2302" alt="Program Flow" src="https://github.com/user-attachments/assets/3b5c6286-74be-48fc-97b2-ec7dee82cc52" />

<br><br>

## 💠[SD] TABLE - ERD
<img width="3323" height="3571" alt="ERD" src="https://github.com/user-attachments/assets/eb1deb99-93d4-43c1-ae86-646712558a13" />

<br><br>

## 💠[SD] 본인 파트 프로그램 구동 영상
#### ZLSDSMC010 : 구매 오더(SO) 생성
https://github.com/user-attachments/assets/b0fbd9b5-4cf3-4be1-989b-79fad7e59c82

<br>

#### ZLSDSMC020 : 대금청구서 생성

https://github.com/user-attachments/assets/f43117a9-dc2c-4f0d-9368-3f53136e8485



=====

### 성능 저하 개선 사례 기록
#### 문제점
ZLSDSMC010 - ZLSDSMC010_F01 : 테이블 데이터가 적을 때는 문제가 없었으나(100건 이하), 많아지면(1000건 이상부터) 심각한 병목 현상 발생.<br>
```
FORM search_quotation .
  DATA: lt_head TYPE TABLE OF ztsds00010,
        ls_head TYPE ztsds00010,
        ls_quot  TYPE ty_quot.

  CLEAR gt_quot.

  SELECT * FROM ztsds00010
    WHERE vbeln BETWEEN '0000000000' AND '0999999999'
      AND faksk = ' '
    INTO TABLE @lt_head.

  LOOP AT lt_head INTO ls_head.
    CLEAR ls_quot.
    ls_quot-vbeln = ls_head-vbeln.
    ls_quot-bstnk = ls_head-bstnk.
    ls_quot-vkbur = ls_head-vkbur.
    ls_quot-kunnr = ls_head-kunnr.
    ls_quot-vdatu = ls_head-vdatu.


    " 고객명
    SELECT SINGLE name1, adrnr
      FROM ztsds00070
      WHERE kunnr = @ls_head-kunnr
      INTO (@ls_quot-name1, @DATA(lv_adrnr)).

    " 배송지
    SELECT SINGLE street
      FROM ztsds00170
      WHERE addrnumber = @lv_adrnr
      INTO @ls_quot-street.

    " 담당자 이메일
    SELECT SINGLE smtp_addr
      FROM ztsds00090
      WHERE addrnumber = @lv_adrnr
      INTO @ls_quot-smtp_addr.

    " 담당자 전화번호
    SELECT SINGLE tel_number
      FROM ztsds00180
      WHERE addrnumber = @lv_adrnr
      INTO @ls_quot-tel_number.

    APPEND ls_quot TO gt_quot.
  ENDLOOP.

ENDFORM.
```

반복문 안에서 SELECT가 건수만큼 반복 실행되는 N+1 문제로 인해 병목이 발생했고, 그 결과 화면 로딩에 급격한 성능 저하가 나타남.

```
FORM search_quotation .
  CLEAR gt_quot.

  DATA: lv_name1          TYPE name1_gp,
        lv_name1_pattern  TYPE name1_gp.

  CLEAR gt_quot.

  "고객명 검색조건 - 부분일치해도 검색되게!
  IF iofield2 IS NOT INITIAL.
    lv_name1 = iofield2.
    TRANSLATE lv_name1 TO UPPER CASE. "대문자 변환해서 검색
    lv_name1_pattern = |%{ lv_name1 }%|.
  ENDIF.

  "데이터를 테이블에서 가져옴.
  SELECT  a~vbeln,
          a~bstnk,
          a~vkbur,
          a~kunnr,
          b~name1 AS name1,
          a~vdatu,
          c~street,
          c~name1 AS cont_name,
          d~smtp_addr,
          e~tel_number
  FROM ztsds00010 AS a
    JOIN ztsds00070 AS b ON b~kunnr = a~kunnr
    LEFT OUTER JOIN ztsds00170 AS c ON c~addrnumber = b~adrnr
    LEFT OUTER JOIN ztsds00090 AS d ON d~addrnumber = b~adrnr
    LEFT OUTER JOIN ztsds00180 AS e ON e~addrnumber = b~adrnr
  WHERE a~vbeln BETWEEN '0000000000' AND '0999999999'
    AND a~faksk = ' '
    AND ( @iofield1 IS INITIAL OR a~kunnr = @iofield1 )
    AND ( @lv_name1_pattern IS INITIAL OR UPPER( b~name1 ) LIKE @lv_name1_pattern )
    INTO TABLE @gt_quot.
  IF sy-subrc <> 0.
    MESSAGE '데이터가 없습니다.' TYPE 'S'.
  ELSE.
    MESSAGE |{ lines( gt_quot ) }건 조회되었습니다.| TYPE 'S'.
  ENDIF.

ENDFORM.
```



