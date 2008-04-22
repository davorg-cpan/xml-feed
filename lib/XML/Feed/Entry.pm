# $Id: Entry.pm,v 1.1.1.1 2004/05/29 17:29:56 btrott Exp $

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

The full entry body, or as much as is available in the feed.

In RSS feeds, this method will look first for
I<http://purl.org/rss/1.0/modules/content/#encoded> and
I<http://www.w3.org/1999/xhtml#body> elements, then fall back to a
I<E<lt>descriptionE<gt>> element.

=head2 $entry->summary

A short summary of the entry. Possibly.

Since RSS feeds do not have the idea of a summary separate from the entry
body, this may return the same value as the I<$entry-E<gt>content> method.
But it won't always, even with RSS feeds. For example, a number of RSS feeds
use an element like I<http://purl.org/rss/1.0/modules/content/#encoded>
for the entry body and put an excerpt in the I<E<lt>descriptionE<gt>> element;
in those cases, this method will return the excerpt.

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
