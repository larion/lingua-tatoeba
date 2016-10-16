package Lingua::Tatoeba::Item;

use Moose;
use MooseX::HasDefaults::RO;
use MooseX::StrictConstructor;
use namespace::autoclean;

has id => (
    isa => 'Num',
    required => 1,
);

has lang => (
    isa      => 'Str',
    required => 1,
);

has text => (
    isa      => 'Str',
    required => 1,
);

has collection => (
    isa      => 'Lingua::Tatoeba',
    required => 1,
);

sub get_related {
    my ($self) = @_;

    return $self->collection->get_related($self->id);
}

__PACKAGE__->meta->make_immutable();
no Moose;
1;

=pod

=head1 NAME

Lingua::Tatoeba::Item - an object representating a single Tatoeba sentence

=head1 SYNOPSIS

    my $sentence = $tatoeba->get(42);
    printf("%s: %s", $sentence->lang, $sentence->text);

=head1 FUNCTIONS

=head2 my @rel = $item->get_related()

Fetch related items

=head1 ACCESSORS

=head2 id

The ID

=head2 lang

The ISO-639-3 language code of the sentence

=head2 text

The sentence itself

=head2 collection

A reference to the L<Lingua::Tatoeba> object this item comes from.

=cut
