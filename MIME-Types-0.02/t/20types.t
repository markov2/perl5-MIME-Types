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

my @t = $a->type('multipart/mixed');
ok(@t==1);
my $t = $t[0];
ok(ref $t eq 'MIME::Type');
ok($t->type eq 'multipart/mixed');

@t = $a->type('TEXT/x-RTF');
ok(@t==1);
$t = $t[0];
ok($t->type eq 'text/rtf');

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

my $q = $a->mimeTypeOf('windows.doc');
ok($q->type eq 'application/msword');
ok($a->mimeTypeOf('my.lzh')->type eq 'application/octet-stream');

