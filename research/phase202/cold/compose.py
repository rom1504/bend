"""Stage a reproducible research producer without changing the selected compiler."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SOURCE = ROOT / "selfhost/build/phase201/source02/compiler.bend"
CHOICES = {"opcodes": "opcodes/prepare.py", "template": "continuations/prepare.py",
           "stream": "elf/prepare.py", "sized": "elf/sized.py"}

def load(path):
    sys.path.insert(0, str(path.parent))
    spec = importlib.util.spec_from_file_location("p202_" + path.parent.name + "_" + path.stem, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

def compose(out, variants):
    if len(set(variants)) != len(variants) or {"stream","sized"} <= set(variants):
        raise ValueError("select each writer at most once")
    raw = SOURCE.read_bytes()
    digest = lambda data: hashlib.sha256(data).hexdigest()
    if digest(raw) != "a68ba12c823fff623c58f31154ddca5de8d80cce9a207f3f14b04e95c20836d0":
        raise ValueError("unexpected parent source")
    report = {"parent": digest(raw), "changes": []}
    for name in variants:
        overlay = load(HERE.parent / CHOICES[name])
        raw = overlay.apply(raw.decode()).encode() if name == "opcodes" else overlay.apply(raw)
        report["changes"].append({"variant": name, "outputSha256": digest(raw), "sourceBytes": len(raw)})
    out.mkdir(parents=True, exist_ok=False)
    (out / "compiler.bend").write_bytes(raw)
    (out / "composition.json").write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report))

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("variants", choices=CHOICES, nargs="+")
    args = p.parse_args()
    compose(args.out, args.variants)
