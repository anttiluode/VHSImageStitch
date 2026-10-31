#!/usr/bin/env python3
"""Windows GUI entry point for the packaged VHSImageStitch application.

The repository's actual stitching engine lives in SweepAtlasSigh.txt; the
Windows build copies it to SweepAtlasSigh.py before PyInstaller runs.
"""
from __future__ import annotations

import os
from pathlib import Path
import sys
import traceback


def _prepare_logging() -> Path | None:
    """Windowed PyInstaller programs have no stdout/stderr on Windows."""
    if sys.stdout is not None and sys.stderr is not None:
        return None

    target = None
    try:
        base = Path(os.environ.get("LOCALAPPDATA") or Path.home())
        folder = base / "VHSImageStitch"
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / "vhsimagestitch.log"
        stream = target.open("a", encoding="utf-8", buffering=1)
    except (OSError, ValueError):
        stream = open(os.devnull, "w", encoding="utf-8")
        target = None

    if sys.stdout is None:
        sys.stdout = stream
    if sys.stderr is None:
        sys.stderr = stream
    return target


def main() -> int:
    log_path = _prepare_logging()
    try:
        from SweepAtlasSigh import main as run_app
        return int(run_app())
    except BaseException:
        traceback.print_exc()
        if sys.platform == "win32":
            try:
                import ctypes
                where = str(log_path) if log_path else "the Windows event log"
                ctypes.windll.user32.MessageBoxW(
                    None,
                    "VHSImageStitch encountered an error.\n\nDetails: " + where,
                    "VHSImageStitch",
                    0x10,
                )
            except Exception:
                pass
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
