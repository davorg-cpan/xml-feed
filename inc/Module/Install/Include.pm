#line 1 "inc/Module/Install/Include.pm - /Library/Perl/5.8.1/Module/Install/Include.pm"
# $File: //depot/cpan/Module-Install/lib/Module/Install/Include.pm $ $Author: autrijus $
# $Revision: #9 $ $Change: 2288 $ $DateTime: 2004/07/01 04:49:12 $ vim: expandtab shiftwidth=4

package Module::Install::Include;
use Module::Install::Base; @ISA = qw(Module::Install::Base);

sub include { +shift->admin->include(@_) };
sub include_deps { +shift->admin->include_deps(@_) };
sub auto_include { +shift->admin->auto_include(@_) };
sub auto_include_deps { +shift->admin->auto_include_deps(@_) };

1;
