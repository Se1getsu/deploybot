#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Module::Load;
use Adapter::Logger;

my %subcommands = (
    'hello'   => 'Dpb::Hello',  # TODO: Delete this sample subcommand
    'run'     => 'Dpb::Run',
    'log'     => 'Dpb::Log',
);

my $subcommand = shift @ARGV;

unless ($subcommand) {
    print "Usage: $0 <subcommand> [options]\n";
    exit 1;
}

if (exists $subcommands{$subcommand}) {
    my $module = $subcommands{$subcommand};
    load $module;
    if ($subcommand eq 'log') {
        $module->run(@ARGV);
    } else {
        $module->new(
            logger => Adapter::Logger->new()
        )->run(@ARGV);
    }
} else {
    print "Unknown subcommand: $subcommand\n";
    exit 1;
}
