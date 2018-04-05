#!perl

use strict;
use warnings;
use Test::More;
use XML::Feed;
use XML::Feed::Enclosure;

my @formats = qw(atom rss20);
plan tests => scalar(@formats)*22;

foreach my $format (@formats) {
    ok (my $feed      = XML::Feed->parse("t/samples/$format-enclosure.xml"), "Parsed $format");
    my ($entry)       = $feed->entries;
    ok (my $enclosure = $entry->enclosure,                                   "Got enclosure");
    ok ($enclosure->isa("XML::Feed::Enclosure"),                             "Object isa XML::Feed::Enclosure");
    is ($enclosure->type,   "audio/mpeg",                                    "Got the enclosure mime type");
    is ($enclosure->length, "2478719",                                       "Got enclosure length");
    is ($enclosure->url,    "http://example.com/sample_podcast.mp3",         "Got enclosure url");

    ok (my $tmp       = XML::Feed::Enclosure->new({ type => "image/jpeg" }), "Created a new enclosure");
    is ($tmp->type,         "image/jpeg",                                    "Got type back");
    ok ($tmp->url("http://example.com/sample_image.jpg"),                    "Set url");
    ok ($tmp->length("1337"),                                                "Set length");
    ok ($entry->enclosure($tmp),                                             "Set the enclosure");

    ok ($enclosure    = $entry->enclosure,                                   "Got enclosure again");
    ok ($enclosure->isa("XML::Feed::Enclosure"),                             "Object still isa XML::Feed::Enclosure");
    is ($enclosure->type,   "image/jpeg",                                    "Got the enclosure mime type");
    is ($enclosure->length, "1337",                                          "Got enclosure length again");
    is ($enclosure->url,    "http://example.com/sample_image.jpg",           "Got enclosure url again");

    my $xml = $feed->as_xml;
    ok ($feed         = XML::Feed->parse(\$xml),                             "Parsed xml again");
    ok ($enclosure    = $entry->enclosure,                                   "Got enclosure again");
    ok ($enclosure->isa("XML::Feed::Enclosure"),                             "Object still isa XML::Feed::Enclosure");
    is ($enclosure->type,   "image/jpeg",                                    "Got the enclosure mime type");
    is ($enclosure->length, "1337",                                          "Got enclosure length again");
    is ($enclosure->url,    "http://example.com/sample_image.jpg",           "Got enclosure url again");


}
