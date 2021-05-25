package XML::Feed::Entry::Format::RSS;
use strict;
use warnings;
use v5.10;

our $VERSION = '0.63';

sub format { 'RSS ' . $_[0]->{'_version'} }

use XML::Feed::Content;
use XML::Feed::Util qw( format_w3cdtf parse_mail_date parse_w3cdtf_date );

use base qw( XML::Feed::Entry );

sub init_empty { $_[0]->{entry} = { } }

sub base {
    my $entry = shift;
    @_ ? $entry->{entry}->{'xml:base'} = $_[0] : $entry->{entry}->{'xml:base'};
}

sub title {
    my $entry = shift;
    @_ ? $entry->{entry}{title} = $_[0] : $entry->{entry}{title};
}

sub link {
    my $entry = shift;
    if (@_) {
        $entry->{entry}{link} = $_[0];
        ## For RSS 2.0 output from XML::RSS. Sigh.
        $entry->{entry}{permaLink} = $_[0];
    } else {
        my $link = $entry->{entry}{link} //
            $entry->{entry}{permaLink} //
            $entry->{entry}{guid};
        if (defined $link) {
            $link =~ s/^\s+//;
            $link =~ s/\s+$//;
        }
        return $link;
    }
}

sub summary {
    my $entry = shift;
    my $item  = $entry->{entry};
    if (@_) {
        $item->{description} = ref($_[0]) eq 'XML::Feed::Content' ?
            $_[0]->body : $_[0];
        $entry->{description_is_summary} = 1;
    } else {
        ## Some RSS feeds use <description> for a summary, and some use it
        ## for the full content. Pretty gross. We don't want to return the
        ## full content if the caller expects a summary, so the heuristic is:
        ## if the <entry> contains both a <description> and one of the elements
        ## typically used for the full content, use <description> as summary.
        my $txt;
        if ($item->{description} &&
            ($entry->{description_is_summary} ||
             $entry->_content //
             $item->{'http://www.w3.org/1999/xhtml'}{body})) {
            $txt = $item->{description};
        ## Blogspot's 'short' RSS feeds do this in the Atom namespace
        ## for no obviously good reason.
        } elsif ($item->{'http://www.w3.org/2005/Atom'}{summary}) {
            $txt = $item->{'http://www.w3.org/2005/Atom'}{summary};
        }
        XML::Feed::Content->wrap({ type => 'text/plain', body => $txt });
    }
}

# Get contentfrom HASH ref or scalar.
sub _content {
    my $entry = shift;
    my $content = $entry->{entry}{content};
    return ref $content ? $content->{encoded} : $content;
}

sub content {
    my $entry = shift;
    my $item = $entry->{entry};
    if (@_) {
        my $c;
        if (ref($_[0]) eq 'XML::Feed::Content') {
            if (defined $_[0]->base) {
                $c = { 'content' => $_[0]->body, 'xml:base' => $_[0]->base };
            } else {
                $c = $_[0]->body;
            }
        } else {
            $c = $_[0];
        }
        $item->{content} = {} unless ref $item->{content};
        $item->{content}{encoded} = $c;
    } else {
        my $base;
        my $body =
            $entry->_content //
            $item->{'http://www.w3.org/1999/xhtml'}{body} //
            $item->{description};
        if ('HASH' eq ref($body)) {
            $base = $body->{'xml:base'};
            $body = $body->{content};
        }
        XML::Feed::Content->wrap({ type => 'text/html', body => $body, base => $base });
    }
}

sub category {
    my $entry = shift;
    my $item  = $entry->{entry};
    if (@_) {
        my @tmp = ($entry->category, @_);
        $item->{category}    = [@tmp];
        $item->{dc}{subject} = [@tmp];
    } else {
        my $r = $item->{category} // $item->{dc}{subject};
        my @r = ref($r) eq 'ARRAY' ? @$r : defined $r? ($r) : ();
        return wantarray? @r : $r[0];
    }
}

sub author {
    my $item = shift->{entry};
    if (@_) {
        $item->{author} = $item->{dc}{creator} = $_[0];
    } else {
        $item->{author} // $item->{dc}{creator};
    }
}

## XML::RSS doesn't give us access to the rdf:about for the <item>,
## so we have to fall back to the <link> element in RSS 1.0 feeds.
sub id {
    my $item = shift->{entry};
    if (@_) {
        $item->{guid} = $_[0];
    } else {
        $item->{guid} // $item->{permaLink} // $item->{link};
    }
}

sub issued {
    my $item = shift->{entry};
    if (@_) {
        $item->{dc}{date} = format_w3cdtf($_[0]);
        $item->{pubDate} = DateTime::Format::Mail->format_datetime($_[0]);
    } else {
        return parse_mail_date($item->{pubDate})
            || parse_w3cdtf_date($item->{dc}{date} || $item->{dcterms}{date});
    }
}

sub modified {
    my $item = shift->{entry};
    if (@_) {
        $item->{dcterms}{modified} = format_w3cdtf($_[0]);
    } else {
        return parse_w3cdtf_date(
            $item->{dcterms}{modified} || $item->{atom}{updated}
        );
    }
}

sub lat {
    my $item = shift->{entry};
    if (@_) {
        $item->{geo}{lat} = $_[0];
    } else {
        return $item->{geo}{lat};
    }
}

sub long {
    my $item = shift->{entry};
    if (@_) {
        $item->{geo}{long} = $_[0];
    } else {
         return $item->{geo}{long};
    }
}

sub enclosure {
    my $entry  = shift;

    if (@_) {
        my $enclosure = shift;
        my $val       =  {
                 url    => $enclosure->{url},
                 type   => $enclosure->{type},
                 length => $enclosure->{length}
        };
        if ($XML::Feed::MULTIPLE_ENCLOSURES) {
            push @{$entry->{entry}->{enclosure}}, $val;
        } else {
            $entry->{entry}->{enclosure} =  $val;
        }
    } else {
        my $tmp  = $entry->{entry}->{enclosure};
        if (defined $tmp) {
            my @encs = map { XML::Feed::Enclosure->new($_) }
              (ref $tmp eq 'ARRAY')? @$tmp : ($tmp);
            return ($XML::Feed::MULTIPLE_ENCLOSURES)? @encs : $encs[-1];
        }
        return;
    }
}

1;

