package SHARYANTO::Proc::Util;

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_parent_processes);

our $VERSION = '0.60'; # VERSION

sub get_parent_processes {
    my ($pid, $opts) = @_;
    $pid //= $$;
    $opts //= {};

    my %proc;
    if (($opts->{method} // 'proctable') eq 'pstree') {
        # things will be simpler if we use the -s option, however not all
        # versions of pstree supports it. -l is for --long (to avoid pstree to
        # cut its output at 132 cols)

        my @lines = `pstree -pAl`;
        return undef unless @lines;

        my @p;
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
    } else {
        eval { require Proc::ProcessTable };
        return undef if $@;

        state $pt = Proc::ProcessTable->new;
        for my $p (@{ $pt->table }) {
            $proc{ $p->{pid} } = {
                name=>$p->{fname}, pid=>$p->{pid}, ppid=>$p->{ppid},
            };
        }
    }

    my @p = ();
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

=encoding UTF-8

=head1 NAME

SHARYANTO::Proc::Util - OS-process-related routines

=head1 VERSION

version 0.60

=head1 SYNOPSIS

=head1 FUNCTIONS

None are exported by default, but they are exportable.

=head2 get_parent_processes($pid[, \%opts]) => ARRAY

Return an array containing information about parent processes of C<$pid> up to
the parent of all processes (usually C<init>). If C<$pid> is not mentioned, it
defaults to C<$$>. The immediate parent is in the first element of array,
followed by its parent, and so on. For example:

 [{name=>"perl",pid=>13134}, {name=>"konsole",pid=>2232}, {name=>"init",pid=>1}]

Currently retrieves information by calling B<pstree> program. Return undef on
failure.

Known options:

=over

=item * method => STR (default: C<proctable>)

Either C<proctable> (the default, which means to use L<Proc::ProcessTable>) or
C<pstree> (which uses the B<pstree> command, which might not be portable between
Unices).

=back

=head1 SEE ALSO

L<SHARYANTO>

L<Proc::ProcessTable>. Pros: does not depend on pstree command, process names
not truncated by pstree. Cons: a little bit more heavyweight (uses File::Spec,
Cwd, File::Find).

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/SHARYANTO-Proc-Util>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-SHARYANTO-Proc-Util>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=SHARYANTO-Proc-Util>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
