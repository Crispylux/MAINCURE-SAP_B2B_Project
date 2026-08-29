*&---------------------------------------------------------------------*
* 모듈/서브모듈    : SD/SLS
* Program ID  : ZLSDSMC020
* Desc        : [SD] 대금청구서 생성
* Transaction : ZLSDSMC020
* Creator     : 정세영 (SHAREDMAH60)
* Create day  : 2026.06.27
*&---------------------------------------------------------------------*
*              변경이력
*-------  ----------    ---------------   -----------------------------
* No      Changed On    Changed by        C/R Number
* New     2026.06.27    정세영              최초작성
* New     2026.07.02    정세영              화면 틀 완성
* U02     ~2026.08.02    정세영             SCREEN 틀 완성
* U02     ~2026.08.10   정세영              기본 기능 구현 완성
* U02     ~2026.08.11   정세영              다듬기-1(검색 기능 추가, 편의성 고려한 ui 수정)
*
*&----------- ~ 메모장 ~ ---------------------------------- -------------*
*
*
*&---------------------------------------------------------------------*
REPORT ZLSDSMC020.

INCLUDE ZLSDSMC020_TOP.     " Global Data 선언
INCLUDE ZLSDSMC020_SEL.     " SELECTION 스크린 정의
INCLUDE ZLSDSMC020_F01.     " 서브루틴(FORM)
INCLUDE ZLSDSMC020_PBO.     " Process Before Output (화면 출력 전 처리)
INCLUDE ZLSDSMC020_PAI.     " Process After Input   (사용자 입력 후 처리)


*=============================
* Start Of Selection
*=============================
START-OF-SELECTION.
  CALL SCREEN 100.         " 스크린 호출
