package Adapter::Logger;

use strict;
use warnings;

use DateTime;
use Moose;
with 'Role::LoggerRole';

sub new {
    my ($class) = @_;
    return bless {}, $class;
}

sub info {
    my ($self, $message) = @_;
    my $timestamp = DateTime
        ->now(time_zone => 'Asia/Tokyo')
        ->strftime('%Y-%m-%d %H:%M:%S');
    print STDOUT "[$timestamp] INFO: $message\n";
}

sub error {
    my ($self, $message) = @_;
    my $timestamp = DateTime
        ->now(time_zone => 'Asia/Tokyo')
        ->strftime('%Y-%m-%d %H:%M:%S');
    print STDERR "[$timestamp] ERROR: $message\n";
}

1;
