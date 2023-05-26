package Cdist::Simple::Misc;

# ABSTRACT: Glue for the Cdist Configuration Manager
our $VERSION = '0.001000';

use strict;
use warnings;

use Text::Trim        qw( trim );
# use Cdist::Simple::Util qw(trim);

use Exporter::Handy::Util qw(expand_xtags);
use Exporter::Handy -exporter_setup => 1;

our %EXPORT_TAGS= (
  misc     => [ map { 'cdist_' . "$_" } qw( type id gid reqs ) ],
);
export( expand_xtags(\%EXPORT_TAGS, values %EXPORT_TAGS) );

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

=pod

=encoding UTF-8

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=cut
