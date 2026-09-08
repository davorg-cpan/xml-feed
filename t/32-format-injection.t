use strict;
use warnings;
use Test::More tests => 11;

use XML::Feed;
use XML::Feed::Entry;

# %formatters should be populated with the known, safe format names.
ok exists $XML::Feed::formatters{Atom}, 'Atom is a known formatter';
ok exists $XML::Feed::formatters{RSS},  'RSS is a known formatter';

my $marker = '/tmp/xml-feed-format-injection-test';
unlink $marker;

my $malicious = qq{Atom; system('touch $marker')};

eval {
    XML::Feed->new($malicious);
};
like $@, qr{Unsupported format \Q$malicious\E:}, 'XML::Feed->new rejects an unrecognised format';
ok !-e $marker, 'XML::Feed->new did not execute injected code';

eval {
    XML::Feed::Entry->new($malicious);
};
like $@, qr{Unsupported format \Q$malicious\E:}, 'XML::Feed::Entry->new rejects an unrecognised format';
ok !-e $marker, 'XML::Feed::Entry->new did not execute injected code';

{
    my $result = XML::Feed->parse(\<<'XML', $malicious);
<?xml version="1.0"?>
<rss version="2.0"><channel><title>Test</title></channel></rss>
XML
    ok !defined($result), 'XML::Feed->parse rejects an unrecognised format';
    like( XML::Feed->errstr, qr{Unsupported format \Q$malicious\E:}, 'XML::Feed->parse error message' );
    ok !-e $marker, 'XML::Feed->parse did not execute injected code';
}

unlink $marker;

eval {
    XML::Feed->new('Nofeed;semicolon');
};
like $@, qr{Unsupported format Nofeed;semicolon:}, 'XML::Feed->new rejects format names with a semicolon';

eval {
    XML::Feed::Entry->new('Nofeed;semicolon');
};
like $@, qr{Unsupported format Nofeed;semicolon:}, 'XML::Feed::Entry->new rejects format names with a semicolon';
