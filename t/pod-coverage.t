#!perl

use strict;
use warnings;
use Test::More;
eval 'use Test::Pod::Coverage 1.04';
plan skip_all => 'Test::Pod::Coverage 1.04 required for testing POD coverage' if $@;
my @modules   = grep { !/(RSS|Atom)/ }Test::Pod::Coverage::all_modules();
plan tests => scalar(@modules);
pod_coverage_ok($_, { also_private => [ qr/^init_empty/ ], },) for @modules;

