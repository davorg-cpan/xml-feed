use strict;
use warnings;
use Test::More;

use XML::Feed;
use DateTime;

my $now = DateTime->now();

my $feed = XML::Feed->new('Atom');
$feed->title("foo");
$feed->description("Atom 1.0 feed");
$feed->link("http://example.org/");
$feed->id("tag:cpan.org;xml-feed-atom");
$feed->modified($now);

my $entry = XML::Feed::Entry->new('Atom');
$entry->title("1st Entry");
$entry->link("http://example.org/");
$entry->category("blah");
$entry->content("<p>Hello world.</p>");
$entry->id("tag:cpan.org;xml-feed-atom-entry");
$entry->modified($now);

$feed->add_entry($entry);

my $xml = $feed->as_xml;
like $xml, qr!<feed xmlns="http://www.w3.org/2005/Atom"!;
like $xml, qr!<content .*type="xhtml">!;
like $xml, qr!<div xmlns="http://www.w3.org/1999/xhtml">!;

# roundtrip
$feed = XML::Feed->parse(\$xml);
is $feed->format, 'Atom';
is $feed->title, "foo";
is $feed->description, "Atom 1.0 feed";
is $feed->link, "http://example.org/";
is $feed->id, "tag:cpan.org;xml-feed-atom";
is $feed->modified->iso8601, $now->iso8601;

my @entries = $feed->entries;
is @entries, 1;
$entry = $entries[0];

is $entry->title, '1st Entry';
is $entry->link, 'http://example.org/';
is $entry->category, 'blah';
is $entry->content->type, 'text/html';
like $entry->content->body, qr!\s*<p>Hello world.</p>\s*!s;

is $entry->id, "tag:cpan.org;xml-feed-atom-entry";
is $entry->modified->iso8601, $now->iso8601;

done_testing();
