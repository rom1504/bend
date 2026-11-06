#!/usr/bin/env python3
"""Offline policy-aware successor; keeps legacy guard passes separate from RFC promotions.

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


def validate_policy(body, source, policy):
    """Exact reviewed source and emitted wrapper; refuse other guard policies."""
    source_hashes = {"legacy": "5d713668c30959c3b192014fe69564424d90d31b70b7be8b05a5169f1d8862bc",
                     "result-or-rfc": "7167a981c47f2115213c54d7c2aed485bc16aa2563aecaaede6bb379237c8e32"}
    def definition_hash(name):
        found = re.search(r"^def " + name + r"\(.*?(?=^@unsafe|\Z)", source, re.M | re.S)
        require(found is not None, "Missing reviewed source helper: " + name)
        return hashlib.sha256("".join(found[0].split()).encode()).hexdigest()
    actual_hash = definition_hash("p171d_wrapper")
    require(actual_hash == source_hashes[policy], "Unreviewed source wrapper/policy")
    if policy == "result-or-rfc":
        require(definition_hash("p171d_promote_ops") ==
                "aecf650f1468fac707b51f877f74983810d9ef8d2d9a1169494d2f6dbfb9b255",
                "Unreviewed source promotion operations")
    lines = body.splitlines()
    header = re.fullmatch(r"function l \$(\S+)\(l %state((?:, l %v_\w+)*)\) \{", lines[0])
    require(header is not None, "Unsupported wrapper signature")
    symbol, params = header.groups()
    values = [part[2:] for part in params.removeprefix(", ").split(", ")] if params else []
    root = re.search(r"^%v_p171desc_roots =l call \$p118_rt_borrow_scalar_safe\(l %state, l (%v_\w+), l (%v_\w+|0), w ([12])\)$", body, re.M)
    require(root is not None, "Unsupported root guard")
    first, second, count = root.groups()
    held = [first] if count == "1" else [first, second]
    require(all(v in values for v in held) and len(set(held)) == len(held) and
            (count == "2" or second == "0"), "Invalid held-root arguments")
    reader = re.search(r"^%p113_status =l call \$(\S+)\(", body, re.M)
    fallback = re.search(r"^%v_p171desc_fallback =l call \$(\S+)\(", body, re.M)
    require(reader is not None and fallback is not None, "Missing reader/fallback")
    require(decoded(reader[1]) == "$p171desc." + decoded(symbol) + ".0" and
            decoded(fallback[1]) == "$p171desc.owned." + decoded(symbol), "Unexpected reader/fallback identity")
    expected = [lines[0], "@entry", "%v_scratch =l alloc8 2048", "%p113_results =l alloc8 64",
                "jmp @p113_loop", "@p113_loop", root[0],
                "%v_p171desc_roots_bool =w cnel %v_p171desc_roots, 0",
                "jnz %v_p171desc_roots_bool, @b_0, @b_1", "@b_0",
                f"%p113_status =l call ${reader[1]}(l %state, l %p113_results{params})",
                "%p113_result_at_3 =l add %p113_results, 0",
                "%v_p171desc_accepted =l loadl %p113_result_at_3",
                "%p113_result_at_4 =l add %p113_results, 8",
                "%v_p171desc_result =l loadl %p113_result_at_4",
                "%v_p171desc_accepted_bool =w cnel %v_p171desc_accepted, 0",
                "jnz %v_p171desc_accepted_bool, @b_5, @b_6", "@b_5",
                "%v_p171desc_escape =l call $p118_rt_borrow_scalar_safe(l %state, l %v_p171desc_result, l 0, w 1)",
                "%v_p171desc_escape_bool =w cnel %v_p171desc_escape, 0"]
    predicate = "%v_p171desc_escape_bool"
    if policy == "result-or-rfc":
        expected += ["%v_p171desc_rfc_bits =l and %v_p171desc_result, 9223372036854775808",
                     "%v_p171desc_rfc_bool =w cnel %v_p171desc_rfc_bits, 0",
                     "%v_p171desc_promote =w or %v_p171desc_escape_bool, %v_p171desc_rfc_bool"]
        predicate = "%v_p171desc_promote"
    expected += [f"jnz {predicate}, @b_8, @b_9", "@b_8",
                 "%v_p171desc_owned =l call $p111_rt_keep(l %state, l %v_p171desc_result)"]
    expected += [f"%v_p128bs_drop_{i} =l call $p111_rt_sink(l %state, l {v})" for i, v in enumerate(held)]
    expected.append("ret %v_p171desc_owned")
    for label in ["@b_9", "@b_6", "@b_1"]:
        expected += [label, f"%v_p171desc_fallback =l call ${fallback[1]}(l %state{params})",
                     "ret %v_p171desc_fallback"]
    expected.append("}")
    require(lines == expected, "QBE wrapper differs from the complete reviewed policy/CFG")
    return {"sourceWrapperNormalizedSha256": actual_hash, "completeQbeWrapperExact": True,
            "rootGuardUnchanged": True, "resultGuardArgumentsExact": True,
            "heldRoots": held, "keepBeforeDrop": True, "fallbackUnchanged": True,
            "rfcMask": "0x8000000000000000" if policy == "result-or-rfc" else None}


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
        if args.policy == "result-or-rfc":
            require("firstRfc" in row and "failedFirstRfc" in row, "RFC policy requires v2 counters")
        if "firstRfc" in row:
            require(0 <= row["failedFirstRfc"] <= min(row["firstRfc"], row["calls"] - row["passed"]) and
                    row["firstRfc"] <= row["calls"] and
                    row["firstRfc"] - row["failedFirstRfc"] <= row["passed"], "Inconsistent RFC counters")
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
                          "firstRfc": row.get("firstRfc", 0 if ret not in observed else None),
                          "failedFirstRfc": row.get("failedFirstRfc", 0 if ret not in observed else None),
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
    policy_check = validate_policy(wrapper_text, source_text, args.policy)
    extra = result["failedFirstRfc"] if args.policy == "result-or-rfc" else 0
    require(extra is not None, "Missing result RFC observations")
    derived.update({"oldResultGuardPassed": result["passed"], "additionalRfcPromotions": extra,
                    "promotions": result["passed"] + extra,
                    "resultDeclines": result["calls"] - result["passed"] - extra,
                    "ownedFallbacks": root["calls"] - result["passed"] - extra})
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
    output = {"kind": "phase171-descendant-guard-coverage", "version": 2, "complete": True, "policy": args.policy, "policyCheck": policy_check,
              "snapshotUtc": datetime.now(timezone.utc).isoformat(), "targetsRunByAnalyzer": False,
              "inputs": inputs, "disassemblyCommand": command, "disassembly": pin(paths["disassembly"]),
              "fullDisassemblyDigest": {"bytes": len(disassembly.encode()),
                 "sha256": hashlib.sha256(disassembly.encode()).hexdigest(), "retained": "guard-caller excerpts only"},
              "wrapper": {"symbol": wrapper, "decoded": decoded(wrapper), "qbe": qbe[wrapper],
                          "frozenBendSource": source_lines}, "sites": sites, "derived": derived,
              "promotionMeasurement": "Derived, not directly counted: legacy=passed; result-or-rfc=passed+failedFirstRfc, under the exact source/QBE CFG. Old guard passed remains a separate observation.",
              "limitations": ["One diagnostic execution; link counters alter timing, never a speed sample.",
                  "Return addresses bind only this fixed-address ELF; remap after every relink.",
                  "Counts derive path coverage under the displayed wrapper CFG, not a general lifetime proof.",
                  "Helper guard failures identify boundary refusal, not its underlying runtime representation reason.",
                  "Diagnostic coverage is not clean timing or a whole-compiler performance claim."]}
    paths["json"].write_text(json.dumps(output, indent=2) + "\n")
    lines = ["# Phase171 borrowed-descendant guard coverage", "", "Offline snapshot: " + output["snapshotUtc"] + ".",
             "", "The exact diagnostic wrapper **" + decoded(wrapper) + "** makes " + str(root["calls"]) +
             " calls: " + str(root["passed"]) + " pass the root guard, " + str(derived["readerDeclines"]) +
             " readers decline, and **" + str(derived["promotions"]) + " promotions are derived** under the authenticated " + args.policy + " policy.", "",
             str(derived["ownedFallbacks"]) + " calls use the owned fallback. Old result-guard passes: " + str(result["passed"]) + "; additional RFC-permitted promotions: " + str(extra) + ". Promotions are derived from counters and the exact validated CFG, not directly instrumented.",
             "", "The root-owned diagnostic reused the exact program/runtime objects and interposed only the guard call. The shim forwards unchanged arguments and result; counters are separate from the Bend heap. Exact stdout, empty stderr, zero lost sites and zero unexpected guard values passed. No target was executed by this analyzer.",
             "", "| Site | Return address | Calls | Old guard passed | Failed + RFC | QBE line |", "| --- | --- | ---: | ---: | ---: | ---: |"]
    lines += [f"| {s['role']}: `{s['decoded']}` | `{s['returnAddress']}` | {s['calls']} | {s['passed']} | {s['failedFirstRfc']} | {s['qbeLine']} |" for s in sites]
    lines += ["", "The result site is authenticated from the diagnostic ELF even when absent from the counter table; with zero losses, absence means zero calls. Reader declines = passed roots − result-guard calls. For legacy policy, promotions = passed result guards. For result-or-rfc, promotions = passed + failedFirstRfc (disjoint sets). Owned fallbacks = wrapper calls − promotions. Missing RFC fields in legacy observations remain unknown, not measured zero.",
              "", "QBE and machine mapping: the wrapper first tests `p171desc_roots`, invokes the two-result reader, tests `p171desc_accepted`, and only then reaches `p171desc_escape`. The selected policy then determines success; the RFC variant additionally masks bit63, canonicalizes both predicates and ORs them. Promotion calls `p111_rt_keep` before dropping both held roots. Each refusal branches to the original owned implementation. The JSON retains this exact QBE body and the frozen Bend producer; the disassembly contains every guard caller from this ELF.",
              "", "Exact binary SHA256: `" + binary["sha256"] + "`. Full receipt/source/object/QBE/method/tool pins and mapped instructions: [JSON](" + paths["json"].name + "). Disassembly: [guard callers](" + paths["disassembly"].name + ").",
              "", "This establishes observed refusal/acceptance coverage, not a compiler-wide speed prediction, promotion decision or universal ownership proof. The counters do not reveal why helper guards reject their arguments. Reuse the analyzer with an explicit policy and fresh output prefix, remapping its own executable; never reuse these addresses. Wrong-policy QBE/source is rejected.",
              "", "```sh", "python3 -B experiments/phase171/tools/analyze-descendant-guards-v2.py \\",
              "  --report " + str(report_path) + " \\", "  --policy " + args.policy + " --out FRESH_OUTPUT_PREFIX", "```", ""]
    paths["markdown"].write_text("\n".join(lines))
    print(json.dumps({"output": str(paths["json"]), "derived": derived}))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--report", required=True)
    parser.add_argument("--policy", required=True, choices=["legacy", "result-or-rfc"])
    parser.add_argument("--out", required=True, help="Fresh output prefix, creates .json/.md/-disassembly.txt")
    parser.add_argument("--objdump", default="/usr/bin/objdump")
    analyze(parser.parse_args())
