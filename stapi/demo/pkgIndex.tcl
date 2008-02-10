# Tcl package index file, version 1.1
# This file is generated by the "pkg_mkIndex" command
# and sourced either when an application starts up or
# by a "package unknown" script.  It invokes the
# "package ifneeded" command to set up package-related
# information so that packages will be loaded automatically
# in response to "package require" commands.  When this
# script is sourced, the variable $dir must contain the
# full path name of this file's directory.

package ifneeded demo_ctable 1.0 [list source [file join $dir demo_ctable.tcl]]
package ifneeded disks_client 1.0 [list source [file join $dir disks_client.tcl]]
package ifneeded disks_ctable 1.0 [list source [file join $dir disks_ctable.tcl]]
package ifneeded disks_lib 1.0 [list source [file join $dir disks_lib.tcl]]
package ifneeded fsstat_ctable 1.0 [list source [file join $dir fsstat_ctable.tcl]]
package ifneeded stapi_demo_bsd 1.0 [list source [file join $dir demo_bsd.tcl]]
package ifneeded stapi_demo_disks 1.0 [list source [file join $dir demo_disks.tcl]]
package ifneeded stapi_demo_server 1.0 [list source [file join $dir demo_server.tcl]]
package ifneeded stapi_demo_simple 1.0 [list source [file join $dir demo.tcl]]
package ifneeded stapi_demo_sql 1.0 [list source [file join $dir demo_sql.tcl]]
