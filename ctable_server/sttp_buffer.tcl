#
# $Id$
#

#
# sttp_buffer ... create or use a ctable from a ctable server
#

namespace eval ::sttp_buffer:: {

# tables(URL) contains the name of the buffer associated with the URL
variable tables

# auto(URL) contains the name of the autogenerated buffer for the URL
variable auto

# meta(definition) contains the name of the meta-table for a given definition
variable meta

# metatable sequence number for autogenerated tables
variable metasequence 0

# definitions(URL) contains the definition for the URL
variable definitions

# extensions(URL) contains the CTable extension for the URL
variable extensions

#
# Forget everything about a URL
#
proc forget {cttpUrl} {
    variable extensions
    variable definitions
    variable tables

    autodestroy $cttpUrl
    unset -nocomplain tables($cttpUrl)
    unset -nocomplain definitions($cttpUrl)
    unset -nocomplain extensions($cttpUrl)
}

#
# Create a table given the definition
#
proc metacreate {definition} {
    variable meta
    variable metaseqence

    if [info exists meta($definition)] {
	return $meta($definition)
    }

    set name c_meta$metasequence
    set package C_meta$metasequence
    incr metasequence

    CExtension $name 1.0 [list Ctable $name $definition]
    package require $package

    set meta($definition) $name
    return $name
}

#
# recreate a speed table definition from its properties
#
proc getdefinition {cttpUrl {class ""}} {
  set table [uplevel 1 [list namespace which $table]]

  foreach field [remote_ctable_send $cttpUrl fields] {
    array unset props
    array set props [remote_ctable_send $cttpUrl [list field $field proplist]]
    set type $props(type)
    unset props(type)
    set name $props(name)
    unset props(name)
    unset -nocomplain props(needsQuoting)
    lappend definition [linsert [array get props] 0 $type $field]
  }

  if {![info exists definition]} {
    return -code error "No definition for $table"
  }

  if {"$class" == ""} {
    set class [remote_ctable_send $cttpUrl type]
  }
  return "CTable $class {
	[join $definition "\n\t"]
  }"
}

proc autocreate {cttpUrl} {
    variable definitions
    variable extensions
    variable auto

    if {[info exists auto($cttpUrl)]} {
	$auto($cttpUrl) reset
    } else {
        if {![info exists definitions($cttpUrl)]} {
	    set definitions($cttpUrl) [getdefinition $cttpUrl]
        }

        if {![info exists extensions($cttpUrl)]} {
	    set extensions($cttpUrl) [metacreate $definitions($cttpUrl)]
        }

        set auto($cttpUrl) [$extensions($cttpUrl) create #auto]
    }

    return $auto($cttpUrl)
}

#
# Destroy the autocreated ctable for cttpUrl if it exists
#
proc autodestroy {cttpUrl} {
    variable auto

    if [info exists auto($cttpUrl)] {
	$auto($cttpUrl) destroy
	unset auto($cttpUrl)
    }
}

#
# Attach a buffer table, creating it if necessary
#
proc attach {cttpUrl {ctable #auto}} {
    variable tables

    if {"$ctable" == "#auto"} {
	if {[info exists tables($cttpUrl)]} {
	    set ctable $tables($cttpUrl)
	} else {
	    set ctable [autocreate $cttpUrl]
	}
    } else {
        if {[info exists tables($cttpUrl)]} {
	    if {"$tables($cttpUrl)" != "$ctable"} {
	        autodestroy $cttpUrl
	    }
	}
    }

    set tables($cttpUrl) $ctable

    return $ctable
}

#
# Detach a buffer table, destroying it if necessary
#
proc detach {cttpUrl} {
    variable tables

    if {[info exists tables($cttpUrl)]} {
    	unset tables($cttpUrl)
    	autodestroy $cttpUrl
    }
}

#
# Return the buffer table associated with the URL, or NULL
#
proc table {cttpUrl} {
    variable tables

    if {[info exists tables($cttpUrl)]} {
        return $tables($cttpUrl)
    }

    return [attach $cttpUrl #auto]
}

}

package provide sttp_buffer 1.12.0

# vim: set ts=8 sw=4 sts=4 noet :
