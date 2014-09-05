package MojoX::MIME::Types;
use Mojo::Base -base;

use MIME::Types   ();

=chapter NAME
MojoX::MIME::Types - MIME Types for Mojolicious

=chapter SYNOPSIS

  use MojoX::MIME::Types;

  # set in Mojolicious as default
  $app->types(MojoX::MIME::Types->new);
  app->types(MojoX::MIME::Types->new);   # ::Lite

  # basic interface translated into pure MIME::Types
  $types->type(foo => 'text/foo');
  say $types->type('foo');

=chapter DESCRIPTION

[Added to MIME::Types 2.07]
This module is a drop-in replacement for M<Mojolicious::Types>, but
with a more correct handling plus a complete list of types... a huge
list of types.

Some methods ignore information they receive: those parameters are
accepted for compatibility with the M<Mojolicious::Types> interface,
but should not contain useful information.

Read the L</DETAILS> below, about how to connect this module into
Mojolicious and the differences you get.

=chapter METHODS

=section Constructors

=c_method new %options
Create the 'type' handler for Mojolicious.  When you do not specify your
own MIME::Type object ($mime_type), it will be instantanted for you.
You create one yourself when you would like to pass some parameter to
the object constructor.

=option  types HASH
=default types undef
Ignored.

=option  mime_types MIME::Types-object
=default mime_types <created internally>
Pass your own prepared M<MIME::Types> object, when you need some
instantiation parameters different from the defaults.

=examples
  $app->types(MojoX::MIME::Types->new);

  # when you need to pass options to MIME::Types->new
  my $mt    = MIME::Types->new(%opts);
  my $types = MojoX::MIME::Types->new(mime_types => $mt);
  $app->types($types);

=cut

sub new(%)
{   # base new() constructor incorrect: should call init()
    my $self        = shift->SUPER::new(@_);
    $self->{MMT_mt} = delete $self->{mime_types} || MIME::Types->new;
    $self;
}

#----------
=section Attributes

=method mimeTypes
Returns the internal mime types object.
=cut

sub mimeTypes() { shift->{MMT_mt} }

=method types [\%table]
In M<Mojolicious::Types>, this attribute exposes the internal
administration of types, offering to change it with using a clean
abstract interface.  That interface mistake bites now we have more
complex internals.

B<Avoid this method!>  The returned HASH is expensive to construct,
changes passed via C<%table> are ignored: M<MIME::Types> is very complete!
=cut

sub types(;$)
{   my $self = shift;
    return $self->{MMT_ext} if $self->{MMT_ext};

    my %exttable;
    my $t = MIME::Types->_MojoExtTable;
    while(my ($ext, $type) = each %$t) { $exttable{$ext} = [$type] }
    $self->{MMT_ext} = \%exttable;
}

#----------
=section Actions

=method detect $accept, [$prio]
Returns a list of filename extensions.  The $accept header in HTTP can
contain multiple types, with a priority indication ('q' attributes).
The returned list contains a list with extensions, the extensions related
to the highest priority type first.  The C<$prio>-flag is ignored.
See M<MIME::Types::httpAccept()>.

This detect() function is not the correct approach for the Accept header:
the "Accept" may contain wildcards ('*') in types for globbing, which
does not produce extensions.  Better use M<MIME::Types::httpAcceptBest()>
or M<MIME::Types::httpAcceptSelect()>.

=examples
  my $exts = $types->detect('application/json;q=9');
  my $exts = $types->detect('text/html, application/json;q=9');
=cut

sub detect($$;$)
{   my ($self, $accept, $prio) = @_;
    my $mt  = $self->mimeTypes;
    my @ext = map $mt->type($_)->extensions,
        grep !/\*/, $mt->httpAccept($accept);
    \@ext;
}

=method type $ext, [$type|\@types]
Returns the first type name for an extension $ext, unless you specify
type names.

When a single $type or an ARRAY of @types are specified, the C<$self>
object is returned.  Nothing is done with the provided info.
=cut

sub type($;$)
{   my ($self, $ext, $types) = @_;

    my $mt  = $self->mimeTypes;
    defined $types
        or return $mt->mimeTypeOf($ext);

    # stupid interface compatibility!
    $self;
}

#---------------
=chapter DETAILS

=section Why?

The M<Mojolicious::Types> module has only very little knowledge about
what is really needed to treat types correctly, and only contains a tiny
list of extensions.  M<MIME::Types> tries to follow the standards
very closely and contains all types found in various lists on internet.

=section How to use with Mojolicious

Start your Mojo application like this:

  package MyApp;
  use Mojo::Base 'Mojolicious';

  sub startup {
     my $self = shift;
     ...
     $self->types(MojoX::MIME::Types->new);
  }

If you have special options for M<MIME::Types::new()>, then create
your own MIME::Types object first:

  my $mt    = MIME::Types->new(%opts);
  my $types = MojoX::MIME::Types->new(mime_types => $mt);
  $self->types($types);

In any case, you can reach the smart M<MIME::Types> object later as

  my $mt    = $app->types->mimeTypes;
  my $mime  = $mt->mimeTypeOf($filename);
 
=section How to use with Mojolicious::Lite

The use in M<Mojolicious::Lite> applications is only slightly different
from above:

  app->types(MojoX::MIME::Types->new);
  my $types = app->types;

=section Differences with Mojolicious::Types

There are a few major difference with Mojolicious::Types:

=over 4
=item *
the tables maintained by M<MIME::Types> are complete.  So: there shouldn't
be a need to add your own types, not via M<types()>, not via M<type()>.
All attempts to add types are ignored; better remove them from your code.

=item *
This plugin understands the experimental flag 'x-' in types and handles
casing issues.

=item *
Updates to the internal hash via types() are simply ignored, because it
is expensive to implement (and won't add something new).

=item *
The M<detect()> is implemented in a compatible way, but does not understand
wildcards ('*').  You should use M<MIME::Types::httpAcceptBest()> or
M<MIME::Types::httpAcceptSelect()> to replace this broken function.

=back

=cut

1;
