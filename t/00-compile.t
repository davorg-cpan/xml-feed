# $Id: 00-compile.t 922 2004-05-29 18:19:50Z btrott $

my $loaded;
BEGIN { print "1..1\n" }
use XML::Feed;
use XML::Feed::Entry;
use XML::Feed::RSS;
use XML::Feed::Atom;
$loaded++;
print "ok 1\n";
END { print "not ok 1\n" unless $loaded }
