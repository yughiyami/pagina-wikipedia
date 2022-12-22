#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml');

my $title = $q->param('title');
my $text = $q->param('text');
my $owner = $q->param('owner');

if(checkOwner($owner) && defined($title) && defined($text) && defined($owner)){
  insertaBD($title, $text, $owner);
  my $cuerpoXML= renderBody($title, $text);
  print renderXML($cuerpoXML);
}else{
  print renderXML();
}
sub checkOwner{
  my $user = 'alumno';
  my $password = 'pweb1';
  my $owner = $_[0];
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.1.7';
  my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");
  my $sql = "SELECT * FROM Users WHERE userName=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner);
  my @row = $sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return @row;
}
sub insertaBD{
  my $user = 'alumno';
  my $password = 'pweb1';
  my $title = $_[0];
  my $text = $_[1];
  my $owner = $_[2];
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");
  my $sql = "INSERT INTO Articles(title,owner,text)VALUES(?,?,?)";
  my $sth = $dbh->prepare($sql);
  $sth->execute($title, $owner, $text);
  $sth->finish;
  $dbh->disconnect;
}

sub renderBody{
  my $title = $_[0];
  my $text = $_[1];
  my $cuerpo = <<"BODY";
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