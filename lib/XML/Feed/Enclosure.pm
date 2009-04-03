package XML::Feed::Enclosure;
use strict;

use strict;

use base qw( Class::ErrorHandler );

sub wrap {
    my $class = shift;
    my($c) = @_;
    bless { %$c }, $class;
}
*new = \&wrap;

sub _var {
    my $enclosure = shift;
    my $var = shift;
    $enclosure->{$var} = shift if @_;
    $enclosure->{$var};
}

sub type   { shift->_var('type',   @_) }
sub length { shift->_var('length', @_) }
sub url    { shift->_var('url',    @_) }

1;
__END__

=head1 NAME

XML::Feed::Enclosure - Wrapper for enclosure objects

=head1 SYNOPSIS

    my ($enclosure) = $entry->enclosure;
    print $enclosure->type;

=head1 DESCRIPTION

I<XML::Feed::Enclosure> represents a content object in an I<XML::Feed::Entry>
entry in a syndication feed. 

=head1 USAGE

=head2 wrap

Take params and turn them into a I<XML::Feed::Enclosure> object.

=head2 new

A synonym for I<wrap>.

=head2 $enclosure->url

The url of the object.

=head2 $enclosure->type

The MIME type of the item referred to in I<url>.

=head2 $enclosure->length

The length of object refereed to in I<url>

=head1 AUTHOR & COPYRIGHT

Please see the I<XML::Feed> manpage for author, copyright, and license
information.

=cut

