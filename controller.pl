#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

use Mojo::File ();

get '/' => sub ($c) {
  $c->render(template => 'index');
} => 'index';

post '/' => sub ($c) {
  my $params = $c->every_param('pad');
  my $file = Mojo::File->new('./controller.yaml');
  my $content = join "\n", @$params;
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
<table>
% for my $row (1 .. 8) {
  <tr>
%   for my $col (1 .. 8) {
    <td>
      <input type="text" class="" name="pad" maxlength="10" size="4">
    </td>
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
