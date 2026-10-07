*** Settings ***
Documentation       Smoke coverage for safe cart interaction; it never starts checkout.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Resource            ../../resources/pages/search.resource
Resource            ../../resources/pages/product.resource
Resource            ../../resources/pages/cart.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-006 Add Product To Cart
    [Tags]    smoke    cart    product
    Open Products Page
    Search For Product    ${DEFAULT_SEARCH_TERM}
    Open First Search Result
    ${product_name}=    Get Text    css=.product-information h2
    Add Current Product To Cart
    Open Cart
    Cart Should Contain Product    ${product_name}
