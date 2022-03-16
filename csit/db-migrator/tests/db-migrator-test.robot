*** Settings ***
Suite Setup       Connect To Database    psycopg2    ${DB_NAME}    ${DB_USERNAME}    ${DB_PASSWORD}    ${POSTGRES_IP}    ${DB_PORT}
Suite Teardown    Disconnect From Database
Library           DatabaseLibrary
Library           String
Library           RequestsLibrary
Library           OperatingSystem
Library           json
Resource          ${CURDIR}/../../common-library.robot

*** Variables ***
${DB_NAME} =  policyadmin
${DB_USERNAME} =  policy_user
${DB_PASSWORD} =  policy_user
${DB_PORT} =  5432
${PGPASSWORD} =  policy_user

*** Keywords ***
GetReq
     [Arguments]  ${url}
     ${auth}=  PolicyAdminAuth
     ${resp}=  PerformGetRequest  ${POLICY_API_IP}  ${url}  200  null  ${auth}
     [return]  ${resp}

*** Test Cases ***
Test Connection
     ${output} =    Execute SQL String    SELECT datname FROM pg_database WHERE datname='policyadmin';
     Log    ${output}
     Should Be Equal As Strings    ${output}    None

Healthcheck
     [Documentation]  Verify policy api health check
     ${resp}=  GetReq  /policy/api/v1/healthcheck
     Should Be Equal As Strings  ${resp.json()['code']}  200