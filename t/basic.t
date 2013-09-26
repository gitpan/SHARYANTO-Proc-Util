#!perl

use strict;
use warnings;

use Test::More 0.98 tests => 4;
use SHARYANTO::Proc::Util 'get_parent_processes';

my $ppids = get_parent_processes;

SKIP: {
    ok(defined $ppids, 'get_parent_process() result is defined')
	or skip 'failure', 3;
    is(ref($ppids), 'ARRAY', 'result is an ARRAY')
	or skip 'failure', 2;
    cmp_ok(scalar @$ppids, '>=', 2, 'at least 2 processes');
    is($ppids->[0]->{pid}, getppid(), 'first process is getppid()')
	or diag explain $ppids;
}
