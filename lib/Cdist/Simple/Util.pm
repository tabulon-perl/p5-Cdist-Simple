package Cdist::Simple::Util;

# ABSTRACT: Utilities for Cdist::Simple
our $VERSION = '0.001000';

use strict;
use warnings;

use List::Util        qw( pairs uniq );
use Text::ParseWords  qw( shellwords );
use Text::Trim        qw( trim );

use Exporter::Handy::Util qw(expand_xtags);
use Exporter::Handy -exporter_setup => 1;

our %EXPORT_TAGS = (
  util  => [ qw(:io :list :text :words) ],
  io    => [ qw(cat slurp) ],
  list  => [ qw(flat) ],
  text  => [ qw(trim) ],
  words => [ qw(shellwords) ],
);
export( expand_xtags(\%EXPORT_TAGS, values %EXPORT_TAGS) );


#== General purpose UTILITIES

# File
sub cat   { goto &slurp }
sub slurp {
    my ($path) = @_;
    ## no critic
    return unless open( my $fh, $path );
    local ($/);
    <$fh>
}

# List
sub _is_plain_arrayref { ref( $_[0] ) eq 'ARRAY' }
sub flat { # shamelessly copied from: [List::Flat](https://metacpan.org/pod/List::Flat)
  my @results;

  while (@_) {
    if ( _is_plain_arrayref( my $element = shift @_ ) ) {
        unshift @_, @{$element};
    }
    else {
        push @results, $element;
    }
  }
  return wantarray ? @results : \@results;  ## no critic
}

# Hash
sub prefix_keys {
  # prefix keys (every odd item within pairs) with a given string
  my $prefix = shift // '';
  my %hash   = (@_);

  my %res = map {
    ( "$prefix" . "$_" , $hash{$_} )
  } keys %hash;

  return wantarray ? %res : \%res;  ## no critic
}


1;

__END__

=pod

=encoding UTF-8

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=cut