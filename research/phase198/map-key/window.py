"""Compare root-anchored snapshots on complete Map and Unicode aggregation traces."""
from collections import Counter
import json
from pathlib import Path

from trace import Node, ProbeTrace, digest, pop, set_key, word

ROOT = Path(__file__).resolve().parents[3]


class SnapshotCounts:
    def __init__(self):
        self.counts = Counter()

    def record(self, root, key, probes):
        self.counts['operations'] += 1
        self.counts['probes'] += len(probes)
        self.counts['dataProbes'] += sum(p['exists'] and p['off']!=0 for p in probes)
        self.counts['stockCons'] += sum(min(p['ci'] + 1, len(key)) for p in probes)
        plans = [('prefix-byte-7', 0, 7, 255)]
        if isinstance(root, Node):
            anchor = root.position // 33
            plans += [('pivot-byte-7', anchor, 7, 255), ('pivot-u32-1', anchor, 1, 0xffffffff),
                      ('pivot-u32-2', anchor, 2, 0xffffffff)]
        else:
            for name in ('pivot-byte-7', 'pivot-u32-1', 'pivot-u32-2'):
                self.counts[name + '/fallback'] += len(probes)
                self.counts[name + '/cons'] += sum(min(p['ci'] + 1, len(key)) for p in probes)
        for name, start, capacity, limit in plans:
            # Skip to the pivot and pack only characters that satisfy the representation.
            cost = min(start, len(key))
            words = []
            for char in key[start:start+capacity]:
                cost += 1
                if word(char) > limit:
                    break
                words.append(word(char))
            complete = start + len(words) >= len(key)
            for p in probes:
                ci,off = p['ci'],p['off']
                offset = ci - start
                if name=='pivot-u32-2' and 0 <= offset < len(words) and words[offset]>=0xfffffffe:
                    self.counts[name + '/escape'] += 1
                    self.counts[name + '/fallback'] += 1
                    cost += min(ci+1,len(key))
                    continue
                if 0 <= offset < len(words):
                    value = off == 0 or bool((words[offset] >> (32-off)) & 1)
                elif offset >= len(words) and complete and (name != 'pivot-u32-2' or offset < capacity):
                    value = False
                else:
                    self.counts[name + '/fallback'] += 1
                    cost += min(ci + 1, len(key))
                    continue
                assert value == p['bit']
                self.counts[name + '/hits'] += 1
            self.counts[name + '/cons'] += cost


def get(node,key,trace):
    trace.start('get',key)
    while isinstance(node,Node):
        node=node.children[trace.bit(key,node.position)]
    return node[1] if node and node[0]==key else 0


def ordered(node):
    if isinstance(node,Node):
        yield from ordered(node.children[0])
        yield from ordered(node.children[1])
    elif node is not None:
        yield node


def simulate(row):
    name = row['id']
    size,seed = row['point']['runtimeArgs']
    stats = SnapshotCounts()
    root = None
    if 'aggregation' in name:
        for i in range(size):
            key = '部門' + str((i+seed)%16)
            amount = (i*37+seed)%1000
            t = ProbeTrace()
            old = get(root,key,t)
            stats.record(root,key,t.probes)
            t = ProbeTrace()
            old_root = root
            root = set_key(root,key,old+amount,t)
            stats.record(old_root,key,t.probes)
        observed = ''.join(k+'='+str(v)+';' for k,v in ordered(root))
    else:
        for step in (1,3,4):
            for i in range(0,size,step):
                key = 'key'+str(i)
                old = root
                t = ProbeTrace()
                if step == 4: root = pop(root,key,t)
                else: root = set_key(root,key,((seed+17*i)&0xffffffff) if step==1 else seed^(31*i),t)
                stats.record(old,key,t.probes)
        observed = str(digest(root))
    assert observed + '\n' == row['point']['expectedStdout'], name
    return dict(name=name,output=observed,counts=dict(sorted(stats.counts.items())))


if __name__ == '__main__':
    refs=json.loads((ROOT/'selfhost/build/phase195/references01/manifest.json').read_text())['cases']
    result=[simulate(row) for row in refs if 'coverage-map-churn' in row['id'] or 'coverage-record-aggregation' in row['id']]
    measure=json.loads((ROOT/'selfhost/build/phase198/runtime-count01/report.json').read_text())['cases']
    for receipt in result:
        count=next(row for row in measure if row['id']==receipt['name'])
        site=next(key for key,name in count['siteNames'].items() if 'borrow.read.Map.bit.go' in name)
        observed=[count['first'][site],count['second'][site]]
        assert observed==[receipt['counts']['dataProbes']]*2
        receipt['observedDataProbes']=observed
        receipt['counterSite']=site
    print(json.dumps(result,indent=2))
