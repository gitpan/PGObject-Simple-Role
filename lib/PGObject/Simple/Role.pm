package PGObject::Simple::Role;

use 5.006;
use strict;
use warnings;
use Moo::Role;
use PGObject::Simple;
use Carp;

=head1 NAME

PGObject::Simple::Role - Moo/Moose mappers for minimalist PGObject framework

=head1 VERSION

Version 0.10

=cut

our $VERSION = '0.10';


=head1 SYNOPSIS

Take the following (Moose) class:

    package MyAPP::Foo;
    use Moose;
    with 'PGObject::Simple::Role';

    has id  => (is => 'ro', isa => 'Int', required => 0);
    has foo => (is => 'ro', isa => 'Str', required => 0);
    has bar => (is => 'ro', isa => 'Str', required => 0);
    has baz => (is => 'ro', isa => 'Int', required => 0);

    sub get_dbh {
        return DBI->connect('dbi:Pg:dbname=foobar');
    }

And a stored procedure:  

    CREATE OR REPLACE FUNCTION foo_to_int
    (in_id int, in_foo text, in_bar text, in_baz int)
    RETURNS INT LANGUAGE SQL AS
    $$
    select char_length($2) + char_length($3) + $1 * $4;
    $$;

Then the following Perl code would work to invoke it:

    my $foobar = MyApp->foo(id => 3, foo => 'foo', bar => 'baz', baz => 33);
    $foobar->call_dbmethod(funcname => 'foo_to_int');

The full interface of call_dbmethod and call_procedure from PGObject::Simple are
supported.

=head1 DESCRIPTION



=head1 ATTRIBUTES AND LAZY GETTERS

=cut

# Private attribute for database handle, not intended to be directly set.

has _PGObject_DBH => ( 
       is => 'lazy', 
       isa => sub { 
                    croak "Expected a database handle.  Got $_[0] instead"
                       unless eval {$_[0]->isa('DBI::db')};
       },
);

sub _build__PGObject_DBH {
    my ($self) = @_;
    return $self->_get_dbh;
}

has _PGObject_FuncPrefix => (is => 'lazy');

=head1 _get_prefix

Returns string, default is an empty string, used to set a prefix for mapping
stored prcedures to an object class.

=cut

sub _build__PGObject_FuncPrefix {
    return $_[0]->_get_prefix;
}

sub _get_prefix {
    return '';
}

has _PGObject_Simple => (
    is => 'lazy',
);

sub _build__PGObject_Simple {
    return PGObject::Simple->new();
}

=head2 _get_dbh

Subclasses or sub-roles MUST implement a function which returns a DBI database
handle (DBD::Pg 2.0 or hgher required).  If this is not overridden an exception
will be raised.

=cut

sub _get_dbh {
    croak 'Subclasses MUST set their own get_dbh methods!';
}

=head2 call_procedure

Identical interface to PGObject::Simple->call_procedure

=cut

sub call_procedure {
    my $self = shift @_;
    my %args = @_;
    $args{dbh} ||= $self->_PGObject_DBH;
    $args{funcprefix} = $self->_PGObject_FuncPrefix 
           if not defined $args{funcprefix};
    return $self->_PGObject_Simple->call_procedure(%args);
}

=head2 call_dbmethod

Identical interface to PGObject::Simple->call_dbmethod

=cut

sub call_dbmethod {
    my $self = shift @_;
    my %args = @_;
    $args{dbh} ||= $self->_PGObject_DBH;
    $args{funcprefix} = $self->_PGObject_FuncPrefix 
           if not defined $args{funcprefix};
    for my $key(keys %$self){
        $args{args}->{$key} = $self->{$key} unless defined $args{args}->{$key};
    }
    return $self->_PGObject_Simple->call_dbmethod(%args);
}

=head1 AUTHOR

Chris Travers,, C<< <chris.travers at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pgobject-simple-role at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PGObject-Simple-Role>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PGObject::Simple::Role


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PGObject-Simple-Role>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PGObject-Simple-Role>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PGObject-Simple-Role>

=item * Search CPAN

L<http://search.cpan.org/dist/PGObject-Simple-Role/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Chris Travers,.

Redistribution and use in source and compiled forms with or without 
modification, are permitted provided that the following conditions are met:

=over

=item 

Redistributions of source code must retain the above
copyright notice, this list of conditions and the following disclaimer as the
first lines of this file unmodified.

=item 

Redistributions in compiled form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
source code, documentation, and/or other materials provided with the 
distribution.

=back

THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of PGObject::Simple::Role
