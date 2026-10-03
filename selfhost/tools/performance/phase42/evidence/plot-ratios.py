#!/usr/bin/env python3
"""Standalone SVG per-point family comparison from maintained runtime report."""
import argparse,hashlib,html,json,math
from pathlib import Path

def esc(x):return html.escape(str(x),quote=True)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('report',type=Path);p.add_argument('--catalog',type=Path);p.add_argument('--out',type=Path,required=True);p.add_argument('--before-role',default='baseline');p.add_argument('--after-role',default='candidate');p.add_argument('--reference-role',default='typescript');p.add_argument('--min-ratio',type=float,default=.1);p.add_argument('--max-ratio',type=float,default=64);p.add_argument('--allow-partial',action='store_true');a=p.parse_args();assert not a.out.exists();assert 0<a.min_ratio<1<a.max_ratio
 raw=a.report.read_bytes();input_hash=hashlib.sha256(raw).hexdigest();data=json.loads(raw);families={}
 if a.catalog:
  catalog=json.loads(a.catalog.read_text());families={r['id']:r.get('family',r['id']) for r in catalog['cases']}
 rows=[];omitted=[]
 for r in data['cases']:
  summary=r.get('summary',{});stats=summary.get('stats',{})
  if not summary.get('complete') or any(role not in stats for role in [a.before_role,a.after_role,a.reference_role]):omitted.append(r['id']);continue
  ref=stats[a.reference_role]['medianMs'];before=stats[a.before_role]['medianMs']/ref;after=stats[a.after_role]['medianMs']/ref
  assert all(math.isfinite(x) and x>0 for x in [ref,before,after]);rows.append(dict(id=r['id'],family=families.get(r['id'],r.get('family','Unspecified family')),before=before,after=after))
 assert rows,'No complete paired rows';assert not omitted or a.allow_partial,'Incomplete rows; use --allow-partial for an explicitly labeled partial chart'
 rows.sort(key=lambda r:(r['family'],r['id']));groups=[];last=None;y=123
 for row in rows:
  if row['family']!=last:groups.append((y,row['family']));y+=25;last=row['family']
  row['y']=y;y+=29
 height=y+100;width=1180;left=390;right=925;span=right-left;lo=math.log(a.min_ratio);hi=math.log(a.max_ratio)
 def x(value):return left+(math.log(min(a.max_ratio,max(a.min_ratio,value)))-lo)/(hi-lo)*span
 parts=[f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">', '<rect width="100%" height="100%" fill="white"/>','<style>text{font-family:Arial,sans-serif;fill:#172033}.small{font-size:12px}.label{font-size:13px}.family{font-size:14px;font-weight:bold}</style>', '<text x="20" y="28" font-size="21" font-weight="bold">Generated runtime relative to TypeScript</text>', '<text x="20" y="50" class="label">Every measured point shown by family; lower is faster. Logarithmic scale; no family average.</text>',f'<circle cx="28" cy="75" r="5" fill="#2563eb"/><text x="40" y="80" class="label">Before ({esc(a.before_role)})</text>',f'<circle cx="230" cy="75" r="5" fill="#ea580c"/><text x="242" y="80" class="label">After ({esc(a.after_role)})</text>']
 ticks=[.1,.25,.5,1,2,4,8,16,32,64,128,256,512,1024]
 for tick in ticks:
  if a.min_ratio<=tick<=a.max_ratio:
   xx=x(tick);parts.append(f'<line x1="{xx:.2f}" y1="100" x2="{xx:.2f}" y2="{y}" stroke="{"#64748b" if tick==1 else "#e2e8f0"}" stroke-dasharray="{"4 3" if tick==1 else "0"}"/><text x="{xx:.2f}" y="115" text-anchor="middle" class="small">{tick:g}×</text>')
 for gy,family in groups:parts.append(f'<text x="20" y="{gy}" class="family">{esc(family)}</text>')
 clipped=0
 for row in rows:
  yy=row['y'];parts.append(f'<text x="28" y="{yy+4}" class="label">{esc(row["id"])}</text><line x1="{x(row["before"]):.2f}" y1="{yy}" x2="{x(row["after"]):.2f}" y2="{yy}" stroke="#94a3b8" stroke-width="2"/>')
  for field,color,offset in [('before','#2563eb',-3),('after','#ea580c',3)]:
   value=row[field];xx=x(value);yyy=yy+offset
   if value>a.max_ratio or value<a.min_ratio:
    clipped+=1;direction=1 if value>a.max_ratio else -1;parts.append(f'<path d="M {xx-5*direction:.2f} {yyy-5} L {xx+5*direction:.2f} {yyy} L {xx-5*direction:.2f} {yyy+5} Z" fill="{color}"><title>{esc(field)}: {value:.6g}×; clipped</title></path>')
   else:parts.append(f'<circle cx="{xx:.2f}" cy="{yyy}" r="4.5" fill="{color}"><title>{esc(field)}: {value:.6g}×</title></circle>')
  parts.append(f'<text x="950" y="{yy+4}" class="label">{row["before"]:.3g}× → {row["after"]:.3g}×</text>')
 parts+=[f'<text x="20" y="{y+25}" class="small">Display bounds {a.min_ratio:g}×–{a.max_ratio:g}×. {clipped} values clipped with triangles; exact ratios remain printed at right.</text>',f'<text x="20" y="{y+44}" class="small">{len(rows)} complete points; {len(omitted)} omitted incomplete points. Ratios use report medians; ranges and drift remain in source JSON.</text>',f'<text x="20" y="{y+63}" class="small">Input SHA256: {input_hash}</text>','</svg>']
 assert hashlib.sha256(a.report.read_bytes()).hexdigest()==input_hash,'Runtime report changed during plotting'
 a.out.parent.mkdir(parents=True,exist_ok=True);a.out.write_text('\n'.join(parts)+'\n');receipt=a.out.with_suffix(a.out.suffix+'.json');assert not receipt.exists();receipt.write_text(json.dumps(dict(kind='phase42-runtime-ratio-plot',complete=True,input=str(a.report.resolve()),inputSha256=input_hash,catalog=str(a.catalog.resolve()) if a.catalog else None,catalogSha256=hashlib.sha256(a.catalog.read_bytes()).hexdigest() if a.catalog else None,producer=dict(file=str(Path(__file__).resolve()),sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest()),output=dict(file=str(a.out.resolve()),sha256=hashlib.sha256(a.out.read_bytes()).hexdigest()),roles=dict(before=a.before_role,after=a.after_role,reference=a.reference_role),minRatio=a.min_ratio,maxRatio=a.max_ratio,clippedValues=clipped,omitted=omitted,points=rows,scope='Per-point median ratios on log scale. No family aggregate, confidence interval or parity generalization.'),indent=2)+'\n');print(json.dumps(dict(points=len(rows),clipped=clipped,omitted=len(omitted),out=str(a.out))))

if __name__=='__main__':main()
