#!/usr/bin/env python3
"""Extend the frozen Phase190 ELF audit with conservative frame transport witnesses.

Accepts exactly machine-audit.py's arguments; writes its report.json and an
additional frame-transitions.json. Executes nm/objdump, never target programs.
"""
import importlib.util
import json
from pathlib import Path
import re
import sys


AUDIT_PATH = Path(__file__).resolve().parents[1] / "phase190/machine-audit.py"
spec = importlib.util.spec_from_file_location("phase190_machine_audit", AUDIT_PATH)
audit = importlib.util.module_from_spec(spec)
spec.loader.exec_module(audit)


def operands(text):
    # AT&T commas inside memory operands do not separate operands.
    return [x.strip() for x in re.split(r",(?![^()]*\))", text.split("#", 1)[0])]


def frame_slot(value):
    match = re.fullmatch(r"(-?(?:0x[0-9a-f]+|[0-9]+))?\(%rbp\)", value)
    return int(match[1] or "0", 0) if match else None


def register_width(value):
    for pattern, width in [
        (r"%(?:r(?:ax|bx|cx|dx|si|di|bp|sp)|r(?:[89]|1[0-5]))", 8),
        (r"%(?:e(?:ax|bx|cx|dx|si|di|bp|sp)|r(?:[89]|1[0-5])d)", 4),
        (r"%(?:ax|bx|cx|dx|si|di|bp|sp|r(?:[89]|1[0-5])w)", 2),
        (r"%(?:[abcd][lh]|sil|dil|bpl|spl|r(?:[89]|1[0-5])b)", 1),
    ]:
        if re.fullmatch(pattern, value):
            return width
    return None


def boundary(ins):
    return ins["mnemonic"].startswith(("j", "loop", "call", "ret"))


def transition_stats(instructions, all_instructions):
    targets = set()
    unknown_jump = False
    for ins in all_instructions:
        if ins["mnemonic"].startswith(("j", "loop")):
            match = re.match(r"(?:0x)?([0-9a-f]+)\b", ins["operands"])
            if match:
                targets.add(int(match[1], 16))
            else:
                unknown_jump = True
    pending, events = {}, []
    previous_end = None
    stats = {"recognized_frame_stores": 0, "recognized_frame_loads": 0,
             "frame_store_next_load_transitions": 0, "analysis_barriers": 0,
             "unknown_jump_target": unknown_jump}
    # Only explicit, familiar two-operand instructions may preserve state.
    harmless = re.compile(r"(?:mov(?:abs)?[bwlq]?|lea[bwlq]?|add[bwlq]?|sub[bwlq]?|"
                           r"and[bwlq]?|or[bwlq]?|xor[bwlq]?|cmp[bwlq]?|test[bwlq]?|"
                           r"sh[lr][bwlq]?|sa[lr][bwlq]?|imul[bwlq]?)")
    for ordinal, ins in enumerate(sorted(instructions, key=lambda x: x["offset"])):
        pc = int(ins["address"], 16)
        if pc != previous_end or pc in targets or unknown_jump:
            pending.clear()
        previous_end = pc + ins["bytes"]
        op = ins["mnemonic"]
        args = operands(ins["operands"])
        if boundary(ins) or len(args) != 2 or not harmless.fullmatch(op):
            pending.clear()
            stats["analysis_barriers"] += 1
            continue
        src, dst = args
        if dst in ("%rbp", "%ebp", "%bp", "%bpl"):
            pending.clear()
            stats["analysis_barriers"] += 1
            continue
        source_slot, dest_slot = frame_slot(src), frame_slot(dst)
        plain_move = bool(re.fullmatch(r"mov[bwlq]?", op))
        width = register_width(src) if dest_slot is not None else register_width(dst)
        if plain_move and width and dest_slot is not None:
            stats["recognized_frame_stores"] += 1
            # A partial/overlapping write invalidates any earlier whole-slot store.
            pending = {key: value for key, value in pending.items()
                       if key[0] + key[1] <= dest_slot or dest_slot + width <= key[0]}
            pending[(dest_slot, width)] = (ordinal, ins)
        elif plain_move and width and source_slot is not None:
            stats["recognized_frame_loads"] += 1
            stored = pending.pop((source_slot, width), None)
            if stored:
                index, producer = stored
                events.append({"frame_displacement": source_slot, "bytes": width,
                               "intervening_instructions": ordinal - index - 1,
                               "store": producer, "next_load": ins})
            pending = {key: value for key, value in pending.items()
                       if key[0] + key[1] <= source_slot or source_slot + width <= key[0]}
        elif not register_width(dst) or "%rbp" in src or "%rbp" in dst:
            # Unknown memory writes/widths/frame accesses can alias pending slots.
            pending.clear()
            stats["analysis_barriers"] += 1
    stats["frame_store_next_load_transitions"] = len(events)
    return {"static": stats, "witnesses": events}


def main():
    audit.main()
    # The inherited parser already validated and created this fresh output root.
    out_arg = next((x.split("=", 1)[1] for x in sys.argv if x.startswith("--out=")), None)
    output = Path(out_arg or sys.argv[sys.argv.index("--out") + 1])
    path = output / "report.json"
    source = json.loads(path.read_text())
    result = {
        "kind": "phase191-static-frame-transitions", "version": 1,
        "script": audit.identity(__file__), "base_script": audit.identity(AUDIT_PATH),
        "machine_audit": audit.identity(path),
        "scope": "Same-width explicit rbp store followed by its next recognized load inside a conservative straight-line span.",
        "limits": [
            "No target execution, frequencies, cache misses, DRAM traffic, forwarding latency or runtime prediction.",
            "Transitions are transport witnesses, not proof that either instruction is redundant.",
            "Only integer register/memory mov widths are recognized; immediate stores and SIMD/extensions are barriers.",
            "State resets at direct branch targets, control transfers, gaps, unsupported instructions, rbp writes and unknown memory writes.",
            "An indirect jump disables cross-instruction matching for that function; no cross-block or loop-carried dependencies are inferred.",
        ],
        "artifacts": {},
    }
    for role, artifact in source["artifacts"].items():
        if audit.identity(artifact["artifact"]["path"]) != artifact["artifact"]:
            raise ValueError("ELF changed after machine audit")
        functions = {}
        for name, function in artifact["functions"].items():
            instructions = function["instructions"]
            regions = {}
            for region, record in function["regions"].items():
                spans = record["offset_ranges_end_exclusive"]
                selected = [i for i in instructions if any(lo <= i["offset"] < hi for lo, hi in spans)]
                regions[region] = {"offset_ranges_end_exclusive": spans,
                                   **transition_stats(selected, instructions)}
            functions[name] = {"address": function["address"],
                               "raw_disassembly": function["raw_disassembly"],
                               "whole_function": transition_stats(instructions, instructions),
                               "regions": regions}
        result["artifacts"][role] = {"artifact": artifact["artifact"], "functions": functions}
    (output / "frame-transitions.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
