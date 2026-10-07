"""Environment-backed Robot Framework variables.

This module intentionally exposes only non-secret execution configuration.
AI credentials are read only inside the optional diagnostics library.
"""

from __future__ import annotations

import os
from pathlib import Path

from dotenv import load_dotenv


PROJECT_ROOT = Path(__file__).resolve().parents[1]
load_dotenv(PROJECT_ROOT / ".env")


def _boolean(value: str) -> bool:
    return value.strip().lower() in {"1", "true", "yes", "on"}


def get_variables() -> dict[str, object]:
    """Return Robot variables while allowing CLI variables to override them."""
    return {
        "BASE_URL": os.getenv("BASE_URL", "https://automationexercise.com").rstrip("/"),
        "BROWSER": os.getenv("BROWSER", "chrome"),
        "HEADLESS": _boolean(os.getenv("HEADLESS", "false")),
        "TIMEOUT": os.getenv("TIMEOUT", "12"),
        "PROJECT_ROOT": str(PROJECT_ROOT),
        "REPORTS_DIR": str(PROJECT_ROOT / "reports"),
    }
