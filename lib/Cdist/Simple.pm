package Cdist::Simple;

our $VERSION = '0.001000';

use v5.14;  # Exporter::Almighty requires perl v5.12+.
use strict;
use warnings;


use IO::Handle;
use namespace::autoclean;


use Cdist::Simple::Env  qw(:meta :vars);
use Cdist::Simple::Util qw(:all);

no warnings qw(redefine);

use Exporter::Almighty -setup => {
  tag => {
    # functions
    functions     => [ qw(:util :cdist) ],

    tag_group( cdist => {
      cmd         => [ qw( cmd_ensure )  ],
      sugar       => [ qw( ensure item ) ],
      meta        => [ map { ( 'cdist_' . "$_") } qw( meta vars ro_vars rw_vars log_levels_native log_levels_prefixed ) ],
      misc        => [ map { ( 'cdist_' . "$_") } qw( id gid type reqs ) ],
      log_levels  => [ cdist_log_levels_prefixed() ]
    }),

    tag_group( util => {
      %Cdist::Simple::Util::EXPORT_TAGS
    }),

    # environment variables (tied as regular variables)
    tag_group( env => {
      ro    => [( map { '$' . "$_" } cdist_ro_vars() )],
      rw    => [( map { '$' . "$_" } cdist_rw_vars() )],
    }),

  },
  also => [
    'strict',
    'warnings',
  ],
};





1;
__END__

=head1 NAME

Cdist::Simple - Module abstract placeholder text

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
