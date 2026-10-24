#!/usr/bin/env python3
"""Offline analysis/archive of the single required edited-source native request."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile

ROOT=Path(__file__).resolve().parents[5]


def pin(path):
    path=Path(path);h=hashlib.sha256()
    with path.open('rb') as f:
        for b in iter(lambda:f.read(1048576),b''):h.update(b)
    return dict(file=str(path),bytes=path.stat().st_size,sha256=h.hexdigest())


def load(path):return json.loads(Path(path).read_text())


def verify(row):
    p=pin(row['file'])
    if p['bytes']!=row['bytes'] or p['sha256']!=row['sha256']:raise ValueError('Changed input: '+row['file'])


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    out=a.out.resolve()
    if out.exists() or not out.is_relative_to(ROOT/'implementation/phase132'):raise ValueError('Fresh Phase132 implementation output required')
    files={
      'observation-report.json':ROOT/'selfhost/build/phase132/edited-full-observation01/report.json',
      'samples.jsonl':ROOT/'selfhost/build/phase132/edited-full-observation01/samples.jsonl',
      'native-request-report.json':ROOT/'selfhost/build/phase130/p132-edited-full01/report.json',
      'native-guard.json':ROOT/'selfhost/build/phase132/edited-full01-guard/process.json',
      'minimal-api-report.json':ROOT/'selfhost/build/phase111/p132-edited-api01/report.json',
      'minimal-api-guard.json':ROOT/'selfhost/build/phase132/source-check01-guard/process.json',
      'observe-request.py':Path(__file__).with_name('observe-request.py'),
      'test-observe-request.py':Path(__file__).with_name('test-observe-request.py'),
      'analyze-observation.py':Path(__file__),
      'native-request-method.py':ROOT/'selfhost/tools/performance/phase130/native-request.py',
      'independent-check-method.py':ROOT/'selfhost/tools/performance/phase111/check-api.py',
      'stage0-library.mjs':ROOT/'selfhost/tools/stage0-library.mjs'}
    obs=load(files['observation-report.json']);req=load(files['native-request-report.json']);guard=load(files['native-guard.json']);api=load(files['minimal-api-report.json']);api_guard=load(files['minimal-api-guard.json'])
    for item in (obs['method'],obs['samplesFile'],obs['requestReport'],req['source'],req['image'],req['product']):verify(item)
    if not all(x['complete'] for x in (obs,req,guard,api,api_guard)):raise ValueError('Incomplete evidence')
    if req['source'] not in api['inputs']:raise ValueError('Independent source-check identity mismatch')
    rows=[json.loads(l) for l in files['samples.jsonl'].read_text().splitlines()]
    if len(rows)!=obs['samples']:raise ValueError('Sample count mismatch')
    if any(b['elapsedSeconds']<=a['elapsedSeconds'] for a,b in zip(rows,rows[1:])):raise ValueError('Nonmonotone observations')
    output=[r for r in rows if r['productBytes'] is not None]
    if any(b['productBytes']<a['productBytes'] for a,b in zip(output,output[1:])):raise ValueError('Output size decreased')
    if output[-1]['productBytes']!=req['product']['bytes']:raise ValueError('Final output size mismatch')
    first=next(i for i,r in enumerate(rows) if r['productBytes']);zero=rows[first-1];nonzero=rows[first]
    complete=next(r for r in rows if r['productBytes']==req['product']['bytes'])
    peak=max(rows,key=lambda r:r['processTreeRssBytes']);early=min(rows,key=lambda r:abs(r['elapsedSeconds']-330));late=min(rows,key=lambda r:abs(r['elapsedSeconds']-365))
    summary=dict(kind='phase132-edited-source-memory-output-observation',complete=True,noNewTargetExecution=True,
      source=req['source'],image=req['image'],product=req['product'],observationMethod=obs['method'],
      nativeRequestSeconds=req['nativeSeconds'],nativeCpuSeconds=req['cpuSeconds'],nativeChildPeakRssBytes=req['peakRssKiB']*1024,
      observerWallSeconds=obs['wallSeconds'],outerGuardSeconds=guard['wallSeconds'],outerGuardPeakTreeRssBytes=guard['peakTreeRssBytes'],
      sampledPeakDescendantRssBytes=peak['processTreeRssBytes'],sampledPeakAtSeconds=peak['elapsedSeconds'],
      maxSampleIntervalSeconds=max(b['elapsedSeconds']-a['elapsedSeconds']for a,b in zip(rows,rows[1:])),sampleCount=len(rows),
      lastZeroOutputAtSeconds=zero['elapsedSeconds'],firstNonzeroOutputAtSeconds=nonzero['elapsedSeconds'],firstNonzeroOutputBytes=nonzero['productBytes'],completeOutputObservedAtSeconds=complete['elapsedSeconds'],
      lateGrowth=dict(firstAtSeconds=early['elapsedSeconds'],firstRssBytes=early['processTreeRssBytes'],lastAtSeconds=late['elapsedSeconds'],lastRssBytes=late['processTreeRssBytes'],increaseBytes=late['processTreeRssBytes']-early['processTreeRssBytes']),
      independentMinimalApi=dict(checked=api['checked'],seconds=api['seconds'],outerGuardSeconds=api_guard['wallSeconds'],outerGuardPeakTreeRssBytes=api_guard['peakTreeRssBytes'],apiBytes=api['api']['bytes'],exports=api['command'][4:],scope='Whole-book independent checking and one-helper JS API emission; not equivalent to Phase131 many-export API gate; pure checking unmeasured.'),
      caveats=['Single required changed-source run; observer overhead unmeasured; no old/new speedup claim.','Observer time origin precedes native child startup; not native phase coordinates.','RSS sum can count shared pages repeatedly and retained arena pages; not PSS or peak live heap.','Output file size reflects visible writes/page cache, not fsync or disk completion; initial stdio buffering is possible.','No exclusive parsing/checking/lowering/verification/rendering timing is established.','Final artifact is a full changed-source reference, not yet a self-host-qualified successor.'])
    out.mkdir(parents=True)
    with (out/'evidence.tar.gz').open('xb') as raw:
      with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as gz:
       with tarfile.open(fileobj=gz,mode='w') as tar:
        for name,path in sorted(files.items()):
          data=path.read_bytes();info=tarfile.TarInfo(name);info.size=len(data);info.mtime=0;info.mode=0o644;tar.addfile(info,io.BytesIO(data))
    summary['evidenceArchive']=pin(out/'evidence.tar.gz');summary['archiveMembers']={name:pin(path)for name,path in files.items()}
    (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    matplotlib.rcParams['svg.hashsalt']='phase132-edited-source-observation'
    fig,(ax,bx)=plt.subplots(2,1,figsize=(10,6.5),sharex=True,gridspec_kw={'height_ratios':[2,1]})
    t=[r['elapsedSeconds']for r in rows]
    ax.plot(t,[r['processTreeRssBytes']/1e9 for r in rows],color='#2e6fbb',lw=2,label='Sampled descendant RSS sum')
    ax.set_ylabel('RSS (GB, decimal)');ax.set_ylim(0,3.2);ax.grid(alpha=.2)
    ax.annotate('+1.90 GB before visible output\n330–366 s; phase/liveness unknown',xy=(350,2.1),xytext=(155,2.65),arrowprops=dict(arrowstyle='->',color='#555'),fontsize=10)
    ax.axvspan(zero['elapsedSeconds'],nonzero['elapsedSeconds'],color='#e08c22',alpha=.25,label='First visible output interval')
    ax.legend(loc='upper left',frameon=False,fontsize=9)
    bx.step(t,[0 if r['productBytes']is None else r['productBytes']/1e6 for r in rows],where='post',color='#3a8658',lw=2)
    bx.set_ylabel('Output file (MB)');bx.set_xlabel('Seconds from observer launch (not compiler stage timestamps)');bx.set_ylim(0,120);bx.set_xlim(0,380);bx.grid(alpha=.2)
    fig.suptitle('One full edited-source request: late memory growth, output at the end',fontsize=13)
    fig.text(.5,.008,'Final Phase131 N2 • source 3ebf67c… • 1 s observations • no new speed comparison',ha='center',fontsize=9,color='#555')
    fig.tight_layout(rect=(0,.025,1,.95));fig.savefig(out/'memory-output.svg',metadata={'Date':None});plt.close(fig)
    print(json.dumps({k:summary[k]for k in ['nativeRequestSeconds','sampleCount','lastZeroOutputAtSeconds','firstNonzeroOutputAtSeconds','completeOutputObservedAtSeconds','lateGrowth']},indent=2))


if __name__=='__main__':main()
