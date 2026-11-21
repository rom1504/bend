"""Recheck the final candidate's matcher exposure, native firing and compiler costs."""

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

from cost import census

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BUILD = ROOT / "selfhost/build/phase198"
spec = importlib.util.spec_from_file_location("pairwise_elf_witness", HERE / "native-witness.py")
elf = importlib.util.module_from_spec(spec)
spec.loader.exec_module(elf)


def pin(path):
    data = path.read_bytes()
    return dict(file=str(path.relative_to(ROOT)), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def resource(stage):
    guard = BUILD / (stage + "-guard") / "process.json"
    machine = BUILD / stage / "report.json"
    g, m = json.loads(guard.read_text()), json.loads(machine.read_text())
    assert g["complete"] and g["returncode"] == 0 and m["complete"]
    assert not m.get("changedInputs")
    assert g["peakTreeRssBytes"] <= g["rssLimitBytes"]
    return dict(stage=stage, guard=pin(guard), machine=pin(machine), wallSeconds=g["wallSeconds"],
                peakTreeRssBytes=g["peakTreeRssBytes"], rssCapBytes=g["rssLimitBytes"],
                productSha256=m["binary"]["sha256"])


def main(stage, source, out):
    manifest = BUILD / (stage + "-native45-01") / "programs.manifest.json"
    doc = json.loads(manifest.read_text())
    assert len(doc["cases"]) == 45
    source_sha = pin(source)["sha256"]
    assert doc["roles"]["candidate"]["compilerSource"]["sha256"] == source_sha
    reference = BUILD / "reuse-fusion-emit04/tree-bitonic/program.o"
    body = elf.symbols(reference)
    assert len(body) == 1
    firing = []
    for case in doc["cases"]:
        obj = case["products"]["candidate"]["generatedSource"]
        path = Path(obj["file"])
        assert pin(path)["sha256"] == obj["sha256"]
        workers = elf.symbols(path)
        if workers:
            assert len(workers) == 1
            for key, value in workers.items():
                assert value["wrapper"] == body[key]["wrapper"]
                firing.append(dict(case=case["id"], object=obj, wrapper=value["wrapper"],
                                   fallback=value["fallback"]))
    assert sorted(x["case"] for x in firing) == sorted(
        ["tree-bitonic", "variation-tree-bitonic-6-17", "variation-tree-bitonic-9-123"])
    pairs = []
    for phase in ("native-image01", "native-self01", "native-reproduction01"):
        pairs.append(dict(incumbent=resource(phase), selected=resource(stage + "-" + phase)))
    output = dict(kind="phase198-final-tree-exposure", source=census(source),
                  sourcePin=pin(source), incumbentSource=pin(BUILD/"selected-source01/compiler.bend"),
                  importedBase=census(ROOT/"selfhost/.bootstrap/upstream-phase182/bend2/base.bend"),
                  manifest=pin(manifest), nativeObjects=45, firing=firing, hostedObject=pin(reference),
                  nativeCompilerResources=pairs, method=pin(Path(__file__).resolve()),
                  scope="Canonical complete candidate plus cohort costs. The matcher scan runs once "
                        "over reachable declarations. Generation costs measure all combined changes.")
    out.write_text(json.dumps(output, indent=2) + "\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", required=True)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    main(args.stage, args.source.resolve(), args.out)
