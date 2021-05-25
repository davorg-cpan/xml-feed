package XML::Feed::Format::Atom;
use strict;
use warnings;
use v5.10;

our $VERSION = '0.63';

use base qw( XML::Feed );
use XML::Atom::Feed;
use XML::Feed::Util qw( format_w3cdtf parse_datetime );
use List::Util qw( first );
use HTML::Entities;

use XML::Atom::Entry;
XML::Atom::Entry->mk_elem_accessors(qw( lat long ), ['http://www.w3.org/2003/01/geo/wgs84_pos#']);

use XML::Atom::Content;
use XML::Feed::Entry::Format::Atom;

sub identify {
    my $class   = shift;
    my $xml     = shift;
    my $tag     = $class->_get_first_tag($xml);
    return ($tag eq 'feed');
}


sub init_empty {
    my ($feed, %args) = @_;
    $args{'Version'} //= '1.0';

    $feed->{atom} = XML::Atom::Feed->new(%args);
    $feed;
}

sub init_string {
    my $feed = shift;
    my($str) = @_;
    if ($str) {
        $feed->{atom} = XML::Atom::Feed->new(Stream => $str)
            or return $feed->error(XML::Atom::Feed->errstr);
    }
    $feed;
}

sub format { 'Atom' }

sub title { shift->{atom}->title(@_) }
sub link {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->add_link({ rel => 'alternate', href => $_[0],
                                  type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $feed->{atom}->link;
        $l ? $l->href : undef;
    }
}

sub _rel_link {
    my $feed = shift;
    my $rel  = shift;
    if (@_) {
        my $uri = shift;
        $feed->{atom}->add_link({type => "application/atom+xml", rel => $rel, href => $uri});
        return $uri;
    }
    else
    {
        my $l;

        if ($rel eq 'self') {
            $l = first
                { !defined $_->rel || $_->rel eq 'self' }
                $feed->{atom}->link;
        } else {
            $l = first
                { !defined $_->rel || $_->rel eq $rel }
                $feed->{atom}->link;
        }

        return $l ? $l->href : undef;
    }
}

sub self_link   { shift->_rel_link( 'self', @_ ) }
sub first_link  { shift->_rel_link( 'first', @_ ) }
sub last_link   { shift->_rel_link( 'last', @_ ) }
sub next_link   { shift->_rel_link( 'next', @_ ) }
sub previous_link     { shift->_rel_link( 'previous', @_ ) }
sub current_link      { shift->_rel_link( 'current', @_ ) }
sub prev_archive_link { shift->_rel_link( 'prev-archive', @_ ) }
sub next_archive_link { shift->_rel_link( 'next-archive', @_ ) }

sub description { shift->{atom}->tagline(@_) }
sub copyright   { shift->{atom}->copyright(@_) }
sub language    { shift->{atom}->language(@_) }
sub generator   { shift->{atom}->generator(@_) }
sub id          { shift->{atom}->id(@_) }
sub updated     { shift->modified(@_) }
sub add_link    { shift->{atom}->add_link(@_) }
sub base        { shift->{atom}->base(@_) }

sub author {
    my $feed = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $feed->{atom}->author($person);
    } else {
        $feed->{atom}->author ? $feed->{atom}->author->name : undef;
    }
}

sub image {
    return;
}

sub modified {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->modified(format_w3cdtf($_[0]));
    } else {
        parse_datetime($feed->{atom}->modified || $feed->{atom}->updated);
    }
}

sub entries {
    my @entries;
    for my $entry ($_[0]->{atom}->entries) {
        push @entries, XML::Feed::Entry::Format::Atom->wrap($entry);
    }

    @entries;
}

sub add_entry {
    my $feed  = shift;
    my $entry = shift || return;
    $entry    = $feed->_convert_entry($entry);
    $feed->{atom}->add_entry($entry->unwrap);
}

sub as_xml { $_[0]->{atom}->as_xml }

1;
