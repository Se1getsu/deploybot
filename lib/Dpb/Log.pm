package Dpb::Log;

use strict;
use warnings;

use Adapter::WebhookURLRepository 'load_urls';

sub run {
    my $self = shift;
    my @args = @_;

    my @urls = load_urls;
    while(my ($i,$url) = each @urls){
        print(($i+1) . ": $url\n");
    }
}

1;
