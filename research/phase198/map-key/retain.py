"""Archive compact receipts and generated source, excluding compiler binaries and objects."""
import argparse
import json
from pathlib import Path
import shutil
import importlib.util

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
spec=importlib.util.spec_from_file_location('pivot_summary',HERE/'summarize-pivot.py')
summary=importlib.util.module_from_spec(spec)
spec.loader.exec_module(summary)


def copy(source,dest):
    if source.is_file():
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copy2(source,dest)


def main(jobs,output):
    output.mkdir(parents=True,exist_ok=False)
    rows={}
    for job in jobs:
        run=ROOT/'selfhost/build/phase198'/job
        guard=run.with_name(job+'-guard')
        close=ROOT/'selfhost/build-retention/phase198'/(job+'-close')/'report.json'
        retention=summary.read(guard/'retention.json')
        assert retention['closed'] and close.is_file(),job
        dst=output/job
        for name in ('report.json','refusal.json'):
            copy(run/name,dst/name)
        for name in ('process.json','retention.json','stderr.log'):
            copy(guard/name,dst/('guard-'+name))
        copy(close,dst/'close.json')
        if not (run/'report.json').exists():
            rows[job]=dict(complete=False,error='No experiment receipt before host import refusal')
            continue
        rows[job]=summary.summarize(job)
        source_report=summary.read(run/'report.json')['source']
        manifest=summary.read(Path(source_report['file']))
        copy(Path(source_report['file']),dst/'source-manifest.json')
        for check in sorted(run.glob('*/*-source-check/report.json')):
            role=check.parent.name.removesuffix('-source-check')
            case=check.parent.parent.name
            copy(check,dst/case/(role+'-check.json'))
            copy(Path(manifest['cases'][case]['roles'][role]['file']),dst/case/(role+'.bend'))
    (output/'summary.json').write_text(json.dumps(rows,indent=2,ensure_ascii=False)+'\n')


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('output',type=Path);parser.add_argument('jobs',nargs='+')
    args=parser.parse_args();main(args.jobs,args.output.resolve())
