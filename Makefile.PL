use ExtUtils::MakeMaker;

require 5.005;

WriteMakefile
  ( NAME		=> 'MIME::Types'
  , VERSION_FROM	=> 'lib/MIME/Types.pm'
  , PREREQ_PM		=> { Test::More => 0.47 }
  , AUTHOR              => 'Mark Overmeer'
  , ABSTRACT            => 'Definition of MIME types'
  );
