@unsafe
def p205_repeat_equation() -> P205Equation:
  P205Equation{["Nat", "String", "String"],
    N205{"Mat","Zero",[L205{N205{"Ctr","SNil",[]}},N205{"Mat","Succ",[L205{L205{N205{"App","",[N205{"App","",[R205{"append"},V205{0}]},N205{"App","",[N205{"App","",[R205{"repeat"},V205{1}]},V205{0}]}]}}},N205{"Efq","",[]}]}]}}

@unsafe
def p205_split_equation() -> P205Equation:
  P205Equation{["U32", "String", "Strings"],
    L205{N205{"Mat","SNil",[N205{"Ctr","Con",[N205{"Ctr","SNil",[]},N205{"Ctr","Nil",[]}]},N205{"Mat","SCon",[N205{"Mat","Chr",[L205{L205{B205{V205{1},N205{"App","",[N205{"App","",[N205{"App","",[R205{"pick"},V205{0}]},N205{"App","",[N205{"App","",[R205{"split"},V205{3}]},V205{1}]}]},N205{"App","",[N205{"App","",[N205{"Ref","U32.is_eq",[]},V205{0}]},V205{3}]}]}}}},N205{"Efq","",[]}]},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_pick_equation() -> P205Equation:
  P205Equation{["U32", "Strings", "Bool", "Strings"],
    L205{L205{N205{"Mat","True",[N205{"Ctr","Con",[N205{"Ctr","SNil",[]},V205{0}]},N205{"Mat","False",[N205{"App","",[N205{"App","",[R205{"push"},N205{"Ctr","Chr",[V205{1}]}]},V205{0}]},N205{"Efq","",[]}]}]}}}}

@unsafe
def p205_push_equation() -> P205Equation:
  P205Equation{["Char", "Strings", "Strings"],
    L205{N205{"Mat","Nil",[N205{"Ctr","Con",[N205{"Ctr","SCon",[V205{0},N205{"Ctr","SNil",[]}]},N205{"Ctr","Nil",[]}]},N205{"Mat","Con",[L205{L205{N205{"Ctr","Con",[N205{"Ctr","SCon",[V205{2},V205{1}]},V205{0}]}}},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_join_equation() -> P205Equation:
  P205Equation{["String", "Strings", "String"],
    L205{N205{"Mat","Nil",[N205{"Ctr","SNil",[]},N205{"Mat","Con",[L205{L205{N205{"App","",[N205{"App","",[N205{"App","",[R205{"join_rest"},V205{2}]},V205{0}]},V205{1}]}}},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_join_rest_equation() -> P205Equation:
  P205Equation{["String", "Strings", "String", "String"],
    L205{N205{"Mat","Nil",[L205{V205{0}},N205{"Mat","Con",[L205{L205{L205{N205{"App","",[N205{"App","",[R205{"append"},V205{0}]},N205{"App","",[N205{"App","",[R205{"append"},V205{3}]},N205{"App","",[N205{"App","",[N205{"App","",[R205{"join_rest"},V205{3}]},V205{1}]},V205{2}]}]}]}}}},N205{"Efq","",[]}]}]}}}

@unsafe
def p205_append_equation() -> P205Equation:
  P205Equation{["String", "String", "String"],
    N205{"Mat","SNil",[L205{V205{0}},N205{"Mat","SCon",[L205{L205{L205{N205{"Ctr","SCon",[V205{2},N205{"App","",[N205{"App","",[R205{"append"},V205{1}]},V205{0}]}]}}}},N205{"Efq","",[]}]}]}}
