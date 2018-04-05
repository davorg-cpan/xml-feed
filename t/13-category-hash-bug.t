use strict;
use warnings;
use Test::More;

eval { require XML::RSS::LibXML };
plan skip_all => "XML::RSS::LibXML is required." if $@;

plan tests => 20;

use XML::Feed;

for my $parser (qw( XML::RSS XML::RSS::LibXML )) {
    $XML::Feed::Format::RSS::PREFERRED_PARSER = $parser;

    my $f = XML::Feed->parse("t/samples/category-bug.xml");
    for my $e ($f->entries) {
        eval { $e->category };
        ok !$@, $@;
    }
}
