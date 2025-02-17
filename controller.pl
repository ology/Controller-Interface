#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

use Mojo::File ();
use Music::Scales qw(get_scale_notes);
use YAML qw(LoadFile);

sub mapping {
  return {
    57 => 13,
    58 => 14,
    59 => 15,
    60 => 16,

    49 => 29,
    50 => 30,
    51 => 31,
    52 => 32,

    41 => 45,
    42 => 46,
    43 => 47,
    44 => 48,

    33 => 61,
    34 => 62,
    35 => 63,
    36 => 64,

    25 =>  9,
    26 => 10,
    27 => 11,
    28 => 12,

    17 => 25,
    18 => 26,
    19 => 27,
    20 => 28,

     9 => 41,
    10 => 42,
    11 => 43,
    12 => 44,

     1 => 57,
     2 => 58,
     3 => 59,
     4 => 60,

    61 =>  5,
    62 =>  6,
    63 =>  7,
    64 =>  8,

    53 => 21,
    54 => 22,
    55 => 23,
    56 => 24,

    45 => 37,
    46 => 38,
    47 => 39,
    48 => 40,

    37 => 53,
    38 => 54,
    39 => 55,
    40 => 56,

    29 =>  1,
    30 =>  2,
    31 =>  3,
    32 =>  4,

    21 => 17,
    22 => 18,
    23 => 19,
    24 => 20,

    13 => 33,
    14 => 34,
    15 => 35,
    16 => 36,

     5 => 49,
     6 => 50,
     7 => 51,
     8 => 52,

  };
};

get '/' => sub ($c) {
  my $config = LoadFile('./controller.yaml');
  my %reversed = reverse mapping()->%*;
  $c->render(
    template => 'index',
    device   => $config->{device},
    size     => 8,
    params   => $config->{triggers},
    mapping  => \%reversed,
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
  my $octave = 1;
  for my $n (0 .. $#$params) {
    my $m = mapping()->{ $n + 1 } - 1;
    my $p = $params->[$m];
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
%     my $m = $mapping->{ $n + 1 } - 1;
    <td>
      <input type="text" class="" name="pad" size="6" value="<%= $params->[$m]{key} || $params->[$m]{text} %>">
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
