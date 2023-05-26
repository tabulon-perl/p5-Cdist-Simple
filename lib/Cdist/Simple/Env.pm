package Cdist::Simple::Env;

# ABSTRACT: Easy access to the ENVIRONMENT VARIABLES used by the Cdist Configuration Manager
our $VERSION = '0.001000';

use strict;
use warnings;
use Readonly; ## no critic

BEGIN {
  sub cdist_ro_vars {
    qw(
      __cdist_colored_log
      __cdist_dry_run
      __cdist_log_level
      __cdist_log_level_name
      __explorer
      __files
      __global
      __manifest
      __messages_in
      __messages_out
      __object
      __object_id
      __object_name
      __target_fqdn
      __target_host
      __target_host_tags
      __target_hostname
      __type
      __type_explorer
    )
  }

  sub cdist_rw_vars {
    qw(
      require
      __cdist_log_level
      CDIST_BETA
      CDIST_CACHE_PATH_PATTERN
      CDIST_COLORED_OUTPUT
      CDIST_INVENTORY_DIR
      CDIST_LOCAL_SHELL
      CDIST_ORDER_DEPENDENCY
      CDIST_OVERRIDE
      CDIST_PATH
      CDIST_REMOTE_COPY
      CDIST_REMOTE_EXEC
      CDIST_REMOTE_SHELL
    )
  }

  sub cdist_vars {(
    cdist_ro_vars(),
    cdist_rw_vars(),
  )}

  sub cdist_log_levels {
    my %res = ( OFF => 60, ERROR => 40, WARNING => 30, INFO => 20, VERBOSE => 15, DEBUG => 10, TRACE => 5);
    wantarray ? %res : \%res  ## no critic
  }

  sub cdist_meta {(
      ro_vars => [ cdist_ro_vars() ],
      rw_vars => [ cdist_rw_vars() ],
      vars    => [ cdist_vars()    ],
      log_levels   => { cdist_log_levels()   },
  )}

}

# CDIST LOG LEVELS
Readonly our %CLL_        => cdist_log_levels();

Readonly our $CLL_OFF     => $CLL_{OFF};
Readonly our $CLL_ERROR   => $CLL_{ERROR};
Readonly our $CLL_WARNING => $CLL_{WARNING};
Readonly our $CLL_INFO    => $CLL_{INFO};
Readonly our $CLL_VERBOSE => $CLL_{VERBOSE};
Readonly our $CLL_DEBUG   => $CLL_{DEBUG};
Readonly our $CLL_TRACE   => $CLL_{TRACE};


use Env (  cdist_ro_vars(), cdist_rw_vars() );

use Exporter::Handy::Util qw(expand_xtags);
use Exporter::Handy -exporter_setup => 1;

our %EXPORT_TAGS= (
  env     => [qw(:meta :vars :const)],

  # meta
  meta    => [ map { ( 'cdist_' . "$_") } qw(meta vars ro_vars rw_vars log_levels) ],

  # environment variables (tied as regular variables, thanks to the 'Env' module
  vars  => [qw(:ro :rw)],
  ro    => [( map { '$' . "$_" } cdist_ro_vars() )],
  rw    => [( map { '$' . "$_" } cdist_rw_vars() )],

  # constants
  const      => [qw(:log_levels)],
  log_levels => ['%CLL_', ( map { '$CLL_' . "$_" } (sort keys %CLL_) )], # LOG LEVELS
);
export( expand_xtags(\%EXPORT_TAGS, values %EXPORT_TAGS) );


1;


=pod

=encoding UTF-8

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=cut
