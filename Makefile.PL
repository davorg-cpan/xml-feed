# $Id: Makefile.PL 1869 2005-08-10 00:02:25Z btrott $

use inc::Module::Install;

name('XML-Feed');
abstract('XML Syndication Feed Support');
author('Six Apart <cpan@sixapart.com>');
version_from('lib/XML/Feed.pm');
license('perl');
no_index(directory => 't');
sign(1);

include('ExtUtils::AutoInstall');

requires('Class::ErrorHandler');
requires('Feed::Find');
requires('URI::Fetch');
requires('XML::RSS' => 1.01);
requires('XML::Atom' => 0.08);
requires('LWP');
requires('HTML::Parser');
requires('URI');
requires('DateTime');
requires('DateTime::Format::Mail');
requires('DateTime::Format::W3CDTF');
requires('List::Util');

auto_include();
auto_install();

&WriteAll;
