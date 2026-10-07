*** Settings ***
Documentation       Smoke coverage for public homepage availability and essential UI.
Resource            ../../resources/common.resource
Resource            ../../resources/pages/home.resource
Test Setup          Open Storefront
Test Teardown       Run Keywords    Capture Failure Diagnostics    AND    Close Storefront

*** Test Cases ***
TC-001 Homepage Loads Successfully
    [Tags]    smoke    homepage
    Homepage Should Be Ready
