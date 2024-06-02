package Adapter::Logger;

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(log_info);

sub log_info {
    my ($content) = @_;
    print "Info: $content\n";
}
