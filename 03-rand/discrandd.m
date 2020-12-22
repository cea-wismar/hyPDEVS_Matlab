function y=discrandd(genno,prob_tab)
% y=DISCRANDD(genno,prob_tab)  Spezialisierung der Funktion disc.
% Eine Zahl x (hier aus dem Bereich [0,1], erzeugt mit rand) wird 
% ueber eine Tabelle prob_tab in eine Zahl y umkodiert.
% Die erste Spalte entspricht der Eingangs-, die zweite Spalte der
% Ausgangsinformation:
%           -Inf      < x <= prob_tab(1,1) ==> y=prob_tab(2,1)
%      prob_tab(1,1)  < x <= prob_tab(1,2) ==> y=prob_tab(2,2)
%                      ...
%     prob_tab(1,n-1) < x <     +Inf       ==> y=prob_tab(2,n)
% Ueblicherweise dient diese Funktion der Erzeugung von Zufallszahlen nach
% einer diskreten Verteilung.
% Die erste Spalte von prob_tab beschreibt die kumulativen 
% Wahrscheinlichkeiten, die zweite Spalte die entprechenden zu erzeugenden
% Zufallszahlen, s.a. CONT
%   Inputs: 
%     genno=number of random generator
%     prob_tab= Warscheinlichkeitstabelle als Matrix
%   globals:
%     RANDSTATES... Matrix, die spaltenweise die Zustaende aller
%         rand-Generatoren speichert. Die zugehoerige Spalte zu
%         einem Generator folgt aus dessen "genno" (random generator number) 
%
%   2004/10/18, T. Pawletta 

global RANDSTATES MAXRANDNUMBERS

% globale Datenstrukturen initialisieren 
if ~exist('MAXRANDNUMBERS','var') | isempty(MAXRANDNUMBERS)
   MAXRANDNUMBERS=20;       % max. Anzahl verschiedener Zufallszahlenfolgen;
   RANDSTATES=zeros(length(rand('state')),MAXRANDNUMBERS);
   RANDSTATES(:,:)=NaN;
end

% initialize generator#genno
if isnan(RANDSTATES(1,genno))
   rand('state',genno);
   RANDSTATES(:,genno)=rand('state');
end

% load last state of generator#genno
rand('state',RANDSTATES(:,genno));

% ### generator alg. to generate one number ########################
% ggf. Begrenzung des oberen A-Wertes:
x=min(prob_tab(end,1),rand);

idx=min(find(x <= prob_tab(:,1)));
y=prob_tab(idx,2);
% ###################################################################

% save recent state of generator#genno
RANDSTATES(:,genno)=rand('state');

