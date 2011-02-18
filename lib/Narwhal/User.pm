package Narwhal::User;
use Moose;

with 'KiokuDB::Role::ID';

has id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has is_anon => (
    is      => 'ro',
    isa     => 'Str',
    default => 0,
);

sub kiokudb_object_id { 'user:' . shift->id }

__PACKAGE__->meta->make_immutable;
no Moose;

1;
