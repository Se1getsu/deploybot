package Dpb::Hello;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

subtype 'LoggerRoleObject',
    as 'Object',
    where { $_->does('Role::LoggerRole') },
    message { "The object you provided does not implement LoggerRole" };

has 'logger' => (
    is       => 'ro',
    isa      => 'LoggerRoleObject',
    required => 1
);

sub run {
    my $self = shift;
    my @args = @_;

    $self->logger->info("Hello, world!");
    $self->logger->info("Additional arguments: @args") if @args;
}

1;
