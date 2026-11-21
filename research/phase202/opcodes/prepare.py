"""Generate a checked Bend opcode decoder from the frozen scalar and CMOV tables."""
from collections import Counter
from pathlib import Path
import re

def declaration(text, name):
    start = text.index("def " + name + "(")
    end = text.index("\n\n", start)
    return text[start:end]

def apply(text):
    regular = declaration(text, "x187_e_spec")
    cmov = declaration(text, "x191cm_spec")
    rows = dict(re.findall(r'String.eq\(op,"(\w+)"\),u => (X187Op\{[\d,]+\})', regular + cmov))
    assert "String.eq(op,\"comiss\"),v => 47,v => 46" in regular
    rows.update(comiss="X187Op{7,128,47,0,0}", ucomiss="X187Op{7,128,46,0,0}")
    assert set(rows) == set(re.findall(r'String.eq\(op,"(\w+)"\)', regular + cmov))
    calls = Counter(re.findall(r'x188_i[012]\("(\w+)"', text))
    # Every bucket still compares the complete suffix. Unknown spellings fail.
    chunks = [regular.splitlines()[0], "  match op:", "    case SNil{}: X187OpNone{}", "    case SCon{head,+tail}:", "      x202o_dispatch(Char.to_u32(head),tail)", "", "@unsafe", "def x202o_dispatch(initial: U32, +tail: String) -> X187Op:", "  match initial:"]
    for initial in sorted({name[0] for name in rows}, key=lambda c: (-sum(calls[n] for n in rows if n[0] == c), c)):
        names = sorted((n for n in rows if n.startswith(initial)), key=lambda n: (-calls[n], n))
        chunks.append(f"    case {ord(initial)}:")
        for n in names:
            chunks.append(f'      nt_choose(X187Op,String.eq(tail,"{n[1:]}"),u => {rows[n]},u =>')
        chunks.append("      X187OpNone{}" + ")" * len(names))
    chunks.append("    case _: X187OpNone{}")
    return text.replace(regular, "\n".join(chunks))

if __name__ == "__main__":
    import argparse
    p = argparse.ArgumentParser()
    p.add_argument("input", type=Path)
    p.add_argument("output", type=Path)
    a = p.parse_args()
    with a.output.open("x") as out:
        out.write(apply(a.input.read_text()))
