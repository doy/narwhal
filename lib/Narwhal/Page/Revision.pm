package Narwhal::Page::Revision;
use KiokuDB::Class;

use DateTime;

with 'KiokuDB::Role::ID::Digest', 'MooseX::Clone';

has page_id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has text => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has author => (
    is       => 'ro',
    isa      => 'Narwhal::User',
    required => 1,
);

has modification_date => (
    traits  => ['NoClone'],
    is      => 'ro',
    isa     => 'DateTime',
    default => sub { DateTime->now },
);

has previous_revision => (
    traits => ['KiokuDB::Lazy'],
    is     => 'ro',
    isa    => 'Narwhal::Page::Revision',
);

sub new_revision {
    my $self = shift;
    $self->clone(
        previous_revision => $self,
        @_,
    );
}

sub digest_parts {
    my $self = shift;
    return (
        $self->page_id,
        $self->text,
        $self->modification_date->iso8601,
        $self->author->id,
        ($self->previous_revision ? $self->previous_revision->digest : ''),
    );
}

__PACKAGE__->meta->make_immutable;
no KiokuDB::Class;

1;
