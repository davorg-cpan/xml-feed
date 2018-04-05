use strict;
use warnings;
use XML::Feed;

use Test::More;
plan tests => 7;

my $feed = XML::Feed->parse("t/samples/atom-full.xml");
is $feed->title, 'Content Considered Harmful Atom Feed';
is $feed->link, 'http://blog.jrock.us/', "link without rel";

my $e = ($feed->entries)[0];
ok $e->link, 'entry link without rel';
is "".$e->category, "Catalyst", "atom:category support";
is "".$e->modified, "2006-08-09T19:07:58", "atom:updated";
is $e->content->type, 'text/html';
like $e->content->body, qr/^<div class="pod">/;



