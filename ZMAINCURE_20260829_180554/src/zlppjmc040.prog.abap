*&---------------------------------------------------------------------*
* 모듈/서브모듈    : PP
* Program ID  : ZLPPJMC040
* Desc        : [MC] 설명 작성. 이때 MC는 저희 패키지명에서 따왔습니다
* Transaction : ZLPPJMC040
* Creator     : 정재희
* Create day  : 2026.07.01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.07.01    정재희              최초작성
*&---------------------------------------------------------------------*
REPORT ZLPPJMC040.

INCLUDE ZLPPJMC040_TOP. "전역변수, 인터널테이블, 클래스 객체 선언
INCLUDE ZLPPJMC040_SEL. "PARAMETERS, SELECT-OPTIONS (조회 조건)
INCLUDE ZLPPJMC040_F01. "FORM 서브루틴 (SELECT, 데이터 가공, 필드카탈로그)
INCLUDE ZLPPJMC040_PBO. "Process Before Output — CC/ALV 생성
INCLUDE ZLPPJMC040_PAI. "Process After Input — 버튼 이벤트 처리
