package Narwhal::Component::Redirect;
use Moose;

sub permanent {
    my $self = shift;
    my ($req) = @_;
    my $res = $req->new_response(301);
    $res->location($self->_get_location($req));
    return $res;
}

sub temporary {
    my $self = shift;
    my ($req) = @_;
    my $res = $req->new_response(302);
    $res->location($self->_get_location($req));
    return $res;
}

sub _get_location {
    my $self = shift;
    my ($req) = @_;
    my $to = $req->env->{'plack.router.match'}->mapping->{to};
    die "must supply a location to redirect to" unless $to;
    return $to;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
