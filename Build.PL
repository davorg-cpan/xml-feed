# $Id$
use Module::Build;

my $build = Module::Build
  ->new( module_name   => "XML::Feed",
         dist_abstract => "XML Syndication Feed Support", 
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
                          'XML::Atom'                  => '0.37',
                          'XML::LibXML'                => '1.66',
                          'XML::RSS'                   => '1.47',
                          'Test::More'                 => 0,
                        },
         create_makefile_pl => 'traditional',
       );

$build->create_build_script;


