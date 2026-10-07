*** Settings ***
Documentation       Category filtering coverage for the selected storefront.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Resource            ../../resources/pages/search.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-004 Filter Products By Category
    [Tags]    regression    filter    product
    Open Products Page
    Filter Products By Women Dresses Category
    Category Filter Should Be Applied
