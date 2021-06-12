*&---------------------------------------------------------------------*
*& Report Y_POST_JSON
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT y_post_json.

START-OF-SELECTION.

  CONSTANTS lc_content    TYPE string VALUE 'Content-Type'.
  CONSTANTS lc_contentval TYPE string VALUE 'application/json'.

  DATA lo_http_client TYPE REF TO if_http_client.
  DATA lv_httpcode    TYPE i.
  DATA lv_reason      TYPE string.

* データ抽出
  SELECT *
    FROM sflight
    INTO TABLE @DATA(lt_flightdata).

* 内部テーブルからJSONに変換
  DATA(lv_json) = /ui2/cl_json=>serialize( lt_flightdata ).

* 変換結果の確認
  cl_demo_output=>display_json( lv_json ).

* 宛先の設定
  CALL METHOD cl_http_client=>create_by_destination
    EXPORTING
      destination              = 'Z_HTTPBIN'  "SM59で作成した宛先
    IMPORTING
      client                   = lo_http_client
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6.
  IF sy-subrc <> 0.
* 省略
  ENDIF.

  lo_http_client->refresh_request( ).
  lo_http_client->request->set_version( if_http_request=>co_protocol_version_1_0 ).

* メソッドの設定(POST)
  CALL METHOD lo_http_client->request->set_method
    EXPORTING
      method = lo_http_client->request->co_request_method_post.

* ヘッダ部の設定
  CALL METHOD lo_http_client->request->set_header_field
    EXPORTING
      name  = lc_content
      value = lc_contentval.

* JSONデータの設定
  CALL METHOD lo_http_client->request->set_cdata
    EXPORTING
      data = lv_json.

* データ送信
  lo_http_client->send(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2 ).

* 送信結果の取得
  lo_http_client->receive(
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3 ).

* ステータス取得
  CALL METHOD lo_http_client->response->get_status
    IMPORTING
      code   = lv_httpcode
      reason = lv_reason.

* 結果出力
  WRITE lv_httpcode.
  WRITE lv_reason.
