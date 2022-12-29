#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml; charset=UTF-8');

my $owner = $q->param('owner');
print STDERR "$owner\n";

if(defined($owner)){
  my @articles = buscarBD($owner);
  if(@articles){
    print STEDERR "@articles";
    push(@articles, $owner);
    my  $articlesXML =renderCuerpo(@articles);
    print STDERR  "$articlesXML";
    print renderXML($articlesXML);

  }else{
    print STDERR "no se encontro dicho dao\n";
    print renderXML();
  }
}else{
  print STDERR "nose ingreso datos\n";
  print renderXML();
}
sub buscarBD{
  my $owner = $_[0];
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';

  my $dbh = DBI->connect($dsn, $user, $password) or die
  ('No se pudo conectar');
  my $sql = "SELECT title FROM Articles WHERE owner=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner);
  my @articles;
  while(my @row = $sth->fetchrow_array){
    push(@articles, @row);
  }
  return @articles;
}

sub renderCuerpo{
  my @titulos = @_;
  my $len = @titulos;
  my $lista = "";
  for (my $i = 0 ; $i < $len-1; $i++){
    $lista .= "     <article>
         <owner>$titulos[$len-1]</owner>
         <title>$titulos[$i]</title>
      </article>\n";
  }
  return $lista;
}
sub renderXML{
  my $cuerpoxml = $_[0];
  my $xml = <<"XML";
<?xml version= '1.0' encoding = 'utf-8'?>  
   <articles>
   $cuerpoxml
   </articles>
XML
  return $xml;
}
