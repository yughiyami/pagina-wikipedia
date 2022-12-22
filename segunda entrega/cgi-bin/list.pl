#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml');

my $owner = $q->param('owner');

if(defined($owner) && checkOwner($owner)){
  my $cuerpoXML = searchBD($owner);
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
  my $sql = "SELECT * FROM Articles WHERE owner=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner);
  my @row = $sth->fetchrow_array;
  $sth->finish;
  $dbh->disconnect;
  return @row;
}
sub searchBD{
  my $user = 'alumno';
  my $password = 'pweb1';
  my $owner = $_[0];
  my $body = "";
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die("No se pudo conectar!");
  my $sql = "SELECT * FROM Articles WHERE owner=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner);
  while(my @row = $sth->fetchrow_array){
    $body .= renderBody(@row);
  }
  $sth->finish;
  $dbh->disconnect;
  return $body;
}

sub renderBody{
  my $title = $_[0];
  my $owner = $_[1];
  my $cuerpo = <<"BODY";
    <article>
      <owner>$owner</owner>
      <title>$title</title>
    </article>
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
    <articles>
      $cuerpo
    </articles>
XML
return $xml
}