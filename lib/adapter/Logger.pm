package Adapter::Logger;

use strict;
use warnings;

use Moose;
with 'Role::LoggerRole';

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub info {
    my ($self, $message) = @_;
    my $timestamp = localtime;
    print "[$timestamp] INFO: $message\n";
}

1;
