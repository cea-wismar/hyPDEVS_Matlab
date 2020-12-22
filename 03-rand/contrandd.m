function y=contrandd(genno,prob_tab)
% y=CONTRANDD(genno,prob_tab)  Spezialisierung der Funktion cont.
% Eine Zahl x (hier aus dem Bereich [0,1], erzeugt mit rand) wird 
% ueber eine Tabelle prob_tab in eine Zahl y umkodiert.
% Die erste Spalte entspricht der Eingangs-, die zweite Spalte der
% Ausgangsinformation:
%           -Inf      < x <= prob_tab(1,1) ==> y=prob_tab(2,1)
%      prob_tab(1,1)  < x <= prob_tab(1,2) ==> y=prob_tab(2,2)
%                      ...
%     prob_tab(1,n-1) < x <     +Inf       ==> y=prob_tab(2,n)
% Liegt der x-Wert zwischen den Tabellenwerten, wird
% linear interpoliert!!!
% Ueblicherweise dient diese Funktion der Erzeugung von Zufallszahlen nach
% einer kontinuierlichen Verteilung.
% Die erste Spalte von prob_tab beschreibt die cumulativen 
% Wahrscheinlichkeiten, die zweite Spalte die entprechenden zu erzeugenden
% Zufallszahlen, s.a. CONT, DISC, DISCRANDD
%   Inputs: 
%     genno=number of random generator
%     prob_tab= Warscheinlichkeitstabelle als Matrix
%   globals:
%     RANDSTATES... Matrix, die spaltenweise die Zustaende aller
%         rand-Generatoren speichert. Die zugehoerige Spalte zu
%         einem Generator folgt aus dessen "genno" (random generator number) 

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
x=max(0,min(prob_tab(end,1),rand));

% Finden des Index auf untere Stuetzstelle
idx=max(find(x>=prob_tab(:,1)));
if idx==size(prob_tab,1), idx=idx-1; end 

% eigentliche Interpolation
y=prob_tab(idx,2)+(prob_tab(idx+1,2)-prob_tab(idx,2))*(x-prob_tab(idx,1))...
        /(prob_tab(idx+1,1)-prob_tab(idx,1));
% ###################################################################

% save recent state of generator#genno
RANDSTATES(:,genno)=rand('state');

