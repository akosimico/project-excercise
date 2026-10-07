*** Settings ***
Documentation       Negative public search behavior.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Resource            ../../resources/pages/search.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-003 Search With Invalid Product Is Graceful
    [Tags]    regression    search    negative
    Open Products Page
    Search For Product    ${UNLIKELY_SEARCH_TERM}
    No Search Results Should Be Displayed
