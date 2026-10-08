#!/usr/bin/env python3
"""Derive one actual native-entry diagnostic control from the frozen07 role."""
from pathlib import Path
import copy,hashlib,json
ROOT=Path(__file__).resolve().parents[5]
def pin(p):
 p=p.resolve(strict=True);b=p.read_bytes();return {'file':str(p),'sha256':hashlib.sha256(b).hexdigest(),'bytes':len(b)}
def main():
 out=ROOT/'selfhost/build/phase66/native-admission07-recipe';parent=out/'recipe.json';d=json.loads(parent.read_text());assert d['attempt']['sha256']==pin(ROOT/'selfhost/build/phase66/checked-b1-07/attempt.json')['sha256']
 result=out/'focused-recipe.json';assert not result.exists();selection=out/'focused-selection.json';selection.write_text(json.dumps({'cases':[{'id':'phase66/printable-name-collision.bend','lanes':['native']}]},indent=2)+'\n')
 c=copy.deepcopy(d['commands'][0]);cmd=c['command'];cmd[cmd.index('--seconds')+1]='45';cmd[cmd.index('--selection')+1]=str(selection);report=out/'focused-report.json';cmd[cmd.index('--output')+1]=str(report);cmd[next(i for i,x in enumerate(cmd) if x.endswith('/supervisor'))]=str(out/'focused-supervisor');c.update({'name':'native-entry-collision','expectedObservations':1,'selection':pin(selection),'report':str(report),'excludedDeclaredGaps':[]})
 result.write_text(json.dumps({'kind':'phase66-native-entry-diagnostic07','targetExecuted':False,'producer':pin(Path(__file__)),'parent':pin(parent),'attempt':d['attempt'],'commands':[c],'scope':'One fresh checked07 source compile refusal in native lane. It ends before C compilation. Preserve exact native05 diagnostic; no broader native replay or performance claim.'},indent=2)+'\n');print(json.dumps({'recipe':pin(result)}))
if __name__=='__main__':main()
