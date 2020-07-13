=head1 compat::perl7

=head2 Subroutines

=head3 import

Do the clever stuff.

=cut

package compat::perl7;

# use compat::perl7 enables perl 5 code to function in a perl 7-ish way as much as possible compared to the version you are running.
# it also is a hint to both tools and the compiler what the level of compatibility is with future versions of the language.

BEGIN {
    # This code is a proof of concept provided against 5.30. In order for this code to work on other versions of perl
    # we would need to generate it via p7.pm.PL as part of shipping it to CPAN.
    $] >= 5.030 && $] < 5.031 or die("Perl 5.30 is required to use this module.");
}

sub import {

    # use warnings; no warnings qw/experimental/;
    # perl -e'use warnings; no warnings qw/experimental/;  my $w; BEGIN {$w = ${^WARNING_BITS} } print unpack("H*", $w) . "\n"'
    ${^WARNING_BITS} = pack( "H*", "55555555555555555555555515000440050454" );

    # use strict; use utf8;
    # perl  -MData::Dumper -e'my $h; use strict; use utf8; use feature (qw/bitwise current_sub declared_refs evalbytes fc postderef_qq refaliasing say signatures state switch unicode_eval unicode_strings/); BEGIN {  $h = $^H } printf("\$^H = 0x%08X\n", $h); print Dumper \%^H; '
    $^H = 0x1C820FE2;

    %^H = (
        'feature___SUB__'      => 1,
        'feature_bitwise'      => 1,
        'feature_evalbytes'    => 1,
        'feature_fc'           => 1,
        'feature_myref'        => 1,
        'feature_postderef_qq' => 1,
        'feature_refaliasing'  => 1,
        'feature_say'          => 1,
        'feature_signatures'   => 1,
        'feature_state'        => 1,
        'feature_switch'       => 1,
        'feature_unicode'      => 1,
        'feature_unieval'      => 1
    );
}

1;
