use strict;
use warnings;
use XML::Feed;

use Test::More;
plan tests => 3;

my $feed = XML::Feed->parse("t/samples/atom-10-example.xml");
is $feed->title, 'Example Feed';
is $feed->link, 'http://example.org/', "link without rel";

my $e = ($feed->entries)[0];
ok $e->link, 'entry link without rel';

