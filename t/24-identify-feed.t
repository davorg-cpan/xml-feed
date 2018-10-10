use strict;
use warnings;
use Test::More;
use XML::Feed;
use URI;

my %feeds = (
    't/samples/atom.xml' => 'Atom',
    't/samples/rss10.xml' => 'RSS',
    't/samples/rss20.xml' => 'RSS',
);
plan tests => scalar keys %feeds;

for my $file (keys %feeds) {
    my $feed = XML::Feed->parse($file);
    my $xml  = $feed->as_xml;
    my $format = XML::Feed->identify_format(\$xml);
    is($format, $feeds{$file});
}
