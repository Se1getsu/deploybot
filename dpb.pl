#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Adapter::Logger;
use Service::Factory;

my %subcommands = (
    'hello'   => 'Dpb::Hello',  # TODO: Delete this sample subcommand
    'run'     => 'Dpb::Run',
    'log'     => 'Dpb::Log',
    'set-log' => 'Dpb::SetLog',
);

my $subcommand = shift @ARGV;

unless ($subcommand) {
    print "Usage: $0 <subcommand> [options]\n";
    exit 1;
}

if (exists $subcommands{$subcommand}) {
    my $module = $subcommands{$subcommand};
    create($module)->run(@ARGV);
} else {
    print "Unknown subcommand: $subcommand\n";
    exit 1;
}
