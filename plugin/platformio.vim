command Ghdlinit lua require('ghdl.ghdlinit').ghdlinit()
command Ghdlanal lua require('ghdl.ghdlrun').ghdlanalyze()
command -nargs=* Ghdlelab lua require('ghdl.ghdlrun').ghdlelaborate(<f-args>)
command -nargs=* Ghdlrun lua require('ghdl.ghdlrun').ghdlrun(<f-args>)
