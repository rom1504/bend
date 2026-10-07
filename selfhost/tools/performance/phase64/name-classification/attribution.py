#!/usr/bin/env python3
"""Read-only sampled-leaf attribution. Does not invoke a compiler or profiler."""
import collections, hashlib, json
from pathlib import Path
ROOT = Path(__file__).resolve().parents[5]
ROWS = []
for case in ["numeric-recurrence", "lexer", "test-map-set-ops"]:
    # Match catalog names by the existing result paths, without inventing a target.
    directory = ROOT / "selfhost/build/phase64/baseline-state09/allocation"
    matches = sorted(directory.glob(case + "-0-baseline-profile/profile.heapprofile"))
    if not matches and case == "lexer":
        matches = sorted(directory.glob("*lexer*-0-baseline-profile/profile.heapprofile"))
    assert len(matches) == 1, (case, matches)
    file = matches[0]
    content = file.read_bytes(); profile = json.loads(content)
    nodes, parents = {}, {}
    todo = [(profile["head"], None)]
    while todo:
        node, parent = todo.pop(); nodes[node["id"]] = node; parents[node["id"]] = parent
        todo.extend((child, node["id"]) for child in node.get("children", []))
    groups = collections.Counter(); leaves = collections.Counter()
    for sample in profile["samples"]:
        node = nodes[sample["nodeId"]]; name = node["callFrame"]["functionName"]
        if not name.startswith("$jd$String_46_contains"):
            continue
        leaves[name] += sample["size"]
        at = parents[node["id"]]
        while at is not None:
            caller = nodes[at]["callFrame"]["functionName"]
            if caller.startswith("$jd$") and not caller.startswith("$jd$String_46_"):
                groups[caller] += sample["size"]; break
            at = parents[at]
        else:
            groups["unattributed"] += sample["size"]
    ROWS.append({"case":case,"raw":{"file":str(file),"sha256":hashlib.sha256(content).hexdigest()},"sampledLeafBytes":sum(leaves.values()),"leafSymbols":dict(leaves),"nearestNonStringGeneratedCaller":dict(groups)})
print(json.dumps({"kind":"phase64-constant-name-allocation-attribution","producer":{"file":str(Path(__file__).resolve()),"sha256":hashlib.sha256(Path(__file__).read_bytes()).hexdigest()},"dataOnly":True,"targetExecuted":False,"scope":"Only samples whose leaf is a String.contains shared-SCC symbol; nearest non-String generated ancestor is attributed. This is sampled allocation, not complete allocation or CPU time, and SCC labels do not isolate every logical function.","rows":ROWS},indent=2))
