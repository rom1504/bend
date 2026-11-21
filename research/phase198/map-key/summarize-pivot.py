"""Retain source gates, paired raw observations and independent semantic oracles."""
import argparse
from hashlib import sha256
import json
from pathlib import Path

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]


def read(p):
    return json.loads(p.read_text())


def pin(p):
    return {'file':str(p.relative_to(ROOT)),'sha256':sha256(p.read_bytes()).hexdigest(),'bytes':p.stat().st_size}


def summarize(run):
    directory=ROOT/'selfhost/build/phase198'/run
    guard=directory.with_name(run+'-guard')
    report=read(directory/'report.json')
    result={'complete':report['complete'],'pins':{},'cases':{}}
    for name,p in [('report',directory/'report.json'),('guard',guard/'process.json'),('retention',guard/'retention.json'),
            ('close',ROOT/'selfhost/build-retention/phase198'/(run+'-close')/'report.json')]:
        if p.exists():result['pins'][name]=pin(p)
    if (directory/'refusal.json').exists():
        refusal=read(directory/'refusal.json')
        if 'detail' in refusal:refusal['detail']=refusal['detail'].get('error',refusal['detail'])
        result['refusal']=refusal
    for name,case in report['cases'].items():
        row={'products':{},'checks':[],'sessions':case['cells'],'timings':[]}
        for role,product in case['products'].items():
            item={'executable':product['binary']['sha256'],'object':product['object']['sha256']}
            if 'source' in product:
                check=read(Path(product['sourceCheck']['file']))
                item.update(source=product['source']['sha256'],checker=product['sourceCheck']['sha256'],
                            typeAccepted=check['typeAccepted'],holes=check['unresolvedHoles'])
            row['products'][role]=item
        for check in case['checks']:
            row['checks'].append({'inputs':check['inputs'],'expected':check['expected'],
                'roles':list(check['roles']),'matureC':'matureC' in check})
        for sample in case['samples']:
            ob=sample['observations'];row['timings'].append(dict(session=sample['session'],round=sample['round'],
                repetitions=sample['repetitions'],milliseconds={k:v['elapsedMs'] for k,v in ob.items()}))
        result['cases'][name]=row
    return result


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('jobs',nargs='+');args=p.parse_args()
    print(json.dumps({name:summarize(name) for name in args.jobs},indent=2,ensure_ascii=False))
