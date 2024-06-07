package Dpb::Run;

use strict;
use warnings;

use Cwd;
use Moose;
use Moose::Util::TypeConstraints;
use POSIX ":sys_wait_h";
use Getopt::Long qw(GetOptionsFromArray);
use Adapter::Git;

subtype 'LoggerRoleObject',
    as 'Object',
    where { $_->does('Role::LoggerRole') },
    message { "The object you provided does not implement LoggerRole" };

subtype 'TargetExecutionStrategyObject',
    as 'Object',
    where { $_->does('Role::TargetExecutionStrategy') },
    message { "The object you provided does not implement TargetExecutionStrategy" };

has 'logger' => (
    is       => 'ro',
    isa      => 'LoggerRoleObject',
    required => 1
);

has 'target_executor' => (
    is       => 'ro',
    isa      => 'TargetExecutionStrategyObject',
    required => 1
);

my constant $DEFAULT_INTERVAL = 10;

sub _show_usage {
    print <<EOD;
usage: $0 run [-h | --help] [-i | --interval <minutes>] <target_directory_path>

Options:
  -h    print this help message and exit
  -i    set the interval of minutes between deployments (default: $DEFAULT_INTERVAL)
EOD
}

sub _test_log {
    my ($self) = @_;
    $self->logger->info("**This channel is assigned to [0] dpb standard log**");
    $self->logger->error("**This channel is assigned to [1] dpb error log**");
}

sub _load_target_info {
    my ($target_dir) = @_;
    my $absolute_target_dir = Cwd::abs_path($target_dir);
    my $original_dir = getcwd();

    chdir($target_dir) or die "Directory $target_dir not found: $!\n";

    my ($origin_url, $error) = get_origin_url;
    die $error if defined $error;

    (my $branch_name, $error) = get_branch_name;
    die $error if defined $error;
    die "You are in 'detached HEAD' state.\n" if $branch_name eq "HEAD";

    my %result = (
        path => $absolute_target_dir,
        origin_url => $origin_url,
        branch_name => $branch_name
    );

    print "--- TARGET INFO ---\n";
    while (my ($key, $value) = each %result) {
        print "$key: $value\n";
    }
    print "\n";

    return %result
}

sub _exec_repotitory {
    my ($self) = @_;
    my $error = $self->{target_executor}->execute;
    if (defined $error) {
        $self->{logger}->error("Target run-time error: $error");
    } else {
        $self->{logger}->info("The target execution has completed successfully.")
    }
    exit 0;
}

sub _needs_deploy {
    my $self = shift;
    return 1 if $self->{_initial_pull};

    $self->logger->info("Checking for remote updates...");
    my ($remote_latest_commit, $error) = get_remote_latest_commit_hash $self->{_branch_name};
    if (defined $error) {
        $self->logger->error($error);
        return 0;
    }
    return $self->{_prev_commit} ne $remote_latest_commit
}

sub _depoy {
    my $self = shift;

    $self->{_initial_pull} = 0;

    $self->logger->info("Applying remote changes...");
    my ($result, $error) = pull_reposiotory $self->{_branch_name};
    return $error if defined $error;

    $self->logger->info("Restarting the process...");
    if ($self->{_exec_pid}) {
        kill 'TERM', $self->{_exec_pid};
        waitpid($self->{_exec_pid}, 0);
    }

    if (my $pid = fork()) {     # parent process
        $self->{_exec_pid} = $pid;
    } elsif (defined $pid) {    # child process
        _exec_repotitory $self;
    } else {
        return "Failed to fork: $!\n";
    }

    ($result, $error) = get_currect_commit_hash;
    return $error if defined $error;
    $self->{_prev_commit} = $result;

    return undef
}

sub run {
    my $self = shift;
    my @args = @_;
    my $interval = $DEFAULT_INTERVAL;

    GetOptionsFromArray(\@args,
        "help|h"       => sub { _show_usage; exit; },
        "interval|i=i" => \$interval,
    ) or exit 1;

    if (@args != 1) {  _show_usage; exit 1; }

    my %info = _load_target_info $args[0];

    $self->{_branch_name} = $info{branch_name};
    $self->{_initial_pull} = 1;
    $self->{_prev_commit} = "";
    $self->{_exec_pid} = 0;

    print "--- START RUNNING ---\n";
    $self->logger->info("**dpb (DeployBot) started.**");
    _test_log $self;

    while (1) {
        if (_needs_deploy $self) {
            my $error = _depoy $self;
            if (defined $error) {
                $self->logger->error("Deploy failed: $error");
            } else {
                $self->logger->info("Deployment complete.");
            }
        } else {
            $self->logger->info("No updates.");
        }

        sleep($interval * 60);
    }
}

1;
