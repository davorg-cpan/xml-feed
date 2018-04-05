#!perl

use strict;
use warnings;
use Test::More tests => 3;
use XML::Feed;

ok (my $feed  = XML::Feed->parse('t/samples/rss10-odd-date.xml'),  "Parsed file");
ok (my ($entry) = $feed->entries,                                  "Got entry");
is ($entry->issued . '',"2009-05-29T20:17:07",                     "Got correct issued date");

