package XML::Feed::Util;
use strict;
use warnings;

our $VERSION = '0.01';

use base qw( Exporter );
use DateTime::Format::W3CDTF;

our @EXPORT_OK = qw( format_W3CDTF );

sub format_W3CDTF {
    my $date = DateTime::Format::W3CDTF->format_datetime(shift);

    # Add timezone "Z" if "floating" DateTime.
    $date =~ s/(:\d\d(?:\.\d+)?)\s*$/$1Z/;

    return $date;
}

1;

__END__

=head1 NAME

XML::Feed::Util - Utility functions

=head1 SYNOPSIS

    use XML::Feed::Util qw( format_W3CDTF );
    use DateTime;
    
    print format_W3CDTF(DateTime->now);

=head1 DESCRIPTION

Common utility or helper functions.

=head1 USAGE

=head2 format_W3CDTF($date)

Convert DateTime object to W3CDTF format string.
Uses default timezone "Z" for "floating" DateTime.

=head1 AUTHOR & COPYRIGHT

Please see the I<XML::Feed> manpage for author, copyright, and license
information.

=cut
