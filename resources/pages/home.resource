*** Settings ***
Resource            ../locators/home.resource

*** Keywords ***
Homepage Should Be Ready
    Title Should Be    Automation Exercise
    Wait Until Element Is Visible    ${HOME_LOGO}
    Wait Until Element Is Visible    ${PRIMARY_NAVIGATION}
    Wait Until Element Is Visible    ${HOME_FEATURED_ITEMS}

Open Products Page
    # Third-party advertising can intercept the public nav link. Use the
    # equivalent public route for feature setup; TC-001 verifies navigation.
    Go To    ${BASE_URL}/products
    Location Should Contain    /products
