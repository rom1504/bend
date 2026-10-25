# Approximate sampled-thread CPU timeline

Coordinates are approximate sampled-thread CPU seconds from sampling start, never wall timestamps.

Physical leaves and active Bend owners are separate observations. Unknown samples remain in each denominator.

| Window | Samples | Top physical leaves | Top active owners | Unknown leaf / owner |
| --- | ---: | --- | --- | ---: |
| 0.000–30.016 s | 938 | term_drop 19.6%; p113d_FID_$p118borrow.read.p88_string_eq_go 12.8%; span_fade 8.6% | f_find 27.3%; f_eq 6.8%; f_grow_base 3.6% | 31 / 13 |
| 30.016–60.032 s | 938 | term_drop 17.9%; span_fade 14.8%; p113d_FID_$p118borrow.read.p88_string_eq_go 12.9% | lookup 19.7%; index_remove 13.8%; f_find 9.7% | 30 / 14 |
| 60.032–90.048 s | 938 | term_drop 18.8%; span_fade 17.6%; p113d_FID_$p118borrow.read.p88_string_eq_go 12.9% | index_remove 26.5%; lookup 20.8%; p88_string_eq 17.1% | 27 / 14 |
| 90.048–120.064 s | 938 | p113d_FID_$p118borrow.read.p88_string_eq_go 36.7%; term_drop 9.9%; span_fade 7.8% | has_name 34.9%; constructor_exists 7.8%; lookup 7.6% | 33 / 15 |
| 120.064–150.080 s | 938 | term_drop 18.8%; span_fade 15.0%; p113d_FID_$p118borrow.read.p88_string_eq_go 13.0% | nb_contains 34.3%; nc_ctor_owned 30.0%; lookup 3.0% | 11 / 7 |
| 150.080–180.096 s | 938 | term_drop 12.5%; span_fade 8.4%; p113d_FID_$p118borrow.read.p88_string_eq_go 6.3% | nc_occurs 19.5%; nc_occurs_list 11.8%; nc_uses_term 5.7% | 52 / 35 |
| 180.096–210.112 s | 938 | term_drop 16.0%; span_fade 8.6%; p113d_FID_$p118borrow.read.p88_string_eq_go 6.6% | nc_ctor_owned 16.5%; nc_occurs 8.7%; nc_uses_term 6.1% | 33 / 30 |
| 210.112–240.128 s | 938 | term_drop 17.3%; span_fade 8.8%; p113d_FID_$p118borrow.read.index_hash 8.1% | p111v_get 18.3%; p113k_get 8.6%; p131i_insert 8.3% | 31 / 16 |
| 240.128–270.144 s | 938 | term_drop 18.8%; span_fade 10.9%; p113d_FID_$p118borrow.read.index_hash 5.7% | p111v_get 12.5%; p111v_name_chars 7.4%; p131i_insert 5.8% | 44 / 16 |
| 270.144–300.160 s | 938 | term_drop 17.4%; span_fade 9.3%; p113d_FID_$p118borrow.read.String.cmp 5.3% | p111v_get 9.5%; String.eq 8.7%; String.append 6.7% | 37 / 25 |
| 300.160–330.176 s | 938 | p125_rt_take2 18.2%; p118_rt_extend1 8.4%; term_drop 7.4% | String.append 25.9%; p111q_body_text 8.5%; [unknown] 8.0% | 34 / 75 |
| 330.176–345.120 s | 467 | p125_rt_take2 13.9%; term_drop 10.1%; p118_rt_extend1 7.5% | String.append 21.0%; [unknown] 9.6%; p111q_memory 7.5% | 19 / 45 |

Active owners are execution contexts, not inclusive stacks. Window boundaries do not establish compiler phases.
