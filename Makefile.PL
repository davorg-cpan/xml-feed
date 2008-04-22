# $Id: Makefile.PL,v 1.2 2004/10/04 03:38:11 btrott Exp $

use inc::Module::Install;

name('XML-Feed');
abstract('XML Syndication Feed Support');
author('Benjamin Trott <cpan@stupidfool.org>');
version_from('lib/XML/Feed.pm');
license('perl');
no_index(directory => 't');
sign(1);

include('ExtUtils::AutoInstall');

requires('Class::ErrorHandler');
requires('Feed::Find');
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
