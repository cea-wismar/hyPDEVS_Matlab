
classdef am_bb2 < atomic
    %% class methods and properties
    % Template for atomic DEVS models
    % derived from class atomic
    %
    % class methods:
    %
    % ta = tafun(obj) //time advance function
    %
    % obj = deltaconffun(obj,gt)//confluent function
    % obj = deltaextfun(obj,gt) //external transition function
    % obj = deltaintfun(obj)    //internal transition function
    % obj = lambdafun(obj)      //output function
    % showall(obj)              //display the object 
    %
    % inherited properties
    % name    //(unique) name of this model --> for debugging purposes
    % x       //typ: structure     //set of inport/input value pairs
    % y       //typ: structure     //set of outport/output value pairs
    % c_states //array             //set of ports and continuous states 
    % c_x      %//type: structure  //set of ports and continuous inputs
    % c_y      %//type: structure  //set of continuous outputs
    % mealy    //type: bool        //1 if it is of Mealy type, 0 if it
    %                                is of Moore type
    % s       //typ: structure     //set of states
    % e       //typ: float         //time elapsed since last 
    %                                transition (only for
    %                                initialization)
    %
    % for continuous simulation
    % num_c_state_events = []; % number of cont. state events
    % event_offset = NaN;     % offset in global event location vector
    % state_offset = NaN;     % offset in global state vector
    % input_offset = [];      % input offsets in global state vector
    %
    % define user defined properties, which are necessary for this special kind of
    % atomic model
    % e. g. a service_time, 
    
    properties (Access = public)
           attenuation % attenuation parameter 0.5 - 0.9
    end
    
    methods
        %% constructor method
        function obj = am_bb2(name,x,y,c_states,c_x,c_y,s,elapsed,attenuation) % with user-defined parameter service_time; name,x,y,s,e required
            % or have to be initiated before constructor of superclass is called
            obj = obj@atomic(name,x,y,c_states,c_x,c_y,s,elapsed);
                        
            if nargin==9
                % define and set the continuous state variables
                obj.mealy = 0; % model is of Moore type 
                obj.output_length = 1; % the function lamda_c returns 1 element
                obj.attenuation = attenuation;
            else
                disp('mistake at constructor method for class am_bball');
            end
            % end example
        end

        %% time advance function
        % calculates time until next internal event by evaluating the states in s
        function ta = tafun(obj)
            global DEBUG
            if DEBUG == 1
                disp(['tafun of ',obj.name,' called']);
            end
            ta = obj.s.sigma; 
        end
        
        %% confluent function
        % calculates new states from states s, inputs x and elapsed time elapsed 
        function obj = deltaconffun(obj,gt) 
            global DEBUG
            if DEBUG == 1
                disp(['deltaconf of ',obj.name, ' called at t=', num2str(gt)]);
            end
        end

        %% external transition function
        % calculates new states from states s, inputs x and elapsed time elapsed
        function obj = deltaextfun(obj,gt)
             % no external events, just state events
             global DEBUG
             if DEBUG == 1
                disp(['deltaext of ',obj.name,' called at t=', num2str(gt)]);
             end             
             % external event occured
                 disp(['external event occurred in ',obj.name]);
                 if DEBUG == 1
                    disp(['external event in ',obj.name,' ocurred at t=', num2str(gt)]);
                 end
                 disp(['ball ',obj.name,' received discrete ext. event']); 
                 if strcmp(obj.x.xd_p1,'down');
                   obj.c_states(1) = -obj.attenuation*obj.c_states(1);  
                 end
        end
        
        %% internal transition function
        % calculates new states from states s
        function obj = deltaintfun(obj)
            global DEBUG
            if DEBUG
                disp(['deltaint of ',obj.name, ' called']);
            end
            %obj.s.sigma = inf;
             plot(obj.tnext,24,'mo',...
                'LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor',[.49 1 .63],...
                'MarkerSize',8);
             %disp(['XXXXXXXXXXXX INTERNAL EVENT in ',obj.name, ' XXXXXXXXXXXXXXX']);
        end
               
        %% discrete output function
        % calculates from states s the ouptputs y
        function obj = lambdafun(obj) 
            global DEBUG
            if DEBUG
                disp(['lambdafun of ',obj.name,' called']);
            end
            %no discrete output
        end 
        
        %% rate of change function
        function dq = f(obj,gt,x,y)
            %gt current time, x continuous input vector
            %y local continuous state vector
            global DEBUG
            if DEBUG
                disp(['rate of change function of ',obj.name,' called at t=', num2str(gt)]);
            end
           if (obj.s.active==0)
                dq = 0; %if ball has not yet started
           else
            dq = -9.81;%derivation is acceleration 
            % x is empty here, because there are no continuous inputs
            obj.c_states(1)= y(1);% set/put back the current state
            %disp(['state of bb2: ',num2str(y(1))]);
            end
        end
        
        %% state events condition function
        function ret = cse(obj,gt,y)
            global DEBUG
            if DEBUG
                disp(['state event condition function in ',obj.name,' called at t=', num2str(gt)]);
            end
                  %continuous state value height
                  % | zero-crossing direction from + to -
                  % | | integration termination event
                  % | | |
            %ret = {q(1),-1 ,1};
            ret = [1,0,0];% no state events are defined for this object! 
            %ret={};
%             if gt > 0
%              obj.c_states(1)= y(1);
%             end
        end
        %% state events transition function
        % describes the reaction on state events 
        function obj = deltastatefun(obj,gt,y,event_number)
        % state event occurred in THIS atomic 
            global DEBUG
            if DEBUG
                 disp(['state event number ',num2str(event_number),' in ',obj.name,' ocurred at t=', num2str(gt)]);
            end
            
                obj.c_states(1) = 0; % set height to zero
                % obj.c_states(2) = -obj.attenuation*y(2);% reverse direction and calculate new velocity
                % 
                
        end
      
        %% continuous output function
        % calculates from continuous states c_states the continuous ouptputs c_y
        function cy = lambda_c(obj,gt,y)
            % current time
            % local states
            global DEBUG
            if DEBUG
                disp(['lambda_c of ',obj.name,' called']);
            end
            cy = y(1); % output of current height at continuous output port 'cp1'
            %cy = obj.c_states(1); % output of current height at continuous output port 'cp1'
            end 
        
        %% helper functions for displaying atomic objects
        % allow to display inherited properties athough they are not public
            function showall(obj)
                disp(obj);
                showxports(obj);
                showyports(obj);
                showstates(obj);
            end
               
    end
        
        
 end

