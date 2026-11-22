"""Verify and time serial, fresh-process runs, retaining failures and censored cells."""
import argparse
import json
import os
from pathlib import Path
import subprocess
import threading
import time
from statistics import median
from build import BUN, FLAGS, REV, ROLES, SPEC, replace_once, sha

LIMIT_SECONDS = {'small':20,'medium':45,'upstream':60}
RSS_KIB = 1536*1024

def expected_result(checkout, out, family, size):
    spec=SPEC[family]
    if size=='upstream':
        return spec['expected'][size], 'published upstream full-size checksum'
    path=checkout/'bench/runtime'/family/'main.ts'
    if sha(path)!=spec['oracleSha256']:
        raise ValueError('upstream TypeScript oracle changed')
    text=path.read_text()
    knobs=spec[size]
    if family=='histogram':
        for name,old,new in zip(spec['cKnobs'],spec['upstream'],knobs):
            text=replace_once(text,rf'(^const {name} = ){old};',rf'\g<1>{new};')
    elif family=='gameoflife':
        text=replace_once(text,r'console.log\(census_fin\(batch_run\(18, 0, 32\)\)\);',
                          f'console.log(census_fin(batch_run({knobs[0]}, 0, {knobs[1]})));')
    else:
        text=replace_once(text,r'const SY = 17,',f'const SY = {knobs[0]},')
    oracle=out/f'{family}-{size}-oracle.ts'
    oracle.write_text(text)
    answer=int(subprocess.check_output([BUN,oracle],timeout=90,text=True).strip())
    if size=='small' and answer!=spec['expected']['small']:
        raise ValueError(f'{family}: independent TS oracle disagrees with published small checksum')
    return answer,'upstream TypeScript twin '+sha(oracle)

def sample(argv,timeout,want):
    started=time.monotonic_ns()
    process=subprocess.Popen(argv,stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    done=threading.Event()
    stopped=[]
    def watch():
        while not done.wait(0.08):
            try:
                for line in Path(f'/proc/{process.pid}/status').read_text().splitlines():
                    if line.startswith('VmRSS:') and int(line.split()[1])>RSS_KIB:
                        stopped.append('memory-limit')
                        process.kill()
                        return
            except FileNotFoundError:
                return
    monitor=threading.Thread(target=watch,daemon=True)
    monitor.start()
    try:
        try:
            stdout,stderr=process.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            stopped.append('timeout')
            process.kill()
            stdout,stderr=process.communicate()
        elapsed=(time.monotonic_ns()-started)/1e9
    finally:
        done.set()
        monitor.join()
    correct=(stdout==f'{want}\n'.encode())
    status=(stopped[0] if stopped else 'exit-error' if process.returncode else
            'wrong-output' if not correct else 'unexpected-stderr' if stderr else 'ok')
    return dict(status=status,seconds=elapsed,returncode=process.returncode,
                stdout=stdout.decode(errors='replace')[:500],stderr=stderr.decode(errors='replace')[-1000:])

def measure(build,out,checkout,sizes,families):
    if 'BENDRTS' in os.environ or len(os.sched_getaffinity(0))!=1:
        raise ValueError('run pinned to one CPU, without BENDRTS')
    manifest=json.loads((build/'build.json').read_text())
    if manifest['upstream']!=REV:
        raise ValueError('different reference revision')
    out.mkdir(exist_ok=True,parents=True)
    results=dict(upstream=REV,cpu=list(os.sched_getaffinity(0)),timeoutSeconds=LIMIT_SECONDS,
                 memoryLimitKiB=RSS_KIB,cFlags=FLAGS,points={})
    def save():
        (out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    for size in sizes:
        for family in families:
            answer,oracle=expected_result(checkout,out,family,size)
            rows={}
            results['points'][f'{family}/{size}']=dict(expected=answer,oracle=oracle,roles=rows)
            commands={}
            for role in ROLES:
                item=manifest['products'][f'{family}/{size}/{role}']
                if item['status']!='built':
                    rows[role]=dict(status=item['status'],error=item['error'])
                    continue
                cmd=item['argv']
                if sha(Path(cmd[0]))!=item['sha256']:
                    raise ValueError(f'changed executable: {role}')
                rows[role]=dict(status='pending',samples=[],sha256=item['sha256'])
                commands[role]=cmd
            # Rotate the starting role. Medium is the primary repeated comparison.
            for r in range(5 if size=='medium' else 1):
                order=ROLES[r:]+ROLES[:r]
                for role in order:
                    row=rows[role]
                    if row['status'] not in ('ok','pending'):
                        continue
                    trial=sample(commands[role],LIMIT_SECONDS[size],answer)
                    row['samples'].append(trial)
                    row['status']=trial['status']
                    if row['status']=='ok':
                        row['seconds']=median(s['seconds'] for s in row['samples'])
                    else:
                        row.pop('seconds',None)
                    save()
                    print(f'{family}/{size}/{role} {r+1} {trial["status"]} {trial["seconds"]:.4f}',flush=True)
    return results

def finish_full(build, out, previous, timeout):
    """Resume after a guard interruption or extend full-size censored cells."""
    if 'BENDRTS' in os.environ or len(os.sched_getaffinity(0))!=1:
        raise ValueError('run pinned to one CPU, without BENDRTS')
    data=json.loads(previous.read_text())
    manifest=json.loads((build/'build.json').read_text())
    if data['upstream']!=REV or manifest['upstream']!=REV or data['cpu']!=list(os.sched_getaffinity(0)):
        raise ValueError('incompatible baseline')
    out.mkdir(exist_ok=True,parents=True)
    data['fullExtensionSeconds']=timeout
    data.setdefault('previousSha256',[]).append(sha(previous))
    pending=[]
    primary_families=[f for f in SPEC if f+'/medium' in data['points']]
    if not primary_families:
        raise ValueError('no completed medium campaign to continue')
    for family in primary_families:
        for size in ('small','medium'):
            point=data['points'][f'{family}/{size}']
            for role in ROLES:
                row=point['roles'][role]
                product=manifest['products'][f'{family}/{size}/{role}']
                if row['status']=='pending' or row.get('sha256')!=product.get('sha256'):
                    raise ValueError('missing or incompatible primary evidence')
                if row['status']=='ok' and len(row['samples'])!=(5 if size=='medium' else 1):
                    raise ValueError('primary observations incomplete')
        spec=SPEC[family]
        point=data['points'].setdefault(family+'/upstream',dict(expected=spec['expected']['upstream'],
                  oracle='published upstream full-size checksum',roles={}))
        if point['expected']!=spec['expected']['upstream']:
            raise ValueError('full oracle changed')
        # Finish shorter pending cells first. The medium time only determines
        # run order; it is never reported as an observed full-size time.
        multiplier=2**(spec['upstream'][0]-spec['medium'][0])
        if family=='histogram':
            multiplier*=spec['upstream'][2]/spec['medium'][2]
        for role in ROLES:
            item=manifest['products'][family+'/upstream/'+role]
            if item['status']!='built':
                point['roles'][role]=dict(status=item['status'],error=item['error'])
                continue
            row=point['roles'].setdefault(role,dict(status='pending',samples=[],sha256=item['sha256']))
            if row['sha256']!=item['sha256'] or sha(Path(item['argv'][0]))!=row['sha256']:
                raise ValueError('cannot continue with a different executable')
            if row['status']=='pending' or (row['status']=='timeout' and timeout>row.get('deadlineSeconds',data['timeoutSeconds']['upstream'])):
                pilot=data['points'][family+'/medium']['roles'][role].get('seconds',timeout)
                pending.append((pilot*multiplier, family, role))
    target=out/'results.json'
    target.write_text(json.dumps(data,indent=2)+'\n')
    for _,family,role in sorted(pending):
        point=data['points'][family+'/upstream']
        row=point['roles'][role]
        trial=sample(manifest['products'][family+'/upstream/'+role]['argv'],timeout,point['expected'])
        row['samples'].append(trial)
        row['status']=trial['status']
        row['deadlineSeconds']=timeout
        if trial['status']=='ok':
            row['seconds']=trial['seconds']
        target.write_text(json.dumps(data,indent=2)+'\n')
        print(f'{family}/upstream/{role} {trial["status"]} {trial["seconds"]:.4f}',flush=True)

if __name__=='__main__':
    p=argparse.ArgumentParser()
    p.add_argument('out',type=Path)
    p.add_argument('build',type=Path)
    p.add_argument('checkout',type=Path)
    p.add_argument('--sizes',nargs='+',choices=LIMIT_SECONDS,default=list(LIMIT_SECONDS))
    p.add_argument('--extend-from',type=Path,help='resume pending full-size cells and retry shorter full-size timeouts')
    p.add_argument('--full-seconds',type=int,default=300)
    p.add_argument('--families',nargs='+',choices=SPEC,default=list(SPEC))
    a=p.parse_args()
    if a.extend_from:
        finish_full(a.build.resolve(),a.out.resolve(),a.extend_from.resolve(),a.full_seconds)
    else:
        measure(a.build.resolve(),a.out.resolve(),a.checkout.resolve(),a.sizes,a.families)
