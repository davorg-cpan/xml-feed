# $Id: ErrorHandler.pm,v 1.2 2004/05/29 18:19:50 btrott Exp $

package XML::Feed::ErrorHandler;
use strict;

use vars qw( $ERROR );

sub error  {
    my $msg = $_[1] || '';
    $msg .= "\n" unless $msg =~ /\n$/;
    if (ref($_[0])) {
        $_[0]->{_errstr} = $msg;
    } else {
        $ERROR = $msg;
    }
    return;
 }
sub errstr { ref($_[0]) ? $_[0]->{_errstr} : $ERROR }

1;
