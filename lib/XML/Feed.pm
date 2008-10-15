# $Id: Feed.pm 1958 2006-08-14 05:31:27Z btrott $

package XML::Feed;
use strict;

use base qw( Class::ErrorHandler );
use Feed::Find;
use URI::Fetch;
use Carp;

our $VERSION = '0.20';

sub new {
    my $class = shift;
    my $format = shift || 'Atom';
    my $format_class = 'XML::Feed::' . $format;
    eval "use $format_class";
    Carp::croak("Unsupported format $format: $@") if $@;
    my $feed = bless {}, join('::', __PACKAGE__, $format);
    $feed->init_empty(@_) or return $class->error($feed->errstr);
    $feed;
}

sub init_empty { 1 }

sub parse {
    my $class = shift;
    my($stream, $specified_format) = @_;
    return $class->error("Stream parameter is required") unless $stream;
    my $feed = bless {}, $class;
    my $xml = '';
    if (UNIVERSAL::isa($stream, 'URI')) {
        my $res = URI::Fetch->fetch($stream)
            or return $class->error(URI::Fetch->errstr);
        return $class->error("This feed has been permanently removed")
            if $res->status == URI::Fetch::URI_GONE();
        $xml = $res->content;
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
    my $format;
    if ($specified_format) {
        $format = $specified_format;
    } else {
        $format = $feed->identify_format(\$xml) or return $class->error($feed->errstr);
    }

    my $format_class = join '::', __PACKAGE__, $format;
    eval "use $format_class";
    return $class->error("Unsupported format $format: $@") if $@;
    bless $feed, $format_class;
    $feed->init_string(\$xml) or return $class->error($feed->errstr);
    $feed;
}

sub identify_format {
    my $feed = shift;
    my($xml) = @_;
    ## Auto-detect feed type based on first element. This is prone
    ## to breakage, but then again we don't want to parse the whole
    ## feed ourselves.
    my $tag;
    while ($$xml =~ /<(\S+)/sg) {
        (my $t = $1) =~ tr/a-zA-Z0-9:\-\?!//cd;
        my $first = substr $t, 0, 1;
        $tag = $t, last unless $first eq '?' || $first eq '!';
    }
    return $feed->error("Cannot find first element") unless $tag;
    $tag =~ s/^.*://;
    if ($tag eq 'rss' || $tag eq 'RDF') {
        return 'RSS';
    } elsif ($tag eq 'feed') {
        return 'Atom';
    } else {
        return $feed->error("Cannot detect feed type");
    }
}

sub find_feeds {
    my $class = shift;
    my($uri) = @_;
    my @feeds = Feed::Find->find($uri)
        or return $class->error(Feed::Find->errstr);
    @feeds;
}

sub convert {
    my $feed = shift;
    my($format) = @_;
    my $new = __PACKAGE__->new($format);
    for my $field (qw( title link description language author copyright modified generator )) {
        my $val = $feed->$field();
        next unless defined $val;
        $new->$field($val);
    }
    for my $entry ($feed->entries) {
        $new->add_entry($entry->convert($format));
    }
    $new;
}

sub splice {
    my $feed = shift;
    my($other) = @_;
    my %ids = map { $_->id => 1 } $feed->entries;
    for my $entry ($other->entries) {
        $feed->add_entry($entry) unless $ids{$entry->id}++;
    }
}

sub format;
sub title;
sub link;
sub description;
sub language;
sub author;
sub copyright;
sub modified;
sub generator;
sub add_entry;
sub entries;
sub as_xml;

sub tagline { shift->description(@_) }
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

=head2 XML::Feed->new($format)

Creates a new empty I<XML::Feed> object using the format I<$format>.

=head2 XML::Feed->parse($stream)

=head2 XML::Feed->parse($stream, $format)

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

C<$format> allows you to override format guessing.

=head2 XML::Feed->find_feeds($uri)

Given a URI I<$uri>, use auto-discovery to find all of the feeds linked
from that page (using I<E<lt>linkE<gt>> tags).

Returns a list of feed URIs.

=head2 $feed->convert($format)

Converts the I<XML::Feed> object into the I<$format> format, and returns
the new object.

=head2 $feed->splice($other_feed)

Splices in all of the entries from the feed I<$other_feed> into I<$feed>,
skipping posts that are already in I<$feed>.

=head2 $feed->format

Returns the format of the feed (C<Atom>, or some version of C<RSS>).

=head2 $feed->title([ $title ])

The title of the feed/channel.

=head2 $feed->link([ $uri ])

The permalink of the feed/channel.

=head2 $feed->tagline([ $tagline ])

The description or tagline of the feed/channel.

=head2 $feed->description([ $description ])

Alias for I<$feed-E<gt>tagline>.

=head2 $feed->author([ $author ])

The author of the feed/channel.

=head2 $feed->language([ $language ])

The language of the feed.

=head2 $feed->copyright([ $copyright ])

The copyright notice of the feed.

=head2 $feed->modified([ $modified ])

A I<DateTime> object representing the last-modified date of the feed.

If present, I<$modified> should be a I<DateTime> object.

=head2 $feed->generator([ $generator ])

The generator of the feed.

=head2 $feed->entries

A list of the entries/items in the feed. Returns an array containing
I<XML::Feed::Entry> objects.

=head2 $feed->add_entry($entry)

Adds an entry to the feed. I<$entry> should be an I<XML::Feed::Entry>
object in the correct format for the feed.

=head2 $feed->as_xml

Returns an XML representation of the feed, in the format determined by
the current format of the I<$feed> object.

=head1 PACKAGE VARIABLES

=over 4

=item C<$XML::Feed::RSS::PREFERRED_PARSER>

If you want to use another RSS parser class than XML::RSS (default), you can
change the class by setting C<$PREFERRED_PARSER> variable in XML::Feed::RSS
package.

    $XML::Feed::RSS::PREFERRED_PARSER = "XML::RSS::LibXML";

B<Note:> this will only work for parsing feeds, not creating feeds.

=back

=head1 LICENSE

I<XML::Feed> is free software; you may redistribute it and/or modify it
under the same terms as Perl itself.

=head1 AUTHOR & COPYRIGHT

Except where otherwise noted, I<XML::Feed> is Copyright 2004-2008
Six Apart, cpan@sixapart.com. All rights reserved.

=head1 SUBVERSION 

The latest version of I<XML::Feed> can be found at

    http://code.sixapart.com/svn/XML-Feed/trunk/

=cut
