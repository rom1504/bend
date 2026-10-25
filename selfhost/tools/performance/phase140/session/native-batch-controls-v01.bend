# Pure controlled job-file and cross-job output admission, no IO execution.
def p140nbc_count(parsed: P140NBJobs) -> U32:
  match parsed:
    case P140NBError{error}: 4294967295
    case P140NBReady{jobs}: nt_count(P140NBJob,jobs)

def p140nbc_outputs(parsed: P140NBJobs) -> Bool:
  match parsed:
    case P140NBError{error}: False{}
    case P140NBReady{+jobs}: p140nb_outputs(jobs,p140nb_inputs(jobs,["/logical","/base","/carrier","/jobs"]),[])

@unsafe
def p140nb_controls() -> List<&2,String>:
  +one = "/a\n/out-a\n0\nowner\ncold"
  [p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one)),1),"batch-one-no-final-LF"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\n")),1),"batch-one-final-LF"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\n/b\n/out-b\n37\nother\nwarm\n")),2),"batch-two-jobs"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("")),4294967295),"batch-empty-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("/a\n/out\n0\nowner")),4294967295),"batch-incomplete-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\n\n")),4294967295),"batch-extra-blank-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("/a\n/out\n00\nowner\nwarm")),4294967295),"batch-noncanonical-hint"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("/a\n/out\n0\nowner\nunknown")),4294967295),"batch-policy-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse("a\n/out\n0\nowner\nwarm")),4294967295),"batch-relative-input-refused"),
   p131u_row(U32.is_eq(p140nbc_count(p140nb_parse(one ++ "\r\n")),4294967295),"batch-CR-refused"),
   p131u_row(p140nbc_outputs(p140nb_parse(one)),"batch-disjoint-output"),
   p131u_row(Bool.not(p140nbc_outputs(p140nb_parse("/a\n/b\n0\none\ncold\n/b\n/out\n0\ntwo\nwarm"))),"batch-output-cannot-clobber-later-input"),
   p131u_row(Bool.not(p140nbc_outputs(p140nb_parse(one ++ "\n/b\n/out-a\n0\nother\nwarm"))),"batch-repeated-output-refused"),
   p131u_row(Bool.not(p140nbc_outputs(p140nb_parse("/a\n/carrier\n0\nowner\nwarm"))),"batch-output-carrier-refused")]
