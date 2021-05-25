package XML::Feed::Util;
use strict;
use warnings;

our $VERSION = '0.63';

use base qw( Exporter );
use DateTime::Format::Flexible;
use DateTime::Format::ISO8601;
use DateTime::Format::Natural;
use DateTime::Format::W3CDTF;
use DateTime::Format::Mail;

our @EXPORT_OK = qw(
    format_w3cdtf
    parse_datetime
    parse_w3cdtf_date
    parse_mail_date
);

sub format_w3cdtf {
    my $dt = shift;

    my $date = DateTime::Format::W3CDTF->format_datetime($dt);

    # Add timezone "Z" if "floating" DateTime.
    $date .= 'Z' if $dt->time_zone->is_floating;

    return $date;
}

sub parse_datetime {
    my $ts = shift or return undef;

    $ts = _strip_spaces($ts);

    return eval { DateTime::Format::ISO8601->parse_datetime($ts) }
        || eval { DateTime::Format::Flexible->parse_datetime($ts) }
        || do {
        my $p = DateTime::Format::Natural->new;
        my $dt = $p->parse_datetime($ts);
        $p->success ? $dt : undef;
    };
};

sub parse_mail_date {
    my $ts = shift or return undef;

    $ts = _strip_spaces($ts);

    return eval { DateTime::Format::Mail->new(loose => 1)->parse_datetime($ts) }
        || parse_datetime($ts);
};

sub parse_w3cdtf_date {
    my $ts = shift or return undef;

    $ts = _strip_spaces($ts);

    return eval { DateTime::Format::W3CDTF->parse_datetime($ts) }
        || parse_datetime($ts);
};

sub _strip_spaces {
    local $_ = shift;
    s/^\s+//, s/\s+$// if $_;
    return $_;
}

1;

__END__

=head1 NAME

XML::Feed::Util - Utility functions

=head1 SYNOPSIS

    use XML::Feed::Util qw(
        format_w3cdtf
        parse_datetime
        parse_mail_date
        parse_w3cdtf_date
    );
    use DateTime;
    
    print format_w3cdtf(DateTime->now);
    
    my $dt;
    $dt = parse_datetime('January 8, 1999');
    $dt = parse_mail_date('Fri, 23 Nov 2001 21:57:24 -0600');
    $dt = parse_w3cdtf_date('2003-02-15T13:50:05-05:00');

=head1 DESCRIPTION

Common utility or helper functions.

=head1 USAGE

=head2 format_w3cdtf($datetime)

Convert DateTime object to W3CDTF format string.
Uses default timezone "Z" for "floating" DateTime.

=head2 parse_datetime($date)

Parse any date string using L<DateTime::Format::ISO8601>,
L<DateTime::Format::Flexible> or L<DateTime::Format::Natural>.

Returns DateTime object or undef.

=head2 parse_mail_date($date)

Parse date in RFC2822/822 format using L<DateTime::Format::Mail>.
Fallback to C<parse_datetime()> for other formats.

Returns DateTime object or undef.

=head2 parse_w3cdtf_date($date)

Parse date W3CDTF format using L<DateTime::Format::W3CDTF>.
Fallback to C<parse_datetime()> for other formats.

Returns DateTime object or undef.

=head1 AUTHOR & COPYRIGHT

Please see the I<XML::Feed> manpage for author, copyright, and license
information.

=cut
