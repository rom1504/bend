#!/usr/bin/env python3
"""Prepare matched baseline/candidate field and array source jobs; execute no targets."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[5]
HELPER = HERE.parents[1]/"bench/transport-v2.py"
spec = importlib.util.spec_from_file_location("phase113_transport_v2", HELPER)
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return dict(file=str(path), bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def reused_observation(entry, case, api, runtime, emitter, pipeline, contract):
    reports = {key: json.loads((ROOT/entry[key]).read_text()) for key in ['emission', 'build', 'observation']}
    emission, built, observed = [reports[key] for key in ['emission', 'build', 'observation']]
    if (not all(row.get('complete') for row in reports.values()) or
            emission.get('pipeline') != pipeline or emission.get('transportVersion') != 2 or
            any(emission.get(key) != value for key, value in contract.items()) or
            not all(emission.get(key) for key in ['sourceChecked', 'runtimeAdmitted', 'irVerified'])):
        raise ValueError('Complete matching staged emission/build/observation required for reuse')
    inputs = [pin(ROOT/entry[key]) for key in reports]
    for row in reports.values():
        inputs += row['inputs']
    expected = json.loads((ROOT/case['expected']).read_text())
    if (observed['actual'] != expected or observed['expected'] != expected or
            built.get('perProgramC') or built.get('cproc')):
        raise ValueError('Reused observation differs from independent output or direct-QBE build')
    for expected_pin in [pin(api), pin(ROOT/case['source']), pin(emitter)]:
        if expected_pin not in emission['inputs']:
            raise ValueError('Reused emission source/API/transport mismatch')
    if emission['product'] not in built['inputs'] or pin(runtime) not in built['inputs']:
        raise ValueError('Reused build differs from emitted bytes/runtime')
    if built['binary'] not in observed['inputs'] or pin(ROOT/case['expected']) not in observed['inputs']:
        raise ValueError('Reused observer differs from built product/expected output')
    observation_dir = (ROOT/entry['observation']).parent
    for channel in ['stdout', 'stderr']:
        if (observation_dir/channel).read_bytes() != expected[channel].encode():
            raise ValueError('Reused raw observation differs from independent output')
        inputs.append(pin(observation_dir/channel))
    inputs += [emission['product'], built['binary'], built['object']]
    for row in inputs:
        if pin(row['file']) != row:
            raise ValueError('Changed reused input: ' + row['file'])
    return inputs


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--baseline", type=Path, required=True)
    p.add_argument("--candidate", type=Path, required=True)
    p.add_argument("--baseline-pipeline", choices=["direct", "array"], default="direct")
    p.add_argument("--candidate-pipeline", choices=["direct", "array"], default="array")
    p.add_argument("--array-controls-out", type=Path,
                   help="Optionally prepend candidate array structural controls at this fresh Phase113 output")
    p.add_argument("--runtime", type=Path, required=True)
    p.add_argument("--prefix", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--names", nargs="+")
    p.add_argument("--reuse-baseline", type=Path, help="Exact completed baseline receipt map; no new execution claimed")
    a = p.parse_args()
    prefix = a.prefix.resolve()
    if not prefix.is_relative_to(ROOT / "selfhost/build/phase111") or a.out.exists():
        raise ValueError("Fresh plan and Phase111 path prefix required")
    manifest_path = HERE / "source-manifest03.json"
    manifest = json.loads(manifest_path.read_text())
    for row in manifest["inputs"]:
        actual = pin(ROOT / row["file"])
        if any(actual[k] != row[k] for k in ("bytes", "sha256")):
            raise ValueError("Frozen source/method changed: " + row["file"])
    selected = a.names or [case["name"] for case in manifest["cases"]]
    if len(selected) != len(set(selected)) or set(selected) - {case["name"] for case in manifest["cases"]}:
        raise ValueError("Unknown or duplicate case name")
    runtime = a.runtime.resolve()
    if runtime.is_dir():
        runtime /= "runtime.o"
    emitter = HERE.parents[1]/"staged-emit-v2.mjs"
    jobs, roles = [], {}
    reused = json.loads(a.reuse_baseline.read_text()) if a.reuse_baseline else {}
    if set(reused)-set(selected):
        raise ValueError('Reused cases must belong to the selected frozen cases')
    inputs = [pin(manifest_path), pin(__file__), pin(HELPER), pin(emitter), pin(runtime)]
    inputs += [dict(row, file=str((ROOT/row["file"]).resolve())) for row in manifest["inputs"]]
    if a.reuse_baseline:
        inputs.append(pin(a.reuse_baseline))
    for label, api, pipeline in [("baseline", a.baseline.resolve(), a.baseline_pipeline),
                                 ("candidate", a.candidate.resolve(), a.candidate_pipeline)]:
        if api.is_dir():
            api /= "api.mjs"
        receipt_path = api.parent / "report.json"
        receipt = json.loads(receipt_path.read_text())
        if not receipt.get("complete") or not receipt.get("checked") or receipt["api"] != pin(api):
            raise ValueError("Complete exact checked staged API required")
        contract = transport.select_exports(receipt, pipeline)
        roles[label] = dict(api=pin(api), apiReceipt=pin(receipt_path), pipeline=pipeline, **contract)
        inputs += [pin(api), pin(receipt_path), *receipt["inputs"]]
        if label == "candidate" and a.array_controls_out:
            controls = HERE.parents[1]/"array-fast/controls-v2.mjs"
            controls_out = a.array_controls_out.resolve()
            required = ["p113a_verify", "p113a_chunks", "p113a_stmt_id", "p113a_template",
                        "p113a_scan", "p113a_heap_min", "p113a_enabled", "p113a_body_names", "p113d_verify"]
            if (pipeline != "array" or not set(required).issubset(receipt.get("exports", [])) or
                    controls_out.exists() or not controls_out.is_relative_to(ROOT/"selfhost/build/phase113")):
                raise ValueError("Array controls need checked exports and fresh Phase113 output")
            inputs.append(pin(controls))
            jobs.insert(0, dict(name="candidate-array-structural-controls", seconds=60,
                               command=[receipt["command"][0], str(controls), str(api), str(controls_out)]))
        for case in manifest["cases"]:
            if case["name"] not in selected:
                continue
            if label == "baseline" and case["name"] in reused:
                inputs += reused_observation(reused[case["name"]], case, api, runtime, emitter, pipeline, contract)
                continue
            stem = str(prefix) + "-" + label + "-" + case["name"]
            emit, build, observe = [Path(stem + "-" + suffix) for suffix in ("emit", "build", "observe")]
            if any(x.exists() for x in (emit, build, observe)):
                raise ValueError("Output already exists: " + stem)
            jobs.extend([
                dict(name=label+"-"+case["name"]+"-emit", seconds=60, command=[
                    receipt["command"][0], str(emitter),
                    str(api), str(ROOT / case["source"]), str(emit), "cache", pipeline]),
                dict(name=label+"-"+case["name"]+"-build", seconds=60, command=[
                    "python3", "-B", str(ROOT / "selfhost/tools/performance/phase111/build.py"),
                    "--source", str(emit / "program.ssa"), "--runtime", str(runtime),
                    "--out", str(build)]),
                dict(name=label+"-"+case["name"]+"-observe", seconds=20, command=[
                    "python3", "-B", str(ROOT / "selfhost/tools/performance/phase112/observe.py"),
                    "--binary", str(build / "program"), "--expected", str(ROOT / case["expected"]),
                    "--out", str(observe)])
            ])
    for row in inputs:
        if pin(row["file"]) != row:
            raise ValueError("Changed pinned input: " + row["file"])
    a.out.parent.mkdir(parents=True, exist_ok=True)
    report = dict(kind="phase113-independent-field-array-jobs", version=4, transportVersion=2, targetsRun=False,
                  inputs=list({row["file"]: row for row in inputs}.values()), roles=roles,
                  names=selected, manifest=pin(manifest_path), runtime=pin(runtime),
                  reusedBaseline=reused,
                  scheduledNames=dict(baseline=[name for name in selected if name not in reused], candidate=selected),
                  jobs=jobs, scope="Exact frozen source execution parity through explicitly recorded baseline/candidate pipelines. Optional array structural controls are separate from source/native/runtime qualification.")
    a.out.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(dict(plan=str(a.out), jobs=len(jobs), targetsRun=False)))


if __name__ == "__main__":
    main()
