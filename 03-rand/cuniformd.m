function y=cuniformd(genno,a,b)
% y=cuniformd(genno,a,b) generates continuous uniform number in [a,b]
% Inputs: genno ...random generator number
%         a .......lower limit
%         b .......upper limit 
%  globals:
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
y= a + (b-a)*rand;
% ###################################################################

% save recent state of generator#genno
RANDSTATES(:,genno)=rand('state');

