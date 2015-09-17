package App::ProgUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our $_complete_program = sub {
    require Complete::File;
    require Complete::Program;
    require List::MoreUtils;

    my %args = @_;

    my $word = $args{word} // '';

    # combine all executables (including dirs) and programs in PATH
    my $c1 = Complete::File::complete_file(
        word   => $word,
        filter => sub { -x $_[0] },
        #ci    => 1, # convenience, not yet supported by C::U
    );
    my $c2 = Complete::Program::complete_program(
        word => $word,
        ci   => 1, # convenience
    );

    {
        words      => [ List::MoreUtils::uniq(sort(@$c1, @$c2)) ],
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

This distribution provides the following command-line utilities related to
programs found in PATH:

# INSERT_EXECS_LIST

The main feature of these utilities is tab completion.


=head1 FAQ

#INSERT_BLOCK: App::PMUtils faq


=head1 SEE ALSO

#INSERT_BLOCK: App::PMUtils see_also

=cut
