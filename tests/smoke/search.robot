*** Settings ***
Documentation       Smoke coverage for a public product search journey.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Resource            ../../resources/pages/search.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-002 Search For Existing Product
    [Tags]    smoke    search
    Open Products Page
    Search For Product    ${DEFAULT_SEARCH_TERM}
    Search Results Should Be Displayed
