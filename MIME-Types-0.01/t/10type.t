#!/usr/bin/perl -w
#
# Test reporting warnings, errors and family.
#

use Test;
use strict;

use lib qw(. t);

BEGIN {plan tests => 23}

use MIME::Type;

my $a = MIME::Type->new(type => 'x-appl/x-zip', extensions => [ 'zip', 'zp' ]);
ok($a);
ok($a->type eq 'x-appl/x-zip');
ok($a->simplified eq 'appl/zip');
ok($a->simplified('text/plain') eq 'text/plain');
ok(MIME::Type->simplified('x-xyz/abc') eq 'xyz/abc');
ok($a->mainType eq 'appl');
ok($a->subType eq 'zip');

my @ext = $a->extensions;
ok(@ext==2);
ok($ext[0] eq 'zip');
ok($ext[1] eq 'zp');
ok(!defined $a->isBinary);
ok(!defined $a->isAscii);

my $b = MIME::Type->new(type => 'TEXT/PLAIN', encoding => 'ASCII');
ok($b);
ok($b->type eq 'TEXT/PLAIN');
ok($b->simplified eq 'text/plain');
ok($b->mainType eq 'text');
ok($b->subType eq 'plain');
@ext = $b->extensions;
ok(@ext==0);
ok($b->encoding eq 'ASCII');
ok(defined $b->isBinary);
ok(!$b->isBinary);
ok(defined $b->isAscii);
ok($b->isAscii);
