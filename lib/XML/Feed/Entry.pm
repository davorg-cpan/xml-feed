# $Id: Entry.pm,v 1.3 2004/07/29 16:42:29 btrott Exp $

package XML::Feed::Entry;
use strict;

sub wrap {
    my $class = shift;
    my($item) = @_;
    bless { entry => $item }, $class;
}

sub title;
sub link;
sub content;
sub summary;
sub category;
sub author;
sub id;
sub issued;
sub modified;

1;
__END__

=head1 NAME

XML::Feed::Entry - Entry/item in a syndication feed

=head1 SYNOPSIS

    ## $feed is an XML::Feed object.
    for my $entry ($feed->entries) {
        print $entry->title, "\n", $entry->summary, "\n\n";
    }

=head1 DESCRIPTION

I<XML::Feed::Entry> represents an entry/item in an I<XML::Feed> syndication
feed.

=head1 USAGE

=head2 $entry->title

The title of the entry.

=head2 $entry->link

The permalink of the entry, in most cases, except in cases where it points
instead of an offsite URI referenced in the entry.

=head2 $entry->content

Bn I<XML::Feed::Content> object representing the full entry body, or as
much as is available in the feed.

In RSS feeds, this method will look first for
I<http://purl.org/rss/1.0/modules/content/#encoded> and
I<http://www.w3.org/1999/xhtml#body> elements, then fall back to a
I<E<lt>descriptionE<gt>> element.

=head2 $entry->summary

An I<XML::Feed::Content> object representing a short summary of the entry.
Possibly.

Since RSS feeds do not have the idea of a summary separate from the entry
body, this may not always be what you want. If the entry contains both a
I<E<lt>descriptionE<gt>> element B<and> another element typically used for
the full content of the entry--either I<http://www.w3.org/1999/xhtml/body>
or I<http://purl.org/rss/1.0/modules/content/#encoded>--we treat that as
the summary. Otherwise, we assume that there isn't a summary, and return
an I<XML::Feed::Content> object with an empty string in the I<body>.

=head2 $entry->category

The category in which the entry was posted.

=head2 $entry->author

The name or email address of the person who posted the entry.

=head2 $entry->id

The unique ID of the entry.

=head2 $entry->issued

A I<DateTime> object representing the date and time at which the entry
was posted.

=head2 $entry->modified

A I<DateTime> object representing the last-modified date of the entry.

=head1 AUTHOR & COPYRIGHT

Please see the I<XML::Feed> manpage for author, copyright, and license
information.

=cut
