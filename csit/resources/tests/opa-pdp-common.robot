*** Settings ***

*** Keywords ***

Is Variable Dictionary
    [Arguments]  ${variable}
    ${is_dict}=  Set Variable    False
    ${status}    ${result}=    Run Keyword And Ignore Error    Should Contain    ${variable}    data
    Run Keyword If   '${status}'
    ...    Set Variable    ${is_dict}=    True  # It means it's a dictionary.
    RETURN    ${is_dict}
