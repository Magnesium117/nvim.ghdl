command Ghdlinit lua require('ghdl.ghdlinit').ghdlinit()
command Ghdlcp lua require('ghdl.ghdlcp').ghdlcp()
command -nargs=* Ghdlrun lua require('ghdl.ghdlrun').ghdlrun(<f-args>)
