package MIME::Type;

use strict;
use warnings;
use Carp;

our $VERSION = '0.01';

=head1 NAME

 MIME::Type - Definition of one MIME type

=head1 SYNOPSIS

 use MIME::Types;
 my $mimetypes = MIME::Types->new;
 my MIME::Type $plaintext = $mimetype->type('text/plain');

 print MIME::Type->simplified('x-appl/x-zip') #  'appl/zip'

=head1 DESCRIPTION

MIME types are used in MIME entities, for instance as part of e-mail
and HTTP traffic.  Sometimes real knowledge about a mime-type is need.
Objects of C<MIME::Type> store the information on one such type.

=cut

#-------------------------------------------

=head1 METHODS

=over 4

=cut

#-------------------------------------------

=item new OPTIONS

Create a new C<MIME::Type> object which manages one mime type.

 OPTION                    DEFAULT
 type                      <obligatory>
 simplified                <derived from type>
 extensions                undef
 encoding                  'UNKNOWN'

=over 4

=item * type =E<gt> STRING

The type which is defined here.  It consists of a I<type> and a I<sub-type>,
both case-insensitive.  This module will return lower-case, but accept
upper-case.

=item * simplified =E<gt> STRING

The mime types main- and sub-label can both start with C<x->, to indicate
that is a non-registered name.  Of course, after registration this flag
can disappear which adds to the confusion.  The simplified string has the
C<x-> thingies removed and are translated to lower-case.

=item * extensions =E<gt> REF-ARRAY

An array of extensions which are using this mime.

=item * encoding =E<gt> 'UNKNOWN'|'BINARY'|'ASCII'

Which kind of data.  In case of C<'ASCII'>, bytes with a code below \040 and
above \126 are sparse: text data.  C<'BINARY'> data usually has a non-printable
content.  For 'UNKNOWN', it is not (yet) known.  Please contribute if you
know more about these formats.

=back

=cut

sub new(@) { (bless {}, shift)->init( {@_} ) }

sub init($)
{   my ($self, $args) = @_;

    $self->{MT_type}       = $args->{type}
       or confess "Type is obligatory.";

    $self->{MT_simplified} = $args->{simplified}
       || ref($self)->simplified($args->{type});

    $self->{MT_extensions} = $args->{extensions} || [];
    $self->{MT_encoding}   = $args->{encoding}   || 'UNKNOWN';

    $self;
}

#-------------------------------------------

=item type

Returns the long type of this object, for instance C<'text/plain'>

=cut

sub type() {shift->{MT_type}}

#-------------------------------------------

=item simplified [STRING]

(Instance method or Class method)
Returns the simplified mime type for this object or the specified STRING.
Mime type names can get officially registered.  Until then, they have to
carry an C<x-> preamble to indicate that.  Of course, after recognition,
the C<x-> can disappear.  In many cases, we prefer the simplified version
of the type.

Examples:

 my $mime = MIME::Type->new(type => 'x-appl/x-zip');
 print $mime->simplified;                     # 'appl/zip'
 print $mime->simplified('text/plain');       # 'text/plain'
 print MIME::Type->simplified('x-xyz/x-abc'); # 'xyz/abc'

=cut

sub simplified(;$)
{   my $thing = shift;
    return $thing->{MT_simplified} unless @_;

    shift =~ m!^\s*(?:x\-)?([\w.-]+)/(?:x\-)?([\w.-]+)\s*$! ? lc "$1/$2" : undef;
}

#-------------------------------------------

=item mainType

The main type of the simplified mime.
For C<'text/plain'> it will return C<'text'>.

=cut

sub mainType() {shift->{MT_simplified} =~ m!^([\w-]+)/! ? $1 : undef}

#-------------------------------------------

=item subType

The sub type of the simplified mime.
For C<'text/plain'> it will return C<'plain'>.

=cut

sub subType() {shift->{MT_simplified} =~ m!/([\w-]+)$! ? $1 : undef}

#-------------------------------------------

=item extensions

Returns a list of extensions which are known to be used for this
mime type.

=cut

sub extensions() { @{shift->{MT_extensions}} }

#-------------------------------------------

=item encoding

Returns C<'UNKNOWN'>, C<'ASCII'>, or C<'BINARY'>, for the format in which
the data is encoded.

=cut

sub encoding() {shift->{MT_encoding}}

#-------------------------------------------

=item isBinary

Returns C<undef> when the encoding is C<'UNKNOWN'> and C<0> when the encoding
is C<'ASCII'>.  Both are representations of false.  Only for the C<'BINARY'>
encoding true will be returned.

=cut

sub isBinary()
{   for(shift->{MT_encoding}) 
    {   return $_ eq 'UNKNOWN' ? undef
             : $_ eq 'BINARY'  ? 1
             :                   0;
    }
}

#-------------------------------------------

=item isAscii

Returns C<undef> when the encoding is C<'UNKNOWN'> and C<0> when the encoding
is C<'BINARY'>.  Both are representations of false.  Only for the C<'ASCII'>
encoding true will be returned.

=cut

sub isAscii()
{   for(shift->{MT_encoding}) 
    {   return $_ eq 'UNKNOWN' ? undef
             : $_ eq 'ASCII'   ? 1
             :                   0;
    }
}

#-------------------------------------------

=back

=head1 SEE ALSO

L<MIME::Types>

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
