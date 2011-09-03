use strict;
use warnings;

use Test::More tests => 2;
use XML::Feed;

my $file = 't/samples/rss20-p.xml';
my $feed = XML::Feed->parse($file);
isa_ok($feed, 'XML::Feed::Format::RSS');
my $entry = ($feed->entries)[0];
is($entry->link, 'http://creograf.ru/post/regexp -js');
