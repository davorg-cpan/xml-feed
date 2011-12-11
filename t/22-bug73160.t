use strict;
use warnings;

use Test::More;
use XML::Feed;

my $file = 't/samples/rss10-datespaces.xml';
my $feed = XML::Feed->parse($file);
isa_ok($feed, 'XML::Feed::Format::RSS');
ok(my $date = $feed->modified, 'Got a feed modified date');
isa_ok($date, 'DateTime');

my $link = $feed->link;
unlike($link, qr[^\s], 'No spaces at start of link');
unlike($link, qr[\s$], 'No spaces at end of link');

my $entry = ($feed->entries)[0];
ok(my $iss = $entry->issued, 'Got an entry issued date');
isa_ok($iss, 'DateTime');

$link = $entry->link;
unlike($link, qr[^\s], 'No spaces at start of link');
unlike($link, qr[\s$], 'No spaces at end of link');

done_testing;
