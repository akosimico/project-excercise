*** Settings ***
Documentation       Regression coverage for safe cart removal.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Resource            ../../resources/pages/search.resource
Resource            ../../resources/pages/product.resource
Resource            ../../resources/pages/cart.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-008 Remove Product From Cart
    [Tags]    regression    cart
    Open Products Page
    Search For Product    ${DEFAULT_SEARCH_TERM}
    Open First Search Result
    Add Current Product To Cart
    Open Cart
    Remove Product From Cart
    Cart Should Be Empty
