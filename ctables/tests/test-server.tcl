#
# demo server
#
# $Id$
#

source searchtest-def.tcl

source dumb-data.tcl

package require ctable_server

::ctable_server::register ctable://*/dumbData t

puts "running, waiting for connections"

if !$tcl_interactive { vwait die }

