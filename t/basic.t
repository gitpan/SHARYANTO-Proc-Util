#!perl

use strict;
use warnings;

use File::Which;
use SHARYANTO::Proc::Util 'get_parent_processes';
use Test::More 0.98;

my $ppids = get_parent_processes;

if (which("pstree")) {
    ok(defined $ppids, 'get_parent_process() result is defined');
    is(ref($ppids), 'ARRAY', 'result is an ARRAY');
    cmp_ok(scalar @$ppids, '>=', 2, 'at least 2 processes')
        or diag explain $ppids;
    is($ppids->[0]->{pid}, getppid(), 'first process is getppid()')
	or diag explain $ppids;
} else {
    ok(!defined($ppids), 'get_parent_process() result is not defined');
}

done_testing;
