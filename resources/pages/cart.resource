*** Settings ***
Resource            ../locators/cart.resource

*** Keywords ***
Cart Should Contain Product
    [Arguments]    ${expected_product_name}
    Wait Until Element Is Visible    ${CART_ROWS}
    ${cart_text}=    Get Text    css=#cart_info_table
    Should Contain    ${cart_text}    ${expected_product_name}

Remove Product From Cart
    Wait Until Element Is Visible    ${CART_REMOVE_BUTTON}
    Click Element    ${CART_REMOVE_BUTTON}

Cart Should Be Empty
    Wait Until Keyword Succeeds    8 seconds    500 milliseconds    Page Should Not Contain Element    ${CART_ROWS}
