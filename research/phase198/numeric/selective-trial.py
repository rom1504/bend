"""One frozen attempt: independent API+controls, then four actual products."""
import subprocess,sys
api=['python3','-B','research/phase198/numeric/job.py','--rss-mib','3072','numeric-api06','45','96','python3','-B','research/phase198/numeric/selective-check.py','--out','selfhost/build/phase198/numeric-api06']
subprocess.run(api,check=True)
subprocess.run(['python3','-B','research/phase198/numeric/prepare-selective-plan.py'],check=True)
subprocess.run(['python3','-B','research/phase198/numeric/job.py','numeric-products04','85','128','python3','-B','research/phase198/numeric/selective-products.py','--out','selfhost/build/phase198/numeric-products04'],check=True)
