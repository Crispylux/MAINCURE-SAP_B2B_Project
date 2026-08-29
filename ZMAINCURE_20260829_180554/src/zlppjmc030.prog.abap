*&---------------------------------------------------------------------*
* 모듈/서브모듈    : PP
* Program ID  : ZLPPJMC030
* Desc        : [MC] 설명 작성. 이때 MC는 저희 패키지명에서 따왔습니다
* Transaction : ZLPPJMC030
* Creator     : 정재희
* Create day  : 2026.07.01
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.07.01    정재희              최초작성
*&---------------------------------------------------------------------*
REPORT ZLPPJMC030.

INCLUDE ZLPPJMC030_TOP. "전역변수, 인터널테이블, 클래스 객체 선언
INCLUDE ZLPPJMC030_C01.
INCLUDE ZLPPJMC030_SEL. "PARAMETERS, SELECT-OPTIONS (조회 조건)
INCLUDE ZLPPJMC030_F01. "FORM 서브루틴 (SELECT, 데이터 가공, 필드카탈로그)
INCLUDE ZLPPJMC030_PBO. "Process Before Output — CC/ALV 생성
INCLUDE ZLPPJMC030_PAI. "Process After Input — 버튼 이벤트 처리

*LOAD-OF-PROGRAM.
*INITIALIZATION.
*AT SELECTION-SCREEN.
START-OF-SELECTION.
  PERFORM GET_DATA.        " 데이터 조회
*  PERFORM SET_FIELDCAT.    " 필드카탈로그 세팅

END-OF-SELECTION.
  CALL SCREEN 100.         " 화면 호출 → 자동으로 PBO 실행됨
