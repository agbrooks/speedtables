#
# some tests that actually check their results
#
# $Id$
#

package require ctable

set ::ctable::genCompilerDebug 0
set ::ctable::showCompilerCommands 0

source searchtest-def.tcl

source dumb-data.tcl

proc search_test {name searchFields expect} {
    puts -nonewline "running $name..."
    set result ""
    set cmd [linsert $searchFields 0 t search -key key -get data -fields "" -code {lappend result $key}]
    #puts $cmd
    eval $cmd

    if {$result != $expect} {
	puts "error in test: $name"
	puts "got '$result', expected '$expect'"
	puts ""
    } else {
	puts "ok"
    }
}

proc search+_test {name searchFields expect} {
    puts -nonewline "running search+ test $name..."
    set result ""
    set cmd [linsert $searchFields 0 t search+ -get data -fields id -code {lappend result $data}]
    #puts $cmd
    eval $cmd

    if {$result != $expect} {
	puts "error in test: $name"
	puts "got '$result', expected '$expect'"
	puts ""
    } else {
	puts "ok"
    }
}


search_test "case-insensitive match" {-compare {{match name *VENTURE*}}} {jonas_jr rusty jonas dean hank}

search_test "case-sensitive match" {-compare {{match_case name *VENTURE*}}} {}

search_test "case-sensitive match 2" {-compare {{match_case name *Tri*}}} {triana}

search_test "numeric expression, age < 10" {-compare {{< age 10}}} {carr thundercleese ur inignot frylock shake meatwad}

search_test "sort ascending by age, age < 10" {-sort age -compare {{< age 10}}} {ur inignot carr meatwad frylock shake thundercleese}

search_test "sort descending by age, age < 10" {-sort -age -compare {{< age 10}}} {thundercleese frylock shake meatwad inignot carr ur}

search_test "unanchored match" {-sort name -compare {{match name *Doctor*}}} {doctor_girlfriend jonas jonas_jr orpheus}

search_test "anchored match" {-sort name -compare {{match name Doctor*}}} {doctor_girlfriend jonas jonas_jr orpheus}


search_test "sorted search with limit" {-sort name -limit 10} {angel baron brak brock carr carl clarence rick dad dean}

search_test "sorted search with offset 0 and limit 10" {-sort name -offset 0 -limit 10} {angel baron brak brock carr carl clarence rick dad dean}

search_test "sorted search with offset 5 and limit 5" {-sort name -offset 5 -limit 5} {carl clarence rick dad dean}

search_test "unsorted search with offset 5 and limit 10" {-offset 5 -limit 10} {clarence thundercleese mom zorak brak dad ur inignot carl frylock}

search_test "unsorted search with offset 5 and limit 5" {-offset 5 -limit 5} {clarence thundercleese mom zorak brak}

search_test "search where alive is false" {-compare {{false alive}}} {jonas}

t index create name
search+_test "indexed search 1" {} {angel baron brak brock carr carl clarence rick dad dean doctor_girlfriend jonas jonas_jr orpheus frylock hank hoop inignot stroker shake meatwad mom 21 28 phantom_limb rusty the_monarch thundercleese triana ur zorak}

search+_test "indexed search with offset and limit" {-offset 5 -limit 5} {carl clarence rick dad dean}

t index drop name
t index create show

search+_test "indexed search 2" {} {meatwad shake frylock carl inignot ur stroker hoop angel carr rick dad brak zorak mom thundercleese clarence brock hank dean jonas orpheus triana rusty jonas_jr doctor_girlfriend the_monarch 21 28 phantom_limb baron}

search+_test "indexed range" {-compare {{range show A M}}} {meatwad shake frylock carl inignot ur}

search+_test "sorted search+ with offset 0 and limit 10" {-sort name -offset 0 -limit 10} {angel baron brak brock carr carl clarence rick dad dean}

puts -nonewline "testing 'fields'..."
if {[t fields] != {id name home show dad alive gender age coolness}} {
    error "t fields expected to return {t fields id name home show dad alive gender age coolness}"
}
puts "ok"

puts -nonewline "testing 'field'..."
if {[catch {t field} result] == 1} {
    if {$result == "wrong # args: should be \"t field fieldName opt ?arg?\""} {
    } else {
        puts $result
    }
} else {
    error "should have gotten an error"
}

if {[catch {t field asdf} result] == 1} {
    if {$result == "wrong # args: should be \"t field fieldName opt ?arg?\""} {
    } else {
        puts $result
    }
} else {
    error "should have gotten an error"
}

if {[catch {t field alive} result] == 1} {
    if {$result == "wrong # args: should be \"t field fieldName opt ?arg?\""} {
    } else {
        puts $result
    }
} else {
    error "should have gotten an error"
}

if {[catch {t field alive asdf} result] == 1} {
    if {$result == "bad suboption \"asdf\": must be getprop, properties, or proplist"} {
    } else {
        puts $result
    }
} else {
    error "should have gotten an error"
}

if {[catch {t field alive proplist} result] == 1} {
    error "didn't expect an error"
} else {
    if {$result != "default 1 name alive type boolean"} {
       error "didn't get intended result"
    }
}

if {[catch {t field alive properties} result] == 1} {
    error "didn't expect an error"
} else {
    if {$result != "default name type"} {
       error "didn't get intended result"
    }
}

if {[catch {t field alive getprop} result] == 1} {
    if {$result == "wrong # args: should be \"t field alive fieldName propName\""} {
    } else {
        puts $result
    }
} else {
    error "should have gotten an error"
}

if {[catch {t field alive getprop type} result] == 1} {
    error "didn't expect an error"
} else {
    if {$result != "boolean"} {
       error "didn't get intended result"
    }
}

if {[catch {t field alive getprop default} result] == 1} {
    error "didn't expect an error"
} else {
    if {$result != "1"} {
       error "didn't get intended result"
    }
}
puts "ok"

puts -nonewline "testing 'index unique'..."
if {[t index unique name] != 1} {
    error "'t index unique name' should have been 1"
}

if {[t index unique show] != 0} {
    error "'t index unique show' should have been 0"
}
puts "ok"

