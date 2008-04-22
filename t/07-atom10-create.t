use strict;
use Test::More;

plan 'no_plan';

use XML::Feed;

my $feed = XML::Feed->new('Atom');
$feed->title("foo");
$feed->description("Atom 1.0 feed");
$feed->link("http://example.org/");

my $entry = XML::Feed::Entry->new('Atom');
$entry->title("1st Entry");
$entry->link("http://example.org/");
$entry->category("blah");
$entry->content("<p>Hello world.</p>");

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

my @entries = $feed->entries;
is @entries, 1;
$entry = $entries[0];

is $entry->title, '1st Entry';
is $entry->link, 'http://example.org/';
is $entry->category, 'blah';
is $entry->content->type, 'text/html';
like $entry->content->body, qr!\s*<p>Hello world.</p>\s*!s;



