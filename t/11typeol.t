#!/usr/bin/perl -w
#
# Test overloading on MIME::Type objects.
#

use Test::More;
use strict;

use lib qw(. t);

BEGIN {plan tests => 21}

use MIME::Type;

my $a = MIME::Type->new(type => 'x-appl/x-zip');
my $b = MIME::Type->new(type => 'appl/x-zip');
my $c = MIME::Type->new(type => 'x-appl/zip');
my $d = MIME::Type->new(type => 'appl/zip');
my $e = MIME::Type->new(type => 'text/plain');

is($a, $b);
is($a, $c);
is($a, $d);
is($b, $c);
is($b, $d);
is($c, $d);
isnt($a, $e);

ok(!$a->isRegistered);
ok(!$b->isRegistered);
ok(!$c->isRegistered);
ok( $d->isRegistered);
ok( $e->isRegistered);

is("$a", 'x-appl/x-zip');
is("$b", 'appl/x-zip');
is("$c", 'x-appl/zip');
is("$d", 'appl/zip');
is("$e", 'text/plain');

is($a, 'appl/zip');
is($b, 'APPL/ZIP');
is($c, 'x-appl/x-zip');
is($e, 'text/plain');
