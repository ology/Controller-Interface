#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

use Mojo::File ();
use Music::Scales qw(get_scale_notes);
use YAML qw(LoadFile);

get '/' => sub ($c) {
  my $config = LoadFile('./controller.yaml');
  $c->render(
    template => 'index',
    device   => $config->{device},
    params   => $config->{triggers},
  );
} => 'index';

post '/' => sub ($c) {
  my $device = $c->param('device') || 'Synido TempoPAD Z-1';
  my $params = $c->every_param('pad');
  my @scale = get_scale_notes('C', 'chromatic', 0, '#');
  my $file = Mojo::File->new('./controller.yaml');
  my $content =<<"TEXT";
debug: 1
device: $device
triggers:
TEXT
  my $n = 0;
  my $octave = 1;
  for my $p (@$params) {
    my $data = $scale[ $n % scalar(@scale) ] . $octave;
    my $text =<<"PARAM";
  - event: 'note-on'
    data: '$data'
    text: '$p'
PARAM
    $content .= $text;
    $octave++ if scalar(@scale) - 1 == $n % scalar(@scale);
    $n++;
  }
  $file->spew($content);
  $c->redirect_to('index');
} => 'setting';

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'MIDI Controller Interface';
<p></p>
<form method="post">
<input type="text" class="form-control" name="device" value="<%= $device %>" placeholder="Device">
<p></p>
<table>
% my $n = 0;
% for my $row (1 .. 8) {
  <tr>
%   for my $col (1 .. 8) {
    <td>
      <input type="text" class="" name="pad" maxlength="10" size="4" value="<%= $params->[$n]{text} %>">
    </td>
%     $n++;
%   }
  </tr>
% }
</table>
<p></p>
<button type="submit" class="btn btn-primary">Submit</button>
</form>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
    <script src="/js/jquery.min.js"></script>
    <script src="/js/bootstrap.min.js" integrity="sha384-cVKIPhGWiC2Al4u+LWgxfKTRIcfu0JTxR+EQDz/bgldoEyl4H0zUF0QKbrJ0EcQF" crossorigin="anonymous"></script>
    <link rel="stylesheet" href="/css/style.css">
    <title><%= title %></title>
  </head>
  <body>
    <p></p>
    <div class="container">
% if (flash('error')) {
      <h2 style="color:red"><%= flash('error') %></h2>
% }
      <h2><a href="<%= url_for('index') %>"><%= title %></a></h2>
      <%= content %>
      <p></p>
    </div>
  </body>
</html>
