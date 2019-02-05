#!perl

use strict;
use warnings;
use FindBin '$Bin';

use vars qw($type $field);
$type  = "rss";
$field = "subjects";
require "$Bin/12-multi-categories.base";
