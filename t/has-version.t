#!perl

use strict;
use warnings;
use Test::More;
eval 'use Test::HasVersion 0.012';
plan skip_all =>
     'Test::HasVersion required for testing for version numbers' if $@;
all_pm_version_ok();

