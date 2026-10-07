*** Settings ***
Documentation       Smoke coverage for a product-details journey.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Resource            ../../resources/pages/search.resource
Resource            ../../resources/pages/product.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-005 Open Product Details
    [Tags]    smoke    product
    Open Products Page
    Search For Product    ${DEFAULT_SEARCH_TERM}
    Search Results Should Be Displayed
    Open First Search Result
    Product Details Should Be Complete
