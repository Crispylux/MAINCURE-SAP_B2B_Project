*&---------------------------------------------------------------------*
* 모듈/서브모듈    : SD/SLS
* Program ID  : ZLSDSMC010
* Desc        : [SD] 구매 오더(SO) 생성
* Transaction : ZLSDSMC010
* Creator     : 정세영 (SHAREDMAH60)
* Create day  : 2026.05.21
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.05.21    정세영              최초작성
* U01     2026.05.22    정세영              빈 화면+ALV 띄움
* U02     2026.06.22    정세영              SCREEN 틀 완성
* U02     ~2026.08.08   정세영              기본 기능 구현 완성
* U02     ~2026.08.11   정세영              다듬기-1(검색 기능 추가, 편의성 고려한 ui 수정)
*
*&---------------------------------------------------------------------*
REPORT ZLSDSMC010.

INCLUDE ZLSDSMC010_TOP.     " Global Data 선언
INCLUDE ZLSDSMC010_SEL.     " SELECTION 스크린 정의
INCLUDE ZLSDSMC010_F01.     " 서브루틴(FORM)
INCLUDE ZLSDSMC010_PBO.     " Process Before Output (화면 출력 전 처리)
INCLUDE ZLSDSMC010_PAI.     " Process After Input   (사용자 입력 후 처리)


*=====================================================
* Start Of Selection
*=====================================================
START-OF-SELECTION.
  CALL SCREEN 100.         " 스크린 호출
