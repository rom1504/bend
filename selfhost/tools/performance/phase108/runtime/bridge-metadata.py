#!/usr/bin/env python3
"""Add only portable transport macros to an old Bend-emitted C image.

This temporary bridge is for initial runtime controls. New compiler images emit
the same metadata in Bend's nb_bank; ordinary compilation must use that route.
No segment body or other C expression is parsed or changed here.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re


def add_metadata(source: bytes) -> tuple[bytes, int]:
    # Restrict admission to the complete exact declaration shape emitted by
    # nb_bank. The redundant BANK/ALL check catches incomplete or alien headers.
    pattern = rb"(?m)^#define WL_SIG Env e, Stk sp, u32 seq, u32 rn, (Term r[0-9]+(?:, Term (?:r[0-9]+|rp))*)\n"
    matches = list(re.finditer(pattern, source))
    if len(matches) != 1:
        raise ValueError("expected one exact Bend WL_SIG declaration")
    match = matches[0]
    names = [word.removeprefix(b"Term ") for word in match[1].split(b", ")]
    regs = [name for name in names if name != b"rp"]
    width = len(regs)
    want_regs = [b"r" + str(i).encode() for i in range(width)]
    want_names = want_regs[:6] + ([b"rp"] if width > 6 else []) + want_regs[6:]
    if width < 2 or names != want_names:
        raise ValueError("noncanonical Bend register sequence")
    bank = b"#define WL_BANK Term " + b", ".join(names) + b";\n"
    args = b"#define WL_ALL e, sp, seq, rn, " + b", ".join(names) + b"\n"
    if source.count(bank) != 1 or source.count(args) != 1:
        raise ValueError("WL_BANK or WL_ALL disagrees with WL_SIG")
    if re.search(rb"(?m)^#define WL_(?:WIDTH|INIT_BANK|WRITE_STATE|READ_STATE)\b", source):
        raise ValueError("portable metadata already present")
    store = b"".join(b"(V)[" + str(i).encode() + b"] = " + r + b"; " for i, r in enumerate(regs))
    load = b"".join(r + b" = (V)[" + str(i).encode() + b"]; " for i, r in enumerate(regs))
    if width > 6:
        load += b"rp = 0; "
    zero = b"".join(r + b" = 0; " for r in names)
    macros = (b"#define WL_WIDTH " + str(width).encode() + b"\n"
              + b"#define WL_INIT_BANK " + zero + b"\n"
              + b"#define WL_WRITE_STATE(V) " + store + b"\n"
              + b"#define WL_READ_STATE(V) " + load + b"\n")
    return source[:match.start()] + macros + source[match.start():], width


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--receipt", type=Path, required=True)
    args = parser.parse_args()
    if args.output.exists() or args.receipt.exists():
        raise ValueError("output and receipt must be fresh paths")
    source = args.input.read_bytes()
    result, width = add_metadata(source)
    args.output.write_bytes(result)
    args.receipt.write_text(json.dumps({
        "kind": "phase108-temporary-register-metadata-bridge",
        "version": 1,
        "input": str(args.input),
        "inputSha256": hashlib.sha256(source).hexdigest(),
        "output": str(args.output),
        "outputSha256": hashlib.sha256(result).hexdigest(),
        "registerWords": width,
        "insertedBytes": len(result) - len(source),
        "segmentBodiesChanged": False,
        "ordinaryPath": False,
    }, indent=2) + "\n")


if __name__ == "__main__":
    main()
