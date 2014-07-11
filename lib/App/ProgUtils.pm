package App::ProgUtils;

use 5.010001;
use strict;
use warnings;

# VERSION
# DATE

our $_complete_program = sub {
    require Complete::Util;
    my %args = @_;

    my $word = $args{word} // '';
    my $completion;
    my $is_path;
    if ($word =~ m#/#) {
        # if user specify path, e.g. ./foo, ../bar, or /usr/bin/ it means she
        # wants to complete from filesystem. but note that complete_file()
        # doesn't yet support ci=>1 option.
        $is_path = 1;
        $completion = Complete::Util::complete_file(
            word => $word,
            #ci   => 1, # convenience
        );
    } else {
        $completion = Complete::Util::complete_program(
            word      => $args{word},
            ci        => 1, # convenience
        );
    }

    {
        completion => $completion,
        is_path    => $is_path,
    };
};

1;
# ABSTRACT: Command line to manipulate programs in PATH

=head1 SYNOPSIS

This distribution provides the following command-line utilities:

 progless
 progedit
 progman

=head1 SEE ALSO

B<which>

=cut
