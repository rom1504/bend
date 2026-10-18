#!/usr/bin/env python3
"""Freeze previously qualified fixed-contract products; source-only preparation."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[4]
p=argparse.ArgumentParser(description=__doc__)
for name in ['source','out']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.out.resolve()
if out.exists() or not out.is_relative_to(ROOT/'selfhost/build/phase110'):raise ValueError('fresh Phase110 output required')
pin=lambda path:dict(file=str(Path(path).resolve()),bytes=Path(path).stat().st_size,sha256=hashlib.sha256(Path(path).read_bytes()).hexdigest())
def verify(row):
 path=Path(row['file']);path=path if path.is_absolute() else ROOT/path;actual=pin(path)
 if actual['bytes']!=row['bytes'] or actual['sha256']!=row['sha256']:raise ValueError('changed '+str(path))
 return path
read=lambda path:json.loads(Path(path).read_text())
source_file=a.source.resolve()/'manifest.json';m=read(source_file)
if not m['complete']:raise ValueError('complete prepared source required')
inputs=[pin(Path(__file__)),pin(source_file),m['source'],*m['inputs']];rows=[]
for contract,dirname in [('reverse','general-build01'),('tail','general-tail02'),('last','general-last02'),('append','general-append02')]:
 build_file=ROOT/'selfhost/build/phase110'/dirname/'report.json';build=read(build_file);emission_file=build_file.parent/'emit-runtime-ir-single/report.json';emission=read(emission_file)
 if not build['complete'] or not emission['complete'] or emission['variant']!=contract or emission['policy']!='runtime-ir-single':raise ValueError('prior fixed-contract qualification incomplete')
 product=lambda name:next(row for row in emission['outputs'] if Path(row['file']).name==name)
 row=dict(contract=contract,source=m['contracts'][contract],policy='runtime-ir-single',expectedQbe=product('program.ssa'),expectedC=product('program.c'),qualifiedBuild=pin(build_file),emission=pin(emission_file));rows.append(row)
 inputs += [row['source'],row['expectedQbe'],row['expectedC'],row['qualifiedBuild'],row['emission'],*emission['inputs']]
for row in inputs:verify(row)
out.mkdir();report=dict(kind='phase110-native-fixed-expected',complete=True,targetsRun=False,inputs=inputs,rows=rows)
(out/'manifest.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(dict(complete=True,targetsRun=False,contracts=len(rows),manifest=str(out/'manifest.json'))))
