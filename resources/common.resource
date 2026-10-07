*** Settings ***
Variables           ${CURDIR}${/}..${/}config${/}settings.py
Library             SeleniumLibrary
Library             OperatingSystem
Library             libraries.ai_failure_analyzer.AIFailureAnalyzer    ${REPORTS_DIR}
Resource            variables.resource

*** Keywords ***
Open Storefront
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Evaluate    $options.add_argument('--window-size=1440,1000')
    Evaluate    $options.add_argument('--disable-notifications')
    IF    $HEADLESS
        Evaluate    $options.add_argument('--headless=new')
    END
    Open Browser    ${BASE_URL}    ${BROWSER}    options=${options}
    Set Selenium Timeout    ${TIMEOUT} seconds
    Set Selenium Implicit Wait    0 seconds
    Maximize Browser Window
    Dismiss Optional Interstitial

Close Storefront
    Close All Browsers

Capture Failure Diagnostics
    Run Keyword If Test Failed    Capture Failure Artifacts

Capture Failure Artifacts
    Create Directory    ${REPORTS_DIR}${/}screenshots
    ${safe_name}=    Evaluate    re.sub(r'[^a-z0-9]+', '-', '''${TEST NAME}'''.lower()).strip('-') or 'unnamed-test'    re
    ${screenshot}=    Set Variable    ${REPORTS_DIR}${/}screenshots${/}${safe_name}.png
    Run Keyword And Ignore Error    Capture Page Screenshot    ${screenshot}
    ${url_status}    ${current_url}=    Run Keyword And Ignore Error    Get Location
    IF    '${url_status}' != 'PASS'
        ${current_url}=    Set Variable    Unavailable
    END
    ${analysis_path}=    Analyze Failure    ${TEST NAME}    ${TEST MESSAGE}    ${current_url}    ${screenshot}
    Log    Failure analysis saved to: ${analysis_path}    console=yes

Dismiss Optional Interstitial
    # Automation Exercise can display a Google vignette. Escape is ignored
    # when it is absent and does not alter storefront data.
    Run Keyword And Ignore Error    Press Keys    NONE    ESC
