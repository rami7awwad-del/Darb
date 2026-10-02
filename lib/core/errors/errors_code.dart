// ignore_for_file: constant_identifier_names

enum ErrorCode {
  // HTTP Errors
  BAD_REQUEST,
  UNAUTHENTICATED,
  FORBIDDEN,
  NOT_FOUND,
  UNPROCESSABLE_ENTITY,
  TOO_MANY_REQUESTS,
  SERVER_ERROR,

  // Network Errors
  NO_INTERNET_CONNECTION,
  TIMEOUT,
  CANCEL,
  BAD_CERTIFICATE,

  // Business Errors
  PENDING_APPROVAL,
  NOT_EXIST_ACCOUNT,
  EXIST,

  // Application Errors
  APP_ERROR,
  USER_DATA_NOT_FOUND,
  UNKNOWN,
}
