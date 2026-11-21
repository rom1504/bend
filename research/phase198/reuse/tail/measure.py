"""Build and measure the two reauthenticated public-tail products on the guarded CPU."""

import argparse
import itertools
import json
import math
import os
import re
import statistics
import subprocess
import sys
import time
from pathlib import Path

from recover import BUILD, CASES, HERE, ROOT, authenticate, pin, read, write

sys.path.insert(0, str(ROOT / "research/phase196/screen"))
from measure import ASSETS, REFERENCES, bench, execute


def run(command, seconds):
    start = time.monotonic()
    process = subprocess.run(command, capture_output=True, timeout=seconds)
    assert process.returncode == 0, (list(map(str, command)), process.stderr.decode()[-2000:])
    return process, time.monotonic() - start


def diagnostic(out, row, sites, assets):
    source = Path(row["assembly"]["file"]).read_text()
    pattern = r"^  jmp (p111_FID_\S+)$"
    targets = re.findall(pattern, source, re.M)
    assert targets == [s["target"] for s in sites]
    unique = sorted(set(targets))
    assert len(unique) <= 128
    ids = {name: i for i, name in enumerate(unique)}

    def counter(match):
        symbol = match[1]
        return f"  incq p198_public_tail_counts+{8 * ids[symbol]}(%rip)\n  jmp {symbol}"

    instrumented, replaced = re.subn(pattern, counter, source, flags=re.M)
    names = [bytes(int(n) for n in re.findall(r"\d+", name.removeprefix("p111_FID_"))).decode()
             for name in unique]
    directory = out / row["id"]
    directory.mkdir()
    assembly = directory / "count.s"
    assembly.write_text(instrumented)
    obj, binary = directory / "count.o", directory / "count"
    policy = assets["toolchains"]["x86"]
    assembler, linker, runtime = [
        assets["assets"][key]["file"] for key in ("assembler", "linker", "qbe-runtime")
    ]
    assemble = [assembler, *policy["assemblerFlags"], "-o", str(obj), str(assembly)]
    link = [linker, *policy["linkerFlags"], str(obj), runtime, "-O2", str(HERE/"counter.c"),
            *policy["libraries"], "-o", str(binary)]
    run(assemble, 4)
    run(link, 4)
    return binary, dict(instructions=replaced, targets=names, inputs=[row["assembly"], pin(HERE/"counter.c")],
                        assembly=pin(assembly), object=pin(obj), binary=pin(binary), commands=[assemble, link])


def count(binary, args, reps, expected, targets):
    rts = bench.native_runtime_arguments({"runtimeArgumentConvention": "bend-rts-v1"})
    process, seconds = run([binary, *rts, str(reps), "0", *map(str, args)], 3)
    stderr = process.stderr.decode().splitlines()
    match = re.fullmatch(r"public-tail=(\d+)", stderr[0])
    assert match, stderr
    events = {}
    for line in stderr[1:]:
        event = re.fullmatch(r"target (\d+)=(\d+)", line)
        assert event and 0 <= int(event[1]) < len(targets), line
        target = targets[int(event[1])]
        assert target not in events
        events[target] = int(event[2])
    assert sum(events.values()) == int(match[1])
    elapsed = bench.observation(process.stdout, b"", 0,
                                dict(expectedStdout=expected, repetitions=reps, warmups=0), seconds)
    return dict(repetitions=reps, transfers=int(match[1]), targets=events,
                stdout=process.stdout.decode(), stderr=process.stderr.decode(), elapsedMs=elapsed)


def main(out):
    assert os.sched_getaffinity(0) == {3} and "BENDRTS" not in os.environ
    out.mkdir()
    emission_path = BUILD / "heap-tail-auth01/emission.json"
    emission = read(emission_path)
    recovered = read(emission["recovery"]["file"])
    assert emission["complete"] and recovered["complete"] and not recovered["originalComplete"]
    assert CASES == [r["id"] for r in emission["rows"]]
    bases = read(REFERENCES)
    broad_path = BUILD / "portfolio-live-broad01/report.json"
    broad = read(broad_path)
    assets = read(ASSETS)
    references = {r["id"]: r for r in bases["cases"] if r["id"] in CASES}
    retention_path = BUILD / "heap-pair-emission01-guard/retention.json"
    retention = read(retention_path)
    assert retention["closed"] and retention["classification"] == "failed"
    assert retention["closure"] in recovered["citations"]
    fixed_inputs = [emission["recovery"], pin(emission_path), pin(ASSETS), pin(REFERENCES),
                    pin(broad_path), pin(retention_path), retention["closure"],
                    pin(__file__), pin(HERE/"counter.c"),
                    *[assets["assets"][k] for k in ("assembler", "linker", "qbe-runtime")]]
    for ref in references.values():
        fixed_inputs.extend([ref["source"], ref["expectedFile"], ref["products"]["c"]])
    initial = authenticate(recovered["verifiedInputs"], fixed_inputs)
    report = dict(kind="phase198-authenticated-public-tail-two-programs", complete=False,
                  beforeInputs=len(initial), inputs=fixed_inputs, emission=pin(emission_path),
                  recovery=emission["recovery"], rows=[])
    result = out / "report.json"
    write(result, report)

    build = out / "linked"
    command = [sys.executable, "-B", "selfhost/tests/phase190/build-programs.py",
               "--emission", str(emission_path), "--assets", str(ASSETS), "--role", "heap",
               "--out", str(build), "--seconds", "15", "--guarded"]
    process, seconds = run(command, 18)
    (out / "build.stdout").write_bytes(process.stdout)
    (out / "build.stderr").write_bytes(process.stderr)
    built_path = build / "programs.manifest.json"
    built = read(built_path)
    assert read(build / "report.json")["complete"]
    report["build"] = dict(command=command, seconds=seconds, manifest=pin(built_path),
                           receipt=pin(build/"report.json"))
    for row, products in zip(emission["rows"], recovered["products"]):
        case = row["id"]
        point = references[case]["point"]
        args, expected = point["runtimeArgs"], point["expectedStdout"]
        ref = references[case]["products"]["c"]
        heap = next(c for c in built["cases"] if c["id"] == case)["products"]["heap"]
        assert heap["generatedSource"] == row["product"]
        products_by_role = {"baseline": products["baselineBinary"], "heap": heap["artifact"], "c": ref["artifact"]}
        sites = products["tailSites"]["candidate"]
        counter, counter_build = diagnostic(out, row, sites, assets)
        data = dict(id=case, source=row["source"], expected=row["expectedFile"],
                    products=products_by_role, counter=counter_build, controls=[], samples=[])
        report["rows"].append(data)
        write(result, report)
        # Noncanonical lexer inputs use the emitted mature-C output as their oracle.
        # The Map fixture has a fixed expression independent of its runtime arguments.
        points = [args, [6,17], [10,123]] if case == "lexer" else [args]
        for probe in points:
            c_obs, oracle = execute(ref["artifact"]["file"], probe, 0, 0,
                                    expected if probe == args else None, ref["runtimeArgumentConvention"])
            direct = {}
            for role in ("baseline", "heap"):
                direct[role] = execute(products_by_role[role]["file"], probe, 0, 0, oracle)[0]
            counts = [count(counter, probe, n, oracle, counter_build["targets"])
                      for n in ([0,1,5,9] if probe == args else [0])]
            if probe == args:
                # Compare two equal 4-invocation differences. Zero repetitions is
                # retained separately to expose process/harness setup overhead.
                deltas = []
                for start, stop in ((counts[1], counts[2]), (counts[2], counts[3])):
                    increments = {target: (stop["targets"].get(target, 0) - start["targets"].get(target, 0)) / 4
                                  for target in counter_build["targets"]}
                    deltas.append({target: value for target, value in increments.items() if value})
                data["perInvocationTargetDeltas"] = deltas
                data["perInvocationPublicTails"] = [sum(delta.values()) for delta in deltas]
                data["stableDynamicDeltas"] = deltas[0] == deltas[1]
            data["controls"].append(dict(args=probe, c=c_obs, direct=direct, counts=counts))
            write(result, report)
        # Estimate repetition counts using a previously independent complete session.
        # All runtime observations below are remeasured in this one guarded process.
        prior = next(c for c in broad["cases"] if c["id"] == case)["summary"]["stats"]
        counts = {role: max(1, math.ceil(140 / prior["c" if role == "c" else "phase197"]["medianMs"]))
                  for role in products_by_role}
        data["calibration"] = {}
        for role, product in products_by_role.items():
            pilot, _ = execute(product["file"], args, counts[role], 4, expected,
                               ref["runtimeArgumentConvention"] if role == "c" else "bend-rts-v1")
            data["calibration"][role] = dict(repetitions=counts[role], **pilot)
            counts[role] = max(1, math.ceil(counts[role] * 145 / max(1, pilot["elapsedMs"])))
        order = list(itertools.permutations(("c","baseline","heap")))
        data["repetitions"] = counts
        for number, roles in enumerate(order):
            for role in roles:
                n = counts[role]
                observation, _ = execute(products_by_role[role]["file"], args, n, 4, expected,
                                         ref["runtimeArgumentConvention"] if role == "c" else "bend-rts-v1")
                assert observation["elapsedMs"] >= 95, (case, role, observation)
                data["samples"].append(dict(role=role, round=number, position=roles.index(role),
                                            repetitions=n, metricMs=observation["elapsedMs"]/n, **observation))
            write(result, report)
        def series(role):
            return [s["metricMs"] for s in data["samples"] if s["role"] == role]
        medians = {role: statistics.median(series(role)) for role in products_by_role}
        pairs = [h/b for h,b in zip(series("heap"),series("baseline"))]
        data["summary"] = dict(medianMs=medians, heapOverBaseline=medians["heap"]/medians["baseline"],
                               heapOverC=medians["heap"]/medians["c"], perRoundRatios=pairs,
                               favorable=sum(p<1 for p in pairs))
        write(result, report)
    authenticate(initial, [p for r in report["rows"] for p in r["products"].values()])
    report["complete"] = True
    write(result, report)
    for row in report["rows"]:
        print(row["id"], row["perInvocationPublicTails"], row["summary"])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    main(parser.parse_args().out)
