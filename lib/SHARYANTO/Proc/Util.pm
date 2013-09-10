package SHARYANTO::Proc::Util;

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_parent_processes);

our $VERSION = '0.56'; # VERSION

sub get_parent_processes {
    my ($pid) = @_;
    $pid //= $$;

    # things will be simpler if we use the -s option, however not all versions
    # of pstree supports it.

    my @lines = `pstree -pA`;
    return undef unless @lines;

    my @p;
    my %proc;
    for (@lines) {
        my $i = 0;
        while (/(?: (\s*(?:\|-?|`-)) | (.+?)\((\d+)\) )
                (?: -[+-]- )?/gx) {
            unless ($1) {
                my $p = {name=>$2, pid=>$3};
                $p[$i] = $p;
                $p->{ppid} = $p[$i-1]{pid} if $i > 0;
                $proc{$3} = $p;
            }
            $i++;
        }
    }
    #use Data::Dump; dd \%proc;

    @p = ();
    my $cur_pid = $pid;
    while (1) {
        return if !$proc{$cur_pid};
        $proc{$cur_pid}{name} = $1 if $proc{$cur_pid}{name} =~ /\A\{(.+)\}\z/;
        push @p, $proc{$cur_pid};
        $cur_pid = $proc{$cur_pid}{ppid};
        last unless $cur_pid;
    }
    shift @p; # delete cur process

    \@p;
}

# ABSTRACT: OS-process-related routines

__END__

=pod

=encoding utf-8

=head1 NAME

SHARYANTO::Proc::Util - OS-process-related routines

=head1 VERSION

version 0.56

=head1 SYNOPSIS

=head1 FUNCTIONS

None are exported by default, but they are exportable.

=head2 get_parent_processes($pid) => ARRAY

Return an array containing information about parent processes of C<$pid> up to
the parent of all processes (usually C<init>). If C<$pid> is not mentioned, it
defaults to C<$$>. The immediate parent is in the first element of array,
followed by its parent, and so on. For example:

 [{name=>"perl",pid=>13134}, {name=>"konsole",pid=>2232}, {name=>"init",pid=>1}]

Currently retrieves information by calling B<pstree> program. Return undef on
failure.


None are exported by default, but they are exportable.

=head1 SEE ALSO

L<Proc::ProcessTable>. Pros: does not depend on pstree command, process names
not truncated by pstree. Cons: a little bit more heavyweight (uses File::Spec,
Cwd, File::Find).

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DESCRIPTION

=cut
