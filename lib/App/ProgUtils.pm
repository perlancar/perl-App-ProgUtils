package App::ProgUtils;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

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

$SPEC{list_all_programs_in_path} = {
    v => 1.1,
    summary => 'List all programs in PATH',
    args => {
        with_path => {
            schema => 'bool*',
            cmdline_aliases => {
                'x' => {is_flag=>1, summary => 'Show path of each program', code => sub { $_[0]{with_path} = 1 }},
            },
        },
    },
    links => [
        {url=>'prog:pmlist'},
    ],
};
sub list_all_programs_in_path {
    my %args = @_;

    my $with_path = $args{with_path};

    my @dirs = split(($^O =~ /Win32/ ? qr/;/ : qr/:/), $ENV{PATH});
    my @all_progs;
    for my $dir (@dirs) {
        opendir my($dh), $dir or next;
        for (readdir($dh)) {
            push @all_progs, ($with_path ? "$dir/$_" : $_)
                if !(-d "$dir/$_") && (-x _);
        }
    }

    [200, "OK", \@all_progs];
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

L<Complete::Program>

=cut
