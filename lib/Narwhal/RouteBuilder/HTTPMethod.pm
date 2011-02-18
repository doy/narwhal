package Narwhal::RouteBuilder::HTTPMethod;
use Moose;

with 'OX::RouteBuilder';

sub import {
    my $meta = Class::MOP::class_of(caller);
    $meta->add_route_builder(
        class      => __PACKAGE__,
        route_spec => sub {
            my $spec = shift;
            return if ref($spec);
            return unless $spec =~ /^http-method:(\w+)$/;
            return {
                action => $1,
            };
        },
    );
}

sub compile_routes {
    my $self = shift;

    my $spec = $self->route_spec;
    my $params = $self->params;

    my ($defaults, $validations) = $self->extract_defaults_and_validations($params);
    $defaults = { %$spec, %$defaults };

    my $s = $self->service;

    return [
        $self->path,
        defaults    => $defaults,
        target      => sub {
            my ($req) = @_;

            my %match = %{ $req->env->{'plack.router.match'}->mapping };
            my $a = $match{action};
            my $component = $s->get_dependency($a)->get;
            my $method = lc($req->method);

            if ($component->can($method)) {
                return $component->$method(@_);
            }
            elsif ($component->can('any')) {
                return $component->any(@_);
            }
            else {
                return [
                    500,
                    [],
                    ["Component $component has no method $method"]
                ];
            }

        },
        validations => $validations,
    ];
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
