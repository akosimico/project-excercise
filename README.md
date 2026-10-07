# SDET Web UI Automation Framework

A maintainable web UI automation project built with Robot Framework, SeleniumLibrary, Selenium, Python, and optional Groq-assisted failure analysis.

The suite safely tests the public [Automation Exercise](https://automationexercise.com) storefront. It covers public browsing and temporary anonymous cart behavior only. It does **not** register users, create orders, complete checkout, submit payment details, or perform destructive actions.

## What the suite covers

| ID | Scenario | Type |
| --- | --- | --- |
| TC-001 | Homepage loads with branding, navigation, and featured content | Smoke |
| TC-002 | Search for an existing product (`blue top`) | Smoke |
| TC-005 | Open product details and validate name and price | Smoke |
| TC-006 | Add a product to the cart and verify it is present | Smoke |
| TC-003 | Search with an unlikely product value | Regression / negative |
| TC-004 | Filter catalog to Women → Dress | Regression |
| TC-008 | Remove a product from the cart | Regression |

## Architecture

```text
tests/                 High-level test intent and assertions
  smoke/               Critical user journeys
  regression/          Negative and extended coverage

resources/
  pages/               Business-level page keywords
  locators/            Centralized Automation Exercise selectors
  common.resource      Browser lifecycle and diagnostics

libraries/
  ai_failure_analyzer.py
                       Deterministic + optional Groq diagnostics

config/settings.py     Environment-backed Robot variables
reports/               Generated Robot reports, screenshots, and analysis
```

Tests use high-level actions such as `Search For Product`, `Open First Search Result`, and `Add Current Product To Cart`; selectors and low-level Selenium actions remain in resource files.

## Prerequisites

- Python **3.10 or later**
- Google Chrome installed
- Git
- Internet access to `automationexercise.com`
- Optional: a Groq API key for AI-generated diagnostic hypotheses

## Setup on Windows PowerShell

### 1. Clone and enter the repository

```powershell
git clone <your-github-repository-url>
cd <your-repository-folder>
```

### 2. Create and activate the virtual environment

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

If PowerShell prevents activation, run this only for the current terminal and try again:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
```

### 3. Install the pinned dependencies

```powershell
python -m pip install --upgrade pip
pip install -r requirements.txt
```

### 4. Create local configuration

```powershell
Copy-Item .env.example .env
```

Open `.env` and use the following baseline configuration:

```env
BASE_URL=https://automationexercise.com
BROWSER=chrome
HEADLESS=true
TIMEOUT=12

GROQ_API_KEY=
GROQ_MODEL=openai/gpt-oss-20b
```

Configuration meanings:

| Setting | Purpose |
| --- | --- |
| `BASE_URL` | Public storefront opened by the framework. Do not hardcode it in tests. |
| `BROWSER` | Selenium browser name; the project is validated with `chrome`. |
| `HEADLESS` | `true` runs Chrome without a visible window; use `false` to watch the test. |
| `TIMEOUT` | Explicit Selenium wait timeout in seconds. |
| `GROQ_API_KEY` | Optional Groq key used only after a test has already failed. |
| `GROQ_MODEL` | Optional Groq diagnostic model; defaults to `openai/gpt-oss-20b`. |

Never commit `.env` or a real API key. `.env` is already ignored by Git.

## Execute tests

Always run Robot with `--pythonpath .`. This allows Robot to import the custom Python library from `libraries/`.

### Validate Robot syntax and imports first

This does not open a browser or contact the target site:

```powershell
robot --pythonpath . --dryrun tests
```

Expected result:

```text
7 tests, 7 passed, 0 failed
```

### Run the complete suite

```powershell
robot --pythonpath . --outputdir reports tests
```

### Run smoke tests only

```powershell
robot --pythonpath . --outputdir reports --include smoke tests
```

### Run regression tests only

```powershell
robot --pythonpath . --outputdir reports --include regression tests
```

### Run one test file

```powershell
robot --pythonpath . --outputdir reports tests\smoke\search.robot
```

### Watch browser execution

Either set `HEADLESS=false` in `.env`, or override it for one run:

```powershell
robot --pythonpath . --variable HEADLESS:false --outputdir reports --include smoke tests
```

## Read reports

After every execution, Robot Framework writes:

| File | Purpose |
| --- | --- |
| `reports/report.html` | Executive summary of test results. |
| `reports/log.html` | Keyword-by-key execution log and failure details. |
| `reports/output.xml` | Machine-readable Robot Framework execution output. |
| `reports/screenshots/` | Screenshot captured during a failed test. |
| `reports/ai-analysis/` | Deterministic and optional Groq diagnostic reports. |

Open the HTML report from PowerShell:

```powershell
Start-Process .\reports\report.html
```

## Optional Groq failure analysis

Robot Framework is the only authority for test pass/fail. The Groq integration does not retry tests, suppress failures, or decide whether a test passed.

When a test fails, the teardown captures the test name, failure message, current URL, recent action reference, timestamp, and screenshot path. The Python analyzer then:

1. Assigns a deterministic diagnostic category locally.
2. Writes a report under `reports/ai-analysis/`.
3. Calls Groq only if `GROQ_API_KEY` is configured.
4. Appends an advisory, explicitly unconfirmed hypothesis with likely cause, likely source, suggested investigation, and confidence.

To enable the optional live Groq path, add your own key to the ignored `.env` file:

```env
GROQ_API_KEY=your_key_here
```

If the key is absent, invalid, rate-limited, or Groq is unreachable, tests still run normally and the analyzer writes deterministic fallback information such as:

```text
Groq analysis unavailable: missing GROQ_API_KEY configuration.
```

## Troubleshooting

### Automation Exercise reports “website is under heavy load”

This is a public-site availability response. The test may fail because the target returned an overload page instead of the expected catalog/search page. Wait briefly and rerun the affected test; do not weaken assertions to treat the overload page as a valid result.

### A Google vignette covers an interaction

The common resource safely sends Escape to dismiss Automation Exercise’s occasional vignette. Product navigation follows the visible product result’s live URL to avoid forcing a click through a third-party overlay.

### `ModuleNotFoundError` for the custom library

Run the documented command from the repository root:

```powershell
robot --pythonpath . --outputdir reports tests
```

### Chrome does not launch

Confirm Chrome is installed, activate `.venv`, reinstall dependencies, and retry. Selenium Manager obtains the matching browser driver automatically.

## Safety and design decisions

- Tests → page keywords → common keywords → SeleniumLibrary keeps intent separate from implementation.
- Locators are centralized in `resources/locators/` and use stable IDs, semantic selectors, and routes where available.
- Explicit waits replace arbitrary `Sleep` calls.
- Each test gets a clean browser session and interacts only with an anonymous, temporary cart.
- No CAPTCHA bypass, account registration, payment, order completion, aggressive load testing, or destructive activity is performed.
