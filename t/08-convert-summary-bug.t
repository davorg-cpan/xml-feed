use strict;
use warnings;
use Test::More tests => 1;
use XML::Feed;
use XML::Feed::Entry;

my $feed = XML::Feed->new();
$feed->title('My Feed');
$feed->link('http://www.example.com/');
$feed->description('Wow!');

my $entry = XML::Feed::Entry->new();
$entry->title('Foo Bar');
$entry->link('http://www.example.com/foo/bar.html');
$entry->content('This is the content, but there is no summary.');
$entry->author('Foo Baz');

$feed->add_entry($entry);


unlike($feed->convert('Atom')->as_xml(), qr{<summary>},
       'no summary tag after converting to Atom');
