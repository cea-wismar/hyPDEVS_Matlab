%% Debug message for DEVS-Simulation messages
%  stored in DEVS_PATH/00-simulator/db_empty.p
%
% Is provided as p-code.

% no properties


classdef db_empty < handle
    
    properties
        out = 1
    end
    
    methods
        % constructor
        function obj = db_empty()
        end
        % empty prints 
        function dbprint(varargin) % all debug messages connected to simulation message calls
        end
        
        function dbprintcall(varargin) % for debug message of atomics connected to characteristic funtions' calls
        end
        
        function dbprintout(varargin) % print output of atomic
        end
        
        function dbprintroot(varargin) % print output of atomic
        end
    end
end


 