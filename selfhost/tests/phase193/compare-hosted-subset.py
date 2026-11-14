#!/usr/bin/env python3
"""Authenticate exactly four hosted-development/native-N1 products, offline.

Reuses Phase190 producer, build, and independent-observation authentication.
Compares complete emitted objects and linked .text/.data/.rodata. No executable,
compiler, assembler, linker, or disassembler is run. This is not a 45-case gate.
"""
import argparse
import importlib.util
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
METHOD = Path(__file__).resolve().parents[1] / "phase190/compare-products.py"
spec = importlib.util.spec_from_file_location("p193_product_authentication", METHOD)
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
SELECTED = ["coverage-map-churn-32", "coverage-expression-32", "tree-bitonic", "lexer"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--left", type=Path, required=True)
    parser.add_argument("--right", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    evidence = P.Evidence()
    for file in (__file__, METHOD, P.CATALOG, P.bench.__file__, P.common.__file__,
                 P.product_compare.__file__, P.request.__file__):
        evidence.verify(P.common.pin(file))
    out = P.common.fresh_output(args.out, P.ROOT)
    report = dict(kind="phase193-hosted-native-subset-products", version=1,
        complete=False, targetsRun=False, compilerRun=False, selected=SELECTED,
        comparedCases=0, rows=[],
        scope="Offline authentication of exactly four hosted development products against native N1: recorded independent outputs, complete object bytes and linked text/data/rodata. No target execution, all45 product equivalence, runtime speed, or whole-compiler equivalence claim.")

    def save():
        report["inputs"] = list(evidence.inputs.values())
        P.common.write_json(out / "report.json", report)

    save()
    try:
        left = P.load_side(args.left, "candidate", evidence)
        right = P.load_side(args.right, "candidate", evidence)
        P.common.require(left["role"]["host"] == "js" and left["role"]["stage"] == "B1"
            and right["role"]["host"] == "native" and right["role"]["stage"] == "N1",
            "Actual checked hosted B1 and native N1 required")
        known = {case["id"]: case for case in P.bench.catalog(P.CATALOG)["cases"]}
        P.common.require(set(left["rows"]) == set(SELECTED) and len(left["rows"]) == 4
            and set(SELECTED) <= set(right["rows"]) <= set(known),
            "Exact four-case left subset and corresponding native cases required")
        P.common.require(left["role"]["runtime"] == right["role"]["runtime"],
                         "Target runtime identity differs")
        emission = left["emission"]
        preparation = evidence.read(emission["sourcePreparation"]["receipt"])
        parent = emission["sourcePreparation"]["snapshot"]
        native_source = right["producer"]["source"]
        P.common.require(preparation["snapshot"] == parent,
                         "Hosted preparation and recorded parent snapshot differ")
        # Identity deliberately compares bytes/SHA, not the source path: the
        # candidate and selected snapshots have different immutable locations.
        P.common.require(P.product_compare.same(parent, native_source),
                         "Hosted parent/native compiler source bytes or SHA differ")
        P.common.require(evidence.verify(parent).read_bytes() == evidence.verify(native_source).read_bytes(),
                         "Hosted parent/native compiler source content differs")
        base_binding = evidence.read(preparation["binding"])
        P.common.require(base_binding.get("kind") == "phase175-prepared-base"
            and preparation["binding"] in emission["inputs"],
            "Hosted preparation Base binding must be consumed by emission")
        for key in ("base", "carrier"):
            evidence.verify(base_binding[key])
            P.common.require(base_binding[key] in emission["inputs"],
                             "Hosted emission lacks its prepared Base input: " + key)
        report.update(left=dict(manifest=left["identity"], producer=left["producer"]),
            right=dict(manifest=right["identity"], producer=right["producer"]),
            compilerParent=dict(hosted=parent, native=native_source,
                bytesAndShaIdentical=True, completeBytesIdentical=True,
                sourcePathsDiffer=parent["file"] != native_source["file"]),
            base=dict(binding=preparation["binding"], source=base_binding["base"], carrier=base_binding["carrier"]),
            runtime=left["role"]["runtime"], leftCaseCount=len(left["rows"]),
            rightCaseCount=len(right["rows"]))
        save()
        for name in SELECTED:
            a = P.authenticate_product(left, known[name], evidence)
            b = P.authenticate_product(right, known[name], evidence)
            native_build = evidence.read(b["buildReceipt"])
            native_request = native_build["request"]
            for key in ("base", "carrier"):
                evidence.verify(native_request[key])
                P.common.require(P.product_compare.same(native_request[key], base_binding[key]),
                                 "Native/hosted prepared Base input differs: " + key)
            P.common.require(native_request.get("mode") == "cache",
                             "Native prepared Base mode differs")
            equal = {section: a["sections"][section] == b["sections"][section] for section in a["sections"]}
            # Compare actual bytes too; hash equality is not substituted for the
            # requested exact object comparison after pins are authenticated.
            object_equal = (P.product_compare.same(a["object"], b["object"])
                and evidence.verify(a["object"]).read_bytes() == evidence.verify(b["object"]).read_bytes())
            row = dict(id=name, source=known[name]["source"], expectedFile=known[name]["expectedFile"],
                left=a, right=b, objectIdentical=object_equal, linkedSectionsIdentical=equal,
                baseIdentical=True, complete=False)
            report["rows"].append(row); save()
            P.common.require(object_equal and all(equal.values()), "Product mismatch: " + name)
            row["complete"] = True; report["comparedCases"] += 1; save()
        report["complete"] = True
    except BaseException as error:
        report["error"] = repr(error)
    finally:
        report["changedInputs"] = P.common.changed_inputs(list(evidence.inputs.values()))
        if report["changedInputs"]:
            report["complete"] = False
        save()
    print(json.dumps({key: report.get(key) for key in ("complete", "comparedCases", "selected", "error")}))
    return 0 if report["complete"] else 1


if __name__ == "__main__":
    sys.exit(main())
