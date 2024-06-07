package Dpb::SetLog;

use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);
use Adapter::WebhookURLRepository;

sub _show_usage {
    print <<EOD;
usage: $0 set-log [-h | --help] <webhook-url> <index>
       $0 set-log default <index>

Options:
  -h    print this help message and exit
EOD
}

sub run {
    my $self = shift;
    my @args = @_;

    GetOptionsFromArray(\@args,
        "help|h"       => sub { _show_usage; exit; },
    ) or exit 1;

    my ($webhook, $index) = @args;

    unless (@_ == 2 && ($webhook =~ m{^(?:https?)://\S+$} || $webhook eq "default") && $index =~ /^\d+$/) {
        _show_usage; exit 1;
    }
    unless (1 <= $index && $index <= 4) {
        print "Invalid index: $index\n";
        exit 1;
    }

    my @urls = load_urls;
    $urls[$index - 1] = $webhook;
    save_urls @urls;
}

1;
