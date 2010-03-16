#!/usr/bin/perl -w
#
# Test reporting warnings, errors and family.
#

use Test::More;
use strict;

use lib qw(. t);

BEGIN {plan tests => 21}

use MIME::Types;

my $a = MIME::Types->new;
ok(defined $a);

my @t = $a->type('multipart/mixed');
cmp_ok(scalar @t, '==', 1);
my $t = $t[0];
isa_ok($t, 'MIME::Type');
is($t->type, 'multipart/mixed');

# No extensions, but a known, explicit encoding.
@t = $a->type('message/external-body');
cmp_ok(scalar @t, '==', 1);
$t = $t[0];
ok(not $t->extensions);
is($t->encoding, '8bit');

@t = $a->type('TEXT/x-RTF');
cmp_ok(scalar @t, '==', 1);
$t = $t[0];
is($t->type, 'text/rtf');

my $m = $a->mimeTypeOf('gif');
ok(defined $m);
isa_ok($m, 'MIME::Type');
is($m->type, 'image/gif');

my $n = $a->mimeTypeOf('GIF');
ok(defined $n);
is($n->type, 'image/gif');

my $p = $a->mimeTypeOf('my_image.gif');
ok(defined $p);
is($p->type, 'image/gif');

my $q = $a->mimeTypeOf('windows.doc');
if($^O eq 'VMS')
{   # See MIME::Types, OS Exceptions
    is($q->type, 'text/plain');
}
else
{   is($q->type, 'application/x-msword');
}
is($a->mimeTypeOf('my.lzh')->type, 'application/x-lzh');

my $warn;
my $r2 = MIME::Type->new(type => 'text/x-fake2');
{   $SIG{__WARN__} = sub {$warn = join '',@_};
    $a->addType($r2);
}
ok(not defined $warn);

undef $warn;
my $r3 = MIME::Type->new(type => 'x-appl/x-fake3');
{   $SIG{__WARN__} = sub {$warn = join '',@_};
    $a->addType($r3);
}
ok(not defined $warn);

undef $warn;
my $r4 = MIME::Type->new(type => 'x-appl/fake4');
{   $SIG{__WARN__} = sub {$warn = join '',@_};
    $a->addType($r4);
}
ok(not defined $warn);
