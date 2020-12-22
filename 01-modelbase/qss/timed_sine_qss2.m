
classdef timed_sine_qss2 < atomic
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
    % name     //(unique) name of this model --> for debugging purposes
    % x        //typ: structure    //set of inport/input value pairs
    % y        //typ: structure    //set of outport/output value pairs
    % c_states //array             //set of ports and continuous states 
    % c_x      //type: structure   //set of ports and continuous inputs
    % c_y      //type: structure   //set of continuous outputs
    % mealy    //type: bool        //1 if it is of Mealy type, 0 if it
    %                                is of Moore type
    % s        //typ: structure    //set of states
    % elapsed  //typ: float        //time elapsed since last 
    %                                transition (only for
    %                                initialization)
    % for continuous simulation
    % num_c_state_events = []; % number of cont. state events
    % event_offset = NaN;     % offset in global event location vector
    % state_offset = NaN;     % offset in global state vector
    % input_offset = [];      % input offsets in global state vector
    %
    % define user defined properties, which are necessary for this special kind of
    % atomic model
    % e. g. a service_time, 
    %
    % in states s for timed sine:  s.sigma --> time advance variable,
    %                               remains fixed here
    %                               
    properties (Access = public)
         % insert new properties here
    end
    methods
        %% constructor method
        function obj =timed_sine_qss2(name,x,y,s,elapsed) %  name,x,y,c_states,c_x,c_y,s,elapsed required
            % or have to be initiated before constructor of superclass is called
            % pure discrete model, therefore c_states,c_x,c_y are empty!!!
            c_states = [];
            c_x = [];
            c_y = [];
            obj = obj@atomic(name,x,y,c_states,c_x,c_y,s,elapsed);
                        
            if nargin==8
                % define and set the continuous state variables
                obj.mealy = 1; % model is of Mealy type --> continuous outputs depend on inputs AND internal states 
                obj.output_length = 1; % the function lamda_c returns 1 element
            elseif nargin==5
                disp('atomic model of class timed_sine_qss2 successfully generated');
            else
                disp('mistake at constructor method for class qss1');
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
            disp(['deltaconf of ',obj.name, ' called at t=', num2str(gt)]);
           obj = deltaextfun(deltaintfun(obj),gt); % if external and internal event at the same time, first execute internal event        
        end

        %% external transition function
        % calculates new states from states s, inputs x and elapsed time elapsed
        function obj = deltaextfun(obj,gt)
             global DEBUG
             if DEBUG == 1
                disp(['deltaext of ',obj.name,' called at t=', num2str(gt)]);
             end
             % calculations for outputs based on inputs HERE!!!!
             obj.s.sigma = 0; %schedule an internal event and output event before
        end
        
        %% internal transition function
        % calculates new states from states s
        function obj = deltaintfun(obj)
            global DEBUG
            if DEBUG == 1
                disp(['deltaint of ',obj.name, ' called']);
            end
            obj.s.sine=sin(obj.tnext);
              %obj.s.sigma =inf;
            end
               
        %% discrete output function
        % calculates from states s the ouptputs y
        function obj = lambdafun(obj) 
            global DEBUG
            if DEBUG == 1
                disp(['lambdafun of ',obj.name,' called']);
            end
            %obj.y.p1 = obj.s.gravity; % constant output
            %obj.y.p1 = -9.81;
            obj.y.p1 = sin(obj.tnext);
            obj.y.p2 = cos(obj.tnext);
            %disp(obj.y);
        end
        %% rate of change function
        function dq = f(obj,gt,x,y)
            %gt current time, x continuous input vector
            %y local continuous state vector
            global DEBUG
            if DEBUG == 1
                disp(['rate of change function of ',obj.name,' called at t=', num2str(gt)]);
            end
           % empty for pure discrete models
        end
        
        %% state events condition function
        function ret = cse(obj,gt,y)
            global DEBUG
            if DEBUG == 1
                disp(['state event condition function in ',obj.name,' called at t=', num2str(gt)]);
            end
                  %continuous state value height
                  % | zero-crossing direction from + to -
                  % | | integration termination event
                  % | | |
            %ret = {q(1),-1 ,1};
            %ret = [obj.c_states(1),1,-1];%% ACHTUNG neus Matlab: [value,isterminal,direction] = events(t,y)
            
            % empty for pure discrete models
            end
        %% state events transition function
        % describes the reaction on state events 
        function obj = deltastatefun(obj,gt,y)
        % state event occurred in THIS atomic 
            global DEBUG
            if DEBUG == 1
                disp(['state event in ',obj.name,' ocurred at t=', num2str(gt)]);
            end
            
            % empty for pure discrete models
            
                %obj.c_states(1) = y(1); % set height to zero
                %dieses geh�rt in die messages --> SP�TER
                %obj.s.sigma = 0;
                %obj=lambdafun(obj);
                %obj=deltaintfun(obj);
                %obj.tnext = gt + tafun(obj);
                %obj.c_states(2) = -obj.attenuation*y(2);% reverse direction and calculate new velocity
                % 
                
        end
      
        %% continuous output function
        % calculates from continuous states c_states the continuous ouptputs c_y
        function cy = lambda_c(obj,gt,y,x) 
            % current time
            % local states
            global DEBUG
            if DEBUG == 1
                disp(['lambda_c of ',obj.name,' called']);
            end
            % empty for pure discrete models
            
                %cy = inf;%just for defining an output DUMMY! - TO BE CHANGED
                %no output here
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

