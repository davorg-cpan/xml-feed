use strict;
use warnings;
use Test::More tests => 8;

use XML::Feed;
use XML::Feed::Entry;

eval {
	XML::Feed::Entry->new('Nofeed');
};
like $@, qr{Unsupported format Nofeed:}, 'Unsupported format';

{
	my $rss = XML::Feed::Entry->new('RSS');
	isa_ok $rss, 'XML::Feed::Entry::Format::RSS';

	my $atom = XML::Feed::Entry->new('Atom');
	isa_ok $atom, 'XML::Feed::Entry::Format::Atom';

	my $default = XML::Feed::Entry->new();
	isa_ok $default, 'XML::Feed::Entry::Format::Atom';
}


eval {
	XML::Feed->new('Nofeed');
};
like $@, qr{Unsupported format Nofeed:}, 'Unsupported format';

{
	my $rss = XML::Feed->new('RSS');
	isa_ok $rss, 'XML::Feed::Format::RSS';

	my $atom = XML::Feed->new('Atom');
	isa_ok $atom, 'XML::Feed::Format::Atom';

	my $default = XML::Feed->new();
	isa_ok $default, 'XML::Feed::Format::Atom';
}


