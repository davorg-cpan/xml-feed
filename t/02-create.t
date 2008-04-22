# $Id$

use strict;
use Test::More tests => 69;
use XML::Feed;
use XML::Feed::Entry;
use XML::Feed::Content;
use DateTime;

for my $format (qw( Atom RSS )) {
    my $feed = XML::Feed->new($format);
    isa_ok($feed, 'XML::Feed::' . $format);
    like($feed->format, qr/^$format/, 'Format is correct');
    $feed->title('My Feed');
    is($feed->title, 'My Feed', 'feed title is correct');
    $feed->link('http://www.example.com/');
    is($feed->link, 'http://www.example.com/', 'feed link is correct');
    $feed->description('Wow!');
    is($feed->description, 'Wow!', 'feed description is correct');
    is($feed->tagline, 'Wow!', 'tagline works as alias');
    $feed->tagline('Again');
    is($feed->tagline, 'Again', 'setting via tagline works');
    $feed->language('en_US');
    is($feed->language, 'en_US', 'feed language is correct');
    $feed->author('Ben');
    is($feed->author, 'Ben', 'feed author is correct');
    $feed->copyright('Copyright 2005 Me');
    is($feed->copyright, 'Copyright 2005 Me', 'feed copyright is correct');
    my $now = DateTime->now;
    $feed->modified($now);
    isa_ok($feed->modified, 'DateTime', 'modified returns a DateTime');
    is($feed->modified->iso8601, $now->iso8601, 'feed modified is correct');
    $feed->generator('Movable Type');
    is($feed->generator, 'Movable Type', 'feed generator is correct');
    ok($feed->as_xml, 'as_xml returns something');

    my $entry = XML::Feed::Entry->new($format);
    isa_ok($entry, 'XML::Feed::Entry::' . $format);
    $entry->title('Foo Bar');
    is($entry->title, 'Foo Bar', 'entry title is correct');
    $entry->link('http://www.example.com/foo/bar.html');
    is($entry->link, 'http://www.example.com/foo/bar.html', 'entry link is correct');
    $entry->summary('This is a summary.');
    isa_ok($entry->summary, 'XML::Feed::Content');
    is($entry->summary->body, 'This is a summary.', 'entry summary is correct');
    $entry->content('This is the content.');
    isa_ok($entry->content, 'XML::Feed::Content');
    is($entry->content->type, 'text/html', 'entry content type is correct');
    is($entry->content->body, 'This is the content.', 'entry content body is correct');
    $entry->content(XML::Feed::Content->new({
            body => 'This is the content (again).',
            type => 'text/plain',
    }));
    isa_ok($entry->content, 'XML::Feed::Content');
    is($entry->content->body, 'This is the content (again).', 'setting with XML::Feed::Content works');
    $entry->category('Television');
    is($entry->category, 'Television', 'entry category is correct');
    $entry->author('Foo Baz');
    is($entry->author, 'Foo Baz', 'entry author is correct');
    $entry->id('foo:bar-15132');
    is($entry->id, 'foo:bar-15132', 'entry id is correct');
    my $dt = DateTime->now;
    $entry->issued($dt);
    isa_ok($entry->issued, 'DateTime');
    is($entry->issued->iso8601, $dt->iso8601, 'entry issued is correct');
    $entry->modified($dt);
    isa_ok($entry->modified, 'DateTime');
    is($entry->modified->iso8601, $dt->iso8601, 'entry modified is correct');

    $feed->add_entry($entry);
    my @e = $feed->entries;
    is(scalar @e, 1, 'One post in the feed');
    is($e[0]->title, 'Foo Bar', 'Correct post');
    is($e[0]->content->body, 'This is the content (again).', 'content is still correct');

    if ($format eq 'Atom') {
        like $feed->as_xml, qr/This is the content/;
    }
}
