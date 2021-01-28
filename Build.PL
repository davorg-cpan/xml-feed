use Module::Build;

my $build = Module::Build->new( module_name   => "XML::Feed",
  dist_abstract => "XML Syndication Feed Support",
  dist_author   => 'Six Apart',
  license       => 'perl',
  script_files  => [ ],
  requires      => {
    'Class::ErrorHandler'        => 0,
    'DateTime'                   => 0,
    'DateTime::Format::Flexible' => 0,
    'DateTime::Format::ISO8601'  => 0,
    'DateTime::Format::Mail'     => 0,
    'DateTime::Format::Natural'  => 0,
    'DateTime::Format::W3CDTF'   => 0,
    'Feed::Find'                 => 0,
    'HTML::Entities'             => 0,
    'HTML::TokeParser'           => 0,
    'List::Util'                 => 0,
    'LWP::UserAgent'             => 0,
    'Module::Pluggable'          => 0,
    'URI::Fetch'                 => 0,
    'XML::Atom'                  => '0.38',
    'XML::LibXML'                => '1.66',
    'XML::RSS'                   => '1.47',
    'Test::More'                 => 0,
    'Scalar::Util'               => 0,
    'perl'                       => '5.10.0',
  },
  build_requires => {
    'URI'                        => 0,
    'XML::XPath'                 => 0,
  },
  create_makefile_pl => 'traditional',
  meta_merge => {
    'meta-spec' => { version => 2 },
    resources => {
      bugtracker => {
        web => 'https://github.com/davorg/xml-feed/issues',
      },
      repository => {
        url  => 'https://github.com/davorg/xml-feed.git',
        web  => 'https://github.com/davorg/xml-feed',
        type => 'git',
      }
    },
    x_contributors => [
      'Dave Cross <davecross@cpan.org>',
      'Jakob Voss <voss@gbv.de>',
      'Tatsuhiko Miyagawa <miyagawa@bulknews.net>',
      'Simon Wistow <simon@thegestalt.org>',
      'Gabor Szabo <szabgab@cpan.org>',
      'Minty Walker <mintywalker@gmail.com>',
      'Karen Etheridge <ether@cpan.org>',
      'Gerard Ribugent Navarro <ribugent@cpan.org>',
      'Matthew D. Miller <matthew.miller@okbu.edu>',
    ],
  },
);

$build->create_build_script;


