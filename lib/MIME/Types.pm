
package MIME::Types;

use strict;

use MIME::Type     ();
use File::Spec     ();
use File::Basename qw(dirname);

=chapter NAME

MIME::Types - Definition of MIME types

=chapter SYNOPSIS

 use MIME::Types;
 my $mimetypes = MIME::Types->new(...);      # MIME::Types object
 my $type = $mimetypes->type('text/plain');  # MIME::Type  object
 my $type = $mimetypes->mimeTypeOf('gif');

=chapter DESCRIPTION

MIME types are used in many applications (for instance as part of e-mail
and HTTP traffic) to indicate the type of content which is transmitted.

Sometimes detailed knowledge about a mime-type is need, however this
module only knows about the file-name extensions which relate to some
filetype.  It can also be used to produce the right format: types
which are not registered at IANA need to use 'x-' prefixes.

This object administers a huge list of known mime-types, combined
from various sources.  For instance, it contains B<all IANA> types
and the knowledge of Apache.  Probably the most complete table on
the net!

=section MIME::Types and daemons (fork)

If your program uses fork (usually for a daemon), then you want to have
the type table initialized before you start forking. So, first call

   my $mt = MIME::Types->new;

Later, each time you create this object (you may, of course, also reuse
the object you create here) you will get access to B<the same global table>
of types.

=chapter METHODS

=section Constructors

=c_method new OPTIONS

Create a new C<MIME::Types> object which manages the data.  In the current
implementation, it does not matter whether you create this object often
within your program, but in the future this may change.

=option  only_complete BOOLEAN
=default only_complete <false>

Only include complete MIME type definitions: requires at least one known
extension.  This will reduce the number of entries --and with that the
amount of memory consumed-- considerably.

In your program you have to decide: the first time that you call
the creator (C<new>) determines whether you get the full or the partial
information.

=option  skip_extensions BOOLEAN
=default skip_extensions <false>
Do not load the table to map extensions to types, which is quite large.

=option  only_iana BOOLEAN
=default only_iana <false>
Only load the types which are currently known by IANA.

=option  db_file FILENAME
=default db_file <installed source>
=cut

my %typedb;
sub new(@) { (bless {}, shift)->init( {@_} ) }

sub init($)
{   my ($self, $args) = @_;
    keys %typedb or $self->_read_db($args);
    $self;
}

sub _read_db($)
{   my ($self, $args)   = @_;
    my $skip_extensions = $args->{skip_extensions};
    my $only_complete   = $args->{only_complete};
    my $only_iana       = $args->{only_iana};

    my $db              = $args->{db_file}
      || File::Spec->catfile(dirname(__FILE__), 'types.db');

    local *DB;
    open DB, '<:encoding(utf8)', $db
       or die "cannot open type database in $db: $!\n";

    while(1)
    {   my $header = <DB>;
        defined $header or last;
        chomp $header;

        # This logic is entangled with the bin/collect_types script
        my ($count, $major, $is_iana, $has_ext) = split /\:/, $header;
        my $skip_section = $major eq 'EXTENSIONS' ? $skip_extensions
          : (($only_iana && !$is_iana) || ($only_complete && !$has_ext));

#warn "Skipping section $header\n" if $skip_section;
        (my $section = $major) =~ s/^x-//;
        if($major eq 'EXTENSIONS')
        {   local $_;
            while(<DB>)
            {   last if m/^$/;
                next if $skip_section;
                chomp;
                $typedb{$section}{$1} = $2 if m/(.*);(.*)/;
            }
        }
        else
        {   local $_;
            while(<DB>)
            {   last if m/^$/;
                next if $skip_section;
                chomp;
                $typedb{$section}{$1} = "$major/$_" if m/^(?:x-)?([^;]+)/;
            }
        }
    }

    close DB;
}

# Catalyst-Plugin-Static-Simple uses it :(
sub create_type_index {}

#-------------------------------------------

=section Knowledge

=method type STRING

Returns the C<MIME::Type> which describes the type related to STRING.
[2.00] Only one type will be returned.

[before 2.00] One type may be described more than once.  Different
extensions may be in use for this type, and different operating systems
may cause more than one C<MIME::Type> object to be defined.  In scalar
context, only the first is returned.

=cut

sub type($)
{   my $spec    = lc $_[1];
    $spec       = 'text/plain' if $spec eq 'text';   # old mailers

    $spec =~ m!^(?:x\-)?([^/]+)/(?:x-)?(.*)!
        or return;

    my $section = $typedb{$1}    or return;
    my $record  = $section->{$2} or return;
    return $record if ref $record;   # already extended

    my $simple   = $2;
    my ($type, $ext, $enc) = split m/\;/, $record;
    my $os       = undef;   # XXX TODO

    $section->{$simple} = MIME::Type->new
      ( type       => $type
      , extensions => [split /\,/, $ext]
      , encoding   => $enc
      , system     => $os
      );
}

=method mimeTypeOf FILENAME

Returns the C<MIME::Type> object which belongs to the FILENAME (or simply
its filename extension) or C<undef> if the file type is unknown.  The extension
is used and considered case-insensitive.

In some cases, more than one type is known for a certain filename extension.
In that case, the preferred one is taken (for an unclear definition of
preference)

=examples use of mimeTypeOf()

 my $types = MIME::Types->new;
 my $mime = $types->mimeTypeOf('gif');

 my $mime = $types->mimeTypeOf('jpg');
 print $mime->isBinary;

=cut

sub mimeTypeOf($)
{   my ($self, $name) = @_;
    (my $ext = lc $name) =~ s/.*\.//;
    my $type = $typedb{EXTENSIONS}{$ext} or return;
    $self->type($type);
}

=method addType TYPE, ...

Add one or more TYPEs to the set of known types.  Each TYPE is a
C<MIME::Type> which must be experimental: either the main-type or
the sub-type must start with C<x->.

Please inform the maintainer of this module when registered types
are missing.  Before version MIME::Types version 1.14, a warning
was produced when an unknown IANA type was added.  This has been
removed, because some people need that to get their application
to work locally... broken applications...

=cut

sub addType(@)
{   my $self = shift;

    foreach my $type (@_)
    {   my ($major, $minor) = split m!/!, $type->simplified;
        $typedb{$major}{$minor} = $type;
        $typedb{EXTENSIONS}{$_} = $type for $type->extensions;
    }
    $self;
}

=method types
Returns a list of all defined mime-types.  For reasons of backwards
compatibility, this will instantiate M<MIME::Type> objects, which will
be returned.  See M<listTypes()>.
=cut

sub types()
{   my $self  = shift;
    my @types;
    foreach my $section (keys %typedb)
    {   next if $section eq 'EXTENSIONS';
        push @types, map $_->type("$section/$_"),
                         sort keys %{$typedb{$section}};
    }
    @types;
}

=method listTypes
Returns a list of all defined mime-types by name only.  This will B<not>
instantiate M<MIME::Type> objects.  See M<types()>
=cut

sub listTypes()
{   my $self  = shift;
    my @types;
    foreach my $section (keys %typedb)
    {   next if $section eq 'EXTENSIONS';
        foreach my $sub (sort keys %{$typedb{$section}})
        {   my $record = $typedb{$section}{$sub};
            push @types, ref $record            ? $record->type
                       : $record =~ m/^([^;]+)/ ? $1 : die;
        }
    }
    @types;
}


=method extensions
Returns a list of all defined extensions.
=cut

sub extensions { keys %{$typedb{EXTENSIONS}} }

#-------------------------------------------
# OLD INTERGFACE (version 0.06 and lower)

=chapter FUNCTIONS

The next functions are provided for backward compatibility with MIME::Types
versions [0.06] and below.  This code originates from Jeff Okamoto
F<okamoto@corp.hp.com> and others.

=cut

use base 'Exporter';
our @EXPORT_OK = qw(by_suffix by_mediatype import_mime_types);

=function by_suffix FILENAME|SUFFIX

Like C<mimeTypeOf>, but does not return an C<MIME::Type> object. If the file
+type is unknown, both the returned media type and encoding are empty strings.

=examples use of function by_suffix()

 use MIME::Types 'by_suffix';
 my ($mediatype, $encoding) = by_suffix('image.gif');

 my $refdata = by_suffix('image.gif');
 my ($mediatype, $encoding) = @$refdata;

=cut

my $mime_types;

sub by_suffix($)
{   my $filename = shift;
    $mime_types ||= MIME::Types->new;
    my $mime     = $mime_types->mimeTypeOf($filename);

    my @data     = defined $mime ? ($mime->type, $mime->encoding) : ('','');
    wantarray ? @data : \@data;
}

=function by_mediatype TYPE
This function takes a media type and returns a list or anonymous array of
anonymous three-element arrays whose values are the file name suffix used to
identify it, the media type, and a content encoding.

TYPE can be a full type name (contains '/', and will be matched in full),
a partial type (which is used as regular expression) or a real regular
expression.
=cut

sub by_mediatype($)
{   my $type = shift;
    $mime_types ||= MIME::Types->new;

    my @found;
    if(!ref $type && index($type, '/') >= 0)
    {   my $mime   = $mime_types->type($type);
        @found     = $mime if $mime;
    }
    else
    {   my $search = ref $type eq 'Regexp' ? $type : qr/$type/i;
        @found     = map $mime_types->type($_),
                         grep $_ =~ $search,
                             $mime_types->listTypes;
    }

    my @data;
    foreach my $mime (@found)
    {   push @data, map [$_, $mime->type, $mime->encoding],
                        $mime->extensions;
    }

    wantarray ? @data : \@data;
}

=function import_mime_types
This method has been removed: mime-types are only useful if understood
by many parties.  Therefore, the IANA assigns names which can be used.
In the table kept by this C<MIME::Types> module all these names, plus
the most often used temporary names are kept.  When names seem to be
missing, please contact the maintainer for inclusion.
=cut

sub import_mime_types($)
{   my $filename = shift;
    use Carp;
    croak <<'CROAK';
import_mime_types is not supported anymore: if you have types to add
please send them to the author.
CROAK
}

1;
__END__
# Exceptions
vms:text/plain;doc;8bit
mac:application/x-macbase64;;bin

# IE6 bug
image/pjpeg;;base64
