use ExtUtils::MakeMaker;

require 5.005;

WriteMakefile
  ( NAME		=> 'MIME::Types'
  , VERSION_FROM	=> 'lib/MIME/Types.pm'
  , PREREQ_PM		=> {}
  , AUTHOR              => 'Mark Overmeer'
  , ABSTRACT            => 'Definition of MIME types'
  );
