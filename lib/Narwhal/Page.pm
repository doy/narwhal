package Narwhal::Page;
use Moose;

use Narwhal::Page::Revision;

with 'KiokuDB::Role::ID';

has current_revision => (
    is       => 'rw',
    isa      => 'Narwhal::Page::Revision',
    required => 1,
    handles => {
        id                => 'page_id',
        text              => 'text',
        author            => 'author',
        modification_date => 'modification_date',
    },
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
    my $rev = Narwhal::Page::Revision->new(page_id => $id, %opts);
    return $class->new(
        current_revision => $rev,
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
