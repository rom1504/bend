# Approximate sampled-thread CPU timeline

Coordinates are approximate sampled-thread CPU seconds from sampling start, never wall timestamps.

Physical leaves and active Bend owners are separate observations. Unknown samples remain in each denominator.

| Window | Samples | Top physical leaves | Top active owners | Unknown leaf / owner |
| --- | ---: | --- | --- | ---: |
| 0.000–24.999 s | 1923 | term_drop 26.5%; span_fade 18.6%; p125_rt_take2 6.8% | f_find 36.8%; f_eq 3.8%; f_triple_op 2.8% | 54 / 36 |
| 24.999–49.998 s | 1923 | span_fade 26.9%; term_drop 24.9%; p111_rt_keep 5.6% | f_find 55.0%; f_eq 6.0%; f_pattern_sub 4.0% | 29 / 28 |
| 49.998–74.997 s | 1923 | term_drop 23.2%; span_fade 18.7%; p125_rt_take2 4.8% | p88_string_eq 23.7%; lookup 13.6%; index_remove 11.8% | 77 / 39 |
| 74.997–99.996 s | 1923 | span_fade 23.1%; term_drop 23.0%; p125_rt_take2.cold 6.3% | p88_string_eq 32.1%; index_remove 21.0%; lookup 12.2% | 66 / 39 |
| 99.996–124.995 s | 1923 | term_drop 23.9%; span_fade 22.8%; p125_rt_take2.cold 5.7% | p88_string_eq 22.4%; index_remove 16.0%; dr_own_names 14.9% | 63 / 32 |
| 124.995–149.994 s | 1923 | term_drop 35.0%; span_fade 21.2%; p125_rt_take2 7.6% | has_name 71.4%; constructor_exists 10.9%; dr_own_names 4.0% | 19 / 14 |
| 149.994–174.993 s | 1923 | term_drop 31.3%; span_fade 20.8%; p111_rt_keep 7.9% | has_name 33.1%; kr_filter 33.0%; index_find 2.3% | 35 / 17 |
| 174.993–199.992 s | 1923 | term_drop 29.4%; span_fade 19.3%; p125_rt_take2 6.6% | has_name 33.3%; nc_ctor_owned 26.5%; p88_string_eq 15.9% | 61 / 27 |
| 199.992–224.991 s | 1923 | term_drop 26.4%; span_fade 21.3%; p125_rt_take2 7.4% | nb_contains 43.3%; nc_ctor_owned 26.7%; p88_string_eq 16.2% | 54 / 26 |
| 224.991–249.990 s | 1923 | term_drop 23.6%; span_fade 15.2%; p125_rt_take2 6.2% | nb_contains 16.3%; kr_filter 16.0%; nc_occurs 10.7% | 70 / 31 |
| 249.990–274.989 s | 1923 | term_drop 18.2%; span_fade 12.0%; [unknown] 4.8% | nc_occurs 19.0%; nc_occurs_list 8.1%; String.order 6.7% | 94 / 55 |
| 274.989–299.988 s | 1923 | term_drop 20.0%; span_fade 13.5%; [unknown] 5.4% | nc_ctor_owned 14.5%; nc_occurs 12.9%; p88_string_eq 9.9% | 103 / 42 |
| 299.988–324.987 s | 1923 | term_drop 21.5%; span_fade 11.2%; [unknown] 5.7% | String.order 10.1%; nc_ctor_owned 7.9%; index_find 5.1% | 112 / 52 |
| 324.987–349.986 s | 1923 | term_drop 20.7%; span_fade 13.4%; p125_rt_take2 5.5% | index_bucket 15.8%; p111v_get 10.8%; index_find 10.1% | 92 / 65 |
| 349.986–374.985 s | 1923 | term_drop 21.8%; span_fade 15.0%; p125_rt_take2 5.9% | index_bucket 18.3%; p111v_get 12.7%; index_find 10.6% | 79 / 49 |
| 374.985–399.984 s | 1923 | term_drop 19.1%; span_fade 10.3%; [unknown] 5.8% | String.order 13.7%; index_bucket 11.6%; index_find 7.0% | 115 / 75 |
| 399.984–424.983 s | 1923 | term_drop 18.2%; span_fade 7.6%; p125_rt_take2 6.6% | String.order 23.9%; String.append 11.6%; index_find 6.7% | 100 / 42 |
| 424.983–449.982 s | 1923 | p125_rt_take2 11.9%; term_drop 11.2%; p118_destination_fill 7.3% | String.append 30.0%; String.order 11.8%; index_find 7.4% | 96 / 69 |
| 449.982–470.860 s | 1606 | p125_rt_take2 12.0%; term_drop 10.3%; ctr_take 6.9% | String.append 26.4%; [unknown] 11.4%; String.order 10.8% | 60 / 183 |

Active owners are execution contexts, not inclusive stacks. Window boundaries do not establish compiler phases.
