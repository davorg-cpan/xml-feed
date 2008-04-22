# $Id: RSS.pm,v 1.3 2004/05/30 09:39:52 btrott Exp $

package XML::Feed::RSS;
use strict;

use base qw( XML::Feed );
use XML::RSS;
use DateTime::Format::Mail;
use DateTime::Format::W3CDTF;

sub init_string {
    my $feed = shift;
    my($str) = @_;
    my $rss = $feed->{rss} = XML::RSS->new;
    if ($str) {
        $rss->parse($str);
    }
    $feed;
}

sub format { 'RSS ' . $_[0]->{rss}->{'version'} }

## The following elements are the same in all versions of RSS.
sub title { $_[0]->{rss}->channel('title') }
sub link { $_[0]->{rss}->channel('link') }
sub description { $_[0]->{rss}->channel('description') }

## This is RSS 2.0 only--what's the equivalent in RSS 1.0?
sub copyright { $_[0]->{rss}->channel('copyright') }

## The following all work transparently in any RSS version.
sub language {
    $_[0]->{rss}->channel('language') ||
    $_[0]->{rss}->channel->{dc}{language}
}

sub generator {
    $_[0]->{rss}->channel('generator') ||
    $_[0]->{rss}->channel->{'http://webns.net/mvcb/'}{generatorAgent};
}

sub author {
    $_[0]->{rss}->channel('webMaster') ||
    $_[0]->{rss}->channel->{dc}{creator};
}

sub modified {
    my $rss = $_[0]->{rss};
    if (my $ts = $rss->channel('pubDate')) {
        return DateTime::Format::Mail->parse_datetime($ts);
    } elsif ($ts = $rss->channel->{dc}{date}) {
        return DateTime::Format::W3CDTF->parse_datetime($ts);
    }
}

sub entries {
    my $rss = $_[0]->{rss};
    my @entries;
    for my $item (@{ $rss->{items} }) {
        push @entries, XML::Feed::RSS::Entry->wrap($item);
    }
    @entries;
}

package XML::Feed::RSS::Entry;
use strict;

use base qw( XML::Feed::Entry );

sub title { $_[0]->{entry}{title} }
sub link { $_[0]->{entry}{link} }
sub summary { $_[0]->{entry}{description} }

sub content {
    my $item = $_[0]->{entry};
    $_[0]->{entry}{'http://purl.org/rss/1.0/modules/content/'}{encoded} ||
    $_[0]->{entry}{'http://www.w3.org/1999/xhtml'}{body} ||
    $_[0]->{entry}{description};
}

sub category {
    $_[0]->{entry}{category} || $_[0]->{entry}{dc}{subject};
}

sub author {
    $_[0]->{entry}{author} || $_[0]->{entry}{dc}{creator};
}

## XML::RSS doesn't give us access to the rdf:about for the <item>,
## so we have to fall back to the <link> element in RSS 1.0 feeds.
sub id {
    $_[0]->{entry}{guid} || $_[0]->{entry}{link};
}

sub issued {
    if (my $ts = $_[0]->{entry}{pubDate}) {
        return DateTime::Format::Mail->parse_datetime($ts);
    } elsif ($ts = $_[0]->{entry}{dc}{date}) {
        return DateTime::Format::W3CDTF->parse_datetime($ts);
    }
}

sub modified {
    if (my $ts = $_[0]->{entry}{'http://purl.org/rss/1.0/modules/dcterms/'}{modified}) {
        return DateTime::Format::W3CDTF->parse_datetime($ts);
    }
}

1;
