package Dpb::SetLog;

use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);
use Adapter::WebhookURLRepository;

sub _show_usage {
    print <<EOD;
usage: $0 set-log [-h | --help] <webhook-url> <index>

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

    my ($given_url, $index) = @args;

    unless (@_ == 2 && $given_url =~ m{^(?:https?)://\S+$} && $index =~ /^\d+$/) {
        _show_usage; exit 1;
    }
    unless (0 <= $index && $index <= 3) {
        print "Invalid index: $index\n";
        exit 1;
    }

    my @urls = load_urls;
    $urls[$index] = $given_url;
    save_urls @urls;
}

1;
