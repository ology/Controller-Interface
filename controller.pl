#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

use Mojo::File ();
use Music::Scales qw(get_scale_notes);
use YAML qw(LoadFile);

sub mapping {
  return {
    57 =>  1,
    58 =>  2,
    59 =>  3,
    60 =>  4,

    49 =>  5,
    50 =>  6,
    51 =>  7,
    52 =>  8,

    41 =>  9,
    42 => 10,
    43 => 11,
    44 => 12,

    33 => 13,
    34 => 14,
    35 => 15,
    36 => 16,

    25 => 17,
    26 => 18,
    27 => 19,
    28 => 20,

    17 => 21,
    18 => 22,
    19 => 23,
    20 => 24,

     9 => 25,
    10 => 26,
    11 => 27,
    12 => 28,

     1 => 29,
     2 => 30,
     3 => 31,
     4 => 32,

    61 => 33,
    62 => 34,
    63 => 35,
    64 => 36,

    53 => 37,
    54 => 38,
    55 => 39,
    56 => 40,

    45 => 41,
    46 => 42,
    47 => 43,
    48 => 44,

    37 => 45,
    38 => 46,
    39 => 47,
    40 => 48,

    29 => 49,
    30 => 50,
    31 => 51,
    32 => 52,

    21 => 53,
    22 => 54,
    23 => 55,
    24 => 56,

    13 => 57,
    14 => 58,
    15 => 59,
    16 => 60,

     5 => 61,
     6 => 62,
     7 => 63,
     8 => 64,

  };
};

get '/' => sub ($c) {
  my $config = LoadFile('./controller.yaml');
  $c->render(
    template => 'index',
    device   => $config->{device},
    size     => 8,
    params   => $config->{triggers},
    mapping  => mapping(),
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
    my $input = $p =~ /(?:alt|ctrl|meta|shift|super|F\d+)/ ? 'key' : 'text';
    my $trigger =<<"PARAM";
  - event: 'note-on'
    data: '$data'
    $input: '$p'
PARAM
    $content .= $trigger;
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
<p></p>
<form method="post">
<input type="text" class="form-control" name="device" value="<%= $device %>" placeholder="Device">
<p></p>
<table>
% my $n = 0;
% for my $row (1 .. $size) {
  <tr>
%   for my $col (1 .. $size) {
    <td>
      <input type="text" class="" name="pad" size="6" value="<%= $mapping->{ $n + 1 } %>">
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
% title 'MIDI Controller Interface';
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
