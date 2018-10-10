use strict;
use warnings;
use v5.10;

=head1 DESCRIPTION

Given a URL of an Atom or RSS feed or a filename of an already downloaded
feed, this script will try to parse it and print out what it understands
from the feed.

=cut

use XML::Feed;

my $src = shift;

die "Usage: $0 FILE|URL\n" if not $src;
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';

my $source = $src;
if ($src =~ m{^https?://}) {
  $source = URI->new($src);
} else {
  if (not -f $source) {
    die "'$source' does not look like a URL and it does not exist on the file-system either.\n";
  }
}

my @feed_attrs = qw[Title Tagline Format Author Link Base
                    Language Copyright Modified Generator];

my $feed = XML::Feed->parse( $source ) or die XML::Feed->errstr;

for (@feed_attrs) {
  my $method = lc $_;
  printf "%-11s %s\n", "$_:", ($feed->$method // '');
}

for my $entry ($feed->entries) {
	say '';
	say '    Link:      ' . ($entry->link          // '');
	say '    Author:    ' . ($entry->author        // '');
	say '    Title:     ' . ($entry->title         // '');
	say '    Caregory:  ' . ($entry->category      // '');
	say '    Id:        ' . ($entry->id            // '');
	say '    Issued:    ' . ($entry->issued        // ''); # DateTime object
	say '    Modified:  ' . ($entry->modified      // ''); # DateTime object
	say '    Lat:       ' . ($entry->lat           // '');
	say '    Long:      ' . ($entry->long          // '');
	say '    Format:    ' . ($entry->format        // '');
	say '    Tags:      ' . ($entry->tags          // '');
	say '    Enclosure: ' . ($entry->enclosure     // '');
	say '    Summary:   ' . ($entry->summary->body // '');
	say '    Content:   ' . ($entry->content->body // '');
}

