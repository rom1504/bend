"""Inventory calls and immediate result forwarding in qualification's 45 existing direct executables."""
import json
from pathlib import Path
from census import ROOT, BUILD, audit, sha

run=BUILD/'phase198/native45-01'
rows=[]
for receipt in sorted(run.glob('*/machine/report.json')):
    data=json.loads(receipt.read_text())
    assert data['complete']
    path=Path(data['binary']['file'])
    assert data['binary']['sha256'] == sha(path)
    _,sites=audit(path)
    rows.append(dict(case=receipt.parents[1].name,binary=data['binary']['sha256'],object=data['object']['sha256'],sites=sites))
assert len(rows)==45
print(json.dumps(rows,indent=2))
