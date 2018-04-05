#!perl

use strict;
use warnings;
use Test::More tests => 13;

use_ok("XML::Feed");


my $rss_feed;
ok($rss_feed = XML::Feed->new('RSS'),     "Got feed");
ok($rss_feed->title('Happy Feed'),        "Set feed title");
ok($rss_feed->author('Ask Bjork Tate'),   "Set feed author");
ok($rss_feed->link('http://nowhere.com'), "Set feed link");
ok($rss_feed->language('en-US'),          "Set feed language");
ok($rss_feed->description('not existing since who knows when'), "Set feed description");

my $rss_entry;
my $content = <<'EOC';
But that's XML::RSS's problem. Oh, and this would
be an XML::Feed::Content item as specced in the docs, but there is no
constructor documented for XML::Feed::Content and I know this works
anyway.
EOC

ok($rss_entry = XML::Feed::Entry->new('RSS'), "Got entry");
ok($rss_entry->title("Title is not always a required element in RSS2"), "Set entry title");
ok($rss_entry->content($content),                                       "Set entry content");
ok($rss_entry->link('http://nowhere.com/themiddle'),                    "Set entry link");

ok($rss_feed->add_entry($rss_entry),                                    "Added entry");

like($rss_feed->as_xml, qr/problem/i,                                   "Feed has body");

