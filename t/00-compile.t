# $Id: 00-compile.t 1867 2005-08-09 20:41:15Z btrott $

use strict;
use Test::More tests => 4;

use_ok('XML::Feed');
use_ok('XML::Feed::Entry');
use_ok('XML::Feed::RSS');
use_ok('XML::Feed::Atom');
