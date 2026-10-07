*** Settings ***
Resource            ../locators/search.resource

*** Keywords ***
Search For Product
    [Arguments]    ${search_term}
    Wait Until Element Is Visible    ${SEARCH_INPUT}
    Input Text    ${SEARCH_INPUT}    ${search_term}
    Click Button    ${SEARCH_SUBMIT_BUTTON}
    Wait Until Element Is Visible    ${SEARCHED_PRODUCTS_HEADING}

Search Results Should Be Displayed
    Wait Until Element Is Visible    ${PRODUCT_CARD}
    ${names}=    Get WebElements    ${PRODUCT_NAME_IN_CARD}
    Should Not Be Empty    ${names}    Search results should expose at least one product name.

No Search Results Should Be Displayed
    Wait Until Element Is Visible    ${SEARCHED_PRODUCTS_HEADING}
    Wait Until Keyword Succeeds    8 seconds    500 milliseconds    Page Should Not Contain Element    ${PRODUCT_CARD}

Filter Products By Women Dresses Category
    Wait Until Element Is Visible    ${WOMEN_CATEGORY_LINK}
    Click Element    ${WOMEN_CATEGORY_LINK}
    Wait Until Element Is Visible    ${WOMEN_DRESS_LINK}
    Click Element    ${WOMEN_DRESS_LINK}
    Wait Until Element Is Visible    ${CATEGORY_TITLE}

Category Filter Should Be Applied
    ${category_title}=    Get Text    ${CATEGORY_TITLE}
    Should Match Regexp    ${category_title}    (?i)^women\s*-\s*dress\s*products$
    Wait Until Element Is Visible    ${PRODUCT_CARD}
