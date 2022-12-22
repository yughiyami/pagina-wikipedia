#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml');

my $title = $q->param('title');
my $owner = $q->param('owner');

if(defined($title) && defined($owner) && check($title, $owner)){
  my @article = check($title, $owner);
  my $cuerpoXML= renderBody(@article);
  print renderXML($cuerpoXML);
}else{
  print renderXML();
}
sub check{
  my $user = 'alumno';
  my $password = 'pweb1';
  my $title = $_[0];
  my $owner = $_[1];
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");
  my $sql = "SELECT * FROM Articles WHERE title=? AND owner=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($title, $owner);
  my @row = $sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return @row;
}

sub renderBody{
  my $title = $_[0];
  my $owner = $_[1];
  my $text = $_[2];

  my $cuerpo = <<"BODY";
    <owner>$owner</owner>
    <title>$title</title>
    <text>$text</text>
BODY
  return $cuerpo;
}

sub renderXML{
  my $cuerpo = "";
  if(defined($_[0])){
    $cuerpo .= $_[0];
  }
    my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
    <article>
      $cuerpo
    </article>
XML
return $xml
}
