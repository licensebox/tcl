lappend auto_path [file dirname [file dirname [info script]]]
package require licensebox
set r [json::json2dict [read stdin]]
proc clock_hook {} {dict get $::r now}
proc binding_hook {} {dict get $::r binding}
proc sign_hook {u c} {}
proc run {} {
 set r $::r;set op [dict get $r op];set product [dict get $r product]
 if {$op eq "derive"} {return [::licensebox::string [licensebox::derive_binding $product [dict get $r source] [dict get $r raw_id]]]}
 if {$op eq "native"} {return [::licensebox::string [licensebox::native_binding $product]]}
 if {$op eq "verify"} {return [::licensebox::native::verify [dict get $r token] $product [licensebox::keyjson [dict get $r keys]] [dict get $r now]]}
 set options [dict create version conformance server [dict get $r server] directory [dict get $r directory]]
 set opts [list product [licensebox::string $product] keys [licensebox::keyjson [dict get $r keys]] version [licensebox::string conformance] server [licensebox::string [dict get $r server]] directory [licensebox::string [dict get $r directory]]]
 if {[dict exists $r ca_bundle]} {lappend opts ca_bundle [licensebox::string [dict get $r ca_bundle]]}
 # Native command retains typed Tcl callbacks; raw JSON stays test-local for exact adapter output.
 set c [::licensebox::native::create [json::write object {*}$opts] [dict create clock clock_hook machine_binding binding_hook on_sign_in sign_hook]]
 try {
  switch $op {
   require {set m core;if {[dict exists $r module]} {set m [dict get $r module]};$c call require [json::write object module [licensebox::string $m]]}
   heartbeat - heartbeat-repeat - heartbeat-after-require {set m core;if {[dict exists $r module]} {set m [dict get $r module]};set args [json::write object module [licensebox::string $m]];if {$op eq "heartbeat-after-require"} {$c call require $args};if {$op eq "heartbeat-repeat"} {$c call heartbeat $args};$c call heartbeat $args}
   repeat {$c call require {{"module":"core"}};$c call require {{"module":"core"}}}
   sign_in {$c call sign_in {{"timeout":3}}}
   request {$c call request [json::write object modules {["export"]} note [licensebox::string "café – test"]]}
   access-link {$c call access-link {{}}}
   record {$c call record {{"command":"export","success":true,"elapsed":0.125}};$c call record {{"command":"export","success":false,"elapsed":0.025}};return null}
   default {$c call $op {{}}}
  }
 } finally {$c close}
}
try {set value [run];puts [json::write object ok true value $value]} on error {message options} {puts [json::write object ok false error [json::write string [lindex [dict get $options -errorcode] 1]]]}
