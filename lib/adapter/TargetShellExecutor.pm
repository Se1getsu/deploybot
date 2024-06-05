package Adapter::TargetShellExecutor;

use strict;
use warnings;

use Moose;
with 'Role::TargetExecutionStrategy';

sub new {
    my ($class, %args) = @_;
    my $self = {
        _target_info_webhook_url   => $args{info_webhook},
        _target_error_webhook_url  => $args{error_webhook},
    };
    return bless $self, $class;
}

sub execute {
    my ($self) = @_;
    my $command = 'sh run.sh';
    my $info_webhook = $self->{_target_info_webhook_url};
    my $error_webhook = $self->{_target_error_webhook_url};
    my $out = `$command $info_webhook $error_webhook 2>&1`;
    if ($?) {
        my $error = <<EOD;
`run.sh` exited with a non-zero exit code.: $?
```
\$ $command \$info_webhook \$error_webhook
$out
```
EOD
        return $error;
    } else {
        return undef;
    }
}

1;
