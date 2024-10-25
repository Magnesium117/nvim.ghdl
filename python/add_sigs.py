################################################################################
## PyVCD2GTKW.py                                                              ##
## Creates save files for GTKWave from simulation VCD files.                  ##
################################################################################
## This program is free software: you can redistribute it and/or modify it    ##
## under the terms of the GNU General Public License as published by the Free ##
## Software Foundation, either version 3 of the License, or (at your option)  ##
## any later version.                                                         ##
##                                                                            ##
##  This program is distributed in the hope that it will be useful,           ##
##  but WITHOUT ANY WARRANTY; without even the implied warranty of            ##
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             ##
##  GNU General Public License for more details.                              ##
##                                                                            ##
##  You should have received a copy of the GNU General Public License         ##
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.     ##
################################################################################

import sys

if len(sys.argv) < 2 or len(sys.argv) > 3:
    print("usage: PyVCD2GTKW.py vcd_file [level] [> gtkw_file]")
    print("  vcd_file = VCD file to read")
    print("  level = hierarchy levels to descend (0 = all, default)")
    print("  gtkw_file = GTKW file to write")
    print("example:")
    print(" python PyVCD2GTKW.py mysim.vcd 3 > mysim.gtkw")
    sys.exit(1)
file_name = sys.argv[1]
level = 0
if len(sys.argv) == 3:
    level = int(sys.argv[2])
print("processing: " + file_name)
hier = []  # current hierarchy level
scope = ""  # current scope name
signals = []  # signals gathered for current scope
color = 1
with open(file_name, "r") as f:
    while True:
        l = f.readline()  # get next line of text from file
        if "$" in l:  # if it contains a command...
            ll = l.split()  # split it into tokens
            cmd = ll[0][1:]  # strip $ from command token
            if cmd == "enddefinitions":  # marks end of defs section of VCD
                break
            if "scope" in cmd and signals:  # change of scope => dump signals
                # print("-" + "/".join(hier))  # comment: current hierarchy level
                color = (color % 7) + 1  # cycle colour
                for s in signals:
                    # print("[color] " + "00FF00" + "\n" + s)
                    print(s)
                signals = []  # reset signal list
            if cmd == "scope":
                scope = ll[2]  # new scope name
                hier.append(scope)  # update hierarchy level
            elif cmd == "upscope":
                hier.pop()
                scope = hier[-1] if hier else ""
            elif cmd == "var":
                if level == 0 or len(hier) <= level:
                    signals.append(".".join(hier) + "." + ll[4] if hier else ll[4])
