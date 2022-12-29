#!/usr/bin/perl
use strict;
use warnings;
use CGI;
use DBI;

my $q = CGI->new;
print $q->header('text/xml; charset= UTF-8');
my $owner = $q->param('owner');
my $title = $q->param('title');

print STDERR "$owner.$title\n";

my @consulta;
if(defined($owner) and defined($title)){
  print STDERR "los datos estan lleno\n";
  @consulta = buscarBD($owner,$title);
  print STDERR "@consulta\n";
  if(@consulta){
    print STDERR "se encontro\n";
    print STDERR "@consulta\n";
    push(@consulta,$title);
    push(@consulta, $owner);
    print STDERR "@consulta\n";
    my $cuerpoXML =renderCuerpo(@consulta);
    print renderXML($cuerpoXML);
  }else{
    print STDERR "no se encontro\n";
    print renderXML(@consulta);
  }

}else{
  print STDERR "no estan completos los campos\n";
  print renderXML(@consulta);
}

sub buscarBD{
  my $owner =$_[0];
  my $title = $_[1];
  my $user = 'alumno';
  my $password = 'pweb1';
  my $dsn = 'DBI:MariaDB:database=pweb1;host=192.168.5.30';
  my $dbh = DBI->connect($dsn, $user, $password) or die
  die("No se pudo conectar!");
  my $sql = "SELECT text FROM Articles WHERE owner=? AND title=?";
  my $sth = $dbh->prepare($sql);
  $sth->execute($owner,$title);
  my @textArticles;
  while(my @row=$sth->fetchrow_array){
    push(@textArticles, @row);

  }

  $sth->finish;
  $dbh->disconnect;
  return @textArticles;
}

sub renderCuerpo{
  my $owner = $_[2];
  my $title = $_[1];
  my $text = $_[0];
  my $cuerpo = <<"CUERPO";
            <owner>$owner</owner>
                <title>$title</title>
                <text>$text</text>
CUERPO
  return $cuerpo;
}

sub renderXML{
  my $cuerpoxml = $_[0];
  my $xml = <<"XML";
<?xml version='1.0' encoding= 'utf-8'?>
      <article>
        $cuerpoxml
      </article>
XML
  return $xml
}
