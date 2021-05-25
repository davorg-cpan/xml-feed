use strict;
use warnings;
use Test::More;

use DateTime;
use XML::XPath;

use XML::Feed;
use XML::Feed::Entry;

# https://github.com/davorg/xml-feed/issues/55

my $feed = XML::Feed->new('Atom');

# Bugs are with DateTime with non-UTC time zone.
my $dt = DateTime->now(time_zone => 'Asia/Tokyo');

$feed->title("My Atom feed");
$feed->link("http://www.example.com");
$feed->author("Author");
$feed->updated($dt);
$feed->id("urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344eaa6a");

my $entry = XML::Feed::Entry->new('Atom');
$entry->title("An important event");
$entry->author("Important author");
$entry->content("A very interesting event happened.");

$entry->issued($dt);
$entry->updated($dt);
$entry->id("urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a");

$feed->add_entry($entry);

my $xp = XML::XPath->new(xml => $feed->as_xml);
my $rfc3339 = qr!<updated>\d{4}-\d{2}-\d{2}T.+\+09:00</updated>!;
like $xp->findnodes_as_string('/feed/updated'), $rfc3339;
like $xp->findnodes_as_string('/feed/entry/updated'), $rfc3339;

done_testing();
