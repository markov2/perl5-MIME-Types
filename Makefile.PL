use ExtUtils::MakeMaker;

require 5.006;

my $version  = '2.15';   # scanned by bin/collect_types !

WriteMakefile
  ( NAME      => 'MIME::Types'
  , VERSION   => $version
  , PREREQ_PM =>
    { Test::More     => 0.47
    , File::Spec     => 0
    , File::Basename => 0
    , List::Util     => 0
    }
  , AUTHOR    => 'Mark Overmeer'
  , ABSTRACT  => 'Definition of MIME types'
  , LICENSE   => 'perl'
  );

### used by oodist during production of distribution
sub MY::postamble { <<'__POSTAMBLE' }

# for DIST
RAWDIR          = ../public_html/mime-types/raw
DISTDIR         = ../public_html/mime-types/source
LICENSE         = perl

# for POD
FIRST_YEAR      = 1999
EMAIL           = markov@cpan.org
WEBSITE         = http://perl.overmeer.net/CPAN/

# for HTML
HTML_OUTPUT     = ../public_html/mime-types/html
HTML_DOCROOT    = /mime-types/html
HTML_PACKAGE    = ../public_html/mime-types/htmlpkg

__POSTAMBLE
