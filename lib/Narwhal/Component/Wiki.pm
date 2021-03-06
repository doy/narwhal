package Narwhal::Component::Wiki;
use Moose;

with 'Narwhal::Component::Role::Wiki';

sub view {
    my $self = shift;
    my ($req, $page_name) = @_;

    my $page = $self->get_page($page_name);
    if (!$page) {
        my $res = $req->new_response(303);
        $res->location(
            $req->uri_for({
                action     => 'edit',
                page_name  => $page_name,
            })
        );
        return $res;
    }

    $self->render(
        $req,
        'page.tt',
        {
            page     => $page_name,
            text     => $page->text,
            author   => $page->author,
            modified => $page->modification_date,
        },
    );
}

sub view_old {
    my $self = shift;
    my ($req, $page_name, $rev) = @_;

    my $page_rev = $self->get_page_rev($page_name, $rev);
    return $req->new_response(404)
        unless $page_rev;

    $self->render(
        $req,
        'page.tt',
        {
            page       => $page_name,
            text       => $page_rev->text,
            author     => $page_rev->author,
            modified   => $page_rev->modification_date,
            historical => 1,
        },
    );
}

sub history {
    my $self = shift;
    my ($req, $page_name) = @_;

    my $page = $self->get_page($page_name);

    $self->render(
        $req,
        'history.tt',
        {
            page => $page_name,
            head => $page->current_revision,
        }
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
