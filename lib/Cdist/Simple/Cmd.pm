package Cdist::Simple::Cmd;

# ABSTRACT: Gist of the sugar for the Cdist Configuration Manager
our $VERSION = '0.001000';

use strict;
use warnings;

use IO::Handle;

use Cdist::Simple::Env  qw(:all);
use Cdist::Simple::Sugar qw(ensure);

use Exporter::Handy::Util qw(expand_xtags);
use Exporter::Handy -exporter_setup => 1;

our %EXPORT_TAGS= (
  cmd     => [ qw( cmd_ensure )  ],
);
export( expand_xtags(\%EXPORT_TAGS, values %EXPORT_TAGS) );


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



1;

__END__


=pod

=encoding UTF-8

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=cut
