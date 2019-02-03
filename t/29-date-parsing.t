
use strict;
use warnings;
use Test::More;
use XML::Feed;

my ($rss, $atom) = split /\n---\n/, join '', <DATA>;
my $now = DateTime->now;
my $y = $now->year;
my $m = $now->month;
my $d = $now->day;

for my $spec (
    [ '2010-05-17T06:58:50-08:00',       '2010:5:17:6:58:50:-0800'     ],
    [ '2009-05-29T20:17:07+01:00',       '2009:5:29:20:17:7:+0100'     ],
    [ '2010-05-20T12:14:57-05:00',       '2010:5:20:12:14:57:-0500'    ],
    [ 'May 29, 2004 23:39:25',           '2004:5:29:23:39:25:floating' ],
    [ '4/13/2010 6:58:50 PM',            '2010:4:13:18:58:50:floating' ],
    [ 'May 19, 2010',                    '2010:5:19:0:0:0:floating'    ],
    [ 'feb 28 5pm',                      "$y:2:28:17:0:0:floating"     ],
    [ 'may 21st',                        "$y:5:21:0:0:0:floating"      ],
    [ 'march 2nd 2009',                  '2009:3:2:0:0:0:floating'     ],
    [ 'October 2006',                    '2006:10:1:0:0:0:floating'    ],
    [ 'jan 3 2010',                      '2010:1:3:0:0:0:floating'     ],
    [ '3 jan 2010',                      '2010:1:3:0:0:0:floating'     ],
    [ '27/5/1979',                       '1979:5:27:0:0:0:floating'    ],
    [ '4:00',                            "$y:$m:$d:4:0:0:floating"     ],
    [ '20:00',                           "$y:$m:$d:20:0:0:floating"    ],
    [ '3:20:00',                         "$y:$m:$d:3:20:0:floating"    ],
    [ '2009-09-08T00:25:30Z',            '2009:9:8:0:25:30:UTC'        ],
    [ 'Fri, 21 May 2010 12:00:37 +0000', '2010:5:21:12:0:37:UTC'       ],
    [ 'Thu, 20 May 2010 13:55:00 GMT',   '2010:5:20:13:55:0:GMT'       ],
    [ 'Wed, 19 May 2010 14:56:00 -0400', '2010:5:19:14:56:0:-0400'     ],
    [ 'Fri, 21 May 2010 09:30:25 PDT',   '2010:5:21:9:30:25:America/Los_Angeles' ],
    [ 'Wed, 05 May 2010 17:29:27 +0000', '2010:5:5:17:29:27:+0000'     ],
    [ '2010-05-21',                      '2010:5:21:0:0:0:floating'    ],
) {
    my $date = $spec->[0];
    my %params;
    @params{qw(year month day hour minute second time_zone)} = split /:/ => $spec->[1];
    my $dt   = DateTime->new(%params);

    # Try RSS with PubDate.
    ok my $feed = XML::Feed->parse(\sprintf($rss,
        'pubDate',          $date, 'pubDate',
        'pubDate',          $date, 'pubDate',
        'dcterms:modified', $date, 'dcterms:modified'
    )), "Create RSS with PubDate $date";

    is $feed->modified, $dt, 'Feed modified PubDate should be correct';
    my ($entry) = $feed->entries;
    is $entry->issued,   $dt, 'Entry issued PubDate should be correct';
    is $entry->modified, $dt, 'Entry modified date should be correct';

    # Try RSS with dc:date and dcterms:modified.
    ok $feed = XML::Feed->parse(\sprintf($rss,
        'dc:date',          $date, 'dc:date',
        'dc:date',          $date, 'dc:date',
        'dcterms:modified', $date, 'dcterms:modified'
    )), "Create RSS with dc:date $date";

    is $feed->modified, $dt, 'Feed modified dc:date should be correct';
    ($entry) = $feed->entries;
    is $entry->issued,   $dt, 'Entry issued dc:date should be correct';

    # Try RSS with dcterms:date and atom:updated.
    ok $feed = XML::Feed->parse(\sprintf($rss,
        'dc:date',          $date, 'dc:date',
        'dcterms:date',     $date, 'dcterms:date',
        'atom:updated',     $date, 'atom:updated'
    )), "Create RSS with dcterms:date and atom:updated $date";

    ($entry) = $feed->entries;
    is $entry->issued,   $dt, 'Entry issued dcterms:date should be correct';
    is $entry->modified, $dt, 'Entry modified atom:updated should be correct';

    # Try Atom feed.
    ok $feed = XML::Feed->parse(\sprintf($atom,
        'updated', $date, 'updated',
        'published', $date, 'published',
        'updated', $date, 'updated',
    )), "Create Atom with date $date";

    is $feed->modified, $dt, 'Atom feed updated date should be correct';
    ($entry) = $feed->entries;
    is $entry->issued,   $dt, 'Atom entry published date should be correct';
    is $entry->modified, $dt, 'Atom entry updated date should be correct';
}

done_testing;

__DATA__
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
     xmlns:content="http://purl.org/rss/1.0/modules/content/"
     xmlns:wfw="http://wellformedweb.org/CommentAPI/"
     xmlns:dc="http://purl.org/dc/elements/1.1/"
     xmlns:dcterms="http://purl.org/dc/terms/"
     xmlns:atom="http://www.w3.org/2005/Atom"
>
  <channel>
    <title>Simple RSS Feed</title>
    <link>http://example.net</link>
    <%s>%s</%s>
    <item>
      <%s>%s</%s>
      <%s>%s</%s>
    </item>
  </channel>
</rss>
---
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Simple Atom Feed</title>
  <%s>%s</%s>
  <entry>
    <%s>%s</%s>
    <%s>%s</%s>
  </entry>
</feed>
