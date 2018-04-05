use strict;
use warnings;
use Test::More;

use XML::Feed;

my @formats = qw/rss20 atom/;

plan tests => 2*@formats;

for my $format (@formats) {
  ok (my $feed = XML::Feed->parse("t/samples/$format.xml"), "Parsed $format");
  my ($entry) = $feed->entries;
  my @enclosure = $entry->enclosure;
  is(@enclosure, 0);
}
