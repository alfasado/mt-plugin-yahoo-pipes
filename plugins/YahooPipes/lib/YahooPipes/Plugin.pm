package YahooPipes::Plugin;
use strict;
use HTTP::Request::Common;
use LWP::UserAgent;
use JSON qw/decode_json/;

sub _YahooPipes {
    my ( $ctx, $args, $cond ) = @_;
    my $text = $args->{ text };
    my $input = $args->{ input };
    my $output = $args->{ output };
    my $app_id = $args->{ _id };
    if ( (! $text ) || (! $input ) || (! $output ) || (! $app_id ) ) {
        return '';
    }
    my $pipes = 'http://pipes.yahoo.com/pipes/pipe.run';
    my $req = POST( $pipes, [ $input => $text,
                              _id => $app_id,
                              _render => 'json' ] );
    my $ua   = LWP::UserAgent->new;
    my $res  = $ua->request( $req );
    if ( $res->is_error ) {
        my $plugin = MT->component( 'YahooPipes' );
        MT->instance->log( {
            message => $plugin->translate( 
                'An error occurred while trying to post to Yahoo! Pipes : [_1]', $res->status_line ),
            class => 'yahoopipes',
            level => MT::Log::ERROR(),
        } );
        return '';
    }
    my $json = $res->content;
    my $data = decode_json( $json );
    return $data->{ value }->{ items }[0]->{ $output };
}

1;