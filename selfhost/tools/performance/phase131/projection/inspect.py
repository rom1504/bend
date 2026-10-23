"""Inspect actual emitted reader identity and consumer composition; no target runs."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re

FUNCTION = re.compile(r'^\s*(?:export\s+)?function\s+\w+\s+\$([^ (]+)\(')


def pin(path):
    path=Path(path).resolve(); sha=hashlib.sha256()
    with path.open('rb') as stream:
        for block in iter(lambda:stream.read(1048576),b''):sha.update(block)
    return dict(file=str(path),bytes=path.stat().st_size,sha256=sha.hexdigest())


def decode(name):
    found=re.fullmatch(r'(.*FID_)((?:[0-9]+_)+)',name)
    return found[1]+''.join(chr(int(x)) for x in found[2].split('_') if x) if found else name


def functions(path):
    result={};name=None;lines=[]
    with Path(path).open() as stream:
        for line in stream:
            match=FUNCTION.match(line)
            if match:
                assert name is None;name=match[1];lines=[line]
            elif name:
                lines.append(line)
                if line.strip()=='}':
                    result[decode(name)]=''.join(lines);name=None
    assert name is None
    return result


def info(body):
    if body is None:return None
    return dict(bytes=len(body.encode()),sha256=hashlib.sha256(body.encode()).hexdigest(),
        callSites=dict(Counter(decode(n) for n in re.findall(r'\bcall \$([^ (]+)\(',body))),
        lines=len(body.splitlines()))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['parent-ssa','candidate-ssa','out']:p.add_argument('--'+n,type=Path,required=True)
    p.add_argument('--owner',default='String.cmp');p.add_argument('--consumer',default='String.order')
    a=p.parse_args();assert not a.out.exists()
    old,new=functions(a.parent_ssa),functions(a.candidate_ssa)
    reader='p113d_FID_$p118borrow.read.'+a.owner
    consumer='p113d_FID_$p118borrow.read.'+a.consumer
    fallback='p113d_FID_$p128borrow.owned.'+a.consumer
    consumer_info=info(new.get(consumer))
    report=dict(complete=True,targetsRun=False,inputs=[pin(__file__),pin(a.parent_ssa),pin(a.candidate_ssa)],
        owner=a.owner,consumer=a.consumer,reader=reader,parentReader=info(old.get(reader)),
        candidateReader=info(new.get(reader)),
        exactReaderBytesPreserved=reader in old and reader in new and old[reader]==new[reader],
        consumerReader=consumer_info,owningFallback=info(new.get(fallback)),
        eagerOriginalReaderCall=bool(consumer_info and consumer_info['callSites'].get(reader)),
        scope='Static emitted QBE only: exact original reader body, selected consumer call and owning fallback. Does not prove runtime branch use, semantics, speed or all alias behavior.')
    report['compositionDemonstrated']=bool(report['exactReaderBytesPreserved'] and
        report['eagerOriginalReaderCall'] and report['owningFallback'])
    a.out.write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))


if __name__=='__main__':main()
