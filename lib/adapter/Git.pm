package Adapter::Git;

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(get_origin_url get_branch_name get_currect_commit_hash get_remote_latest_commit_hash pull_reposiotory);

sub _execute {
    my ($command, $error_message) = @_;
    my $result = qx{bash -c '$command' 2>&1};
    if ($? == 0) {
        return ($result, undef);
    } else {
        my $error = <<EOD;
$error_message
```
\$ $command
$result
```
EOD
        return (undef, $error);
    }
}

sub get_origin_url {
    my ($res, $err) = _execute("git remote get-url origin",
                    "Failed to execute git remote get-url origin.");
    chomp $res;
    return ($res, $err);
}

sub get_branch_name {
    my ($res, $err) = _execute("git rev-parse --abbrev-ref HEAD",
                    "Failed to execute git rev-parse --abbrev-ref HEAD.");
    chomp $res;
    return ($res, $err);
}

sub get_currect_commit_hash {
    return _execute("git rev-parse HEAD",
                    "Failed to get current commit hash.");
}

sub get_remote_latest_commit_hash {
    my ($branch_name) = @_;
    return _execute("git ls-remote --heads origin $branch_name | cut -f 1",
                    "Failed to execute git ls-remote.");
}

sub pull_reposiotory {
    return _execute("git pull -q origin test",
                    "Failed to execute git pull.");
}

1;
