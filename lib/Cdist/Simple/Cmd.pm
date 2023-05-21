package Cdist::Simple::Cmd;

our $VERSION = '0.001000';

use v5.14;  # Exporter::Almighty requires perl v5.12+.
use strict;
use warnings;


use IO::Handle;

use Cdist::Simple::Env  qw(:all);
use Cdist::Simple::Util qw(:all);
use Cdist::Simple::Sugar qw(ensure);

use Exporter::Almighty -setup => {
  tag => {
    subs         => [ qw( cmd_ensure )  ],
  }
};


sub cmd_ensure {
# Same as 'ensure()', but this one is suitable as the main() routine
# of a script. Just invoke : cmd_ensure( @ARGV )

  my @reqs;

  # Collect and harmonize dependencies
  # By our convention, ALTIN (fd-4) may be used for this purpose.
  for my $fh ( IO::Handle->new() // () ) {
    if ( $fh->fdopen(4, "r") ) {
      push @reqs, slurp($fh) and close($fh);
    }
  }

  my $gid = ensure( @_, '--:REQUIRES' => \@reqs );
  return unless $gid // '';

  # print the cdist object-GID on ALTOUT (fd-5)
  for my $fh ( IO::Handle->new() // () ) {
    if ( $fh->fdopen(5, "w") ) {
      print $fh "${gid}\n" and close($fh);
    }
  }
}



42;

__END__

=head1 NAME

Cdist::Simple::Cmd - Module abstract placeholder text

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
