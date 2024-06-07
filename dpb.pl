#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use Service::Factory;
use Getopt::Long;

my $_version = "1.0.0-dev";

sub show_version {
    print "dpb version $_version\n";
}

sub show_usage {
    print <<EOD;
usage: $0 [-v | --version] [-h | --help] <command> [<args>]

Options:
  -h    print this help message and exit
  -v    print the dpb version number and exit

Commands:
  hello   send "Hello, world!" as an dpb info log
  run     start target execution and periodic deployments
  log     print the list of webhooks configured to receive logs
  set-log edit the list of webhooks configured to receive logs
EOD
}

GetOptions(
    "version|v"  => sub { show_version; exit; },
    "help|h"  => sub { show_usage; exit; },
) or exit 1;

my %subcommands = (
    'hello'   => 'Dpb::Hello',
    'run'     => 'Dpb::Run',
    'log'     => 'Dpb::Log',
    'set-log' => 'Dpb::SetLog',
);

my $subcommand = shift @ARGV;
unless ($subcommand) { show_usage; exit 1; }

if (exists $subcommands{$subcommand}) {
    my $module = $subcommands{$subcommand};
    create($module)->run(@ARGV);
} else {
    print "Unknown subcommand: $subcommand\n";
    exit 1;
}
