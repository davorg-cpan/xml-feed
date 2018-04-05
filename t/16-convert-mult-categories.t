use strict;
use warnings;
use Test::More tests => 2;
use XML::Feed;

my $feed = XML::Feed->parse("t/samples/rss-multiple-categories.xml");

my ($entry) = $feed->entries;

is_deeply(
        [$entry->category()],
        ["foo", "bar", "quux", "simon's tags"],
"Got all categories");

my ($converted_entry) = $feed->convert('Atom')->entries;

is_deeply(
        [$converted_entry->category()],
        ["foo", "bar", "quux", "simon's tags"],
"All categories in place after conversion");
