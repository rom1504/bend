#!/usr/bin/env python3
"""Independent finite instruction-state oracle; no compiler/target execution.

Models the original exact six-instruction edge and the proposed four-instruction
edge. All registers, stack memory and defined TEST flags must agree. AF is
architecturally undefined after either identical TEST and is not compared.
This checks the rewrite's contract, not the Bend implementation or machine bytes.
"""
import copy
import json
import random


def execute(code, initial):
    state = copy.deepcopy(initial)
    for op, *args in code:
        if op == "imm":
            register, value = args
            state["registers"][register] = value
        elif op == "store-home":
            kind, home = args
            state[kind][home] = state["registers"]["r10"]
        elif op == "load-home":
            kind, home = args
            state["registers"]["r10"] = state[kind][home]
        elif op == "test32":
            value = state["registers"]["r10"] & 0xFFFFFFFF
            state["flags"] = {
                "CF": 0, "OF": 0, "ZF": int(value == 0),
                "SF": (value >> 31) & 1,
                "PF": int(bin(value & 255).count("1") % 2 == 0),
            }
        elif op == "branch-zero":
            state["destination"] = "zero" if state["flags"]["ZF"] else "nonzero"
        elif op == "jump":
            state["destination"] = args[0]
        else:
            raise ValueError(op)
    return state


def main():
    rng = random.Random(193)
    values = [0, 1, 2, 255, 256, 2**31, 2**32 - 1, 2**32,
              2**32 + 1, 2**63, 2**64 - 1]
    values += [rng.getrandbits(64) for _ in range(128)]
    homes = [("registers", f"r{i}") for i in range(16) if i not in (4, 5, 10, 11)]
    homes += [("memory", offset) for offset in (-8, -48, -64, -4096)]
    checked = 0
    flags_mutant_rejected = False
    high_word_mutant_rejected = False
    for value in values:
        for kind, home in homes:
            initial = {
                "registers": {f"r{i}": rng.getrandbits(64) for i in range(16)},
                "memory": {offset: rng.getrandbits(64) for offset in (-8, -48, -64, -4096)},
                "flags": {name: rng.randrange(2) for name in ("CF", "OF", "ZF", "SF", "PF")},
                "destination": "before",
            }
            prefix = [("imm", "r10", value), ("store-home", kind, home)]
            before = prefix + [("jump", "header"), ("load-home", kind, home),
                               ("test32",), ("branch-zero",)]
            destination = "zero" if value & 0xFFFFFFFF == 0 else "nonzero"
            after = prefix + [("test32",), ("jump", destination)]
            expected = execute(before, initial)
            actual = execute(after, initial)
            assert actual == expected, (value, kind, home)
            flags_mutant_rejected |= execute(prefix + [("jump", destination)], initial) != expected
            bad_destination = "zero" if value == 0 else "nonzero"
            high_word_mutant_rejected |= execute(prefix + [("test32",), ("jump", bad_destination)], initial) != expected
            checked += 1
    assert flags_mutant_rejected and high_word_mutant_rejected
    print(json.dumps({"kind": "phase193-loop-threading-independent-state-oracle", "observations": checked,
                      "allStateEqual": True, "flagsDeletionMutantRejected": flags_mutant_rejected,
                      "full64PredicateMutantRejected": high_word_mutant_rejected,
                      "compilerExecuted": False, "targetsExecuted": False}, indent=2))


if __name__ == "__main__":
    main()
