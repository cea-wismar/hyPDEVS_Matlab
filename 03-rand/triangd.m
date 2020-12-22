function y=triangd(genno,a,c,b)
% y=triang_d(geno,a,c,b,) triangular distribution
% Erzeugung einer dreiecksverteilten Zufallszahl aus einer
% (0,1)-Gleichverteilung mittels inverser Verteilungsfunktion.
%   Inputs: 
%     genno=random generator number;
%     a=minimum value, c=most likely value, b=maximum value
%   Outputs:
%     y=a triangular distributed random variable
%   globals:
%     RANDSTATES... Matrix, die spaltenweise die Zustaende aller
%         rand-Generatoren speichert. Die zugehoerige Spalte zu
%         einem Generator folgt aus dessen "genno" (random generator number) 

%   Reference: A.M. Law, W.D. Kelton, "Simulation Modeling & Simulation",
%   2nd edition, McGraw-Hill, 1991, pp. 341/342, 494
%
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
c01= (c-a)/(b-a);    % mode value for triang with min=0, max=1
u  = rand;
if u >= 0 & u <= c01 
  y01= sqrt(c01*u);
elseif c01 < u & u <= 1
  y01= 1-sqrt((1-c01)*(1-u)); 
else
  error('Error in random generation using triangular distribution.')
end   
y= a+(b-a)*y01; 
% ###################################################################

% save recent state of generator#genno
RANDSTATES(:,genno)=rand('state');

