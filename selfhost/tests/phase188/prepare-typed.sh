#!/bin/sh
set -eu
python3 -B selfhost/tests/phase181/prepare.py --parent-source "$1" \
 --module selfhost/tests/phase188/typed-controls.bend \
 --export p188tc_controls --export p188tc_object --export p188tc_assembly --out "$2"
