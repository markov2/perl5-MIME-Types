package MIME::Types;

use strict;
use warnings;

use MIME::Type;

our $VERSION = '0.01';

=head1 NAME

 MIME::Types - Definition of MIME types

=head1 SYNOPSIS

 use MIME::Types;
 my $mimetypes = MIME::Types->new;
 my MIME::Type $plaintext = $mimetype->type('text/plain');
 my MIME::Type $imagegif  = $mimetype->extension('gif');

=head1 DESCRIPTION

MIME types are used in MIME entities, for instance as part of e-mail
and HTTP traffic.  Sometimes real knowledge about a mime-type is need.
This module will supply it.

=cut

#-------------------------------------------

=head1 METHODS

=over 4

=cut

#-------------------------------------------

=item new OPTIONS

Create a new C<MIME::Types> object which manages the data.  In the current
implementation, it does not matter whether you create this object often
within your program, but in the future this may change.

There are no OPTIONS yet.

=cut

my %list;
sub new(@) { (bless {}, shift)->init( {@_} ) }

sub init($)
{   my ($self, $args) = @_;

    unless(keys %list)
    {   while(<MIME::Types::DATA>)
        {   my ($type, $extensions, $encoding) = split;
            my $extent = $extensions ? [ split /\,/, $extensions ] : undef;

            my $simplified = MIME::Type->simplified($type);
            push @{$list{$simplified}}, MIME::Type->new
              ( type       => $type
              , extensions => $extent
              , encoding   => $encoding
              );
        }
    }

    close DATA;
    $self;
}

my %type_index;
sub create_type_index()
{   my $self = shift;
    while(my ($simple, $definitions) = each %list)
    {   foreach my $def (@$definitions)
        {   $type_index{$_} = $def foreach $def->extensions;
        }
    }
    $self;
}

#-------------------------------------------

=item type STRING

Return the C<MIME::Type> which describes the type related to STRING.

=cut

sub type($) { @{$list{MIME::Type->simplified($_[1])}} }

#-------------------------------------------

=item mimeTypeOf FILENAME

Returns the C<MIME::Type> object which belongs to the FILENAME (or simply
its filename extension).  The extension is used, and considered
case-insensitive.

Examples:

 my MIME::Types $types = MIME::Types->new;
 my MIME::Type  $mime = $types->mimeTypeOf('gif');

 my MIME::Type  $mime = $types->mimeTypeOf('jpg');
 print $mime->isBinary;

=cut

sub mimeTypeOf($)
{   my ($self, $name) = @_;
    $self->create_type_index unless keys %type_index;
    $name =~ s/.*\.//;
    $type_index{lc $name};
}

#-------------------------------------------

=back

=head1 SEE ALSO

L<MIME::Type>

=head1 AUTHOR

Mark Overmeer (F<mimetypes@overmeer.net>).
All rights reserved.  This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

=head1 VERSION

This code is alpha version 0.01.

Copyright (c) 2001 Mark Overmeer. All rights reserved.
This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

#-------------------------------------------

__DATA__
application/activemessage
application/andrew-inset	ez
application/applefile
application/atomicmail
application/cu-seeme		csm,cu
application/dca-rft
application/dec-dx
application/excel		xls
application/ghostview		
application/mac-binhex40	hqx				ASCII
application/mac-compactpro	cpt
application/macwriteii
application/msword		doc,dot,wrd
application/news-message-id
application/news-transmission
application/octet-stream	bin,dms,lha,lzh,exe,class	BINARY
application/oda			oda
application/pdf			pdf
application/pgp			pgp				ASCII
application/pgp-signature	pgp				ASCII
application/postscript		ai,eps,ps			ASCII
application/powerpoint		ppt
application/remote-printing
application/rtf			rtf
application/slate
application/wita
application/wordperfect5.1	wp5
application/x-123		wk
application/x-Wingz		wz
application/x-bcpio		bcpio
application/x-cdlink		vcd
application/x-chess-pgn		pgn
application/x-compress		z,Z				BINARY
application/x-cpio		cpio				BINARY
application/x-csh		csh				ASCII
application/x-debian-package	deb
application/x-director		dcr,dir,dxr
application/x-dvi		dvi				BINARY
application/x-gtar		gtar,tgz			BINARY
application/x-gunzip		gz				BINARY
application/x-gzip		gz				BINARY
application/x-hdf		hdf
application/x-httpd-php		phtml,pht,php			ASCII
application/x-javascript	js				ASCII
application/x-koan		skp,skd,skt,skm
application/x-latex		latex				ASCII
application/x-maker		frm,maker,frame,fm,fb,book,fbdoc
application/x-mif		mif
application/x-msdos-program	com,bat				ASCII
application/x-msdos-program	exe				BINARY
application/x-netcdf		nc,cdf
application/x-ns-proxy-autoconfig	pac
application/x-perl		pl,pm				ASCII
application/x-sh		sh				ASCII
application/x-shar		shar				ASCII
application/x-stuffit		sit
application/x-sv4cpio		sv4cpio				BINARY
application/x-sv4crc		sv4crc				BINARY
application/x-tar		tar				ASCII
application/x-tcl		tcl				ASCII
application/x-tex		tex				ASCII
application/x-texinfo		texinfo,texi			ASCII
application/x-troff		t,tr,roff			ASCII
application/x-troff-man		man				ASCII
application/x-troff-me		me
application/x-troff-ms		ms
application/x-ustar		ustar				BINARY
application/x-wais-source	src
application/zip			zip				BINARY
audio/basic			au,snd				BINARY
audio/midi			mid,midi,kar			BINARY
audio/mpeg			mpga,mp2,mp3			BINARY
audio/x-aiff			aif,aifc,aiff			BINARY
audio/x-pn-realaudio		ra,ram				BINARY
audio/x-pn-realaudio-plugin					BINARY
audio/x-realaudio		ra				BINARY
audio/x-wav			wav				BINARY
chemical/x-pdb			pdb,xyz
image/gif			gif				BINARY
image/ief			ief				BINARY
image/jpeg			jpeg,jpg,jpe			BINARY
image/png			png				BINARY
image/tiff			tiff,tif			BINARY
image/x-cmu-raster		ras
image/x-portable-anymap		pnm				BINARY
image/x-portable-bitmap		pbm				BINARY
image/x-portable-graymap	pgm				BINARY
image/x-portable-pixmap		ppm				BINARY
image/x-rgb			rgb				BINARY
image/x-xbitmap			xbm				ASCII
image/x-xpixmap			xpm				ASCII
image/x-xwindowdump		xwd				BINARY
message/external-body						ASCII
message/news							ASCII
message/partial							ASCII
message/rfc822							ASCII
model/iges			igs,iges
model/mesh			msh,mesh,silo
model/vrml			wrl,vrml
multipart/alternative						ASCII
multipart/appledouble						ASCII
multipart/digest						ASCII
multipart/mixed							ASCII
multipart/parallel						ASCII
text/css			css				ASCII
text/html			html,htm			ASCII
text/plain			asc,txt,c,cc,h,hh,cpp,hpp	ASCII
text/richtext			rtx
text/tab-separated-values	tsv				ASCII
text/x-setext			etx
text/x-sgml			sgml,sgm			ASCII
text/x-vCalendar		vcs				ASCII
text/x-vCard			vcf				ASCII
text/xml			xml,dtd				ASCII
video/dl			dl				BINARY
video/fli			fli				BINARY
video/gl			gl				BINARY
video/mpeg			mp2,mpe,mpeg,mpg		BINARY
video/quicktime			qt,mov				BINARY
video/x-msvideo			avi				BINARY
video/x-sgi-movie		movie				BINARY
x-conference/x-cooltalk		ice
x-world/x-vrml			wrl,vrml
