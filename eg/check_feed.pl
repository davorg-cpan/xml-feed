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

my @feed_attrs  = qw[Title Tagline Format Author Link Base
                     Language Copyright Modified Generator];

my @entry_attrs = qw[Link Author Title Category Id Issued Modified
                     Lat Long Format Tags Enclosure Summary Content];

my %use_body_attrs = map { $_ => 1 } qw[Summary Content];

my $feed = XML::Feed->parse( $source ) or die XML::Feed->errstr;

for (@feed_attrs) {
  my $method = lc $_;
  printf "%-11s %s\n", "$_:", ($feed->$method // '');
}

for my $entry ($feed->entries) {
  say '';

  for (@entry_attrs) {
    say get_attribute($entry, $_);
  }
}

sub get_attribute {
  my ($entry, $attr) = @_;

  my $method = lc $attr;
  my $data;
  if ($use_body_attrs{$attr}) {
    $data = $entry->$method->body // '';
  } else {
    $data = $entry->$method // '';
  }

  return sprintf(" * %-11s %s", "$attr:", $data);
}
