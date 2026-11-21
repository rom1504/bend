"""Compare fresh source-to-executable builds of one source at a native fixed point."""
import argparse
import json
from pathlib import Path

def compare(reference, successor):
    a, b = (json.loads(p.read_text()) for p in (reference, successor))
    if any(a[k] != b[k] for k in ("sourceSha256", "productRuntimeSha256")):
        raise ValueError("source or linked runtime changed")
    old, new = a["runs"][0], b["runs"][0]
    if any(old[k] != new[k] for k in ("objectSha256","elfSha256","bytes")):
        raise ValueError("generated product changed")
    if new["producerSha256"] != new["elfSha256"]:
        raise ValueError("generated native compiler does not reproduce itself")
    return {"sourceSha256": b["sourceSha256"],"runtimeSha256": b["productRuntimeSha256"],
            "objectSha256":new["objectSha256"],"objectBytes":new["bytes"],"elfSha256":new["elfSha256"],
            "baselineProducer":old["producerSha256"],"baselineSeconds":old["complete"],
            "selfEmitSeconds":new["emit"],"selfLinkSeconds":new["link"],"selfSeconds":new["complete"],
            "ratio":new["complete"]/old["complete"],"remainingFactorTo37s":new["complete"]/37}

if __name__ == "__main__":
    p=argparse.ArgumentParser()
    p.add_argument("reference",type=Path)
    p.add_argument("successor",type=Path)
    args=p.parse_args()
    print(json.dumps(compare(args.reference,args.successor),indent=2))
