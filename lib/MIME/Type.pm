package MIME::Type;

use strict;

use Carp 'croak';

=chapter NAME

MIME::Type - description of one MIME type

=chapter SYNOPSIS

 use MIME::Types;
 my $mimetypes = MIME::Types->new;
 my MIME::Type $plaintext = $mimetypes->type('text/plain');
 print $plaintext->mediaType;   # text
 print $plaintext->subType;     # plain

 my @ext = $plaintext->extensions;
 print "@ext"                   # txt asc c cc h hh cpp

 print $plaintext->encoding     # 8bit
 if($plaintext->isBinary)       # false
 if($plaintext->isAscii)        # true
 if($plaintext->equals('text/plain') {...}
 if($plaintext eq 'text/plain') # same

 print MIME::Type->simplified('x-appl/x-zip') #  'appl/zip'

=chapter DESCRIPTION

MIME types are used in MIME entities, for instance as part of e-mail
and HTTP traffic.  Sometimes real knowledge about a mime-type is need.
Objects of C<MIME::Type> store the information on one such type.
=cut

#-------------------------------------------

=chapter OVERLOADED

=overload stringification

The stringification (use of the object in a place where a string
is required) will result in the type name, the same as M<type()>
returns.

=examples use of stringification
 my $mime = MIME::Type->new('text/html');
 print "$mime\n";   # explicit stringification
 print $mime;       # implicit stringification
 
=overload string comparison

When a MIME::Type object is compared to either a string or another
MIME::TYpe, the M<equals()> method is called.  Comparison is smart,
which means that it extends common string comparison with some
features which are defined in the related RFCs.

=cut

use overload '""' => 'type', cmp => 'equals';

#-------------------------------------------

=chapter METHODS

=section Initiation

=c_method new OPTIONS

Create (I<instantiate>) a new MIME::Type object which manages one
mime type.

=requires type STRING

The type which is defined here.  It consists of a I<type> and a I<sub-type>,
both case-insensitive.  This module will return lower-case, but accept
upper-case.

=option  simplified STRING
=default simplified <derived from type>

The mime types main- and sub-label can both start with C<x->, to indicate
that is a non-registered name.  Of course, after registration this flag
can disappear which adds to the confusion.  The simplified string has the
C<x-> thingies removed and are translated to lower-case.

=option  extensions REF-ARRAY
=default extensions []

An array of extensions which are using this mime.

=option  encoding '7bit'|'8bit'|'base64'|'quoted-printable'
=default encoding <depends on type>

How must this data be encoded to be transported safely.  The default
depends on the type: mimes with as main type C<text/> will default
to C<quoted-printable> and all other to C<base64>.

=option  system REGEX
=default system C<undef>

Regular expression which defines for which systems this rule is valid.  The
REGEX is matched on C<$^O>.

=error Type parameter is obligatory.

When a M<MIME::Type> object is created, the type itself must be
specified with the C<type> option flag.

=cut

sub new(@) { (bless {}, shift)->init( {@_} ) }

sub init($)
{   my ($self, $args) = @_;

    my $type = $self->{MT_type}       = $args->{type}
       or croak "ERROR: Type parameter is obligatory.";

    $self->{MT_simplified} = $args->{simplified}
       || $self->simplified($type);

    $self->{MT_extensions} = $args->{extensions} || [];

    $self->{MT_encoding}
       = $args->{encoding}          ? $args->{encoding}
       : $self->mediaType eq 'text' ? 'quoted-printable'
       :                              'base64';

    $self->{MT_system}     = $args->{system}
       if defined $args->{system};

    $self;
}

#-------------------------------------------

=section Attributes

=method type
Returns the long type of this object, for instance C<'text/plain'>

=cut

sub type() {shift->{MT_type}}

=ci_method simplified [STRING]
Returns the simplified mime type for this object or the specified STRING.
Mime type names can get officially registered.  Until then, they have to
carry an C<x-> preamble to indicate that.  Of course, after recognition,
the C<x-> can disappear.  In many cases, we prefer the simplified version
of the type.

=examples results of simplified()
 my $mime = MIME::Type->new(type => 'x-appl/x-zip');
 print $mime->simplified;                     # 'appl/zip'
 print $mime->simplified('text/plain');       # 'text/plain'
 print MIME::Type->simplified('x-xyz/x-abc'); # 'xyz/abc'

=cut

sub simplified(;$)
{   my $thing = shift;
    return $thing->{MT_simplified} unless @_;

    my $mime  = shift;

      $mime =~ m!^\s*(?:x\-)?([\w.+-]+)/(?:x\-)?([\w.+-]+)\s*$!i ? lc "$1/$2"
    : $mime eq 'text' ? 'text/plain'          # some silly mailers...
    : undef;
}

=method extensions
Returns a list of extensions which are known to be used for this
mime type.
=cut

sub extensions() { @{shift->{MT_extensions}} }

=method encoding
Returns the type of encoding which is required to transport data of this
type safely.
=cut

sub encoding() {shift->{MT_encoding}}

=method system
Returns the regular expression which can be used to determine whether this
type is active on the system where you are working on.

=cut

sub system() {shift->{MT_system}}

#-------------------------------------------

=section Knowledge

=method mediaType
The media type of the simplified mime.
For C<'text/plain'> it will return C<'text'>.

For historical reasons, the C<'mainType'> method still can be used
to retrieve the same value.  However, that method is deprecated.

=cut

sub mediaType() {shift->{MT_simplified} =~ m!^([\w.-]+)/! ? $1 : undef}
sub mainType()  {shift->mediaType} # Backwards compatibility

=method subType
The sub type of the simplified mime.
For C<'text/plain'> it will return C<'plain'>.
=cut

sub subType() {shift->{MT_simplified} =~ m!/([\w+.-]+)$! ? $1 : undef}

=method isRegistered
Mime-types which are not registered by IANA nor defined in RFCs shall
start with an C<x->.  This counts for as well the media-type as the
sub-type.  In case either one of the types starts with C<x-> this
method will return false.
=cut

sub isRegistered() { lc shift->{MT_type} !~ m{^x\-|/x\-} }

=method isVendor
[2.00] Return C<true> when the type is defined by a vendor; the subtype
starts with C<vnd.>

=method isPersonal
[2.00] Return C<true> when the type is defined by a person for
private use; the subtype starts with C<prs.>

=method isExperimental
[2.00] Return C<true> when the type is defined for experimental
use; the subtype starts with C<x.>
=cut

# http://tools.ietf.org/html/rfc4288#section-3
sub isVendor()       {shift->{MT_simplified} =~ m!/vnd\.!}
sub isPersonal()     {shift->{MT_simplified} =~ m!/prs\.!}
sub isExperimental() {shift->{MT_simplified} =~ m!/x\.!  }

=method isBinary
Returns true when the type is not known to be text.  See M<isText()>.

=method isAscii
Old name for M<isText()>.

=method isText
[2.05] All types which may have the charset attribute, are text.  However,
there is currently no record of attributes in this module... so we guess.
=cut

sub isBinary() { shift->{MT_encoding} eq 'base64' }
sub isText()   { shift->{MT_encoding} ne 'base64' }
*isAscii = \&isText;

=method isSignature
Returns true when the type is in the list of known signatures.
=cut

# simplified names only!
my %sigs = map +($_ => 1),
  qw(application/pgp-keys application/pgp application/pgp-signature
     application/pkcs10 application/pkcs7-mime application/pkcs7-signature
     text/vCard);

sub isSignature() { $sigs{shift->{MT_simplified}} }

=method equals STRING|MIME
Compare this mime-type object with a STRING or other object.  In case of
a STRING, simplification will take place.
=cut

sub equals($)
{   my ($self, $other) = @_;

    my $type = ref $other
      ? $other->simplified
      : (ref $self)->simplified($other);

    $self->simplified cmp $type;
}

1;
