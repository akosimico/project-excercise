*** Settings ***
Resource            ../locators/product.resource

*** Keywords ***
Open First Search Result
    Wait Until Element Is Visible    ${FIRST_PRODUCT_DETAILS_LINK}
    ${product_url}=    Get Element Attribute    ${FIRST_PRODUCT_DETAILS_LINK}    href
    Go To    ${product_url}
    Wait Until Element Is Visible    ${PRODUCT_INFORMATION}

Product Details Should Be Complete
    Wait Until Element Is Visible    ${PRODUCT_NAME}
    Wait Until Element Is Visible    ${PRODUCT_PRICE}
    Element Text Should Not Be    ${PRODUCT_NAME}    ${EMPTY}

Add Current Product To Cart
    Wait Until Element Is Visible    ${ADD_TO_CART_BUTTON}
    Click Button    ${ADD_TO_CART_BUTTON}
    Wait Until Element Is Visible    ${ADDED_MODAL}

Open Cart
    Wait Until Element Is Visible    ${MODAL_VIEW_CART_LINK}
    Click Element    ${MODAL_VIEW_CART_LINK}
    Location Should Contain    /view_cart
