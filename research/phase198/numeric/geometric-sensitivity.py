"""Mechanical sensitivity of a 44-case score; no broad execution or prediction."""
from pathlib import Path
import json,math,hashlib
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
def pin(p):
 return dict(file=str(p),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
focused=HERE/'stable-orbit-results.json'
broad=ROOT/'research/phase198/runtime-broad/summary.json'
f=json.loads(focused.read_text());b=json.loads(broad.read_text())
n=b['subsets']['all']['ratioEligibleCount'];assert n==44
assert all(next(x for x in b['cases'] if x['id']==name)['ratioEligible'] for name in ['scalar-region-8192','mandelbrot'])
r={'kind':'phase198-geometric-score-sensitivity','programsExecuted':False,'actualBroadResult':False,'method':pin(Path(__file__)),'focused':pin(focused),'caseUniverse':pin(broad),'eligibleCases':n,'formula':'G=exp(sum(log(case_ratio))/44). All unmeasured case ratios set to1 only for this arithmetic sensitivity, not as an empirical claim.','caveat':'Focused ratios are median paired ratios against frozen native45-02 or same-session escape products. They do not measure later portfolio N1, the live runtime, cross-pass interaction, or other42cases. Actual broad gains and shares require the full portfolio run.','scenarios':{}}
for name,field in [('versusFrozenIncumbent','incumbent'),('versusEscapeOnly','escape')]:
 rows=f['cases'];rs=rows['scalar-region-8192']['ratios']['numeric']['median'] if field=='incumbent' else rows['scalar-region-8192']['numericOverEscapeMedian'];rm=rows['mandelbrot']['ratios']['numeric']['median'] if field=='incumbent' else rows['mandelbrot']['numericOverEscapeMedian']
 gs=math.exp(math.log(rs)/n);gm=math.exp(math.log(rm)/n);both=gs*gm
 r['scenarios'][name]=dict(scalarRatio=rs,mandelbrotRatio=rm,scalarAloneScoreFactor=gs,scalarAlonePercentReduction=100*(1-gs),mandelbrotAloneScoreFactor=gm,twoMeasuredCasesOnlyScoreFactor=both,twoMeasuredCasesOnlyPercentReduction=100*(1-both),scalarShareOfTwoCaseLogGain=math.log(rs)/(math.log(rs)+math.log(rm)),meaning='A share above1 means Mandelbrot offsets part of the scalar gain; no measured broad gain is being attributed.')
(HERE/'geometric-sensitivity.json').write_text(json.dumps(r,indent=2)+'\n')
print(json.dumps(r['scenarios'],indent=2))
