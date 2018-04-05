use strict;
use warnings;

use Test::More 'no_plan';

use XML::Feed;

my $rss = XML::Feed->parse('t/samples/rss10-double.xml');
isa_ok($rss, 'XML::Feed::Format::RSS');
my $rss_entry = ($rss->entries)[0];
isa_ok($rss_entry, 'XML::Feed::Entry::Format::RSS');
my $rss_content = $rss_entry->content;
isa_ok($rss_content, 'XML::Feed::Content');
is($rss_content->type, 'text/html', 'Correct content type');
like($rss_content->body, qr(<|&lt;), 'Contains HTML tags');

my $atom = $rss->convert('Atom');
isa_ok($atom, 'XML::Feed::Format::Atom');
my $atom_entry = ($atom->entries)[0];
isa_ok($atom_entry, 'XML::Feed::Entry::Format::Atom');
my $atom_content = $atom_entry->content;
isa_ok($atom_content, 'XML::Feed::Content');
is($atom_content->type, 'text/html', 'Correct content type');
like($atom_content->body, qr(<|&lt;), 'Contains HTML tags');
