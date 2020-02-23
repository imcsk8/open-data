#!/usr/bin/perl
#
# Revisa csv de sensp

use strict;
use Text::CSV qw( csv );
use Data::Dumper;

my @months = ('Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre');

my $DATA_DIR = "sensp";

# Check only 2019 for now
my $DATA_FILE = "$DATA_DIR/IDVFC_NM_dic19-2019-UTF-8.csv";
my $sensp_data = csv (in => $DATA_FILE,
               headers => "auto", encoding => "UTF-8"); 
my %h = %{$sensp_data->[0]};

my $keys = keys(%{$sensp_data->[0]});

my $total_delitos_mujeres = 0;
my $total_delitos_hombres = 0;
my $total_delitos_nd = 0;
my $total_hom_culposo = 0;
my $total_hom_doloso = 0;
my $total_hom_doloso_hombres = 0;
my $total_hom_doloso_mujeres = 0;
my $total_hom_doloso_nd = 0;
my $total_feminicidio = 0;
foreach my $h (@{$sensp_data}) {

    #ugly hack, fix this
	if($h->{'Sexo'} =~ /Hombre/) {
		$total_delitos_hombres += get_line_total($h);
	}
	elsif($h->{'Sexo'} =~ /Mujer/)	{
		$total_delitos_mujeres += get_line_total($h);
	}
	else {
		$total_delitos_nd += get_line_total($h);
	}

    if($h->{'Tipo de delito'} eq "Feminicidio") {
        $total_feminicidio += get_line_total($h); 
    }

    if($h->{'Tipo de delito'} eq "Homicidio") {
        if($h->{'Subtipo de delito'} =~ /doloso/) {
            $total_hom_doloso += get_line_total($h);
			if($h->{'Sexo'} =~ /Hombre/) {
				$total_hom_doloso_hombres += get_line_total($h);
			}
			elsif($h->{'Sexo'} =~ /Mujer/)	{
				$total_hom_doloso_mujeres += get_line_total($h);
			}
			else {
				$total_hom_doloso_nd += get_line_total($h);
			}
        }

        if($h->{'Subtipo de delito'} =~ /culposo/) {
            $total_hom_culposo += get_line_total($h);
        }
    }
}


my $total_hom = $total_hom_culposo + $total_hom_doloso + $total_feminicidio;
my $percent_hom_doloso_hombres = $total_hom_doloso_hombres * 100 /  $total_hom_doloso;
my $percent_hom_doloso_mujeres = $total_hom_doloso_mujeres * 100 /  $total_hom_doloso; 
my $percent_hom_doloso_nd = $total_hom_doloso_nd * 100 /  $total_hom_doloso;

print "Total Homicidios Culposos 2019: $total_hom_culposo\n";
print "Total Homicidios Dolosos 2019: $total_hom_doloso\n";
print "Total Homicidios Dolosos Hombres 2019: $total_hom_doloso_hombres" . 
  " ($percent_hom_doloso_hombres %)\n";
print "Total Homicidios Dolosos Mujeres 2019: $total_hom_doloso_mujeres" . 
  " ($percent_hom_doloso_mujeres %)\n";
print "Total Homicidios Dolosos No identificado 2019: $total_hom_doloso_nd" .
  " ($percent_hom_doloso_nd %)\n";
print "Total Homicidios 2019: $total_hom\n";

my $total_delitos = $total_delitos_mujeres + $total_delitos_hombres + $total_delitos_nd;
my $percent_delitos_hombres = $total_delitos_hombres * 100 / $total_delitos;
my $percent_delitos_mujeres = $total_delitos_mujeres * 100 / $total_delitos;
my $percent_delitos_nd = $total_delitos_nd * 100 / $total_delitos;
my $percent_feminicidio = $total_feminicidio * 100 / $total_delitos;
my $percent_feminicidio_homicidios = $total_feminicidio * 100 / $total_hom;

print "Total Delitos Mujeres 2019: $total_delitos_mujeres" .
" ($percent_delitos_mujeres %)\n";
print "Total Delitos Hombres 2019: $total_delitos_hombres" .
" ($percent_delitos_hombres %)\n";
print "Total Delitos No identificado 2019: $total_delitos_nd" .
" ($percent_delitos_nd %)\n";

print "Total Feminicidios 2019: $total_feminicidio" .
" ($percent_feminicidio %)\n";

print "Los Feminicidios son el $percent_feminicidio_homicidios del total de homicidios\n";
# Get the yearly total of the felony

sub get_line_total {
    my $line = shift;
    my $total = 0;
    foreach my $m (@months) {
        #print "Getting month $m felony: " . $line->{'Tipo de delito'} . " total mensual " . $line->{$m} . "\n";
        $total += $line->{$m};
    }
    return $total;
}
