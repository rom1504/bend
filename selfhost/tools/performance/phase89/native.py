#!/usr/bin/env python3
"""Guarded Phase89 native compiler: one source importing Base, nine IO providers.

Uses the qualified native image and preserves the Phase88 launcher protocol.
Python authenticates and transports files; compilation runs in native Bend.
"""
import importlib.util
import sys
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from admission import authenticate


def main():
    # A private module instance changes no historical source or shared admission.
    path = HERE.parent / 'phase88/native.py'
    sys.path.insert(0, str(path.parent))
    spec = importlib.util.spec_from_file_location('_phase89_native_launcher', path)
    launcher = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(launcher)
    launcher.authenticate = authenticate
    launcher.__doc__ = __doc__
    return launcher.main()


if __name__ == '__main__':
    sys.exit(main())
