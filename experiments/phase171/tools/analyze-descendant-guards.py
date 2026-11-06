#!/usr/bin/env python3
"""Offline, fail-closed return-address census for the Phase171 link diagnostic.

Runs only objdump on the pinned diagnostic ELF. It never executes that ELF,
relinks objects, runs a compiler, or treats diagnostic duration as clean timing.
"""
import argparse
import hashlib
import json
import re
import struct
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def require(value, message):
    if not value:
        raise ValueError(message)


def pin(path):
    path = Path(path).resolve()
    data = path.read_bytes()
    return {"file": str(path), "bytes": len(data),
            "sha256": hashlib.sha256(data).hexdigest()}


def verify(record):
    actual = pin(record["file"])
    require(all(actual[k] == record[k] for k in ("bytes", "sha256")),
            "Changed pinned input: " + record["file"])
    return actual


def read(path):
    return json.loads(Path(path).read_text())


def decoded(symbol):
    if "FID_" not in symbol:
        return symbol
    suffix = symbol.split("FID_", 1)[1].strip("_")
    return "".join(chr(int(n)) for n in suffix.split("_"))


def functions(text):
    result = {}
    for match in re.finditer(r"^function[^\n]* \$(\S+)\([^\n]*\) \{\n.*?^\}",
                             text, re.M | re.S):
        start = text.count("\n", 0, match.start()) + 1
        result[match[1]] = {"startLine": start, "text": match[0]}
    return result


def analyze(args):
    report_path = Path(args.report).resolve()
    report = read(report_path)
    require(report.get("complete") and report.get("outputExact"), "Incomplete observation")
    plan_record = next(x for x in report["inputs"] if x["file"].endswith("/plan.json"))
    plan = read(verify(plan_record)["file"])
    require(plan.get("complete"), "Incomplete diagnostic plan")
    inputs = [pin(report_path)] + [verify(x) for x in report["inputs"]]
    for item in plan["inputs"]:
        require(any(item == other for other in report["inputs"]), "Plan/observation input mismatch")
    require([j["command"] for j in report["jobs"]] == plan["commands"], "Changed commands")
    for job in report["jobs"]:
        require(job["exitCode"] == 0, "Failed diagnostic job")
        verify(job["stdout"])
        require(verify(job["stderr"])["bytes"] == 0, "Diagnostic stderr is nonempty")
    require(report["jobs"][-1]["stdout"]["sha256"] == plan["expectedStdout"]["sha256"],
            "Output oracle mismatch")
    binary = verify(report["binary"])
    require(report["jobs"][-1]["command"][0] == binary["file"], "Wrong executed binary")
    require(plan["commands"][1][-2:] == ["-o", binary["file"]], "Wrong linked binary")
    header = Path(binary["file"]).read_bytes()[:64]
    require(header[:6] == b"\x7fELF\x02\x01" and struct.unpack_from("<HH", header, 16) == (2, 62),
            "Only fixed-address x86_64 ELF is supported; never reuse addresses across binaries")
    counts_pin = verify(report["counts"])
    counts = read(counts_pin["file"])
    require(counts["unrecorded"] == 0, "Lost counter sites")
    observed = {}
    for row in counts["sites"]:
        address = int(row["returnAddress"], 16)
        require(address not in observed, "Duplicate counter address")
        require(row["unexpected"] == 0 and 0 <= row["passed"] <= row["calls"], "Invalid guard result")
        observed[address] = row
    qbe_pin = next(x for x in inputs if x["file"].endswith("/program.ssa"))
    qbe = functions(Path(qbe_pin["file"]).read_text())
    guard = "p118_rt_borrow_scalar_safe"
    wrapper_names = [name for name, f in qbe.items()
                     if re.search(r"%v_p171desc_roots =l call \$" + guard + r"\(", f["text"])]
    require(len(wrapper_names) == 1, "Exactly one descendant wrapper required")
    wrapper = wrapper_names[0]
    wrapper_text = qbe[wrapper]["text"]
    require(wrapper_text.count("call $" + guard + "(") == 2 and
            wrapper_text.index("%v_p171desc_roots =") < wrapper_text.index("%v_p171desc_accepted =") <
            wrapper_text.index("%v_p171desc_escape ="), "Unsupported wrapper control shape")
    require(wrapper_text.count("%v_p171desc_fallback =") == 3 and
            wrapper_text.count("call $p111_rt_keep(") == 1, "Unsupported fallback/promotion shape")
    objdump = Path(args.objdump).resolve()
    command = [str(objdump), "-d", "--no-show-raw-insn", binary["file"]]
    disassembly = subprocess.run(command, check=True, capture_output=True, text=True).stdout
    machine = {}
    current = None
    for line in disassembly.splitlines():
        match = re.match(r"^[0-9a-f]+ <([^>]+)>:$", line)
        if match:
            current = match[1]
            machine[current] = {"lines": [line], "instructions": []}
        elif current:
            machine[current]["lines"].append(line)
            match = re.match(r"^\s*([0-9a-f]+):\s+(.*)$", line)
            if match:
                machine[current]["instructions"].append((int(match[1], 16), match[2]))
    sites = []
    selected = []
    for symbol, body in machine.items():
        calls = [(i, address, instruction) for i, (address, instruction) in enumerate(body["instructions"])
                 if re.search(r"\bcallq?\s+\S+ <__wrap_" + guard + r">$", instruction)]
        if not calls:
            continue
        require(symbol in qbe, "Guard caller absent from pinned QBE: " + symbol)
        qbe_calls = [(qbe[symbol]["startLine"] + i, line) for i, line in enumerate(qbe[symbol]["text"].splitlines())
                     if "call $" + guard + "(" in line]
        require(len(qbe_calls) == len(calls), "QBE/machine guard count differs: " + symbol)
        selected.append(symbol)
        for ordinal, (index, address, instruction) in enumerate(calls):
            ret = body["instructions"][index + 1][0]
            require(ret == address + 5, "Unexpected x86 direct-call size")
            row = observed.get(ret, {"calls": 0, "passed": 0, "unexpected": 0})
            role = "root" if symbol == wrapper and ordinal == 0 else (
                   "result" if symbol == wrapper else "helper")
            sites.append({"role": role, "symbol": symbol, "decoded": decoded(symbol),
                          "callAddress": hex(address), "returnAddress": hex(ret),
                          "calls": row["calls"], "passed": row["passed"],
                          "missingMeansZero": ret not in observed,
                          "qbeLine": qbe_calls[ordinal][0], "qbeInstruction": qbe_calls[ordinal][1],
                          "machineInstruction": instruction})
    require(set(observed) <= {int(s["returnAddress"], 16) for s in sites}, "Unmapped observed guard site")
    roots = [s for s in sites if s["role"] == "root"]
    results = [s for s in sites if s["role"] == "result"]
    require(len(roots) == len(results) == 1, "Missing wrapper sites")
    root, result = roots[0], results[0]
    require(0 <= result["passed"] <= result["calls"] <= root["passed"] <= root["calls"],
            "Invalid root/reader/result counter order")
    derived = {"wrapperCalls": root["calls"], "rootDeclines": root["calls"] - root["passed"],
               "readerAttempts": root["passed"], "readerDeclines": root["passed"] - result["calls"],
               "readerAccepted": result["calls"], "resultDeclines": result["calls"] - result["passed"],
               "promotions": result["passed"], "ownedFallbacks": root["calls"] - result["passed"]}
    # Authenticate the emitted QBE's immediate receipt and frozen compiler source,
    # without rereading every historical dependency or mutable source module.
    emission_path = Path(qbe_pin["file"]).with_name("report.json")
    emission = read(emission_path)
    require(emission.get("complete") and emission["ir"]["sha256"] == qbe_pin["sha256"], "Wrong emission receipt")
    source_manifest_pin = next(x for x in emission["inputs"] if x["file"].endswith("/manifest.json")
                               and "/descendant-source" in x["file"])
    source_manifest = read(verify(source_manifest_pin)["file"])
    compiler_source = verify(source_manifest["source"])
    source_text = Path(compiler_source["file"]).read_text()
    wrapper_match = re.search(r"^def p171d_wrapper\(.*?(?=^@unsafe|\Z)", source_text, re.M | re.S)
    require(wrapper_match is not None, "Missing source wrapper")
    source_lines = {"first": source_text.count("\n", 0, wrapper_match.start()) + 1,
                    "text": wrapper_match[0].rstrip()}
    inputs += [binary, counts_pin, pin(objdump), pin(__file__), pin(emission_path),
               source_manifest_pin, compiler_source]
    for item in inputs:
        verify(item)
    prefix = Path(args.out).resolve()
    paths = {k: Path(str(prefix) + suffix) for k, suffix in
             (("json", ".json"), ("markdown", ".md"), ("disassembly", "-disassembly.txt"))}
    require(all(not p.exists() for p in paths.values()), "All outputs must be fresh")
    excerpt = "# Exact diagnostic ELF: " + binary["sha256"] + "\n# " + " ".join(command) + "\n\n"
    excerpt += "\n".join("\n".join(machine[s]["lines"]) for s in selected)
    paths["disassembly"].write_text(excerpt)
    output = {"kind": "phase171-descendant-guard-coverage", "version": 1, "complete": True,
              "snapshotUtc": datetime.now(timezone.utc).isoformat(), "targetsRunByAnalyzer": False,
              "inputs": inputs, "disassemblyCommand": command, "disassembly": pin(paths["disassembly"]),
              "fullDisassemblyDigest": {"bytes": len(disassembly.encode()),
                 "sha256": hashlib.sha256(disassembly.encode()).hexdigest(), "retained": "guard-caller excerpts only"},
              "wrapper": {"symbol": wrapper, "decoded": decoded(wrapper), "qbe": qbe[wrapper],
                          "frozenBendSource": source_lines}, "sites": sites, "derived": derived,
              "limitations": ["One diagnostic execution; link counters alter timing, never a speed sample.",
                  "Return addresses bind only this fixed-address ELF; remap after every relink.",
                  "Counts derive path coverage under the displayed wrapper CFG, not a general lifetime proof.",
                  "Helper guard failures identify boundary refusal, not its underlying runtime representation reason.",
                  "Neutral clean timing with zero promotions does not reject the borrowed-descendant capability."]}
    paths["json"].write_text(json.dumps(output, indent=2) + "\n")
    lines = ["# Phase171 borrowed-descendant guard coverage", "", "Offline snapshot: " + output["snapshotUtc"] + ".",
             "", "The exact diagnostic wrapper **" + decoded(wrapper) + "** makes " + str(root["calls"]) +
             " calls: " + str(root["passed"]) + " pass the root guard, " + str(derived["readerDeclines"]) +
             " readers decline, and **" + str(derived["promotions"]) + " borrowed results are promoted**.", "",
             "All " + str(derived["ownedFallbacks"]) + " calls use the owned fallback. The neutral clean runtime result therefore does not measure a successful borrowed-result path or disprove the capability.",
             "", "The root-owned diagnostic reused the exact program/runtime objects and interposed only the guard call. The shim forwards unchanged arguments and result; counters are separate from the Bend heap. Exact stdout, empty stderr, zero lost sites and zero unexpected guard values passed. No target was executed by this analyzer.",
             "", "| Site | Return address | Calls | Passed | QBE line |", "| --- | --- | ---: | ---: | ---: |"]
    lines += [f"| {s['role']}: `{s['decoded']}` | `{s['returnAddress']}` | {s['calls']} | {s['passed']} | {s['qbeLine']} |" for s in sites]
    lines += ["", "The result site is authenticated from the diagnostic ELF even when absent from the counter table; with zero losses, absence means zero calls. Reader declines = passed roots − result-guard calls. Promotions = passed result guards. Owned fallbacks = wrapper calls − promotions.",
              "", "QBE and machine mapping: the wrapper first tests `p171desc_roots`, invokes the two-result reader, tests `p171desc_accepted`, and only then reaches `p171desc_escape`. Promotion calls `p111_rt_keep` before dropping both held roots. Each refusal branches to the original owned implementation. The JSON retains this exact QBE body and the frozen Bend producer; the disassembly contains every guard caller from this ELF.",
              "", "Exact binary SHA256: `" + binary["sha256"] + "`. Full receipt/source/object/QBE/method/tool pins and mapped instructions: [JSON](" + paths["json"].name + "). Disassembly: [guard callers](" + paths["disassembly"].name + ").",
              "", "This establishes observed refusal/acceptance coverage, not a compiler-wide speed prediction, promotion decision or universal ownership proof. The counters do not reveal why helper guards reject their arguments. Reuse the analyzer with a fresh output prefix for source13 and remap its own executable; never reuse these addresses.",
              "", "```sh", "python3 -B experiments/phase171/tools/analyze-descendant-guards.py \\",
              "  --report " + str(report_path) + " \\", "  --out FRESH_OUTPUT_PREFIX", "```", ""]
    paths["markdown"].write_text("\n".join(lines))
    print(json.dumps({"output": str(paths["json"]), "derived": derived}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", required=True)
    parser.add_argument("--out", required=True, help="Fresh output prefix, creates .json/.md/-disassembly.txt")
    parser.add_argument("--objdump", default="/usr/bin/objdump")
    analyze(parser.parse_args())
