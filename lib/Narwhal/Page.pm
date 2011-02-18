package Narwhal::Page;
use Moose;

use Narwhal::Page::Revision;

with 'KiokuDB::Role::ID';

has id => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has current_revision => (
    is       => 'rw',
    isa      => 'Narwhal::Page::Revision',
    required => 1,
    handles  => ['text', 'author', 'modification_date'],
);

sub kiokudb_object_id { 'page:' . shift->id }

sub new_revision {
    my $self = shift;
    my $rev = $self->current_revision->new_revision(@_);
    $self->current_revision($rev);
    return $rev;
}

sub new_page {
    my $class = shift;
    my %opts = @_;
    my $id = delete $opts{id};
    my $rev = Narwhal::Page::Revision->new(%opts);
    return $class->new(
        id               => $id,
        current_revision => $rev,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
