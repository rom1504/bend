# Control arm: ordinary-worker closure runs identically, but retry only receives
# the old scalar-observer summaries. Existing scalar optimizations remain active.
@unsafe
def p131p_retry(+book: List<&2,KDef>, +retry: List<&2,NO_Plan>, +closed: List<&2,P113DFunction>, +helpers: List<&2,P128BRHelper>) -> P128BRPatches:
  p128br_retry_plans(book,retry,closed,p131p_scalar_helpers(helpers))
