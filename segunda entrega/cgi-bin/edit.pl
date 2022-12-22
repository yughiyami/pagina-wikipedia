#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
my $title = $q->param('title');
my $owner = $q->param('owner');

my $user = 'alumno';
my $password = 'pweb1';
my $dsn = "DBI:MariaDB:database=pweb1;host=192.168.5.30";
my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");;

my $sth = $dbh->prepare("SELECT text FROM Articles WHERE title=? AND owner=?");
$sth->execute($title,$owner);
my @row = $sth->fetchrow_array;

$sth->finish;
$dbh->disconnect;

if(@row){
  print $q->header('text/html;charset=UTF-8');
  my $body = renderBody($title,@row,$owner);
  print renderHTMLpage('Update',$body);
}else{
  #Imprime el XML
  print $q->header('text/xml');
  print "<?xml version='1.0' encoding='utf-8' ?>\n";
  print "<article>\n</article>\n";
}

sub renderBody{
  my $title = $_[0];
  my $text = $_[1];
  my $owner = $_[2];
  my $body = <<"BODY";
     <form action="./update.pl">
      <input type="text" name="title" value="$title" readonly><br/>
      <label for="text">Texto: </label>
      <textarea name="text" required>$text</textarea><br/>
      <input type="text" name="owner" value="$owner" readonly><br/>
      <input type="submit" value="Enviar">
    </form>
    <br/>
    <a href="../index.html">Cancelar</a>
BODY
  return $body;
}

sub renderHTMLpage {
  my $title = $_[0];
  my $body = $_[1];
  my $html = <<"HTML";
  <!DOCTYPE html>
  <html lang="es">
    <head>
      <title>$title</title>
      <meta charset="UTF-8">
    </head>
    <body>
      $body
    </body>
  </html>
HTML
  return $html;
}
