#!perl

use strict;
use warnings;
use Test::More;
use XML::Feed;
use XML::Feed::Enclosure;

$XML::Feed::MULTIPLE_ENCLOSURES=1;

my @formats = qw(atom rss20);
plan tests => scalar(@formats)*38;

foreach my $format (@formats) {
    ok (my $feed      = XML::Feed->parse("t/samples/$format-multi-enclosure.xml"), "Parsed $format");
    my ($entry)       = $feed->entries;
    ok (my @enclosures = $entry->enclosure,                                  "Got enclosure");
    ok ($enclosures[0]->isa("XML::Feed::Enclosure"),                         "Object isa XML::Feed::Enclosure");
    is ($enclosures[0]->type,   "audio/mpeg",                                "Got the enclosure mime type");
    is ($enclosures[0]->length, "2478719",                                   "Got enclosure length");
    is ($enclosures[0]->url,    "http://example.com/sample_podcast.mp3",     "Got enclosure url");
    ok ($enclosures[1]->isa("XML::Feed::Enclosure"),                         "Object isa XML::Feed::Enclosure");
    is ($enclosures[1]->type,   "video/mpeg",                                "Got the enclosure mime type");
    is ($enclosures[1]->length, "8888",                                      "Got enclosure length");
    is ($enclosures[1]->url,    "http://example.com/sample_movie.mpg",       "Got enclosure url");

    ok (my $tmp       = XML::Feed::Enclosure->new({ type => "image/jpeg" }), "Created a new enclosure");
    is ($tmp->type,         "image/jpeg",                                    "Got type back");
    ok ($tmp->url("http://example.com/sample_image.jpg"),                    "Set url");
    ok ($tmp->length("1337"),                                                "Set length");
    ok ($entry->enclosure($tmp),                                             "Set the enclosure");

    ok (@enclosures    = $entry->enclosure,                                  "Got enclosure again");
    ok ($enclosures[-1]->isa("XML::Feed::Enclosure"),                        "Object still isa XML::Feed::Enclosure");
    is ($enclosures[-1]->type,   "image/jpeg",                               "Got the enclosure mime type");
    is ($enclosures[-1]->length, "1337",                                     "Got enclosure length again");
    is ($enclosures[-1]->url,    "http://example.com/sample_image.jpg",      "Got enclosure url again");

    my $xml = $feed->as_xml;
    ok ($feed         = XML::Feed->parse(\$xml),                             "Parsed xml again");
    ok (@enclosures    = $entry->enclosure,                                  "Got enclosure again");
    ok ($enclosures[0]->isa("XML::Feed::Enclosure"),                         "Object isa XML::Feed::Enclosure");
    is ($enclosures[0]->type,   "audio/mpeg",                                "Got the enclosure mime type");
    is ($enclosures[0]->length, "2478719",                                   "Got enclosure length");
    is ($enclosures[0]->url,    "http://example.com/sample_podcast.mp3",     "Got enclosure url");
    ok ($enclosures[1]->isa("XML::Feed::Enclosure"),                         "Object isa XML::Feed::Enclosure");
    is ($enclosures[1]->type,   "video/mpeg",                                "Got the enclosure mime type");
    is ($enclosures[1]->length, "8888",                                      "Got enclosure length");
    is ($enclosures[1]->url,    "http://example.com/sample_movie.mpg",       "Got enclosure url");
    ok ($enclosures[2]->isa("XML::Feed::Enclosure"),                         "Object still isa XML::Feed::Enclosure");
    is ($enclosures[2]->type,   "image/jpeg",                                "Got the enclosure mime type");
    is ($enclosures[2]->length, "1337",                                      "Got enclosure length again");
    is ($enclosures[2]->url,    "http://example.com/sample_image.jpg",       "Got enclosure url again");
    ok ($enclosures[-1]->isa("XML::Feed::Enclosure"),                        "Object still isa XML::Feed::Enclosure");
    is ($enclosures[-1]->type,   "image/jpeg",                               "Got the enclosure mime type");
    is ($enclosures[-1]->length, "1337",                                     "Got enclosure length again");
    is ($enclosures[-1]->url,    "http://example.com/sample_image.jpg",      "Got enclosure url again");


}
