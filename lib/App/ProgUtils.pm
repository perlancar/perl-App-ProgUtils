package App::ProgUtils;

use 5.010001;
use strict;
use warnings;

# VERSION
# DATE

our $_complete_program = sub {
    require Complete::Util;
    my %args = @_;
    Complete::Util::mimic_shell_dir_completion(
        completion => Complete::Util::complete_program(
            word      => $args{word},
            ci        => 1,
        )
    );
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
