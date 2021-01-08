# hyPDEVS_Matlab
An advanced DEVS implementation for hybrid system modeling and simulation within the Scientific and Technical Computation Environment Matlab

# ABSTRACT
The hyPDEVS Toolbox for MATLAB (former MatlabDEVS Tbx) has been developed by the research group Computational Engineering and Automation at Hochschule Wismar - University of Applied Sciences, Technology, Business and Design, Germany.
It provides an advanced DEVS implementation for hybrid system modeling and simulation within the Scientific and Technical Computation Environment Matlab®. The theoretical background of the toolbox is based on the general DEVS and PDEVS approaches by [Zeigler et al 2000](https://github.com/cea-wismar/hyPDEVS_Matlab/blob/main/README.md#more-references). and DEVS-based hybrid system extensions introduced in [Pawletta et al 2002](https://github.com/cea-wismar/hyPDEVS_Matlab/blob/main/README.md#2002).
Additionally, the toolbox supports hardware in the loop simulations, such as discussed in [Deatcu, Freymann, and Pawletta 2017](https://github.com/cea-wismar/hyPDEVS_Matlab/blob/main/README.md#2017).
The current name of the toolbox hyPDEVS was created by Bernhard Heinzl, who used the Toolbox while working on his dissertation ([Heinzl 2020](https://github.com/cea-wismar/hyPDEVS_Matlab/blob/main/README.md#more-references))
More information is published at hyPDEVS' webpage:
https://www.cea-wismar.de/tbx/DEVS_Tbx/MatlabDEVS_Tbx.html

# INTRODUCTION
This Toolbox is based on the Parallel DEVS (PDEVS) extension of the Discrete EVent System Specification (DEVS) formalism and its associated abstract simulator algorithms introduced by Zeigler in 1976.
It implements a PDEVS simulator with ports and also offers an experimental status of hybrid simulation by allowing the definition of continuous variables within atomic models. Usage requires a general understanding of how DEVS algorithms and DEVS modeling works. The hyPDEVS Tbx for Matlab comes with some example models for pure discrete and hybrid scenarios and also QSS-based models.
DEVS-based approaches are relatively unknown in the engineering community. So we hope to contribute in bringing DEVS to engineers by providing it for Matlab®. 

# FEATURES
The hyPDEVS Toolbox for MATLAB® offers the following features:
* Simulator and coordinator classes,
* Root coordinators for simulation of pure discrete or hybrid models,
* Debug modi,
* Templates for user defined atomic and coupled models,
* Modelbase containing reusable atomic and coupled models,
* Examples, including QSS and hybrid models,
* Automatic recording of states in atomic models over time during simulation,
* Methods to check plausibility of models.

# INSTALLING hyPDEVS Toolbox for MATLAB®
Note:
The install instructions are based upon a former successful Matlab R2016a (or higher) installation. The software is tested with 32/64 bit Windows 7 and Ubuntu 12.04 but should also work with other operating systems.
Unzip the downloaded file and copy it to your harddisk into a specified folder. Add the folder including any subfolders to the path variable within Matlab (Menue: File -> Set Path -> Add with subfolders).
Alternatively install as Matlab's App: goto Tab APPS --> install Apps --> choose MatlabDEVS.mlappinstall --> done ;-)
For usage, please read the HTML documentation provided in folder /doc/html. Start with  PDEVS_home.html. 

# DOCUMENTATION
The hyPDEVS Toolbox for MATLAB® comes with an HTML-documentation for all examples, all basic models and hints for modeling and simulation.

# BUG REPORT
Please report bugs to the project supervisor by email (christina.deatcu[at]hs-wismar.de). 

# RELATED PUBLICATIONS (by RG CEA)
Relevant publications on the hyPDEVS Toolbox for MATLAB® and further research in this field.

# 2017
# (cite THIS) 	 
[Deatcu, Freymann, and Pawletta 2017] Deatcu, C., Freymann, B., Pawletta, T. (2017). PDEVS-Based Hybrid System Simulation Toolbox for MATLAB. SpringSim-TMS/DEVS 2017, April 23-26, Virginia Beach, VA, USA, Society for Modeling & Simulation International (SCS), pp 989-1000.

# 2012
C. Deatcu, T. Pawletta: A Qualitative Comparison of Two Hybrid DEVS Approaches. In: Simulation Notes Europe (SNE), Vol. 22(1), ARGESIM/ASIM Pub. TU Vienna, Austria, April 2012, Pages 15-24. (Print ISSN 2305-9974, Online ISSN 2306-0271, doi:10.11128/sne.22.tn.10107)

# 2011
C. Deatcu, T. Pawletta, T. Schwatinski: Hybride DEVS - Qualitativer Vergleich zweier konträrer Ansätze. In: Proc. of ASIM STS/GMSS Workshop 2011, Krefeld, Germany, February 24-15, 2011, 12 pages

T. Schwatinski, T. Pawletta: A Solution to ARGESIM Benchmark C17 "SIR-type Epidemic" Using a Quantization-Based Approximation and a HPP-LGCA Approach in a DEVS Environment in Matlab. In: Simulation Notes Europe (SNE), Vol. 21(1), ARGESIM/ASIM Pub. TU Vienna, Austria, April 2011, Pages 57-60. (Print ISSN 2305-9974, Online ISSN 2306-0271, doi:10.11128/sne.21.bn17.10053)

# 2010 	 
O. Hagendorf, T. Pawletta, C. Deatcu, R. Larek: An Approach for Combined Simulation Based Parameter and Structure Optimization Using Evolutionary Algorithms. In: Proc. of 7th EUROSIM Congress on Modelling & Simulation, Prague, Czech Republic, September 6-10, 2010, Volume 2, Full Papers (CD)

T. Schwatinski, T. Pawletta: An Advanced Simulation Approach for Parallel DEVS with Ports. In: Proc. of Spring Simulation Multiconference 2010, Book 4 - Symposium on Theory of Modeling & Simulation -- DEVS, Orlando/Florida, USA, April 11-15, 2010, 132-139

 # 2009
C. Deatcu, T. Pawletta, O. Hagendorf, B. Lampe: Considering Workpieces as Integral Parts of a DEVS Model. In: Proc. of 21st European Modeling & Simulation Symposium, Puerto de la Cruz, Tenerife, Spain, September 23-25, 2009, Volume 1, 27-35

O. Hagendorf, T. Pawletta, C. Deatcu: Extended Dynamic Structure DEVS. In: Proc. of 21st European Modeling & Simulation Symposium, Puerto de la Cruz, Tenerife, Spain, September 23-25, 2009, Volume 1, 36-45

C. Deatcu, T. Pawletta: Towards Dynamic Structure Hybrid DEVS for Scientific and Technical Computing Environments. In: Proc. of Mathematical Modelling MATHMOD 2009 (Argesim Report No. 35), Ed. I. Troch and F. Breitenecker, Vienna, Austria, February 11-13, 2009, ARGESIM-Verlag, Vienna, Austria, 2009, 2716-2719

# 2006 	 
T. Pawletta, C. Deatcu, O. Hagendorf, S. Pawletta, G. Colquhoun: DEVS-Based Modeling and Simulation in Scientific and Technical Computing Environments. In: Proc. of DEVS Integrative M&S Symposium (DEVS'06) - Part of the 2006 Spring Simulation Multiconference (SpringSim'06), D. Hamilton (Ed.), Huntsville/AL, USA, April 2-6, 2006, 151-158

# 2005
O. Hagendorf, T. Pawletta, S. Pawletta, G. Colquhoun: Comparison 16 Restaurant Business Dynamics - A MatlabDEVS based Approach. In: Simulation News Europe (SNE), Issue 44/45, December 2005, page 58 Publisher Eurosim/ARGESIM, Technical University Vienna

# 2004
T. Pawletta, S. Pawletta: A DEVS-based simulation approach for structure variable hybrid systems using high accuracy integration methods. In: Proc. of CSM2004 - Conference on Conceptual Modeling and Simulation, Part of the Mediterranean Modelling Multiconference (I3M), Genova, Italy, October 28-31 2004, Vol.1, 368-373

# 2003
C. Deatcu, T. Pawletta: An Object-oriented Solution to ARGESIM Comparison «C6 Emergency Department» with MATLAB-DEVS2. In: Simulation News Europe, 38/39(2003), page 56

C. Deatcu: Development of an Object-Orientated DEVS-Simulators with MATLAB, Diploma Thesis, Wismar, January 2003

# 2002
[Pawletta et al 2002] Pawletta, T.; Lampe, B.; Pawletta, S.; Drewelow, W.: A DEVS-Based Approach for Modeling and Simulation of Hybrid Variable Structure Systems. In: Modeling, Anlysis, and Design of Hybrid Systems. Engel S., Frehse G., Schnieder E. (Ed.), Lecture Notes in Control and Information Sciences 279, Springer, 2002, 107-129

# 1999
Schildmann, P.; Pawletta, T.; Lampe, B.; Drewelow, W.: Eine Simulationsmethode für hybride Systeme mit Strukturdynamik und deren Umsetzung. In Proc. 2. Wismarer Automatisierungssymposium, Wismar, 1999

# MORE REFERENCES
[Zeigler et al 2000] Zeigler, B., Kim, T., Praehofer, H.: Theory of Modeling and Simulation. Elsevier Science, 2000.

[Heinzl 2020] Heinzl, B.: Methods for Hybrid Modeling and Simulation-Based Optimization in Energy-Aware Production Planning. Dissertation. FBS 37 (Series 'Fortschrittsberichte Simulation / Advances in Simulation'); ISBN ebook: 978-3-903347-37-3, DOI: 10.11128/fbs.37, ARGESIM Wien 2020; ISBN print: 978-3-903311-11-4, TUVerlag Wien (print on demand) 2020. 

