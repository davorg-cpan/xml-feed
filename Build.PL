use Module::Build;

my $build = Module::Build
  ->new( module_name   => "XML::Feed",
         dist_abstract => "XML Syndication Feed Support",
         dist_author   => 'Six Apart',
         license       => 'perl',
         script_files  => [ ],
         requires      => {
                          'Class::ErrorHandler'        => 0,
                          'DateTime'                   => 0,
                          'DateTime::Format::Mail'     => 0,
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
                        },
         build_requires => {
                          'URI'                        => 0,
                        },
         create_makefile_pl => 'traditional',
         meta_merge =>
         {
             resources =>
             {
                 repository => "https://github.com/davorg/xml-feed",
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
             ],
         },
       );

$build->create_build_script;


