#!/usr/bin/env python3
"""Offline runtime-CFI preparation/manifests/observation; never runs targets.

The existing diagnostic ELF retains its original stage-spec hash. A new CFI
table is separately bound to the sampler and observation, without relinking.
"""
import argparse
import copy
import json
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[3]
TOOLS = ROOT / "selfhost/tools/profiler"
sys.path.insert(0, str(TOOLS))
from run import pin, verify, output_matches
from freeze import freeze
import attribute
import stages_v1 as stages

P = ROOT / "selfhost/build/phase171"
OLD_PREP = P / "candidate-profile-prep01"
OLD_BUILD = P / "candidate-profile-build01/report.json"
OLD_PROFILE = P / "candidate-profile-full01/report.json"
OLD_RECIPES = {"full": P / "candidate-profile-manifests01/full-recipe.json",
               "pilot": P / "profile-manifests02/pilot-recipe.json"}


def read(path):
    return json.loads(Path(path).read_text())


def save(path, data):
    with Path(path).open("x") as out:
        json.dump(data, out, indent=2)
        out.write("\n")


def need(test, message):
    if not test:
        raise ValueError(message)


def prepare(out, products):
    need(not out.exists() and not products.exists(), "Fresh prep/products roots required")
    built = read(OLD_BUILD)
    need(built["complete"], "Retained diagnostic build incomplete")
    plan = read(verify(built["plan"]))
    artifacts = {r["label"]: r["product"] for r in built["jobs"]}
    binary = verify(artifacts["link-diagnostic"])
    spec_pin = pin(OLD_PREP / "spec.json")
    spec = read(spec_pin["file"])
    stages.validate_spec(spec, read(verify(spec["ownerMap"])))
    # Exact ELF symbol ranges, no guessed function ends or next-symbol spans.
    command = ["/usr/bin/nm", "-n", "-S", "--defined-only", str(binary)]
    symbols = subprocess.run(command, capture_output=True, text=True, check=True, timeout=30).stdout
    names = {"term_drop", "span_fade", "ctr_take", "heap_alloc", "term_keep", "term_sink",
             "rfc_wrap", "rfc_bump", "term_triv", "p111_rt_keep", "p111_rt_sink", "p111_rt_take",
             "p111_rt_ctor", "p111_rt_special_ctor"}
    selected = []
    for line in symbols.splitlines():
        m = re.fullmatch(r"([0-9a-fA-F]+) ([0-9a-fA-F]+) [tT] (.+)", line)
        if m and (m[3] in names or re.fullmatch(r"p125_rt_take[0-9]+|p118_p111_rt_(take|ctor)[0-9]+|p118_rt_extend[0-9]+", m[3])):
            selected.append(dict(name=m[3], start=int(m[1], 16), end=int(m[1], 16) + int(m[2], 16)))
    need(selected and all(r["end"] > r["start"] for r in selected), "Missing bounded symbols")
    out.mkdir(parents=True)
    save(out / "ranges.json", dict(object=pin(binary), ranges=selected, symbolCommand=command,
                                  scope="Selected complete runtime symbols only; no next-symbol size inference."))
    # Existing reader rejects every unsupported rule/byte; no --allow-partial.
    subprocess.run([sys.executable, "-B", str(TOOLS / "unwind.py"), "--object", str(binary),
                    "--ranges", str(out / "ranges.json"), "--out", str(out / "unwind")], check=True)
    table_pin = pin(out / "unwind/table.json")
    table = read(table_pin["file"])
    need(table["complete"] and not table["skipped"], "Incomplete CFI must not be used")
    previous = read(OLD_PROFILE)
    need(previous["complete"] and previous["passed"] and not previous["changedInputs"], "Prior profile invalid")
    analysis_pin = previous["rows"][0]["analysis"]
    analysis = read(verify(analysis_pin))
    need(analysis["identities"]["binary"]["sha256"] == pin(binary)["sha256"], "Wrong comparison ELF")
    for row in selected:
        row.update(previousSamples=0, supportedPreviousSamples=0)
        for pc in analysis["pcs"]:
            address = pc["elf_address"]
            address = int(address, 0) if isinstance(address, str) else address
            if address is not None and row["start"] <= address < row["end"]:
                row["previousSamples"] += pc["samples"]
                row["supportedPreviousSamples"] += pc["samples"] * any(
                    r["start"] <= address < r["end"] for r in table["rows"])
    covered = sum(r["supportedPreviousSamples"] for r in selected)
    total = analysis["header"]["samples"]
    need(covered / total >= .20, "Insufficient prior-sample coverage for a new capture")
    save(out / "coverage.json", dict(complete=True, targetsRun=False, priorReport=pin(OLD_PROFILE),
         priorAnalysis=analysis_pin, table=table_pin, ranges=selected, allPreviousSamples=total,
         supportedPreviousSamples=covered, supportedPreviousFraction=covered / total,
         scope="Offline eligibility only; no new callers recovered or capture quality predicted."))
    # Copy the already-qualified ordinal-hook sampler byte-for-byte; only the
    # separately generated CFI header and compile output location differ.
    source_pin = next(x for x in plan["outputs"] if x["file"].endswith("/sample.c"))
    source = Path(verify(source_pin)).read_bytes()
    need(source.count(b"uint32_t bend_sample_delivered_count(void)") == 1, "Stage ordinal hook required")
    (out / "sample.c").write_bytes(source)
    old_job = next(j for j in plan["jobs"] if j["label"] == "stage-ordinal-sampler")
    new_command = list(old_job["command"])
    old_header = next(x for x in new_command if x.startswith("-DBEND_PROFILE_UNWIND_TABLE="))
    new_command[new_command.index(old_header)] = '-DBEND_PROFILE_UNWIND_TABLE="' + str(out / "unwind/unwind-table.h") + '"'
    new_command[new_command.index(source_pin["file"])] = str(out / "sample.c")
    new_command[new_command.index("-o") + 1] = str(products / "sampler.so")
    inputs = [pin(__file__), pin(OLD_BUILD), built["plan"], artifacts["link-diagnostic"], spec_pin,
              spec["ownerMap"], source_pin, table_pin, pin(out / "ranges.json"), pin(TOOLS / "unwind.py"),
              pin(new_command[0]), pin(TOOLS / "build-runtime.py")]
    build_plan = dict(schema="bend-native-profile-runtime-plan-v1", complete=True, compiled=False,
                     executed=False, reverseExact=True, inputs=inputs,
                     outputs=[pin(out / "sample.c"), pin(out / "unwind/unwind-table.h")],
                     productsDirectory=str(products), jobs=[dict(label="stage-ordinal-sampler", command=new_command)],
                     stageSpec=spec_pin, callerTable=table_pin,
                     scope="Sampler-only build. Original diagnostic ELF/runtime/stage-spec hash unchanged; source is byte-identical including ordinal hook. Only CFI table changes.")
    save(out / "build-plan.json", build_plan)
    save(out / "ready.json", dict(complete=True, targetsRun=False, binary=pin(binary), originalBuild=pin(OLD_BUILD),
         stageSpec=spec_pin, callerTable=table_pin, samplerSource=pin(out / "sample.c"),
         originalSamplerSource=source_pin, buildPlan=pin(out / "build-plan.json"), coverage=pin(out / "coverage.json")))
    print(json.dumps(dict(complete=True, targetsRun=False, plan=str(out / "build-plan.json"),
                         supportedPreviousSamples=covered, allPreviousSamples=total)))


def manifests(prep, build_report, out):
    need(not out.exists(), "Fresh manifest root required")
    ready, built = read(prep / "ready.json"), read(build_report)
    need(built["complete"] and built["plan"] == ready["buildPlan"], "Successful exact sampler plan required")
    plan = read(verify(ready["buildPlan"]))
    for item in plan["inputs"] + plan["outputs"] + built["products"]:
        verify(item)
    need(len(built["jobs"]) == 1 and built["jobs"][0]["label"] == "stage-ordinal-sampler", "Sampler-only build required")
    sampler = verify(built["jobs"][0]["product"])
    binary = verify(ready["binary"])
    out.mkdir(parents=True)
    for name, old_path in OLD_RECIPES.items():
        recipe = copy.deepcopy(read(old_path))
        recipe.update(sampler=str(sampler), unwindTable=verify(ready["callerTable"]).as_posix(),
                      scope="Same retained candidate diagnostic ELF and original stage-spec hash; new runtime-only one-frame CFI. Diagnostic, no clean timing. Original source/Base/output contract unchanged.")
        recipe["inputs"] = [str(prep / "ready.json"), str(prep / "coverage.json"), str(prep / "build-plan.json"),
                            str(build_report), str(old_path), str(OLD_BUILD), ready["stageSpec"]["file"],
                            str(OLD_PREP / "owners.json"), str(Path(__file__).resolve()), str(TOOLS / "stages_v1.py")]
        for workload in recipe["workloads"]:
            workload["timeoutSeconds"] = 190 if name == "full" else 45
            for variant in workload["variants"]:
                variant["command"][0] = str(binary)
                variant["name"] = "candidate-runtime-callers"
        save(out / (name + "-recipe.json"), recipe)
        save(out / (name + "-manifest.json"), freeze(recipe, out / (name + "-recipe.json")))
    print(json.dumps(dict(complete=True, targetsRun=False, out=str(out))))


def observe(prep, run_path, out):
    """Separate original embedded stage spec from the changed caller table."""
    need(not out.exists(), "Fresh observation output required")
    ready, run = read(prep / "ready.json"), read(run_path)
    spec_path, table_path = verify(ready["stageSpec"]), verify(ready["callerTable"])
    spec = read(spec_path)
    owners = read(verify(spec["ownerMap"]))
    need(run["complete"] and run["passed"] and not run["changedInputs"] and len(run["rows"]) == 1,
         "One complete exact-output sampled row required")
    row = run["rows"][0]
    need(row["correct"] and row["mode"] == "sample" and row["diagnosticRuntime"], "Expected diagnostic sample")
    for item in run["inputs"]:
        verify(item)
    need(ready["stageSpec"] in run["inputs"] and ready["callerTable"] in run["inputs"], "Both stage and caller identities must be captured")
    need(pin(row["command"][0]) == ready["binary"], "Diagnostic executable changed")
    matching = []
    for item in run["inputs"]:
        if Path(item["file"]).suffix != ".json" or item["bytes"] > 2000000:
            continue
        try:
            m = read(item["file"])
        except (ValueError, UnicodeDecodeError):
            continue
        if isinstance(m, dict) and m.get("schema") == "bend-native-profile-workloads-v1":
            for workload in m["workloads"]:
                for variant in workload["variants"]:
                    if workload["name"] == row["workload"] and variant["name"] == row["variant"] and variant["command"] == row["command"]:
                        need(m["unwindTable"] == ready["callerTable"], "Captured caller table mismatch")
                        matching.append((item, variant["expected"]))
    need(len(matching) == 1, "Unique exact oracle manifest required")
    expected = matching[0][1]
    for key in ["profile", "analysis", "contexts", "callers", "stdout", "stderr"]:
        verify(row[key])
    need(all(output_matches(row[k]["file"], expected[k]) for k in ["stdout", "stderr"]), "Output oracle changed")
    side_path = Path(row["profile"]["file"] + ".stages-v1.json")
    side = stages.normalize(read(side_path), spec, ready["stageSpec"]["sha256"])
    doc, events = attribute.attribute(row["analysis"]["file"], row["callers"]["file"], table_path,
                                      row["contexts"]["file"], spec["ownerMap"]["file"])
    need(doc["pairing"]["verified"], "Caller/capture pairing failed")
    _, linked, binding = attribute.bind_owners(owners, row["command"][0])
    observed = stages.check_observations(spec, owners, side, linked, len(events))
    save(out, dict(schema="phase171-runtime-caller-stages-v1", complete=True, targetsRun=False,
         inputs=[pin(__file__), pin(TOOLS / "attribute.py"), pin(TOOLS / "stages_v1.py"), pin(run_path),
                 ready["stageSpec"], ready["callerTable"], spec["ownerMap"], pin(side_path)],
         outputContract=dict(manifest=matching[0][0], expected=expected, passed=True),
         originalEmbeddedStageSpecPreserved=True, stageAttributionValid=True, samples=len(events),
         ownerBinding=binding, quality=doc["quality"], callerCoverage=doc["coverage"], callerMatrix=doc["matrix"],
         intervals=stages.summarize_intervals(spec, observed, side["finish"], events, doc["quality"]),
         limits=doc["limitations"] + ["CFI table differs from the stage spec's historical sampler field; both actual identities checked separately."]))
    print(json.dumps(dict(complete=True, samples=len(events), coverage=doc["coverage"], out=str(out))))


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("operation", choices=["prepare", "manifests", "observe"])
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--products", type=Path)
    p.add_argument("--prep", type=Path)
    p.add_argument("--build-report", type=Path)
    p.add_argument("--run", type=Path)
    a = p.parse_args()
    if a.operation == "prepare":
        prepare(a.out.resolve(), a.products.resolve())
    elif a.operation == "manifests":
        manifests(a.prep.resolve(), a.build_report.resolve(), a.out.resolve())
    else:
        observe(a.prep.resolve(), a.run.resolve(), a.out.resolve())
