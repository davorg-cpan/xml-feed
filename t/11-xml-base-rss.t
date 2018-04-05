use strict;
use warnings;
use Test::More;
use XML::Feed;
use XML::RSS;

plan tests => 13;

my $feed    = XML::Feed->parse('t/samples/base_rss.xml');

my ($entry) = $feed->entries;
my $content = $entry->content;
is($feed->base,    "http://example.org/",                         "Got feed base");
is($entry->base,   "http://example.org/archives/",                "Got entry base");
is($content->base, "http://example.org/archives/000001.html",     "Got content base");

my $xml = $feed->as_xml;
my $new;
ok($new =  XML::Feed->parse(\$xml),                               "Parsed old feed");
my ($new_entry)  = $new->entries;
my $new_content  = $entry->content;
is($new->base,         "http://example.org/",                     "Got feed base");
is($new_entry->base,   "http://example.org/archives/",            "Got entry base");
is($new_content->base, "http://example.org/archives/000001.html", "Got content base");


ok($feed->base("http://foo.com/"),                                "Set feed base");
ok($entry->base("http://foo.com/archives/"),                      "Set entry base");
ok($content->base("http://foo.com/archives/000001.html"),         "Set content base");

is($feed->base,    "http://foo.com/",                             "Got feed base");
is($entry->base,   "http://foo.com/archives/",                    "Got entry base");
is($content->base, "http://foo.com/archives/000001.html",         "Got content base");


