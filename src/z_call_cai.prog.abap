*&---------------------------------------------------------------------*
*& Report Z_CALL_CAI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_call_cai.

SELECTION-SCREEN PUSHBUTTON 1(12) TEXT-b01 USER-COMMAND cai.

*Enter the value of SAP CAI
PARAMETERS src TYPE C LENGTH 100 OBLIGATORY LOWER CASE.
PARAMETERS cid TYPE C LENGTH 100 OBLIGATORY LOWER CASE.
PARAMETERS token TYPE C LENGTH 100 OBLIGATORY LOWER CASE.
PARAMETERS id TYPE C LENGTH 100 OBLIGATORY LOWER CASE.


AT SELECTION-SCREEN.

  CASE sy-ucomm.
    WHEN 'CAI'.
      DATA(html) = |<script src="{ src }" channelId="{ cid }" token="{ token }" id="{ id }"></script>'|.
      cl_demo_output=>display_html( html ).

    WHEN OTHERS.
  ENDCASE.
