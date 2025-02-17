#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

use Mojo::File ();
use Music::Scales qw(get_scale_notes);
use YAML qw(LoadFile);

sub mapping {
  return {
    # pad quadrant => table data index
     1 => { index => 57, quadrant => 1 },
     2 => { index => 58, quadrant => 1 },
     3 => { index => 59, quadrant => 1 },
     4 => { index => 60, quadrant => 1 },

     5 => { index => 49, quadrant => 1 },
     6 => { index => 50, quadrant => 1 },
     7 => { index => 51, quadrant => 1 },
     8 => { index => 52, quadrant => 1 },

     9 => { index => 41, quadrant => 1 },
    10 => { index => 42, quadrant => 1 },
    11 => { index => 43, quadrant => 1 },
    12 => { index => 44, quadrant => 1 },

    13 => { index => 33, quadrant => 1 },
    14 => { index => 34, quadrant => 1 },
    15 => { index => 35, quadrant => 1 },
    16 => { index => 36, quadrant => 1 },

    17 => { index => 25, quadrant => 2 },
    18 => { index => 26, quadrant => 2 },
    19 => { index => 27, quadrant => 2 },
    20 => { index => 28, quadrant => 2 },

    21 => { index => 17, quadrant => 2 },
    22 => { index => 18, quadrant => 2 },
    23 => { index => 19, quadrant => 2 },
    24 => { index => 20, quadrant => 2 },

    25 => { index =>  9, quadrant => 2 },
    26 => { index => 10, quadrant => 2 },
    27 => { index => 11, quadrant => 2 },
    28 => { index => 12, quadrant => 2 },

    29 => { index =>  1, quadrant => 2 },
    30 => { index =>  2, quadrant => 2 },
    31 => { index =>  3, quadrant => 2 },
    32 => { index =>  4, quadrant => 2 },

    33 => { index => 61, quadrant => 3 },
    34 => { index => 62, quadrant => 3 },
    35 => { index => 63, quadrant => 3 },
    36 => { index => 64, quadrant => 3 },

    37 => { index => 53, quadrant => 3 },
    38 => { index => 54, quadrant => 3 },
    39 => { index => 55, quadrant => 3 },
    40 => { index => 56, quadrant => 3 },

    41 => { index => 45, quadrant => 3 },
    42 => { index => 46, quadrant => 3 },
    43 => { index => 47, quadrant => 3 },
    44 => { index => 48, quadrant => 3 },

    45 => { index => 37, quadrant => 3 },
    46 => { index => 38, quadrant => 3 },
    47 => { index => 39, quadrant => 3 },
    48 => { index => 40, quadrant => 3 },

    49 => { index => 29, quadrant => 4 },
    50 => { index => 30, quadrant => 4 },
    51 => { index => 31, quadrant => 4 },
    52 => { index => 32, quadrant => 4 },

    53 => { index => 21, quadrant => 4 },
    54 => { index => 22, quadrant => 4 },
    55 => { index => 23, quadrant => 4 },
    56 => { index => 24, quadrant => 4 },

    57 => { index => 13, quadrant => 4 },
    58 => { index => 14, quadrant => 4 },
    59 => { index => 15, quadrant => 4 },
    60 => { index => 16, quadrant => 4 },

    61 => { index =>  5, quadrant => 4 },
    62 => { index =>  6, quadrant => 4 },
    63 => { index =>  7, quadrant => 4 },
    64 => { index =>  8, quadrant => 4 },

  };
};

get '/' => sub ($c) {
  my $config = LoadFile('./controller.yaml');
  my %mapping = mapping()->%*;
  my %reversed = map { $mapping{$_}{index} => $_ } keys %mapping;
  my %quadrants = map { $mapping{$_}{index} => $mapping{$_}{quadrant} } keys %mapping;
  $c->render(
    template  => 'index',
    device    => $config->{device},
    size      => 8,
    params    => $config->{triggers},
    mapping   => \%reversed,
    quadrants => \%quadrants,
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
    my $m = mapping()->{ $n + 1 }{index} - 1;
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
    <td class="">
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
