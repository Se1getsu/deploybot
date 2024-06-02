package Adapter::Git;

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(get_origin_url get_branch_name get_currect_commit_hash get_remote_latest_commit_hash pull_reposiotory);

sub get_origin_url {
    my $origin_url = `git remote get-url origin`;
    chomp $origin_url;
    die "Failed to execute git remote get-url origin: $!\n" if $?;
    return $origin_url;
}

sub get_branch_name {
    my $branch_name = `git rev-parse --abbrev-ref HEAD`;
    chomp $branch_name;
    die "Failed to execute git rev-parse --abbrev-ref HEAD: $!\n" if $?;
    return $branch_name;
}

sub get_currect_commit_hash {
    my $current_commit = `git rev-parse HEAD`;
    die "Failed to get current commit hash: $!\n" if $?;
    return $current_commit
}

sub get_remote_latest_commit_hash {
    my ($branch_name) = @_;
    my $remote_latest_commit = `git ls-remote --heads origin $branch_name | cut -f 1`;
    die "Failed to execute git ls-remote: $!\n" if $?;
    return $remote_latest_commit
}

sub pull_reposiotory {
    system("git pull -q origin test") == 0 or die "Failed to execute git pull: $!\n";
}

1;
