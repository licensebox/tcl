lappend auto_path [file dirname [file dirname [info script]]]
package require licensebox
if {![string match m1:* [licensebox::derive_binding demo linux-machine-id "12345678123456789abc1234567890ab\x00"]]} {error derive}
try {licensebox::verify_lease bad demo {} 0;error accepted} trap {LICENSEBOX malformed} {} {}
puts "Tcl binding checks passed"
set channel [file tempfile dir];close $channel;file delete $dir
proc fail_binding {} {error "synthetic callback failure"}
set c [licensebox::new demo [dict create test-key A6EHv_POEL4dcN0Y50vAmWfk1jCbpQ1fHdyGZBJVMbg] [dict create directory $dir] [dict create machine_binding fail_binding]]
try {try {$c sign_in 0.1;error accepted} trap {LICENSEBOX callback_error} {} {}} finally {$c close;$c close;$c destroy;file delete -force $dir}
