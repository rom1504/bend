#!/usr/bin/env python3
"""Port research/phase200/ray/sqrt-regions.bend onto a compiler.bend source."""
import re
import sys
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
OVERLAY = ROOT / "research/phase200/ray/sqrt-regions.bend"

def parse_top_defs(text: str):
    """Split a Bend snippet into (name, full_block) pairs."""
    lines = text.splitlines(keepends=True)
    blocks = []
    cur = []
    cur_name = None
    for line in lines:
        if re.match(r"^(?:@unsafe\s*$|def\s+[A-Za-z0-9_]+\()", line):
            if line.startswith("@unsafe"):
                if cur_name is not None:
                    blocks.append((cur_name, "".join(cur)))
                    cur = []
                    cur_name = None
                cur.append(line)
            else:
                m = re.match(r"^def\s+([A-Za-z0-9_]+)\(", line)
                if cur_name is not None:
                    blocks.append((cur_name, "".join(cur)))
                    cur = []
                cur_name = m.group(1)
                cur.append(line)
        else:
            cur.append(line)
    if cur_name is not None:
        blocks.append((cur_name, "".join(cur)))
    return blocks

def replace_def(src: str, name: str, replacement: str) -> str:
    pattern = re.compile(
        rf"(?:^@unsafe\n)?^def {re.escape(name)}\(.*?(?=\n(?:@unsafe\n|def |type |law |# |\Z))",
        re.M | re.S,
    )
    matches = list(pattern.finditer(src))
    if len(matches) != 1:
        raise RuntimeError(f"Expected 1 definition of {name}, found {len(matches)}")
    m = matches[0]
    return src[:m.start()] + replacement.strip() + src[m.end():]

def insert_before(src: str, anchor: str, block: str) -> str:
    if src.count(anchor) != 1:
        raise RuntimeError(f"Anchor {anchor!r} count={src.count(anchor)}")
    return src.replace(anchor, block.strip() + "\n\n" + anchor, 1)

def main():
    src_path = Path(sys.argv[1])
    out_path = Path(sys.argv[2])
    src = src_path.read_text()
    blocks = dict((n, b.strip()) for n, b in parse_top_defs(OVERLAY.read_text()))

    # Insert new helpers in strict file-order respecting non-@unsafe dependencies
    patched = insert_before(src, "@unsafe\ndef x186_inline_op_when(", blocks.pop("x200r_sqrt_admitted"))
    patched = insert_before(patched, "@unsafe\ndef x186_float_operation(", blocks.pop("x200r_float_unary") + "\n\n" + blocks.pop("x200r_sqrt_buffer"))
    patched = insert_before(
        patched,
        "@unsafe\ndef x186_x_emit_node(",
        "\n\n".join([blocks.pop("x200r_sqrt_values"), blocks.pop("x200r_sqrt_core"), blocks.pop("x200r_sqrt_emit")]),
    )

    for name, block in blocks.items():
        patched = replace_def(patched, name, block)

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(patched)
    print(f"Wrote {out_path} ({len(patched)} bytes; +6 helpers, ~{len(blocks)} replaced)")

if __name__ == "__main__":
    main()
