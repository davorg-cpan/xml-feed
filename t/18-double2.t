use strict;
use warnings;

use Test::More tests => 14;

use XML::Feed;
use File::Spec;


{
    my $rss = XML::Feed->parse(
        File::Spec->catfile(File::Spec->curdir(),
            "t", "samples", "rss20-double.xml"
        )
    );

    # TEST
    isa_ok($rss, 'XML::Feed::Format::RSS');
    my $rss_entry = ($rss->entries)[0];

    # TEST
    isa_ok($rss_entry, 'XML::Feed::Entry::Format::RSS');


    my $rss_content = $rss_entry->content;

    # TEST
    isa_ok($rss_content, 'XML::Feed::Content');

    # TEST
    is($rss_content->type, 'text/html', 'Correct content type');

    # TEST
    like($rss_content->body, qr(<|&lt;), 'Contains HTML tags');

    # TEST
    like($rss_content->body,
         qr{\Q<a href="http://search.cpan.org/perldoc?Dancer">Dancer</a>},
         'Contains HTML tags');

    unlike($rss->as_xml, qr{&amp;lt;}, 'No double encoding');

    my $atom = $rss->convert('Atom');

    # TEST
    isa_ok($atom, 'XML::Feed::Format::Atom');

    my $atom_entry = ($atom->entries)[0];

    # TEST
    isa_ok($atom_entry, 'XML::Feed::Entry::Format::Atom');

    my $atom_content = $atom_entry->content;

    # TEST
    isa_ok($atom_content, 'XML::Feed::Content');

    # TEST
    TODO: {
        local $TODO = 'Needs more investigation';
        is($atom_content->type, 'text/html', 'Correct content type');
    }

    # TEST
    like($atom_content->body, qr(<|&lt;), 'Contains HTML tags');

    # TEST
    like($atom_content->body,
        qr{\Q<a href="http://search.cpan.org/perldoc?Dancer">Dancer</a>},
        'Contains HTML tags');

    unlike($atom->as_xml, qr{&amp;lt;}, 'No double encoding');
}

