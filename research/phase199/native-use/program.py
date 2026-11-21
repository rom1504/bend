"""Prepare or run an ordinary Bend-to-x86 build with the scan-enabled N1 and bound runtime."""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

from bundle import ASSETS, LEAF, ROOT, pin, read, symbols, verify


P199 = ROOT / "selfhost/build/phase199"
EXPECTED_N1 = ROOT / "selfhost/build/phase198/p199-integrated-native-image01/report.json"
BUNDLE = P199 / "runtime-bundle01/report.json"
NATIVE = ROOT / "selfhost/tools/build/native.py"
GUARD = ROOT / "research/phase199/screen/job.py"


def prepare(args):
    assert re.fullmatch(r"[a-z0-9][a-z0-9-]*", args.name), "Use a fresh simple guard name."
    assert 1 <= args.seconds <= 600 and args.disk_mib > 0 and args.source.is_file()
    image = read(args.image_receipt)
    binding = image["imageBinding"]
    assert image["complete"] and not image.get("changedInputs") and binding["complete"]
    assert binding["kind"] == "bend-build-image-binding" and binding["protocol"] == "native-x86-source-v1"
    assert binding["host"] == "native" and binding["stage"] == "N1" and "x86" in binding["targets"]
    compiler = verify(binding["image"])
    assert binding["image"] == image["binary"]
    source = verify(binding["sourceIdentity"])
    composition_path = source.parent / "report.json"
    composition = read(composition_path)
    assert verify(composition["selectedSource"]) == source
    scan_modules = [verify(record) for record in composition["modules"]]
    assert scan_modules == [ROOT / "research/phase199/scan-lowering" / (name + ".bend")
                            for name in ("recognizer", "pipeline", "hook")]
    scan_api = verify(composition["checkedAPI"])
    frozen = source.read_bytes()
    assert b'"p199_rt_u32_scan4"' in frozen and b'def x199s_array_emit(' in frozen
    policy = read(ASSETS)["runtimePolicies"]["qbe-runtime"]
    assert (policy["runtimeABI"], policy["runtimeArgumentConvention"]) == (11102, "bend-rts-v1")
    bundle = read(args.bundle_receipt)
    assert bundle["complete"] and (bundle["runtimeABI"], bundle["runtimeArgumentConvention"]) == (11102, "bend-rts-v1")
    for record in bundle["inputs"]:
        verify(record)
    variant = bundle["variants"][args.variant]
    runtime = verify(variant["bundle"])
    assert LEAF in variant["checkedDefinedSymbols"]
    output = P199 / args.name
    command = [
        sys.executable, "-B", str(NATIVE), "--workspace", str(ROOT), "--assets", str(ASSETS),
        "--image", str(compiler), "--image-receipt", str(args.image_receipt.resolve()),
        "--host", "native", "--stage", "N1", "--target", "x86", "--mode", "cache",
        "--emit", "object", "--source", str(args.source.resolve()), "--runtime", str(runtime),
        "--runtime-abi", "11102", "--runtime-argument-convention", "bend-rts-v1",
        "--seconds", str(args.seconds), "--out", str(output),
    ]
    inputs = [pin(p) for p in (Path(__file__), NATIVE, GUARD, ASSETS, args.image_receipt,
                                args.bundle_receipt, composition_path, scan_api, *scan_modules,
                                compiler, source, runtime, args.source)]
    if args.expected_stdout:
        command += ["--expected-stdout", str(args.expected_stdout.resolve())]
        inputs.append(pin(args.expected_stdout))
    guarded = [sys.executable, "-B", str(GUARD), args.name, str(args.seconds + 4), str(args.disk_mib), *command]
    return dict(kind="phase199-ordinary-native-program", inputs=inputs, runtime=pin(runtime),
                image=pin(compiler), compilerSource=pin(source), programSource=pin(args.source),
                output=str(output), runtimeABI=11102, runtimeArgumentConvention="bend-rts-v1",
                variant=args.variant, nativeCommand=command, guardedCommand=guarded,
                expectedStdout=pin(args.expected_stdout) if args.expected_stdout else None)


def check_product(recipe):
    output = Path(recipe["output"])
    built = read(output / "report.json")
    assert built["complete"] and not built["changedInputs"] and built["assemblerSkipped"]
    assert built["runtimeABI"] == 11102 and built["runtimeArgumentConvention"] == "bend-rts-v1"
    assert verify(built["runtime"]) == verify(recipe["runtime"])
    request = read(output / "request.json")
    assert verify(request["image"]) == verify(recipe["image"])
    assert verify(request["source"]) == verify(recipe["programSource"])
    if recipe["expectedStdout"]:
        assert built["outputExact"] and (output/"execute.stdout").read_bytes() == verify(recipe["expectedStdout"]).read_bytes()
    product = verify(built["object"])
    _, undefined = symbols(product)
    return dict(binary=pin(verify(built["binary"])), object=pin(product), receipt=pin(output/"report.json"),
                referencesScanHelper=LEAF in undefined, outputExact=built.get("outputExact", False))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--expected-stdout", type=Path)
    parser.add_argument("--image-receipt", type=Path, default=EXPECTED_N1)
    parser.add_argument("--bundle-receipt", type=Path, default=BUNDLE)
    parser.add_argument("--variant", choices=("live", "original"), default="live")
    parser.add_argument("--name", required=True, help="Fresh directory name under selfhost/build/phase199.")
    parser.add_argument("--seconds", default=24, type=int)
    parser.add_argument("--disk-mib", default=48, type=int)
    parser.add_argument("--recipe-out", type=Path, help="Write the authenticated argv and its input hashes.")
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument("--run", action="store_true", help="Run through the guard on the coordinated CPU 3 lane.")
    modes.add_argument("--inspect-existing", action="store_true", help="Verify an existing product without executing it.")
    args = parser.parse_args()
    recipe = prepare(args)
    if args.recipe_out:
        with args.recipe_out.open("x") as f:
            json.dump(recipe, f, indent=2)
            f.write("\n")
    if args.run:
        assert not Path(recipe["output"]).exists()
        proc = subprocess.run(recipe["guardedCommand"], cwd=ROOT)
        if proc.returncode:
            raise SystemExit(proc.returncode)
    if args.run or args.inspect_existing:
        for p in recipe["inputs"]:
            verify(p)
        print(json.dumps(check_product(recipe), indent=2))
    else:
        print(json.dumps(recipe, indent=2))


if __name__ == "__main__":
    main()
