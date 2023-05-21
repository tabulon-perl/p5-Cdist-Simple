package Cdist::Simple;

our $VERSION = '0.001000';

use v5.14;  # Exporter::Almighty requires perl v5.12+.
use strict;
use warnings;


use Cdist::Simple::Util qw(:all);

use Exporter::Almighty -setup => {
  tag => {
    misc     => [ map { 'cdist_' . "$_" } qw( type id gid reqs ) ],
  },
};


# Miscellenous functions related to cdist
sub cdist_type {
  local $_ = (@_  ? $_[0] : $_);
  trim;
  return undef  unless defined;
  return undef  if m/^[-]/;
  return "$_"   if m/^__/;
  return "__${_}"
}

sub cdist_id {
  local $_ = (@_  ? $_[0] : $_);
  trim;
  return if m/^[-]/;
  $_
}

sub cdist_gid {
  my ($type, $id) = ( cdist_type(shift) // '', cdist_id(shift) // '');

  join( '/', $type || (), $id || () )
}

sub cdist_reqs {
  local $_;

  my @reqs;
  while (@_) {
    my $arg   = shift;
    next unless defined $arg && $arg;
    # avoid mingling with ARRAY elements
    ref($arg) =~ m/^ARRAY$/ and do { push @reqs, @$arg; next };

    push @reqs, shellwords($arg);
  }
  uniq( @reqs );
}




1;
__END__

=head1 NAME

Cdist::Simple::Misc - Module abstract placeholder text

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=head1 AUTHOR

Tabulo[n] <dev@tabulo.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2023 by Tabulo[n].

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
