#!/usr/bin/env python3
"""Prepare/build private runtime objects or relink one unchanged program pair.

Preparation is metadata-only. Build and link commands must run under the
maintained outer disk guard. This tool never executes a generated program.
"""
import argparse
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(ROOT / "selfhost/tools/build"))
from common import fresh_output, pin, verify, require, run, write_json

RUNTIME_SHA = "aa95d2c0426c05bcc4d34244dd8b22b79ebcaf6d30634569201961f60b57f333"
OBJECT_SHA = "2d07832382a11d7e993124ecc70452e4e1a3b7f753cf429343e1183cd8e493a3"
GCC_SHA = "693abcb42e67fb871673f258a3644257ca69a209691ec4d8137a42442834bd19"
BEFORE = """INLINE Term rfc_seal(Env e, Term t) {
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    return t;
  }
  return rfc_wrap(e, t, 1);
}"""
AFTER = """/* Phase172 private static-publication experiment; default is unchanged.
 * Only the authenticated sequential host provider may enable this flag.
 * Static image constructors have recursively static/immediate fields, as
 * established by the unchanged static-image verifier. No heap-owned child,
 * mutable array, effect payload or cyclic image is admitted by that verifier. */
#ifndef P172_STATIC_SEAL
#define P172_STATIC_SEAL 0
#endif
#if P172_STATIC_SEAL != 0 && P172_STATIC_SEAL != 1
#error "Phase172 static seal flag must be zero or one"
#endif
#if P172_STATIC_SEAL && (!defined(P144_SINGLE_MUTATOR_RFC) || !P144_SINGLE_MUTATOR_RFC || DEVICE || BEND_METAL || BEND_CUDA || BANGS)
#error "Phase172 static seal requires the pinned sequential host runtime"
#endif
INLINE Term rfc_seal(Env e, Term t) {
  if (term_tag(t) != TAG_CTR || term_rfc(t)) {
    return t;
  }
#if P172_STATIC_SEAL
  if (term_loc(t) < HEAP_OFF) {
    return t;
  }
#endif
  return rfc_wrap(e, t, 1);
}"""


def authenticated(rows):
    for row in rows:
        verify(row)


def prepare(args):
    source = ROOT / "selfhost/src/runtime/qbe/runtime.c"
    original = source.read_text()
    require(pin(source)["sha256"] == RUNTIME_SHA, "Unexpected runtime source")
    require(original.count(BEFORE) == 1, "Expected unique exact seal definition")
    candidate = original.replace(BEFORE, AFTER, 1)
    require(candidate.replace(AFTER, BEFORE, 1) == original, "Inverse edit differs")
    manifest = ROOT / "selfhost/manifests/assets-native.json"
    assets = json.loads(manifest.read_text())["assets"]
    gcc = pin(ROOT / assets["linker"]["file"])
    runtime = pin(ROOT / assets["qbe-runtime"]["file"])
    require(gcc["sha256"] == GCC_SHA == assets["linker"]["sha256"], "GCC identity")
    require(runtime["sha256"] == OBJECT_SHA == assets["qbe-runtime"]["sha256"], "Installed runtime identity")
    out = fresh_output(args.out, ROOT)
    (out / "runtime.c").write_text(candidate)
    headers = []
    for name in ("runtime.h", "primitives.h"):
        path = source.parent / name
        (out / name).write_bytes(path.read_bytes())
        headers.append(dict(original=pin(path), snapshot=pin(out / name)))
    plan = dict(kind="phase172-static-seal-runtime-plan", version=1,
        targetsRun=False, productionChanged=False, inverseExact=True,
        inputs=[pin(__file__), pin(ROOT / "selfhost/tools/build/common.py"),
                pin(manifest), pin(source), gcc, runtime,
                *[row["original"] for row in headers]],
        compiler=gcc, referenceRuntime=runtime, source=pin(out / "runtime.c"),
        headers=[row["snapshot"] for row in headers],
        edit=dict(before=BEFORE, after=AFTER),
        flags=["-O2", "-std=gnu11", "-ffp-contract=off", "-DP144_SINGLE_MUTATOR_RFC=1"],
        variants=[dict(label="baseline", staticSeal=0), dict(label="static-seal", staticSeal=1)],
        scope="Only static raw constructor sealing changes. Same GCC10, serial provider and program object. No target execution or production selection.",
        requiredChecks=["Disabled object must equal installed runtime exactly",
                        "Valid Bend static/shared/dynamic controls with independent full outputs",
                        "Identical program QBE and machine object for paired runtime links",
                        "No malformed runtime probes"])
    write_json(out / "plan.json", plan)
    print(json.dumps(dict(plan=str(out / "plan.json"), source=plan["source"])))


def build(args):
    plan = json.loads(args.plan.read_text())
    require(plan["kind"] == "phase172-static-seal-runtime-plan" and plan["inverseExact"], "Wrong plan")
    inputs = [pin(__file__), pin(args.plan), *plan["inputs"], plan["source"], *plan["headers"]]
    authenticated(inputs)
    out = fresh_output(args.out, ROOT)
    report = dict(kind="phase172-static-seal-runtime-build", complete=False,
                  generatedProgramsRun=False, inputs=inputs, variants=[], checks=[])
    try:
        for spec in plan["variants"]:
            label = spec["label"]
            require((label, spec["staticSeal"]) in [("baseline", 0), ("static-seal", 1)], "Wrong variant")
            obj = out / (label + ".o")
            command = [plan["compiler"]["file"], *plan["flags"],
                       f'-DP172_STATIC_SEAL={spec["staticSeal"]}', "-c", plan["source"]["file"], "-o", str(obj)]
            job = run(command, cwd=ROOT, stdout=out / (label + ".stdout"),
                      stderr=out / (label + ".stderr"), seconds=60)
            row = dict(**spec, command=command, job=job)
            report["variants"].append(row)
            write_json(out / "report.json", report)
            require(job["complete"], "Runtime compilation failed: " + label)
            row["object"] = pin(obj)
        baseline = report["variants"][0]["object"]
        ref = plan["referenceRuntime"]
        equal = all(baseline[k] == ref[k] for k in ("bytes", "sha256"))
        report["checks"].append(dict(name="disabled-equals-installed-runtime", passed=equal,
                                     actual=baseline, expected=ref))
        require(equal, "Disabled baseline differs; inspect before using pair")
        authenticated(inputs)
        report["compiler"] = plan["compiler"]
        report["complete"] = True
    finally:
        write_json(out / "report.json", report)
        print(json.dumps(dict(report=str(out / "report.json"), complete=report["complete"])))


def link_pair(args):
    build_report = json.loads(args.build.read_text())
    require(build_report.get("complete") and build_report["kind"] == "phase172-static-seal-runtime-build", "Incomplete runtime build")
    variants = build_report["variants"]
    require([r["label"] for r in variants] == ["baseline", "static-seal"], "Wrong pair")
    program, ir = pin(args.program_object), pin(args.program_ir)
    inputs = [pin(__file__), pin(args.build), build_report["compiler"], program, ir,
              *[r["object"] for r in variants], *build_report["inputs"]]
    authenticated(inputs)
    out = fresh_output(args.out, ROOT)
    report = dict(kind="phase172-static-seal-linked-pair", complete=False,
                  generatedProgramsRun=False, inputs=inputs, programObject=program,
                  programIR=ir, variants=[], scope="Same explicit program object and IR; only runtime object differs. No QBE rebuild or target execution.")
    try:
        for variant in variants:
            label = variant["label"]
            binary = out / label
            command = [build_report["compiler"]["file"], "-no-pie", program["file"],
                       variant["object"]["file"], "-pthread", "-lm", "-o", str(binary)]
            job = run(command, cwd=ROOT, stdout=out / (label + ".stdout"),
                      stderr=out / (label + ".stderr"), seconds=60)
            row = dict(label=label, runtime=variant["object"], command=command, job=job)
            report["variants"].append(row)
            write_json(out / "report.json", report)
            require(job["complete"], "Link failed: " + label)
            row["binary"] = pin(binary)
        authenticated(inputs)
        report["complete"] = True
    finally:
        write_json(out / "report.json", report)
        print(json.dumps(dict(report=str(out / "report.json"), complete=report["complete"])))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="action", required=True)
    for name in ("prepare", "build", "link-pair"):
        command = commands.add_parser(name)
        command.add_argument("--out", type=Path, required=True)
        if name == "build": command.add_argument("--plan", type=Path, required=True)
        if name == "link-pair":
            command.add_argument("--build", type=Path, required=True)
            command.add_argument("--program-object", type=Path, required=True)
            command.add_argument("--program-ir", type=Path, required=True)
    args = parser.parse_args()
    {"prepare": prepare, "build": build, "link-pair": link_pair}[args.action](args)


if __name__ == "__main__":
    main()
