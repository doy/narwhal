package Narwhal::Component::Model;
use Moose;

extends 'KiokuX::Model';

sub get_user {
    my $self = shift;
    my ($user_id) = @_;
    return $self->lookup("user:$user_id");
}

sub get_page {
    my $self = shift;
    my ($page_id) = @_;
    return $self->lookup("page:$page_id");
}

sub get_page_rev {
    my $self = shift;
    my ($page_id, $page_rev) = @_;
    my $rev = $self->lookup($page_rev);
    return unless $rev;
    return unless $rev->page_id eq $page_id;
    return $rev;
}

sub create_page_rev {
    my $self = shift;
    my %opts = @_;

    my $page_name = delete $opts{page_name};
    my $page = $self->get_page($page_name);

    if ($page) {
        $page->new_revision(%opts);
    }
    else {
        $page = Narwhal::Page->new_page(
            id => $page_name,
            %opts,
        );
    }

    $self->store($page);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
