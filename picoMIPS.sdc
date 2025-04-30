# Define the 50 MHz clock (20 ns period)
create_clock -name clk -period 20.000 [get_ports {clk}]

# Derive PLL clocks (if any)
derive_pll_clocks

# Derive clock uncertainty
derive_clock_uncertainty