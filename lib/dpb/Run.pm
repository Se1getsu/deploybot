package Dpb::Run;

use strict;
use warnings;

use Cwd;
use POSIX ":sys_wait_h";

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

sub get_currect_commit {
    my $current_commit = `git rev-parse HEAD`;
    die "Failed to get current commit hash: $!\n" if $?;
    return $current_commit
}

sub get_remote_latest_commit {
    my ($branch_name) = @_;
    my $remote_latest_commit = `git ls-remote --heads origin $branch_name | cut -f 1`;
    die "Failed to execute git ls-remote: $!\n" if $?;
    return $remote_latest_commit
}

sub pull_reposiotory {
    system("git pull -q origin test") == 0 or die "Failed to execute git pull: $!\n";
}

sub exec_repository {
    exec('python3', 'main.py') or die "Failed to execute main.py: $!\n";
}

sub run {
    my $class = shift;
    my @args = @_;

    if (@args != 1) {
        die "Usage: $0 <target_directory_path>\n";
    }

    my $target_dir = $args[0];
    my $absolute_target_dir = Cwd::abs_path($target_dir);
    my $original_dir = getcwd();

    chdir($target_dir) or die "Directory $target_dir not found: $!\n";

    my $origin_url = get_origin_url;
    my $branch_name = get_branch_name;
    die "You are in 'detached HEAD' state.\n" if $branch_name eq "HEAD";

    print <<EOD;
--- TARGET INFO ---
path: $absolute_target_dir
origin_url: $origin_url
branch_name: $branch_name

--- START RUNNING ---
EOD

    my $initial_pull = 1;
    my $prev_commit = "";
    my $main_pid = 0;

    while (1) {
        print "INFO: Checking for remote updates...\n";
        my $remote_latest_commit = get_remote_latest_commit $branch_name;

        if ($initial_pull || $prev_commit ne $remote_latest_commit) {
            $initial_pull = 0;

            print "INFO: Applying remote changes...\n";
            pull_reposiotory;

            print "INFO: Restarting the process...\n";
            if ($main_pid) {
                kill 'TERM', $main_pid;
                waitpid($main_pid, 0);
            }

            if (my $pid = fork()) {     # parent process
                $main_pid = $pid;
                print "INFO: Deployment complete.\n";
            } elsif (defined $pid) {    # child process
                exec_repository;
            } else {
                die "Failed to fork: $!\n";
            }

            $prev_commit = get_currect_commit;
        } else {
            print "INFO: No updates.\n"
        }

        sleep(10);  # TODO: スリープ間隔戻す
        # sleep(300); # Wait for 5 minutes
    }
}

1;
