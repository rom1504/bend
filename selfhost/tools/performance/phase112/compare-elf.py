#!/usr/bin/env python3
"""Read-only ELF64 comparison authenticated against completed build receipts.

No subprocess, compiler or executable is launched. Section identity is evidence
about machine products, not proof of semantic equivalence or performance.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct


def digest(data):
    return hashlib.sha256(data).hexdigest()


def pin(path, data):
    return dict(file=str(path.resolve()), bytes=len(data), sha256=digest(data))


def slice_checked(data, offset, size):
    if offset < 0 or size < 0 or offset+size > len(data):
        raise ValueError("ELF region outside file")
    return data[offset:offset+size]


def load(receipt_path):
    raw = receipt_path.read_bytes()
    receipt = json.loads(raw)
    if receipt.get("complete") is not True or "binary" not in receipt:
        raise ValueError("Need a completed build receipt with binary pin")
    expected = receipt["binary"]
    path = Path(expected["file"])
    data = path.read_bytes()
    identity = pin(path, data)
    if identity["bytes"] != expected["bytes"] or identity["sha256"] != expected["sha256"]:
        raise ValueError("Binary differs from authenticated build receipt: " + str(path))
    if len(data) < 64 or data[:7] != b"\x7fELF\x02\x01\x01":
        raise ValueError("Only ELF64 little-endian v1 is supported")
    header = struct.unpack_from("<HHIQQQIHHHHHH", data, 16)
    typ, machine, version, entry, phoff, shoff, flags, ehsize, phentsize, phnum, shentsize, shnum, shstrndx = header
    if machine != 62 or typ not in (2, 3) or ehsize != 64 or shentsize != 64:
        raise ValueError("Only ordinary x86-64 executable ELF layout is supported")
    if not 0 < shnum < 4096 or not 0 <= shstrndx < shnum or phnum >= 4096:
        raise ValueError("Unsupported extended ELF indexes")
    if phnum and phentsize != 56:
        raise ValueError("Unexpected ELF program-header width")
    section_headers = [struct.unpack("<IIQQQQIIQQ", slice_checked(data, shoff+i*64, 64)) for i in range(shnum)]
    names_header = section_headers[shstrndx]
    names = slice_checked(data, names_header[4], names_header[5])
    sections = {}
    for item in section_headers:
        nameoff, kind, sflags, address, offset, size, link, info, align, entsize = item
        if nameoff >= len(names) or b"\0" not in names[nameoff:]:
            raise ValueError("Invalid ELF section-name offset")
        name = names[nameoff:names.index(b"\0", nameoff)].decode("ascii")
        if name in sections:
            raise ValueError("Duplicate ELF section name")
        # SHT_NOBITS has memory size but no bytes stored in the file.
        content = b"" if kind == 8 else slice_checked(data, offset, size)
        sections[name] = dict(type=kind, flags=sflags, address=address, memorySize=size,
            fileBytes=len(content), align=align, entrySize=entsize, sha256=digest(content),
            alloc=bool(sflags & 2), nobits=kind == 8)
    phdrs = [list(struct.unpack("<IIQQQQQQ", slice_checked(data, phoff+i*56, 56))) for i in range(phnum)]
    return dict(receipt=pin(receipt_path, raw), binary=identity,
                header=dict(type=typ, machine=machine, version=version, entry=entry, flags=flags),
                programHeaders=phdrs, sections=sections)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--left-receipt", required=True, type=Path)
    parser.add_argument("--right-receipt", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    args = parser.parse_args()
    if args.out.exists():
        raise ValueError("Output must be fresh")
    left, right = load(args.left_receipt), load(args.right_receipt)
    rows = []
    for name in sorted(left["sections"].keys() | right["sections"].keys()):
        a, b = left["sections"].get(name), right["sections"].get(name)
        rows.append(dict(name=name, left=a, right=b, same=a == b,
                         allocatedEither=bool((a and a["alloc"]) or (b and b["alloc"]))))
    result = dict(kind="phase112-authenticated-elf-section-comparison", complete=True,
        inputs=[{key:value[key] for key in ("receipt", "binary")} for value in (left,right)],
        binaryExact=left["binary"]["sha256"] == right["binary"]["sha256"],
        headersSame=left["header"] == right["header"],
        programHeadersSame=left["programHeaders"] == right["programHeaders"],
        allocatedSectionsSameExceptBuildId=all(r["same"] for r in rows if r["allocatedEither"] and r["name"] != ".note.gnu.build-id"),
        rows=rows, headers=[left["header"], right["header"]],
        programHeaders=[left["programHeaders"], right["programHeaders"]],
        method=pin(Path(__file__), Path(__file__).read_bytes()),
        scope="Authenticated read-only comparison. Memory size, flags, address and alignment are checked, including NOBITS. Only the explicitly named build-id section is excluded from the allocated-section summary. No semantic or speed claim.")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({key:result[key] for key in ("binaryExact", "headersSame", "programHeadersSame", "allocatedSectionsSameExceptBuildId")}))


if __name__ == "__main__":
    main()
