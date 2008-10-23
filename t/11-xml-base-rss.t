# $Id: $

use strict;
#use Test::More tests => 3;
use Test::More skip_all => "xml:base support not available in XML::RSS yet";
use XML::Feed;


my $feed    = XML::Feed->parse('t/samples/base_rss.xml');
my ($entry) = $feed->entries;
my $content = $entry->content;
is($feed->base,    "http://example.org/",                     "Got feed base");
is($entry->base,   "http://example.org/archives/",            "Got entry base");
is($content->base, "http://example.org/archives/000001.html", "Got content base");
