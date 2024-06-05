package Adapter::TargetShellExecutor;

use strict;
use warnings;

use Moose;
with 'Role::TargetExecutionStrategy';

sub execute {
    my $command = 'sh run.sh';
    my $out = `$command 2>&1`;
    if ($?) {
        my $error = <<EOD;
`run.sh` exited with a non-zero exit code.: $?
```
\$ $command
$out
```
EOD
        return $error;
    } else {
        return undef;
    }
}

1;
