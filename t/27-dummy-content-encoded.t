use strict;
use warnings;
use Test::More;

use XML::Feed;
use XML::Feed::Entry;
use DateTime;

# https://rt.cpan.org/Public/Bug/Display.html?id=124346

my $feed = XML::Feed->new('RSS');
my $dt = DateTime->now;

$feed->title("My Atom feed");
$feed->link("http://www.example.com");
$feed->author("Author");
$feed->updated($dt);
$feed->id("urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344eaa6a");

my $entry = XML::Feed::Entry->new('RSS');
$entry->title("Title");
$entry->author("Author");
$entry->issued($dt);
$entry->id("urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a");

ok(!$entry->summary->body, "Entry has so no summary");
ok(!$entry->content->body, "Entry has so no content");

my $summary = "Summary";
$entry->summary($summary);

is($entry->summary->body, $summary, "Set summary...");
is($entry->content->body, $summary, "...did not add dummy content");

$feed->add_entry($entry);

unlike($feed->as_xml, qr/<content/, "XML has no <content>");

done_testing();
