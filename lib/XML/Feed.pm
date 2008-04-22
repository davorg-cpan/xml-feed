# $Id: Feed.pm,v 1.8 2004/07/29 16:44:18 btrott Exp $

package XML::Feed;
use strict;

use base qw( XML::Feed::ErrorHandler );
use LWP::UserAgent;
use HTML::Parser;

use vars qw( $VERSION );
$VERSION = '0.02';

use constant FEED_MIME_TYPES => [
    'application/x.atom+xml',
    'application/atom+xml',
    'text/xml',
    'application/rss+xml',
    'application/rdf+xml',
];

sub parse {
    my $class = shift;
    my($stream) = @_;
    return $class->error("Stream parameter is required") unless $stream;
    my $feed = bless {}, $class;
    my $xml = '';
    if (UNIVERSAL::isa($stream, 'URI')) {
        my $ua = LWP::UserAgent->new;
        my $req = HTTP::Request->new(GET => $stream);
        my $res = $ua->request($req);
        if ($res->is_success) {
            $xml = $res->content;
        }
    } elsif (ref($stream) eq 'SCALAR') {
        $xml = $$stream;
    } elsif (ref($stream)) {
        while (read($stream, my($chunk), 8192)) {
            $xml .= $chunk;
        }
    } else {
        open my $fh, $stream
            or return $class->error("Can't open $stream: $!");
        while (read $fh, my($chunk), 8192) {
            $xml .= $chunk;
        }
        close $fh;
    }
    return $class->error("Can't get feed XML content from $stream")
        unless $xml;
    ## Auto-detect feed type based on first element. This is prone
    ## to breakage, but then again we don't want to parse the whole
    ## feed ourselves.
    my $tag;
    while ($xml =~ /<(\S+)/sg) {
        (my $t = $1) =~ tr/a-zA-Z0-9:\-\?//cd;
        $tag = $t, last unless substr($t, 0, 1) eq '?';
    }
    return $class->error("Cannot find first element") unless $tag;
    $tag =~ s/^.*://;
    if ($tag eq 'rss' || $tag eq 'RDF') {
        require XML::Feed::RSS;
        bless $feed, 'XML::Feed::RSS';
    } elsif ($tag eq 'feed') {
        require XML::Feed::Atom;
        bless $feed, 'XML::Feed::Atom';
    } else {
        return $class->error("Cannot detect feed type");
    }
    $feed->init_string($xml) or return;
    $feed;
}

sub find_feeds {
    my $class = shift;
    my($uri) = @_;
    my $ua = LWP::UserAgent->new;
    my $req = HTTP::Request->new(GET => $uri);
    my $res = $ua->request($req);
    return unless $res->is_success;
    my @feeds;
    my %is_feed = map { $_ => 1 } @{ FEED_MIME_TYPES() };
    my $ct = $res->content_type;
    if ($is_feed{$ct}) {
        @feeds = ($uri);
    } elsif ($ct eq 'text/html' || $ct eq 'application/xhtml+xml') {
        my $base_uri = $uri;
        my $find_links = sub {
            my($tag, $attr) = @_;
            if ($tag eq 'link') {
                return unless $attr->{rel};
                my %rel = map { $_ => 1 } split /\s+/, lc($attr->{rel});
                (my $type = lc $attr->{type}) =~ s/^\s*//;
                $type =~ s/\s*$//;
                push @feeds, URI->new_abs($attr->{href}, $base_uri)->as_string
                   if $is_feed{$type} &&
                      ($rel{alternate} || $rel{'service.feed'});
            } elsif ($tag eq 'base') {
                $base_uri = $attr->{href};
            }
        };
        my $p = HTML::Parser->new(api_version => 3,
                                  start_h => [ $find_links, "tagname, attr" ]);
        $p->parse($res->content);
    }
    @feeds;
}

sub format;
sub title;
sub link;
sub description;
sub language;
sub copyright;
sub modified;
sub generator;
sub entries;

sub tagline { $_[0]->description }
sub items   { $_[0]->entries     }

1;
__END__

=head1 NAME

XML::Feed - Syndication feed parser and auto-discovery

=head1 SYNOPSIS

    use XML::Feed;
    my $feed = XML::Feed->parse(URI->new('http://example.com/atom.xml'))
        or die XML::Feed->errstr;
    print $feed->title, "\n";
    for my $entry ($feed->entries) {
    }

    ## Find all of the syndication feeds on a given page, using
    ## auto-discovery.
    my @feeds = XML::Feed->find_feeds('http://example.com/');

=head1 DESCRIPTION

I<XML::Feed> is a syndication feed parser for both RSS and Atom feeds. It
also implements feed auto-discovery for finding feeds, given a URI.

I<XML::Feed> supports the following syndication feed formats:

=over 4

=item * RSS 0.91

=item * RSS 1.0

=item * RSS 2.0

=item * Atom

=back

The goal of I<XML::Feed> is to provide a unified API for parsing and using
the various syndication formats. The different flavors of RSS and Atom
handle data in different ways: date handling; summaries and content;
escaping and quoting; etc. This module attempts to remove those differences
by providing a wrapper around the formats and the classes implementing
those formats (I<XML::RSS> and I<XML::Atom::Feed>). For example, dates are
handled differently in each of the above formats. To provide a unified API for
date handling, I<XML::Feed> converts all date formats transparently into
I<DateTime> objects, which it then returns to the caller.

=head1 USAGE

=head2 XML::Feed->parse($stream)

Parses a syndication feed identified by I<$stream>. I<$stream> can be any
one of the following:

=over 4

=item * Scalar reference

A reference to string containing the XML body of the feed.

=item * Filehandle

An open filehandle from which the feed XML will be read.

=item * File name

The name of a file containing the feed XML.

=item * URI object

A URI from which the feed XML will be retrieved.

=back

=head2 XML::Feed->find_feeds($uri)

Given a URI I<$uri>, use auto-discovery to find all of the feeds linked
from that page (using I<E<lt>linkE<gt>> tags).

Returns a list of feed URIs.

=head2 $feed->format

Returns the format of the feed (C<Atom>, or some version of C<RSS>).

=head2 $feed->title

The title of the feed/channel.

=head2 $feed->link

The permalink of the feed/channel.

=head2 $feed->tagline

The description or tagline of the feed/channel.

=head2 $feed->description

Alias for I<$feed-E<gt>tagline>.

=head2 $feed->language

The language of the feed.

=head2 $feed->copyright

The copyright notice of the feed.

=head2 $feed->modified

A I<DateTime> object representing the last-modified date of the feed.

=head2 $feed->generator

The generator of the feed.

=head2 $feed->entries

A list of the entries/items in the feed. Returns an array containing
I<XML::Feed::Entry> objects.

=head1 LICENSE

I<XML::Feed> is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, I<XML::Feed> is Copyright 2004 Benjamin
Trott, cpan@stupidfool.org. All rights reserved.

=cut
