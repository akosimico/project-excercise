"""Optional, advisory-only Groq failure analysis for Robot Framework tests.

The static classification is always available. If Groq is configured, the
report also includes a clearly labelled AI hypothesis. No output from this
module affects Robot's authoritative pass/fail result.
"""

from __future__ import annotations

import json
import os
from datetime import datetime, timezone
from pathlib import Path
from dotenv import load_dotenv

from libraries.test_utils import slugify


class AIFailureAnalyzer:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, reports_dir: str | None = None) -> None:
        root = Path(__file__).resolve().parents[1]
        load_dotenv(root / ".env")
        self.reports_dir = Path(reports_dir) if reports_dir else root / "reports"

    def analyze_failure(
        self,
        test_name: str,
        failure: str,
        url: str = "Unavailable",
        screenshot: str = "Unavailable",
        recent_action: str = "See Robot Framework log for the last executed keyword.",
        expected: str = "See the Robot test's assertions and log for the expected behavior.",
    ) -> str:
        """Write a diagnostic report and return its path.

        This keyword is deliberately side-effect-only: callers invoke it after a
        failure and do not use its result in an assertion.
        """
        observed = {
            "test": test_name,
            "failure": failure or "No Robot Framework failure message was supplied.",
            "url": url or "Unavailable",
            "screenshot": screenshot or "Unavailable",
            "recent_action": recent_action,
            "expected": expected,
            "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        }
        category, cause, investigation = self._classify(observed["failure"])
        ai_section = self._optional_ai_hypothesis(observed, category)

        report = self._render_report(observed, category, cause, investigation, ai_section)
        output_dir = self.reports_dir / "ai-analysis"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / f"{slugify(test_name)}.txt"
        output_path.write_text(report, encoding="utf-8")
        return str(output_path)

    @staticmethod
    def _classify(failure: str) -> tuple[str, str, list[str]]:
        text = failure.lower()
        if any(token in text for token in ("not found", "did not match any elements", "invalid locator")):
            return (
                "Locator issue",
                "A locator did not resolve to a current page element.",
                ["Confirm the selector against the current DOM.", "Prefer a stable id, data attribute, or semantic selector.", "Check whether the page or modal changed before the lookup."],
            )
        if any(token in text for token in ("timed out", "not visible", "not clickable", "intercepted")):
            return (
                "Synchronization / timing",
                "The UI may not have reached the required visible or interactive state.",
                ["Check the relevant explicit wait condition.", "Look for an overlay, animation, or delayed request.", "Confirm the element is enabled before interacting."],
            )
        if any(token in text for token in ("should be", "should contain", "should have contained", "should not", "assert", "expected")):
            return (
                "Assertion failure",
                "The observed UI state differed from the test expectation.",
                ["Compare the expected value with the captured UI state.", "Validate whether test data or application content changed.", "Keep the assertion focused on a user-visible outcome."],
            )
        if any(token in text for token in ("connection", "dns", "network", "net::", "certificate")):
            return (
                "Environment / network issue",
                "The browser or test host could not reliably reach a required service.",
                ["Check network reachability and DNS.", "Check the target service status.", "Retry only after confirming this is transient."],
            )
        if any(token in text for token in ("url", "navigation", "location")):
            return (
                "Navigation issue",
                "The browser did not reach the expected page or route.",
                ["Review the destination URL and triggering action.", "Check redirects or consent/modals.", "Confirm the application route remains public."],
            )
        return (
            "Unknown",
            "The failure did not match a deterministic diagnostic signature.",
            ["Review the Robot log and screenshot.", "Reproduce once with the same test data.", "Classify only after collecting a concrete browser observation."],
        )

    @staticmethod
    def _optional_ai_hypothesis(observed: dict[str, str], category: str) -> str:
        api_key = os.getenv("GROQ_API_KEY", "").strip()
        if not api_key:
            return "Groq analysis unavailable: missing GROQ_API_KEY configuration. Static diagnostic classification was saved."
        try:
            from groq import Groq

            client = Groq(api_key=api_key)
            prompt = (
                "You are assisting an SDET. Use only the structured context below. Robot Framework already "
                "determined the test failed; never make pass/fail decisions. Distinguish observed facts from "
                "unconfirmed hypotheses and do not claim an application defect as fact. Return exactly these "
                "headings: Failure Category, Observed Facts, Likely Cause, Likely Source, Recommended "
                "Investigation, Confidence. Likely Source must be one of: Test automation issue, Environment "
                "issue, Potential application defect, Unknown.\n\n"
                + json.dumps({**observed, "deterministic_category": category}, indent=2)
            )
            response = client.chat.completions.create(
                model=os.getenv("GROQ_MODEL", "openai/gpt-oss-20b"),
                messages=[{"role": "user", "content": prompt}],
                temperature=0.2,
            )
            content = response.choices[0].message.content if response.choices else None
            if not content:
                raise ValueError("Groq returned no diagnostic content")
            return "Groq hypothesis (advisory; unconfirmed):\n" + content.strip()
        except Exception as exc:  # AI must never break test diagnostics.
            return f"Groq analysis unavailable: {type(exc).__name__}. Static diagnostic classification was saved."

    @staticmethod
    def _render_report(
        observed: dict[str, str], category: str, cause: str, investigation: list[str], ai_section: str
    ) -> str:
        steps = "\n".join(f"{index}. {step}" for index, step in enumerate(investigation, start=1))
        return f"""Failure Analysis
================

Observed facts
--------------
Test: {observed['test']}
Expected: {observed['expected']}
Failure: {observed['failure']}
URL: {observed['url']}
Screenshot: {observed['screenshot']}
Recent action: {observed['recent_action']}
Timestamp (UTC): {observed['timestamp_utc']}

Deterministic diagnostic classification
---------------------------------------
Likely category: {category}
Possible cause: {cause}
Suggested investigation:
{steps}

{ai_section}
"""
