use strict;
use warnings;

use Test::More;
use XML::Feed;

my $content;
{
    local $/;
    $content = <DATA>;
}

my $feed = XML::Feed->parse( \$content );
my @links = map { $_->link } $feed->entries;

# RT 53661 - GH #45
is_deeply( \@links, ['/earthquakes/recenteqsww/Quakes/us2010rkb8.php'] )
  or diag explain \@links;

done_testing;

__DATA__
<?xml version="1.0"?>
<feed xml:base="http://earthquake.usgs.gov/"
xmlns="http://www.w3.org/2005/Atom"
xmlns:georss="http://www.georss.org/georss">
  <updated>2010-01-13T17:24:37Z</updated>
  <title>USGS M5+ Earthquakes</title>
  <subtitle>Real-time, worldwide earthquake list for the past 7
days</subtitle>
  <link rel="self" href="/earthquakes/catalogs/7day-M5.xml"/>
  <link href="http://earthquake.usgs.gov/earthquakes/"/>
  <author><name>U.S. Geological Survey</name></author>
  <id>http://earthquake.usgs.gov/</id>
  <icon>/favicon.ico</icon>
  <entry><id>urn:earthquake-usgs-gov:us:2010rkb8</id><title>M 5.3,
Tonga</title><updated>2010-01-13T16:21:24Z</updated><link
rel="alternate" type="text/html"
href="/earthquakes/recenteqsww/Quakes/us2010rkb8.php"/><summary
type="html"><![CDATA[<img
src="http://earthquake.usgs.gov/images/globes/-15_-175.jpg"
alt="15.741&#176;S 174.695&#176;W" align="left" hspace="20"
/><p>Wednesday, January 13, 2010 16:21:24 UTC<br>Thursday, January 14,
2010 06:21:24 AM at epicenter</p><p><strong>Depth</strong>: 10.00 km
(6.21 mi)</p>]]></summary><georss:point>-15.7409
-174.6951</georss:point><georss:elev>-10000</georss:elev><category
label="Age" term="Past day"/></entry>
</feed>
