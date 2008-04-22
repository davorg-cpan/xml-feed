# $Id: Atom.pm,v 1.2 2004/06/20 15:20:37 btrott Exp $

package XML::Feed::Atom;
use strict;

use base qw( XML::Feed );
use XML::Atom::Feed;
use XML::Atom::Util qw( iso2dt );
use List::Util qw( first );

sub init_string {
    my $feed = shift;
    my($str) = @_;
    $feed->{atom} = XML::Atom::Feed->new(Stream => \$str)
        or return $feed->error(XML::Atom::Feed->errstr);
    $feed;
}

sub format { 'Atom' }

sub title { $_[0]->{atom}->title }
sub link {
    my $l = first { $_->rel eq 'alternate' } $_[0]->{atom}->link;
    $l ? $l->href : undef;
}
sub description { $_[0]->{atom}->tagline }
sub copyright { $_[0]->{atom}->copyright }
sub language { $_[0]->{atom}->language }
sub generator { $_[0]->{atom}->generator }
sub author { $_[0]->{atom}->author ? $_[0]->{atom}->author->name : undef }
sub modified { iso2dt($_[0]->{atom}->modified) }

sub entries { 
    my @entries;
    for my $entry ($_[0]->{atom}->entries) {
        push @entries, XML::Feed::Atom::Entry->wrap($entry);
    }
    @entries;
}

package XML::Feed::Atom::Entry;
use strict;

use base qw( XML::Feed::Entry );
use XML::Atom::Util qw( iso2dt );
use XML::Feed::Content;
use List::Util qw( first );

sub title { $_[0]->{entry}->title }
sub link {
    my $l = first { $_->rel eq 'alternate' } $_[0]->{entry}->link;
    $l ? $l->href : undef;
}

sub summary {
    XML::Feed::Content->wrap({ type => 'text/html',
                               body => $_[0]->{entry}->summary });
}

sub content {
    my $c = $_[0]->{entry}->content;
    XML::Feed::Content->wrap({ type => $c ? $c->type : undef,
                               body => $c ? $c->body : undef });
}

sub category {
    my $ns = XML::Atom::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
    $_[0]->{entry}->get($ns, 'subject');
}

sub author { $_[0]->{entry}->author ? $_[0]->{entry}->author->name : undef }
sub id { $_[0]->{entry}->id }
sub issued { iso2dt($_[0]->{entry}->issued) }
sub modified { iso2dt($_[0]->{entry}->modified) }

1;
