package require Tcl 8.6
package require json
package require json::write
package require licensebox::native 0.2.0
namespace eval ::licensebox {
 proc arg {s} {if {[::string first \x00 $s]>=0} {return -code error -errorcode {LICENSEBOX invalid_argument} "NUL argument"};return $s}
 proc string {s} {json::write string [arg $s]}
 proc keyjson {keys} {set args {};dict for {k v} $keys {lappend args [arg $k] [string $v]};json::write object {*}$args}
 proc derive_binding {product source raw} {native::derive [arg $product] [arg $source] [::string trimright $raw \x00]}
 proc native_binding {product} {native::binding [arg $product]}
 proc verify_lease {token product keys now} {json::json2dict [native::verify [arg $token] [arg $product] [keyjson $keys] $now]}
 # hooks is a dict of trusted Tcl command prefixes, never serialized identity.
 proc new {product keys {options {}} {hooks {}}} {
  set opts [list product [string $product] keys [keyjson $keys] version [string [expr {[dict exists $options version]?[dict get $options version]:""}]]]
  foreach k {server directory ca_bundle} {if {[dict exists $options $k]} {lappend opts $k [string [dict get $options $k]]}}
  set native [native::create [json::write object {*}$opts] $hooks]
  Client new $native
 }
 oo::class create Client {
  variable native
  constructor {handle} {set native $handle}
  destructor {if {[info commands $native] ne ""} {$native close}}
  method close {} {if {[info commands $native] ne ""} {$native close}}
  method call {op {arguments {}}} {json::json2dict [$native call $op [json::write object {*}$arguments]]}
  method lease {} {my call lease}
  method heartbeat {module} {my call heartbeat [list module [::licensebox::string $module]]}
  method require_module {module} {my call require [list module [::licensebox::string $module]]}
  method status {} {my call status}
  method sign_in {{timeout 0}} {if {![::string is double -strict $timeout] || $timeout in {Inf -Inf NaN}} {return -code error -errorcode {LICENSEBOX invalid_argument} "invalid timeout"};my call sign_in [list timeout $timeout]}
  method logout {} {my call logout}
  method modules {} {my call modules}
  method requests {} {my call requests}
  method request_access {modules {note ""}} {set names {};foreach s $modules {lappend names [::licensebox::string $s]};my call request [list modules [json::write array {*}$names] note [::licensebox::string $note]]}
  method access_link {} {my call access-link}
  method record {command success elapsed} {if {![::string is double -strict $elapsed] || $elapsed in {Inf -Inf NaN} || $elapsed<0} {return -code error -errorcode {LICENSEBOX invalid_argument} "invalid elapsed"};my call record [list command [::licensebox::string $command] success [expr {$success?"true":"false"}] elapsed $elapsed]}
 }
}
package provide licensebox 0.2.0
