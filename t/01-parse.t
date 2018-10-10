use strict;
use warnings;
use Test::More tests => 75;
use XML::Feed;
use URI;

my %feeds = (
    't/samples/atom.xml' => 'Atom',
    't/samples/rss10.xml' => 'RSS 1.0',
    't/samples/rss20.xml' => 'RSS 2.0',
);

## First, test all of the various ways of calling parse.
my $feed;
my $file = 't/samples/atom.xml';
$feed = XML::Feed->parse($file);
isa_ok($feed, 'XML::Feed::Format::Atom');
is($feed->title, 'First Weblog');
open my $fh, '<', $file or die "Can't open $file: $!";
$feed = XML::Feed->parse($fh);
isa_ok($feed, 'XML::Feed::Format::Atom');
is($feed->title, 'First Weblog');
seek $fh, 0, 0;
my $xml = do { local $/; <$fh> };
$feed = XML::Feed->parse(\$xml);
isa_ok($feed, 'XML::Feed::Format::Atom');
is($feed->title, 'First Weblog');
$feed = XML::Feed->parse(URI->new("file:$file"));
isa_ok($feed, 'XML::Feed::Format::Atom');
is($feed->title, 'First Weblog');

## Then try calling all of the unified API methods.
for my $file (sort keys %feeds) {
    $feed = XML::Feed->parse($file) or die XML::Feed->errstr;
    my($subclass) = $feeds{$file} =~ /^(\w+)/;
    isa_ok($feed, 'XML::Feed::Format::' . $subclass);
    is($feed->format, $feeds{$file});
    is($feed->language, 'en-us');
    is($feed->title, 'First Weblog');
    is($feed->link, 'http://localhost/weblog/');
    is($feed->tagline, 'This is a test weblog.');
    is($feed->description, 'This is a test weblog.');
    my $dt = $feed->modified;
    isa_ok($dt, 'DateTime');
    $dt->set_time_zone('UTC');
    is($dt->iso8601, '2004-05-30T07:39:57');
    is($feed->author, 'Melody');

    my @entries = $feed->entries;
    is(scalar @entries, 2);
    my $entry = $entries[0];
    is($entry->title, 'Entry Two');
    is($entry->link, 'http://localhost/weblog/2004/05/entry_two.html');
    $dt = $entry->issued;
    isa_ok($dt, 'DateTime');
    $dt->set_time_zone('UTC');
    is($dt->iso8601, '2004-05-30T07:39:25');
    like($entry->content->body, qr/<p>Hello!<\/p>/);
    is($entry->summary->body, 'Hello!...');
    is(($entry->category)[0], 'Travel');
    is($entry->category, 'Travel');
    is($entry->author, 'Melody');
    ok($entry->id);
}

$feed = XML::Feed->parse('t/samples/rss20-no-summary.xml')
    or die XML::Feed->errstr;
my $entry = ($feed->entries)[0];
ok(!$entry->summary->body);
like($entry->content->body, qr/<p>This is a test.<\/p>/);

$feed = XML::Feed->parse('t/samples/rss10-invalid-date.xml')
    or die XML::Feed->errstr;
$entry = ($feed->entries)[0];
ok(!$entry->issued);   ## Should return undef, but not die.
ok(!$entry->modified); ## Same.
