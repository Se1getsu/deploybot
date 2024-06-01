#!/usr/bin/perl

use strict;
use warnings;

use Cwd;
use POSIX ":sys_wait_h";

if (@ARGV != 1) {
    die "Usage: $0 <target_directory_path>\n";
}

my $target_dir = $ARGV[0];
my $original_dir = getcwd();

chdir($target_dir) or die "Directory $target_dir not found: $!\n";

my $initial_pull = 1;
my $prev_commit = "";
my $main_pid = 0;

while (1) {
    my $git_pull_output = `git pull origin test`;   # TODO: ブランチ名書き換え
    die "Failed to execute git pull: $!\n" if $?;

    my $current_commit = `git rev-parse HEAD`;
    chomp($current_commit);
    die "Failed to get current commit hash: $!\n" if $?;

    if ($initial_pull || $prev_commit ne $current_commit) {
        $initial_pull = 0;

        if ($main_pid) {
            kill 'TERM', $main_pid;
            waitpid($main_pid, 0);
        }

        if (my $pid = fork()) {
            $main_pid = $pid;
        } elsif (defined $pid) {
            exec('python3', 'main.py') or die "Failed to execute main.py: $!\n";
        } else {
            die "Failed to fork: $!\n";
        }
        $prev_commit = $current_commit;
    }

    sleep(10);  # TODO: スリープ間隔戻す
    # sleep(300); # Wait for 5 minutes
}
