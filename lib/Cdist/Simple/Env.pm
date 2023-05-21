
package Cdist::Simple::Env;

our $VERSION = '0.001000';

use v5.14;  # Exporter::Almighty requires perl v5.12+.
use strict;
use warnings;

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

  sub cdist_vars {
    ( cdist_ro_vars(), cdist_rw_vars() )
  }

  sub cdist_log_levels_native {
    my %res = ( OFF => 60, ERROR => 40, WARNING => 30, INFO => 20, VERBOSE => 15, DEBUG => 10, TRACE => 5);
    wantarray ? %res : \%res  ## no critic
  }

  sub cdist_log_levels_prefixed {
    my $prefix = $_[0] // 'CDIST_LOG_';
    my %res = _prefix_keys( $prefix, cdist_log_levels_native());
    wantarray ? %res : \%res  ## no critic
  }

  sub cdist_meta {
    (
      ro_vars => [ cdist_ro_vars() ],
      rw_vars => [ cdist_rw_vars() ],
      vars    => [ cdist_vars()    ],
      log_levels_native   => { cdist_log_levels_native()   },
      log_levels_prefixed => { cdist_log_levels_prefixed()  },
    )
  }

  # PRIVATE routines
  sub _prefix_keys {
    # prefix keys (every odd item within pairs) with a given string
    my $prefix = shift // '';
    my %hash   = (@_);

    map {
      ( "$prefix" . "$_" , $hash{$_} )
    } keys %hash;
  }

}

use Env (  cdist_ro_vars(), cdist_rw_vars(), cdist_log_levels_native() );
use Exporter::Handy 'xtags', -exporter_setup => 1;

export(
  xtags(
    meta    => [ map { ( 'cdist_' . "$_") } qw( meta vars ro_vars rw_vars log_levels_native log_levels_prefixed ) ],

    # environment variables (tied as regular variables, thanks to the 'Env' module
    ro    => [( map { '$' . "$_" } cdist_ro_vars() )],
    rw    => [( map { '$' . "$_" } cdist_rw_vars() )],
  ),
  # const => {
  #  log_levels             => { cdist_log_levels_prefixed() },
  # },
);


42;
