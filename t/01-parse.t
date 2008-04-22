# $Id: 01-parse.t,v 1.5 2004/07/29 16:43:33 btrott Exp $

use strict;
use Test;
use XML::Feed;
use URI;

BEGIN { plan tests => 70 }

my %Feeds = (
    't/samples/atom.xml' => 'Atom',
    't/samples/rss10.xml' => 'RSS 1.0',
    't/samples/rss20.xml' => 'RSS 2.0',
);

## First, test all of the various ways of calling parse.
my $feed;
my $file = 't/samples/atom.xml';
ok($feed = XML::Feed->parse($file));
ok($feed->title, 'First Weblog');
open my $fh, $file or die "Can't open $file: $!";
ok($feed = XML::Feed->parse($fh));
ok($feed->title, 'First Weblog');
seek $fh, 0, 0;
my $xml = do { local $/; <$fh> };
ok($feed = XML::Feed->parse(\$xml));
ok($feed->title, 'First Weblog');
ok($feed = XML::Feed->parse(URI->new("file:$file")));
ok($feed->title, 'First Weblog');

## Then try calling all of the unified API methods.
for my $file (sort keys %Feeds) {
    my $feed = XML::Feed->parse($file) or die XML::Feed->errstr;
    ok($feed);
    ok($feed->format, $Feeds{$file});
    ok($feed->language, 'en-us');
    ok($feed->title, 'First Weblog');
    ok($feed->link, 'http://localhost/weblog/');
    ok($feed->tagline, 'This is a test weblog.');
    ok($feed->description, 'This is a test weblog.');
    my $dt = $feed->modified;
    ok(ref($dt), 'DateTime');
    $dt->set_time_zone('UTC');
    ok($dt->iso8601, '2004-05-30T07:39:57');
    ok($feed->author, 'Melody');

    my @entries = $feed->entries;
    ok(scalar @entries, 2);
    my $entry = $entries[0];
    ok($entry->title, 'Entry Two');
    ok($entry->link, 'http://localhost/weblog/2004/05/entry_two.html');
    $dt = $entry->issued;
    ok(ref($dt), 'DateTime');
    $dt->set_time_zone('UTC');
    ok($dt->iso8601, '2004-05-30T07:39:25');
    ok($entry->content->body =~ /<p>Hello!<\/p>/);
    ok($entry->summary->body, 'Hello!...');
    ok($entry->category, 'Travel');
    ok($entry->author, 'Melody');
    ok($entry->id);
}

$feed = XML::Feed->parse('t/samples/rss20-no-summary.xml')
    or die XML::Feed->errstr;
my $entry = ($feed->entries)[0];
ok(!$entry->summary->body);
ok($entry->content->body =~ m!<p>This is a test.</p>!);
