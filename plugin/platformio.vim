command Ghdlinit lua require('ghdl.ghdlinit').ghdlinit()
command Ghdlupdate lua require('ghdl.ghdlinit').ghdlupdate()
command Ghdlreorder lua require('ghdl.ghdlinit').ghdlreorder()
command Ghdlanal lua require('ghdl.ghdlrun').ghdlanalyze()
command -nargs=* Ghdlelab lua require('ghdl.ghdlrun').ghdlelaborate(<f-args>)
command -nargs=* Ghdlrun lua require('ghdl.ghdlrun').ghdlrun(<f-args>)
command -nargs=* GhdlrunAll lua require('ghdl.ghdlrun').ghdlrunall(<f-args>)
