*===========================
*PBO
*===========================
PROCESS BEFORE OUTPUT.
  MODULE STATUS_0100.
  CALL SUBSCREEN TAB1_REF1 INCLUDING sy-repid '0101'.
  CALL SUBSCREEN TAB2_REF1 INCLUDING sy-repid '0102'.
  CALL SUBSCREEN TAB3_REF1 INCLUDING sy-repid '0103'.

*===========================
*PAI
*===========================
PROCESS AFTER INPUT.

  CHAIN.
    FIELD b1_field1.
    FIELD b1_field2.
    MODULE search_customer_input ON CHAIN-REQUEST.
  ENDCHAIN.
  CALL SUBSCREEN tab1_ref1.
  CALL SUBSCREEN tab2_ref1.
  CALL SUBSCREEN tab3_ref1.
  MODULE USER_COMMAND_0100.
