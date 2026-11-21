"""Census exact shared identities in the emitted public dispatch table and private functions."""
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import re
import sys
from assembly import ROOT
sys.path.insert(0, str(ROOT / "selfhost/tools/profiler"))
from owners import decoded_symbol, group_fids

def census(directory):
    identity = json.loads((directory/"report.json").read_text())
    digest = hashlib.sha256()
    definitions = set()
    public = []
    in_table = False
    with gzip.open(directory/"program.s.gz","rb") as stream:
        for line in stream:
            digest.update(line)
            if line.startswith(b".type "):
                m = re.fullmatch(rb"\.type\s+(p(?:111|112w|113d)_FID_[\d_]+),\s*@function",line.strip())
                if m:
                    name = m[1].decode()
                    assert name not in definitions
                    definitions.add(name)
            if line.startswith(b"p111_segments:"):
                assert not in_table and not public
                in_table = True
            elif in_table:
                if line.strip().startswith(b".size"):
                    in_table = False
                    continue
                m = re.fullmatch(rb"\.quad\s+(p111_FID_[\d_]+)(?:\+0)?",line.strip())
                if not m:
                    raise ValueError(line[:100])
                public.append(m[1].decode())
    assert digest.hexdigest() == identity["sha256"]
    assert not in_table and len(set(public)) == len(public) and set(public) <= definitions and public
    fids = [dict(fid=i,decoded=decoded_symbol(s)) for i,s in enumerate(public)]
    groups = group_fids(fids)
    private = {decoded_symbol(s) for s in definitions if not s.startswith("p111_")}
    counts = dict(groups_with_exact_private_direct=0,
                  groups_with_private_direct_and_continuations=0,
                  anonymous_segments_in_those_groups=0)
    matches = Counter(r["role"] for r in fids if r["decoded"] in private)
    group_errors = Counter(reason for g in groups for reason in g["errors"])
    for g in groups:
        if not g["valid_under_emitter_contract"]:
            continue
        rows = fids[g["first_fid"]:g["last_fid"]+1]
        anon = sum(r["role"]=="anonymous_lowered_segment" for r in rows)
        # Only match a separate machine worker with the exact public direct name.
        direct = any(r["role"]=="direct_segment" and r["decoded"] in private for r in rows)
        if direct:
            counts["groups_with_exact_private_direct"] += 1
            counts["groups_with_private_direct_and_continuations"] += int(anon>0)
            counts["anonymous_segments_in_those_groups"] += anon
    return dict(listing=identity["sha256"],publicSlots=len(public),machineDefinitions=len(definitions),
                privateDecodedIdentities=len(private),publicAlsoPrivate=sum(r["decoded"] in private for r in fids),
                matchedPublicRoles=dict(matches),groupQualificationErrors=dict(group_errors),
                groups=len(groups),validGroups=sum(g["valid_under_emitter_contract"] for g in groups),
                publicRoles=dict(Counter(r["role"] for r in fids)),overlap=dict(counts))
if __name__=="__main__":
    print(json.dumps(census(Path(sys.argv[1])),indent=2))
