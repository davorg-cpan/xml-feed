# $Id: Makefile.PL 1925 2006-03-03 17:37:50Z btrott $

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
requires('DateTime');
requires('DateTime::Format::Mail');
requires('DateTime::Format::W3CDTF');
requires('List::Util');
build_requires('LWP');
build_requires('HTML::TokeParser');

auto_include();
auto_install();

&WriteAll;
