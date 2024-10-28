package App::ProgUtils;

use 5.010001;
use strict;
use warnings;

use Perinci::Sub::Util qw(gen_modified_sub);

# AUTHORITY
# DATE
# DIST
# VERSION

our %SPEC;

our $_complete_program = sub {
    require Complete::File;
    require Complete::Program;
    require Complete::Util;
    require List::MoreUtils;

    my %args = @_;

    my $word = $args{word} // '';

    # combine all executables (including dirs) and programs in PATH
    my $c1 = Complete::Util::arrayify_answer(
        Complete::File::complete_file(
            word   => $word,
            filter => sub { -x $_[0] },
            #ci    => 1, # convenience, not yet supported by C::U
        ),
    );
    my $c2 = Complete::Util::arrayify_answer(
        Complete::Program::complete_program(
            word => $word,
            ci   => 1, # convenience
        ),
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
        {url=>'prog:proglist'},
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

$SPEC{proglist} = {
    v => 1.1,
    summary => 'List programs matching query',
    args => {
        query => {
            schema => 're*',
            req => 0,
            pos => 0,
        },
        type => {
            schema => ['str*', in=>[qw/script binary/]],
        },
        full_path => {
            summary => 'Show full path of each script',
            schema => 'true*',
            cmdline_aliases => {p=>{}},
        },
    },
    examples => [
        {
            summary => 'List all programs',
            argv => [],
            test => 0,
            'x.doc.show_result'=>0,
        },
        {
            summary => 'List all binaries that have "font" in their name',
            argv => [qw/font --type=binary/],
            test => 0,
            'x.doc.show_result'=>0,
        },
        {
            summary => 'List all scripts that have "csv" in their name, show full path of each script',
            argv => [qw/csv --type=script -p/],
            test => 0,
            'x.doc.show_result'=>0,
        },
    ],
    links => [
        {url=>'prog:list-all-programs-in-path'},
        {url=>'prog:scriptlist'},
    ],
};
sub proglist {
    require File::Which;

    my %args = @_;

    my $re = $args{query} || qr//;

    my @res;
    for my $dir (split /:/, $ENV{PATH}) {
        opendir my $dh, $dir or next;
        for my $e (readdir $dh) {
            next if $e eq '.' || $e eq '..';
            next if -d $e;
            next unless $e =~ $re;
            if ($args{type}) {
                my $is_bin = -B "$dir/$e";
                next if $args{type} eq 'script' &&  $is_bin;
                next if $args{type} eq 'binary' && !$is_bin;
            }
            push @res, $args{full_path} ? "$dir/$e" : $e;
        }
    }
    [200, "OK", \@res];
}

{
    my $res = gen_modified_sub(
        output_name => 'scriptlist',
        base_name => 'proglist',
        summary => 'List scripts matching query',
        description => <<'MARKDOWN',

This is a wrapper for <prog:proglist>, it adds the `--type=script` option.

MARKDOWN
        remove_args => ['type'],
        modify_meta => sub {
            my $meta = shift;
            $meta->{examples} = [];
        },
        output_code => sub {
            proglist(@_, type=>'script');
        },
    );
    die "Can't generate scriptlist(): $res->[0] - $res->[1]" unless $res->[0] == 200;
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
