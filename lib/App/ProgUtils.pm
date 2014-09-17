package App::ProgUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our $_complete_program = sub {
    require Complete::Util;
    require List::MoreUtils;

    my %args = @_;

    my $word = $args{word} // '';

    # combine all executables (including dirs) and programs in PATH
    my $c1 = Complete::Util::complete_file(
        word   => $word,
        filter => sub { -x $_[0] },
        #ci    => 1, # convenience, not yet supported by C::U
    );
    my $c2 = Complete::Util::complete_program(
        word => $word,
        ci   => 1, # convenience
    );

    {
        completion => [ List::MoreUtils::uniq(sort(@$c1, @$c2)) ],
        path_sep   => '/',
    };
};

sub _search_program {
    require File::Which;

    my $prog = shift;
    if ($prog =~ m!/!) {
        return $prog;
    } else {
        return File::Which::which($prog) // $prog;
    }
}

1;
# ABSTRACT: Command line to manipulate programs in PATH

=head1 SYNOPSIS

This distribution provides the following command-line utilities:

 progedit
 progless
 progman
 progpath


=head1 SEE ALSO

L<App::PMUtils>, a similarly spirited distribution.

=cut
