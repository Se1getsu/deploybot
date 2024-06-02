package Dpb::SetLog;

use strict;
use warnings;

use Adapter::WebhookURLRepository;

sub run {
    my $self = shift;
    my ($given_url, $index) = @_;

    unless (@_ == 2 && $given_url =~ m{^(?:https?)://\S+$} && $index =~ /^\d+$/) {
        print "Usage: $0 run <webhook-url> <index>\n";
        exit 1;
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
