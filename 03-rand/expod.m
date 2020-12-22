function y=expod(genno,mue)
% y=expod(genno,mue) exponential distribution
% Erzeugung einer exponentialverteilten Zufallszahl aus einer
% (0,1)-Gleichverteilung mittels inverser Verteilungsfunkt.
%   Inputs: 
%     genno... random generator number, 
%     mue..... mean value (mue=1/lambda, lambda the arrival rate)
%   Outputs:
%     y........an exponential distributed random variable
%   globals:
%     RANDSTATES... Matrix, die spaltenweise die Zustaende aller
%         rand-Generatoren speichert. Die zugehoerige Spalte zu
%         einem Generator folgt aus dessen "genno" (random generator number) 

%   Reference: A.M. Law, W.D. Kelton, "Simulation Modeling & Simulation",
%   2nd edition, McGraw-Hill, 1991, pp. 486
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

% ### generator alg. to generate one exponential number #############
y=mue*(-log(1-rand)); 
% ###################################################################

% save recent state of generator#genno
RANDSTATES(:,genno)=rand('state');

