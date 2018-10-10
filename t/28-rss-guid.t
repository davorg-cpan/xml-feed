use strict;
use warnings;
use Test::More;

use XML::Feed;

my $feed = XML::Feed->parse('t/samples/rss-guid.xml');

for my $item ($feed->items) {
    my $re = $item->category;
    my $desc = $item->summary->body;
    like($item->id, qr/$re/, $desc);
}

done_testing();

__DATA__
