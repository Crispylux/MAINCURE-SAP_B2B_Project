*&---------------------------------------------------------------------*
*& Include          ZLFICMC040_TOP
*&---------------------------------------------------------------------*

TYPE-POOLS:
  abap,
  icon.

CONSTANTS:
  gc_acct_bs TYPE ztfic00110-acct_type VALUE 'BS',
  gc_acct_pl TYPE ztfic00110-acct_type VALUE 'PL'.

TYPES: BEGIN OF ty_list,

         acct_type  TYPE ztfic00110-acct_type,  " 재무상태표/손익계산서 구분
         sortno     TYPE ztfic00110-sortno,     " 출력 순서
         grp_cd     TYPE ztfic00110-grp_cd,     " 항목 코드
         grp_nm     TYPE ztfic00110-grp_nm,     " 항목명

         hkont_from TYPE ztfic00110-hkont_from, " 계정 시작 범위
         hkont_to   TYPE ztfic00110-hkont_to,   " 계정 종료 범위
         sign       TYPE ztfic00110-sign,       " 금액 부호 처리
         indent     TYPE ztfic00110-indent,     " Tree 계층 레벨
         is_total   TYPE ztfic00110-is_total,   " 합계 항목 여부

         curr_amt   TYPE ztfic00020-dmbtr,      " 당기 금액
         prev_amt   TYPE ztfic00020-dmbtr,      " 전기 금액
         diff_amt   TYPE ztfic00020-dmbtr,      " 증감액

         waers      TYPE ztfic00020-waers,      " 통화

         node_key   TYPE lvc_nkey,              " Tree 노드 키
         parent_key TYPE lvc_nkey,              " 상위 노드 키

       END OF ty_list.

DATA:
  gt_list TYPE TABLE OF ty_list,
  gs_list TYPE ty_list.

DATA:
  gt_tree TYPE TABLE OF ty_list,
  gs_tree TYPE ty_list.

*---------------------------------------------------------------------*
* ALV Object
*---------------------------------------------------------------------*
DATA:
  go_container TYPE REF TO cl_gui_custom_container,
  go_tree      TYPE REF TO cl_gui_alv_tree.

*---------------------------------------------------------------------*
* ALV Field Catalog / Layout
*---------------------------------------------------------------------*
DATA:
  gt_fcat             TYPE lvc_t_fcat,
  gs_fcat             TYPE lvc_s_fcat,
  gs_layout           TYPE lvc_s_layo,
  gs_hierarchy_header TYPE treev_hhdr.

*---------------------------------------------------------------------*
* OK Code
*---------------------------------------------------------------------*
DATA:
  gv_okcode TYPE sy-ucomm.
