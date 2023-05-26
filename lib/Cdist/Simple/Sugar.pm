package Cdist::Simple::Sugar;

# ABSTRACT: Sugar for the Cdist Configuration Manager
our $VERSION = '0.001000';

use strict;
use warnings;

use IO::Handle;
use namespace::autoclean;
use Text::Trim        qw( trim );


use Cdist::Simple::Util qw(flat);
use Cdist::Simple::Env  qw(:all);

use Exporter::Handy::Util qw(expand_xtags);
use Exporter::Handy -exporter_setup => 1;

our %EXPORT_TAGS = (
  sugar     => [qw( ensure item )],
);
export( expand_xtags(\%EXPORT_TAGS, values %EXPORT_TAGS) );


# cdist SUGAR & synonms
sub item   { goto &ensure }  ## no critic
sub ensure {
  local $_;
  my (@args, @reqs, %env, %opt);

  # Process our own options that may be mixed with the rest
  ARG: for (my $i=0; $i < @_; $i++ ) {

    my $arg = $_ = $_[$i];

    ref($arg) =~ m/^ARRAY$/i and do { push @args, $arg; next ARG };
    ref($arg) =~ m/^HASH$/i  and do { %env = (%env, %{; $arg } );  next ARG };


    if ( m/^(--(.*))?[:](.*)?([:]?(.*))?$/ ) {
      # eg-1: __link /tmp/testlink --source:REQUIRED:file /etc/cdist-configured
      # eg-2: __file /tmp/testdir/testfile --state present --:REQUIRES __directory/tmp/testdir

      my ($ropt, $mopt, $marg) = ($1 // '', lc($3 // ''), $5 // '');

      SWITCH: {
          m/^(strict)$/i        and do { $opt{strict} = 1; last SWITCH                 };
          m/^(require)(d|s)?$/i and do { push @reqs, $_[$i+1]; last SWITCH };
      }

      push @args, "--${ropt}" if $ropt;
      next ARG;
    }

    # the usual case
    push @args, $arg;
  }

  # finalize the dependency list
  @reqs = flat( cdist_reqs( $ENV{require}, $env{require}) );
  $env{require} = join("\t", @reqs);

  # finalize args (still includes the type name)
  @args = flat( @args );

  # identify the type and object
  my $type = cdist_type(shift @args) or return;
  my $gid  = cdist_gid($type, $args[0]);

  # Invoke the requested program (typically a cdist type shim)
  {
  local $ENV{$_} = $env{$_} for (keys %env);

  system( $type, @args ) == 0  or die "system @args failed: $?";
  }

  $gid
}

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

__END__

=pod

=encoding UTF-8

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=cut