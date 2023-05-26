#/usr/bin/env perl

our $VERSION = '0.001000';
use strict;
use warnings;

use IO::Handle;
use Cdist::Simple::Cmd qw(cmd_ensure);


cmd_ensure( @ARGV );
