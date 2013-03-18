use strict;
use Test::More tests => 3;
use XML::Feed;
use URI;

my %Feeds = (
    't/samples/atom.xml' => 'Atom',
    't/samples/rss10.xml' => 'RSS',
    't/samples/rss20.xml' => 'RSS',
);

for my $file (keys %Feeds) {
    my $feed = XML::Feed->parse($file);
    my $xml  = $feed->as_xml;
    my $format = XML::Feed->identify_format(\$xml);
    is($format, $Feeds{$file});
}
