#!/usr/bin/env python3
"""Prepare unchanged parser closure and full-result writer; no target execution."""
import argparse
import hashlib
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "selfhost/tools/build"))
import source as assembly
from common import fresh_output, pin, require, write_json


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    obj = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(obj)
    return obj


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    E = module("extract147_parser160", ROOT / "experiments/phase147/tools/prepare.py")
    N = module("normalize160_parser", ROOT / "experiments/phase160/tools/prepare-request.py")
    recipe = ROOT / "selfhost/src/compiler.json"
    qfile = ROOT / "implementation/phase152/qualification.json"
    q = json.loads(qfile.read_text())
    canonical = assembly.maintained_assemble(recipe, ROOT / "selfhost", "qbe")
    require(hashlib.sha256(canonical).hexdigest() == q["source"]["sha256"], "Qualified source changed")
    _, rows = assembly.blocks(canonical)
    no_main = b"".join(r["data"] for r in rows if r["name"] != "main")
    observation = ROOT / "selfhost/tests/phase155/publication.bend"
    harness = ROOT / "selfhost/tests/phase160/parser.bend"
    body, declarations = E.extract([
        ("canonical", no_main), ("phase155-full-serialization", observation.read_bytes()),
        ("phase160-harness", harness.read_bytes())], ["main", "p160p_text"], 600_000)
    original = body.decode()
    changes, payload = N.scan(original)
    normalized = original
    for change in reversed(changes):
        normalized = normalized[:change["offset"]] + change["after"] + normalized[change["end"]:]
    remaining, after = N.scan(normalized)
    require(not remaining and payload == after, "Normalization changes non-layout payload")
    out = fresh_output(args.out, ROOT)
    (out / "original.bend").write_bytes(body)
    (out / "compiler.bend").write_text(normalized)
    write_json(out / "exports.json", dict(kind="bend-hosted-api-exports", version=1,
        exports=["p160p_parse", "p160p_text"], protocol="hosted-api-v1", targets=["parser-observation"],
        scope="Independent full-result oracle access only; no compiler replacement."))
    base = ROOT / "selfhost/.bootstrap/upstream-phase66/bend2/base.bend"
    inputs = [pin(p) for p in [Path(__file__), Path(E.__file__), Path(N.__file__),
        Path(assembly.__file__), recipe, qfile, observation, harness, base]]
    cases = [dict(id="compiler", source=pin(ROOT / q["source"]["file"]), requiredName="main"),
             dict(id="map", source=pin(ROOT / "selfhost/tests/consolidation/native-broad/coverage-map-churn-128.bend"), requiredName="main")]
    write_json(out / "manifest.json", dict(kind="phase160-parser-preparation", version=1,
        complete=True, targetsRun=False, originalQualifiedSource=q["source"],
        original=pin(out / "original.bend"), normalized=pin(out / "compiler.bend"),
        source=pin(out / "compiler.bend"), base=pin(base), inputs=inputs, cases=cases,
        declarations=declarations, layoutChanges=changes,
        scope="Exact maintained full parser/loader and Phase155 full KDef/KTerm serialization. Fresh live Base plus source, no checking/lowering/emission.",
        output="R + full p155p_defs(book) + E + p155p_string(error) + I + full p155p_terms(imports); per-declaration streaming with exact original serializer.",
        correctnessGate="Pending independent source/layout check and full output byte equality against qualified N2 acquisition (optionally hosted upstream API oracle). Successful parse and main declaration required; no checksum-only gate.",
        timing="Read/parse/observe-write clocks separated by IO.now; clean whole-child time still includes all work and teardown. Clock reports are diagnostics on stderr.",
        argv="C: argv0=phase160-parser, then ABS_INPUT ABS_BASE DISTINCT_ABS_OUTPUT; QBE: explicit phase160-parser before the same paths. Runtime --threads 1 --gpu off -- precedes user arguments.",
        limitations=["Fresh loader Base work differs from the Phase153 prepared-Base stage.",
            "FResult is fully observed; outer FLoadTrace bookkeeping done/sources is not the parser book result and is discarded in all roles.",
            "One declaration serialization can still be large; no full-book text is retained by native CLI.",
            "Layout audit is lexical; it is not a source checker or independent parser-equivalence gate."]))
    print(json.dumps(dict(source=pin(out / "compiler.bend"), declarations=len(declarations),
                          layoutChanges=len(changes), manifest=str(out / "manifest.json"), targetsRun=False)))


if __name__ == "__main__":
    main()
