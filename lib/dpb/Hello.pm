package Dpb::Hello;

use strict;
use warnings;

sub run {
    my $class = shift;
    my @args = @_;

    print "Hello, world!\n";
    print "Additional arguments: @args\n" if @args;
}

1;
