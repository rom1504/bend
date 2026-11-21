"""Summarize disjoint first-entry intervals and matching counter deltas."""
import argparse
import json
from pathlib import Path

BOUNDARIES = [
    ("request and Base", "@start", "p86_plan"),
    ("source plan", "p86_plan", "x198pw_plan"),
    ("shared native preparation", "x198pw_plan", "x187_print_mode"),
    ("x86 cursor and forward index", "x187_print_mode", "x181_program_private"),
    ("private bodies", "x181_program_private", "x181_program_public"),
    ("public bodies and tables", "x181_program_public", "x202p_x201f_finish"),
    ("ELF finish to output open", "x202p_x201f_finish", "x202e_open"),
    ("output and teardown", "x202e_open", "@exit"),
]
COUNTERS = {
    "readHashCalls": "entry:p113d:$p118borrow.read.index_hash",
    "readHashLoopVisits": "loop:p113d:$p118borrow.read.index_hash",
    "selectorLookups": "call:p111v_get:x181_register_best",
    "writesViaP111": "entry:p111:$direct.p111v_put",
    "insertEntriesViaP111": "entry:p111:$direct.p131i_insert",
}

def summarize(marks, counts):
    for key in ("source", "expectedObject"):
        if marks[key] != counts[key]:
            raise ValueError("different " + key)
    if not marks["complete"] or not counts["complete"]:
        raise ValueError("incomplete diagnostic")
    def select(report, role):
        run = next(r for r in report["runs"] if r["role"] == role)
        return {e["stage"]: e for e in run["events"]}
    m, c = select(marks,"marks"), select(counts,"counts")
    def interval(label, a, b):
        row = {"interval": label}
        for key in ("wallNs", "cpuNs"):
            row[key] = m[b][key] - m[a][key]
        for key, event in COUNTERS.items():
            row[key] = c[b]["counts"].get(event,0) - c[a]["counts"].get(event,0)
        return row
    rows = [interval(*span) for span in BOUNDARIES]
    total = interval("complete process between hooks", "@start", "@exit")
    assert all(sum(row[k] for row in rows) == total[k] for k in total if k != "interval")
    return {"source":marks["source"], "expectedObject":marks["expectedObject"], "stages":rows,
            "total":total, "withinPreparation":interval("forwarding text","p168j_forwards","p134e_registered"),
            "counterDefinitions":COUNTERS, "countsFinal":c["@exit"]["counts"]}

if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("marks",type=Path)
    p.add_argument("counts",type=Path)
    a = p.parse_args()
    print(json.dumps(summarize(json.loads(a.marks.read_text()), json.loads(a.counts.read_text())),indent=2))
