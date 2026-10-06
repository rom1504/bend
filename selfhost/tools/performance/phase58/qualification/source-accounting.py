#!/usr/bin/env python3
"""Source-only Phase58 census using the frozen Phase47 counting functions."""
import argparse,importlib.util,json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[5];TOOLS=ROOT/"selfhost/tools/performance";METHOD=TOOLS/"phase47/measure-size.py"
p=argparse.ArgumentParser(description=__doc__);p.add_argument("--attempt",type=Path,required=True);p.add_argument("--out",type=Path,required=True);p.add_argument("--markdown",type=Path);a=p.parse_args()
out=a.out.resolve();allowed=[ROOT/"selfhost/build/phase58",TOOLS/"phase58/evidence"];assert any(out.is_relative_to(x)for x in allowed)and not out.exists()
if a.markdown:assert a.markdown.resolve().is_relative_to(ROOT/"implementation/phase58")and not a.markdown.exists()
spec=importlib.util.spec_from_file_location("phase47_counts",METHOD);old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
old.read(METHOD,"8e59af66ae57c32cb335bacd480404fa1c8e52105b45aab0f4028450cfcf8681");old.read(__file__);old.read(sys.executable)
parent=TOOLS/"phase56/qualification/source-accounting.py";old.read(parent)
prior_file=TOOLS/"phase56/evidence/source-accounting.json";prior=json.loads(old.read(prior_file));assert prior["complete"]and prior["pass"];old.read(parent,prior["producer"]["sha256"])
roles={};support={};attempts={}
for role,attempt_file in [("baseline",ROOT/"selfhost/build/phase56/checked-string01/attempt.json"),("candidate",a.attempt.resolve()/"attempt.json")]:
 row,attempt,_=old.snapshot(attempt_file);attempts[role]=attempt
 frozen={old.record_path(x["frozen"]):x["frozen"]["sha256"]for x in attempt["snapshot"]["sources"]};snapshot=Path(attempt["snapshot"]["root"]);support[role]={}
 for file,sha in frozen.items():
  name=str(file.relative_to(snapshot))
  if name=="src/runtime.mjs"or name.startswith("src/runtime/")or name=="tools/typed-driver.mjs":support[role][name]=old.identity(file,old.read(file,sha))
 row["partitions"]={}
 for name,prefix in [("direct","src/back/js/direct/"),("native","src/back/native/"),("common","src/back/common/"),("front","src/front/"),("check","src/check/"),("core","src/core/")]:
  files=[r for r in row["files"]if r["module"].startswith(prefix)];row["partitions"][name]=dict(modules=len(files),**{k:sum(x[k]for x in files)for k in old.counts(b"")})
 roles[role]=row
b,c=roles["baseline"],roles["candidate"];assert b["totals"]==prior["roles"]["candidate"]["totals"]
assert b["attempt"]["sha256"]==prior["roles"]["candidate"]["attempt"]["sha256"]
live_manifest=ROOT/"selfhost/src/compiler.json";old.read(live_manifest,c["manifest"]["sha256"])
live=[]
for r in c["files"]:
 file=ROOT/"selfhost"/r["module"];live.append(old.identity(file,old.read(file,r["sha256"])))
left={r["module"]:r for r in b["files"]};right={r["module"]:r for r in c["files"]};metrics=old.counts(b"")
changes=[];unchanged=[]
for name in sorted(left.keys()|right.keys()):
 x,y=left.get(name),right.get(name)
 if x and y and x["sha256"]==y["sha256"]:unchanged.append(name);continue
 changes.append(dict(module=name,status="added"if x is None else"removed"if y is None else"changed",before=x,after=y,delta={k:(y[k]if y else 0)-(x[k]if x else 0)for k in metrics}))
runtime_rows=[]
for name in sorted(support["baseline"].keys()|support["candidate"].keys()):
 x=support["baseline"].get(name);y=support["candidate"].get(name);runtime_rows.append(dict(module=name,before=x,after=y,byteEqual=bool(x and y and x["sha256"]==y["sha256"])))
for file,row in old.INPUTS.items():assert old.identity(file,Path(file).read_bytes())==row
result=dict(kind="phase58-frozen-source-accounting",complete=True,**{"pass":True},targetExecuted=False,producer=old.identity(__file__,Path(__file__).read_bytes()),method=old.identity(METHOD,METHOD.read_bytes()),parentMethod=old.identity(parent,parent.read_bytes()),parentEvidence=old.identity(prior_file,prior_file.read_bytes()),roles=roles,delta=old.delta(b["totals"],c["totals"]),changedModules=changes,unchangedModules=unchanged,runtimeAndDriver=runtime_rows,live=dict(manifest=old.INPUTS[str(live_manifest.resolve())],moduleCount=len(live),modulesExact=True,files=live),invariants=dict(nativeModules=len([x for x in right if x.startswith("src/back/native/")]),nativeModulesExact=all(x in unchanged for x in left.keys()|right.keys()if x.startswith("src/back/native/")),runtimeAndDriverExact=all(x["byteEqual"]for x in runtime_rows),manifestModuleListEqual=list(left)==list(right)),inputs=list(old.INPUTS.values()),inputsUnchanged=True,scope="Manifest-listed frozen Bend modules, with current live manifest/modules required byte-identical to selected snapshot. Physical lines include comments/blanks; code excludes blank and #-comment-only lines; def/law/type declarations are line-start syntactic counts. Generated API/runtime images are separate. No compiler, benchmark, profile, archive hash sweep or abstract concept-count claim.")
if a.markdown:
 lines=["# Source complexity accounting","","The current manifest and every listed Bend module match the selected checked snapshot. Counts use the unchanged Phase47 rules; they measure source size, not correctness or speed.","","| Metric | Phase56 String01 | Selected Phase58 | Change |","| --- | ---: | ---: | ---: |"]
 for key in ["physicalLines","codeLines","definitions","laws","types","modules","bytes"]:lines.append(f"| {key} | {b['totals'][key]:,} | {c['totals'][key]:,} | {result['delta'][key]:+,} |")
 lines += ["","Physical lines include comments and blanks. Code lines exclude blank and comment-only lines. Declarations are recognized at line starts. Generated compiler images and runtime support are reported separately in the JSON receipt.","","| Changed module | Status | Physical lines | Code lines | Definitions | Types |","| --- | --- | ---: | ---: | ---: | ---: |"]
 for r in changes:lines.append(f"| `{r['module']}` | {r['status']} | {r['delta']['physicalLines']:+,} | {r['delta']['codeLines']:+,} | {r['delta']['definitions']:+,} | {r['delta']['types']:+,} |")
 lines += ["",f"{len(unchanged)} source modules retain exact bytes. Native modules exact: {result['invariants']['nativeModulesExact']}. Runtime/support/driver inventory exact: {result['invariants']['runtimeAndDriverExact']}.","",f"Receipt: [{out.name}]({out}). It pins both attempts, the inherited counting method, every source input and the final rehash. No historical archive was opened.",""]
 a.markdown.parent.mkdir(parents=True,exist_ok=True)
 with a.markdown.open("x")as f:f.write("\n".join(lines))
 result["markdown"]=old.identity(a.markdown,a.markdown.read_bytes())
out.parent.mkdir(parents=True,exist_ok=True)
with out.open("x")as f:json.dump(result,f,indent=2);f.write("\n")
print(json.dumps(dict(output=old.identity(out,out.read_bytes()),totals=c["totals"],delta=result["delta"],changedModules=len(changes),unchangedModules=len(unchanged),invariants=result["invariants"])))
