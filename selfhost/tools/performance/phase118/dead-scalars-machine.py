"""Read existing generated text only; never compile or run a target."""
import collections
import hashlib
import json
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[4]
output = Path(sys.argv[1]).resolve()
if output.exists():
    raise SystemExit("Fresh output file required")


def pin(path):
    data = path.read_bytes()
    return {"file": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def instructions(lines):
    return [line.strip() for line in lines if line.startswith("\t")
            and not line.lstrip().startswith(".")]


def counts(lines):
    ins = instructions(lines)
    ops = collections.Counter(line.split()[0] for line in ins)
    return {"instructions": len(ins),
            "conditionalJumps": sum(n for op, n in ops.items() if op.startswith("j") and op != "jmp"),
            "setcc": sum(n for op, n in ops.items() if op.startswith("set")),
            "cmov": sum(n for op, n in ops.items() if op.startswith("cmov")),
            "calls": sum(n for op, n in ops.items() if op.startswith("call")),
            "frameMemoryReferences": sum("%rbp)" in line or "%rsp)" in line for line in ins)}


report = {"kind": "phase118-dce-existing-machine-comparison", "complete": False,
          "method": pin(Path(__file__).resolve()), "targetsExecuted": False,
          "counting": "Static instruction lines, excluding directives/labels. Loop includes both selection paths, first body label through its explicit backedge. Frame references count textual rbp/rsp memory operands, not dynamic spills.",
          "roles": []}
for role, emit, build in [("parent", "broad-emit01", "p118-broad01"),
                          ("dce", "dce-emit03", "p118-dce03")]:
    emission = ROOT / "selfhost/build/phase118" / emit / "report.json"
    er = json.loads(emission.read_text())
    assert er["complete"]
    for case in ["mandelbrot", "lexer"]:
        qpath = emission.parent / (case + ".ssa")
        directory = ROOT / "selfhost/build/phase111" / (build + "-" + case + "-build")
        apath = directory / "program.s"
        qbe, asm = qpath.read_text(), apath.read_text()
        row = {"role": role, "case": case,
               "source": er["source"],
               "inputs": [pin(emission), pin(qpath), pin(apath),
                          pin(directory / "report.json"), pin(directory / "program")],
               "functions": []}
        wanted = ["$direct.mit"] if case == "mandelbrot" else [
            "$p118borrow.read.String.cmp", "$p118.trmc.$direct.ident",
            "$p118.trmc.$direct.num", "$direct.gen.at", "$product.lex", "$direct.lex"]
        for name in wanted:
            symbol = "p113d_FID_" + "".join(str(ord(c)) + "_" for c in name)
            qm = re.search(r"^function[^\n]*\$" + re.escape(symbol) + r"\([^\n]*\) \{\n", qbe, re.M)
            assert qm, name
            qs = qm.start()
            qb = qbe[qs:qbe.index("\n}", qs) + 2]
            start = asm.index("\n" + symbol + ":") + 1
            body = asm[start:asm.index("\n.size " + symbol, start)]
            lines = body.splitlines()
            f = {"name": name, "qbeLine": qbe[:qs].count("\n") + 1,
                 "qbeLines": len(qb.splitlines()), "qbeJnz": qb.count("\njnz "),
                 "boolNormalizations": re.findall(r"^%p113_bool_[^\n]* =w [^\n]*", qb, re.M),
                 "assemblyLine": asm[:start].count("\n") + 1,
                 "assembly": counts(lines)}
            if case == "mandelbrot":
                loop = next(line for line in lines if line.startswith(".Lbb"))
                a = lines.index(loop)
                b = next(i for i in range(a + 1, len(lines)) if lines[i].strip() == "jmp " + loop[:-1])
                f["loop"] = dict(counts(lines[a:b + 1]), firstLine=f["assemblyLine"] + a,
                                 lastLine=f["assemblyLine"] + b)
                f["frameReservations"] = [line.strip() for line in lines if "subq $" in line and "%rsp" in line]
                f["savedRegisters"] = [line.strip() for line in lines if "pushq " in line]
            row["functions"].append(f)
        report["roles"].append(row)
report["complete"] = True
output.write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps({"complete": True, "output": str(output), "rows": len(report["roles"])}))
