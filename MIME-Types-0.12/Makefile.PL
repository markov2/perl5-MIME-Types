use ExtUtils::MakeMaker;

WriteMakefile
  ( NAME		=> 'MIME::Types'
  , VERSION_FROM	=> 'MIME/Types.pm'
  , DIR                 => [ 'MIME' ]
  , PREREQ_PM		=> {}
  , AUTHOR              => 'Mark Overmeer'
  , ABSTRACT            => 'Definition of MIME types'
  );
