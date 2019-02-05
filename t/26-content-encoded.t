use strict;
use warnings;

use Test::More;
use XML::Feed;
use FindBin '$Bin';

# https://rt.cpan.org/Public/Bug/Display.html?id=76738

my $feed = XML::Feed->parse("$Bin/samples/rss-content-encoded.xml");

my @items = $feed->items;
my @labels = qw/ First Second /;

# XML::RSS will set $item->{content}{encoded} from <content:encoded>,
# but set $item->{content} from <content>.
is(ref $items[0]->unwrap->{content}, 'HASH',
   "$labels[0] entry set <content:encoded> as HASH ref");
ok(!ref $items[1]->unwrap->{content},
   "$labels[1] entry set <content> as string");

# Both summary() and content() access content.  Neither should die
# trying to use a string as a HASH ref.
#
# Test summary() first, since setting content() will force it to a
# HASH ref.
for my $item (@items) {
    my $label = shift @labels;
    my $name = "\l$label entry";

    my $summary = "$label Description";
    is($item->summary->body, $summary,      "Get old summary from $name");

    $summary = "Summary for $name";
    ok($item->summary($summary),            "Set new summary for $name");
    is($item->summary->body, $summary,      "Get new summary from $name");

    my $content_re = qr/^$label Content/;
    like($item->content->body, $content_re, "Get old content from $name");
    
    my $content = "Content for $name";
    ok($item->content($content),            "Set new content for $name");
    is($item->content->body, $content,      "Get new content from $name");
}

done_testing();
