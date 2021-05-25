# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.63] - 2021-05-25

### Fixed

* Fixed a bug with non-UTC time zones (thanks @nanto)

## [0.62] - 2021-05-24

### Fixed

* Fixed a broken constructor call (thanks @bbkr)
* Reduced some code complexity

### Added

* Added an explicit "use" statement

## [0.61] - 2021-01-28

### Fixed

* Reformated Build.PL

## [0.60] - 2021-01-14

### Added

* CI improvements
* Started a real ChangeLog

## [0.59] - 2019-02-06

## [0.58] - 2019-02-05

## [0.57] - 2019-02-04

## [0.56] - 2019-02-04

## [0.55] - 2018-10-11

## [0.54] - 2018-10-03

## [0.53] - 2015-12-14

## [0.52] - 2013-03-01

## [0.51] - 2013-01-04

## [0.50] - 2012-07-10

## [0.49] - 2012-04-06

## [0.48] - 2012-03-12

## [0.47] - 2012-03-10

## [0.46] - 2011-09-03
    - Method 'enclosure' doesn't work in feed without enclosures
      https://rt.cpan.org/Ticket/Display.html?id=66685
    - Documentation re PREFERRED_PARSER is wrong
      https://rt.cpan.org/Ticket/Display.html?id=62129
    - Add support for <guid isPermaLink> in RSS 2.0 feeds
      https://rt.cpan.org/Ticket/Display.html?id=67349
 
## [0.45] - 2011-08-09
    - Another go at fixing bug 44899
      (Dave Cross & Shlomi Fish)
 
## [0.44] - 2011-07-13
    - Fix problem with HTML escaping in conversion
      https://rt.cpan.org/Public/Bug/Display.html?id=44899
      (Dave Cross & Shlomi Fish)
 
## [0.43] - 2009-05-07
    - Add optional multi enclosure support
    - Fix buglet with odd date terms
      https://rt.cpan.org/Ticket/Display.html?id=46494
      (Joey Hess)

## [0.42] - 2009-04-03
    - Fix conversion of multi value fields
      http://rt.cpan.org/Ticket/Display.html?id=41794 
      (Mario Domgoergen)
 
    - Fixed a bug where $e->category fails when XML::RSS::LibXML is preferred.
      (Tatsuhiko Miyagawa)
    - Added support for enclosures
 
## [0.41] - 2008-12-10
    - Add handling for multiple categories/tags, including
      patch from Shlomi Fish (SHLOMIF)
      http://rt.cpan.org/Ticket/Display.html?id=41396
    - Force v1.40 of XML::RSS to get proper multiple category support
 
## [0.40] - 2008-11-24
    - Force v1.37 of XML::RSS to get proper xml:base support
    - Force v0.32 of XML::Atom to fix 
      http://rt.cpan.org/Ticket/Display.html?id=40766
      (Thanks to David Brownlee for the help in fixing)
    - Add support for format() in Entry
 
## [0.3] - 2008-11-04
    - Allow more flexible identification of Formats
      https://rt.cpan.org/Ticket/Display.html?id=14725
      (Brian Cassidy BRICAS)
   
## [0.23] - 2008-10-24
    - Fix mixing and matching of RSS and Atom
      http://rt.cpan.org/Ticket/Display.html?id=21335
      (Shlomi Fish SHLOMIF)
    - Note that multiple categories was fixed at some point
      http://rt.cpan.org/Ticket/Display.html?id=30234
      (mattn)
    - Work with xml:base (depending on version of XML::RSS)
      http://rt.cpan.org/Ticket/Display.html?id=21135
      http://bugs.debian.org/381359
      (Gregor Herrmann and Joey Hess)
 
## [0.22] - 2008-10-22
    - Correct namespace for terms in RSS
      http://rt.cpan.org/Ticket/Display.html?id=25393
      (Kent Cowgill KCOWGILL)
    - Up the minimum requirement for XML::RSS to 1.31
      http://rt.cpan.org/Ticket/Display.html?id=23588
      (Andreas König ANDK)    
    - Created test for
      http://rt.cpan.org/Ticket/Display.html?id=18810
      (Ryan Tate)
    - Allow creation of a self link
      http://rt.cpan.org/Ticket/Display.html?id=39924
      (Shlomi Fish SHLOMIF)
    - Add support for GEORSS
      http://rt.cpan.org/Ticket/Display.html?id=39924
      (Scott Gifford GIFF)
    - Fix fetching through proxies
      http://rt.cpan.org/Ticket/Display.html?id=36233
      (Trevor Vallender)
 
## [0.21] - 2008-10-15
    - Remove the inc directory because it's not needed anymore
 
## [0.20] - 2008-10-15
    - Allow specification of the parsing format. Fixes bugs
      http://rt.cpan.org/Public/Bug/Display.html?id=35580 and
      http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=477394
      (Gregor Herrmann and Martin F Krafft)
    - Allow pass through of initialisation options
      http://rt.cpan.org/Public/Bug/Display.html?id=24729
      (Christopher H. Laco CLACO)
    - Force working version XML::Atom 
      http://rt.cpan.org/Public/Bug/Display.html?id=22548
      http://rt.cpan.org/Public/Bug/Display.html?id=19920
    - Allow extra Atom accessors
      http://rt.cpan.org/Public/Bug/Display.html?id=33881
      (Paul Mison PMISON)
    - Prevent empty content
      http://rt.cpan.org/Public/Bug/Display.html?id=29684
      (Dave Rolsky DROLSKY)
    - Cope with "updated" and "published" elements
      http://rt.cpan.org/Public/Bug/Display.html?id=20763
      http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=380498
      (Gregor Herrmann and Joey Hess)
    - Switch to Module::Build
      http://rt.cpan.org/Public/Bug/Display.html?id=38283
      http://rt.cpan.org/Public/Bug/Display.html?id=20575
      http://rt.cpan.org/Public/Bug/Display.html?id=21300
   
## [0.12] - 2006-08-13
    - Generate Atom 1.0 feeds by default. Thanks to Tatsuhiko Miyagawa for
      the patch.
 
## [0.11] - 2006-08-07
    - Fixed a bug in XML::Feed::Atom where entry->link and feed->link didn't
      return the proper link element if the "rel" attribute wasn't defined for
      a <link /> tag. Thanks to Tatsuhiko Miyagawa for the patch.
 
## [0.10] - 2006-07-17
    - Oops, an Atom test in 01-parse.t was previously succeeding only because
      of a bug in XML::Atom. Now that that bug is fixed, this one is now
      fixed, too.
 
## [0.09] - 2006-07-10
    - Fixed date format errors with XML::Feed::RSS. Thanks to Tatsuhiko
      Miyagawa for the patch.
    - Use add_module to properly add namespaces to the RSS document. Thanks
      to Tatsuhiko Miyagawa for the patch.
 
## [0.08] - 2006-03-03
    - $feed->author wasn't being converted properly by Feed->convert. Thanks
      to Tatsuhiko Miyagawa for the patch.
    - Added eval around Entry->issued calls, to properly catch invalid
      date formats, and just return undef, rather than dying. Thanks to
      Tatsuhiko Miyagawa for the spot.
    - Fixed issued/modified format issue with dates in timezones other than
      UTC. Thanks to Tatsuhiko Miyagawa for the patch.
 
## [0.07] - 2005-08-11
    - Added XML::Feed::splice method, to make feed splicing easier.
    - Fixed some unitialized value warnings.
 
## [0.06] - 2005-08-09
    - Added Feed->convert and Entry->convert methods to allow conversion
      between formats.
    - Added ability to create new Feed and Entry objects, add entries, etc.
    - Added $PREFERRED_PARSER variable to allow usage of compatible
      RSS parsers, like XML::RSS::LibXML. Thanks to Tatsuhiko Miyagawa
      for the patch.
 
## [0.05] - 2005-01-01
    - Call URI::Fetch::URI_GONE() instead of URI::Fetch::FEED_GONE(). Thanks
      to Richard Clamp for the patch.
 
## [0.04] - 2004-12-31
    - Use "loose" parsing in DateTime::Format::Mail so that we don't die
      on invalid RFC-822 dates.
    - XML::Feed::Entry->link on RSS feeds will now use a <guid> element
      if a <link> element isn't found.
    - Switched to using URI::Fetch when fetching feeds. Since we're not
      storing or caching feeds currently, this basically just buys us
      GZIP support, but that's something.
 
## [0.03] - 2004-10-09
    - Fixed bug with feed format detection: properly detect format even in
      feeds with <!DOCTYPE> at the top. (Thanks to Alberto Quario for the
      note.)
    - Use Class::ErrorHandler instead of XML::Feed::ErrorHandler.
    - Moved auto-discovery code into Feed::Find. XML::Feed->find_feeds is
      now just a wrapper around that module.
 
## [0.02] - 2004-07-29
    - Changed behavior of Entry->summary to prevent it from returning the
      full contents of the entry. Now, in an RSS feed, summary only returns
      a value if there is both a <description> element *and* one of the
      other elements typically used for the full content.
    - Changed content model for Entry->content and Entry->summary.
      They now return an XML::Feed::Content object, which knows about both
      the actual content and the MIME type of the content.
    - Improved feed format detection by first tag in feed.
 
## [0.01] - 2004-06-01
    - Initial distribution.
