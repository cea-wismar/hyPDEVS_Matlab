# hyPDEVS_Matlab
An advanced DEVS implementation for hybrid system modeling and simulation within the Scientific and Technical Computation Environment Matlab

# Abstract
The hyPDEVS Toolbox for MATLAB (former MatlabDEVS Tbx) has been developed by the research group Computational Engineering and Automation at Hochschule Wismar - University of Applied Sciences, Technology, Business and Design, Germany.
It provides an advanced DEVS implementation for hybrid system modeling and simulation within the Scientific and Technical Computation Environment Matlab®. The theoretical background of the toolbox is based on the general DEVS and PDEVS approaches by Zeigler et al 2000. and DEVS-based hybrid system extensions introduced in Pawletta et al 2002.
Additionally, the toolbox supports hardware in the loop simulations, such as discussed in (Deatcu, Freymann, and Pawletta 2017).
The current name of the toolbox hyPDEVS was created by Bernhard Heinzl, who used the Toolbox while working on his dissertation (Heinzl 2020). 

# Introduction
This Toolbox is based on the Parallel DEVS (PDEVS) extension of the Discrete EVent System Specification (DEVS) formalism and its associated abstract simulator algorithms introduced by Zeigler in 1976.
It implements a PDEVS simulator with ports and also offers an experimental status of hybrid simulation by allowing the definition of continuous variables within atomic models. Usage requires a general understanding of how DEVS algorithms and DEVS modeling works. The MatlabDEVS Tbx comes with some example models for pure discrete and hybrid scenarios and also QSS-based models.
DEVS-based approaches are relatively unknown in the engineering community. So we hope to contribute in bringing DEVS to engineers by providing it for Matlab®. 

# Features
The hyPDEVS Toolbox for MATLAB® offers the following features:
* Simulator and coordinator classes,
* Root coordinators for simulation of pure discrete or hybrid models,
* Debug modi,
* Templates for user defined atomic and coupled models,
* Modelbase containing reusable atomic and coupled models,
* Examples, including QSS and hybrid models,
* Automatic recording of states in atomic models over time during simulation,
* Methods to check plausibility of models.


