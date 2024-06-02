package Adapter::WebhookURLRepository;

use strict;
use warnings;

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(save_urls load_urls);

use File::Path qw(make_path);
use FindBin;

my $dir = "$FindBin::Bin/data";
my $filename = "$dir/webhook_url";

sub _ensure_directory {
    unless (-d $dir) {
        make_path($dir) or die "Could not create directory '$dir': $!";
    }
}

sub save_urls {
    my (@urls) = @_;

    _ensure_directory();

    open my $fh, '>', $filename or die "Could not open file '$filename' $!";
    foreach my $url (@urls) {
        print $fh "$url\n";
    }
    close $fh;
}

sub load_urls {
    _ensure_directory();

    open my $fh, '<', $filename or die "Could not open file '$filename' $!";
    my @urls = <$fh>;
    chomp @urls;
    close $fh;
    return @urls;
}

1;
