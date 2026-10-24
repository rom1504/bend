# Approximate sampled-thread CPU timeline

Coordinates are approximate sampled-thread CPU seconds from sampling start, never wall timestamps.

Physical leaves and active Bend owners are separate observations. Unknown samples remain in each denominator.

| Window | Samples | Top physical leaves | Top active owners | Unknown leaf / owner |
| --- | ---: | --- | --- | ---: |
| 0.000–30.016 s | 938 | term_drop 20.8%; span_fade 12.6%; p113d_FID_$p118borrow.read.p88_string_eq_go 8.8% | f_find 36.5%; f_eq 3.6%; f_grow_base 2.5% | 26 / 16 |
| 30.016–60.032 s | 938 | span_fade 18.9%; term_drop 18.8%; p113d_FID_$p118borrow.read.p88_string_eq_go 12.4% | f_find 26.5%; lookup 9.7%; constructor_exists 7.1% | 21 / 17 |
| 60.032–90.048 s | 938 | term_drop 23.2%; span_fade 18.9%; p113d_FID_$p118borrow.read.p88_string_eq_go 11.4% | lookup 31.3%; index_remove 26.1%; p88_string_eq 13.5% | 19 / 13 |
| 90.048–120.064 s | 938 | p113d_FID_$p118borrow.read.p88_string_eq_go 32.2%; term_drop 12.7%; span_fade 10.9% | has_name 25.6%; index_remove 13.1%; p88_string_eq 9.2% | 27 / 9 |
| 120.064–150.080 s | 938 | term_drop 19.3%; span_fade 17.8%; p113d_FID_$p118borrow.read.p88_string_eq_go 17.3% | nc_ctor_owned 49.0%; has_name 10.1%; nb_contains 6.7% | 15 / 13 |
| 150.080–180.096 s | 938 | term_drop 16.1%; span_fade 14.4%; p113d_FID_$p118borrow.read.p88_string_eq_go 11.3% | nb_contains 28.4%; nc_occurs 10.1%; nc_ctor_owned 7.8% | 31 / 20 |
| 180.096–210.112 s | 938 | term_drop 14.9%; span_fade 10.2%; p113d_FID_$p118borrow.read.p88_string_eq_go 6.6% | nc_occurs 16.3%; nc_ctor_owned 12.5%; nc_occurs_list 10.7% | 34 / 31 |
| 210.112–240.128 s | 938 | term_drop 20.0%; span_fade 10.4%; p113d_FID_$p118borrow.read.p88_string_eq_go 4.1% | nc_ctor_owned 15.5%; p111v_get 5.8%; nc_uses_term 4.2% | 39 / 25 |
| 240.128–270.144 s | 938 | term_drop 19.6%; span_fade 12.3%; p113d_FID_$p118borrow.read.index_hash 8.3% | p111v_get 18.8%; p113k_get 11.9%; p131i_insert 5.7% | 36 / 20 |
| 270.144–300.160 s | 938 | term_drop 22.4%; span_fade 12.7%; p113d_FID_$p118borrow.read.index_hash 4.9% | nc_ctor_owned 12.7%; p111v_get 11.4%; p111v_name_chars 5.8% | 33 / 22 |
| 300.160–330.176 s | 938 | term_drop 14.9%; p125_rt_take2 9.1%; span_fade 6.5% | String.append 16.0%; String.eq 8.0%; p111v_get 7.9% | 48 / 43 |
| 330.176–360.192 s | 938 | p125_rt_take2 17.5%; term_drop 7.2%; p118_rt_extend1 7.0% | String.append 20.5%; [unknown] 10.3%; p111q_body_text 8.8% | 23 / 97 |
| 360.192–370.208 s | 313 | p125_rt_take2 16.0%; term_drop 14.7%; p118_rt_extend1 6.7% | String.append 16.0%; [unknown] 10.5%; p111q_body_text 8.0% | 8 / 33 |

Active owners are execution contexts, not inclusive stacks. Window boundaries do not establish compiler phases.
