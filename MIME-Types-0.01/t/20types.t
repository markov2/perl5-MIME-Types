#!/usr/bin/perl -w
#
# Test reporting warnings, errors and family.
#

use Test;
use strict;

use lib qw(. t);

BEGIN {plan tests => 13}

use MIME::Types;

my $a = MIME::Types->new;
ok($a);

my @t = $a->type('text/plain');
ok(@t==1);
my $t = $t[0];
ok(ref $t eq 'MIME::Type');
ok($t->type eq 'text/plain');

@t = $a->type('TEXT/x-PLAIN');
ok(@t==1);
$t = $t[0];
ok($t->type eq 'text/plain');

my $m = $a->mimeTypeOf('gif');
ok($m);
ok(ref $m eq 'MIME::Type');
ok($m->type eq 'image/gif');

my $n = $a->mimeTypeOf('GIF');
ok($n);
ok($n->type eq 'image/gif');

my $p = $a->mimeTypeOf('my_image.gif');
ok($p);
ok($p->type eq 'image/gif');
