# $Id: Build.PL 918 2004-05-29 17:29:55Z btrott $
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
                          'HTML::TokeParser'           => 0,
                          'List::Util'                 => 0,
                          'LWP::UserAgent'             => 0,
                          'URI::Fetch'                 => 0,
                          'XML::Atom'                  => 0.23,
                          'XML::LibXML'                => 1.66,
                          'XML::RSS'                   => 1.31,
                          'Test::More'                 => 0,
                        },
         create_makefile_pl => 'traditional',
       );

$build->create_build_script;


