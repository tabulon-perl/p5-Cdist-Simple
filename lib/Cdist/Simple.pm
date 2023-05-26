package Cdist::Simple;

# ABSTRACT: Simple glue and sugar for the Cdist Configuration Manager
our $VERSION = '0.001000';

use strict;
use warnings;


use Cdist::Simple::Env    -exporter_setup => 1;
use Cdist::Simple::Misc   -exporter_setup => 1;
use Cdist::Simple::Sugar  -exporter_setup => 1;
use Cdist::Simple::Util   -exporter_setup => 1;

1;

__END__

=pod

=encoding UTF-8

=head1 SYNOPSIS

=for comment Brief examples of using the module.

=head1 DESCRIPTION

=for comment The module's description.

=cut
