"""Small deterministic helpers used by high-level Robot keywords."""

from __future__ import annotations

import re


def slugify(value: str) -> str:
    """Make a safe report filename without relying on platform-specific paths."""
    normalized = re.sub(r"[^a-z0-9]+", "-", value.lower()).strip("-")
    return normalized or "unnamed-test"
