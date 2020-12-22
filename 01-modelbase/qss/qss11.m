
classdef qss11< atomic
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
    % in states s for integrator:   s.sigma --> time advance variable
    %                               s.X --> State value, initialize it with
    %                               startvalue
    %                               s.dX --> actual rate of change
    %                               s.q --> quantized variable
    %                               s.traj --> trajectory of X/t pairs for
    %                               display
    %                               s.qtraj --> trajectory of q/t pairs for
    %                               display
    properties (Access = public)
         % insert new properties here
         epsilon = 0.0001; % hysteresis 0.001
         dq = 0.001 % quantum --> accuracy=quantization level of QSS1-Integrator 
         se=0; %marks, if state event
    end
    methods
        %% constructor method
        function obj = qss11(name,x,y,s,elapsed,epsilon,dq) %  name,x,y,c_states,c_x,c_y,s,elapsed required
            % or have to be initiated before constructor of superclass is called
            % pure discrete model, therefore c_states,c_x,c_y are empty!!!
            c_states = [];
            c_x = [];
            c_y = [];
            obj = obj@atomic(name,x,y,c_states,c_x,c_y,s,elapsed);
                        
            if nargin==10
                % define and set the continuous state variables
                obj.mealy = 1; % model is of Mealy type --> continuous outputs depend on inputs AND internal states 
                obj.output_length = 1; % the function lamda_c returns 1 element
            elseif nargin==7
                obj.epsilon= epsilon;
                obj.dq = dq;
                disp('atomic model of class qss1 successfully generated');
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
            obj = deltaextfun(deltaintfun(obj),gt); % if external and internal event at the same time, execute internal event
        end

        %% external transition function
        % calculates new states from states s, inputs x and elapsed time elapsed
        function obj = deltaextfun(obj,gt)
             global DEBUG
             if DEBUG == 1
                disp(['deltaext of ',obj.name,' called at t=', num2str(gt)]);
             end
             %disp(['input of integrator ',num2str(obj.x.p1)]);%DEBUGGING
             obj.elapsed = gt - obj.tlast;% calculate time since last event
             obj.s.X = obj.s.X + obj.s.dX * obj.elapsed; % calculate actual state from state before this event and rate of change until now
             obj.s.traj = [obj.s.traj; gt,obj.s.X,1]; % add X/t-pair to trajectorie
             if (obj.x.p2 == 1) %if state event
                  disp(['event arrived: on floor at gt= ', num2str(gt)]);
                 %Änderungen an X nur in internal
                 obj.se = obj.x.p2;%copy event to local variable
                 obj.s.sigma = 0;
                 obj.x.p2 = 0;%reset
             else
             if (obj.x.p1 > 0 ) % if there is a positive rate of change at input-port
                 obj.s.sigma = (obj.s.q + obj.dq - obj.s.X) / obj.x.p1; % calculate time of next internal event
                 %disp(['new sigma integrator ',num2str(obj.s.sigma)]);%DEBUGGING
             elseif (obj.x.p1 < 0 ) % if there is a negative rate of change at input-port
                 obj.s.sigma = (obj.s.q - obj.epsilon - obj.s.X) / obj.x.p1; % calculate time of next internal event HYSTERESIS!!!
             else % if there is no change at input-port
                 obj.s.sigma = inf ;
             end
             obj.s.dX = obj.x.p1;
             end
             
        end
        
        %% internal transition function
        % calculates new states from states s
        function obj = deltaintfun(obj)
            global DEBUG
            %if obj.tnext > 4.06
             %   DEBUG =1;
            %end
            if DEBUG == 1
                disp(['deltaint of ',obj.name, ' called']);
                pause;
            end
            obj.s.X = obj.s.X + obj.s.sigma * obj.s.dX; % calculate actual state
            if obj.se ==1
                disp(['internal event after on floor at tnext= ', num2str(obj.tnext)]);
                disp(['X vor Umschaltung:',num2str(obj.s.X)])
                obj.s.X = - obj.s.X * 0.95; % reverse direction and damping
                disp(['X nach Umschaltung:',num2str(obj.s.X)]);
                %pause
            end
            if (obj.s.dX > 0) % for positive change
                obj.s.sigma = obj.dq / obj.s.dX; % calculate time until next internal event
                if obj.se
                    disp(['q vor Umschaltung:',num2str(obj.s.q)]);
                    
                end
                obj.s.q = obj.s.q + obj.dq; % add a quantum to quantized state
                if obj.se
                    %obj.s.q= - obj.s.q*0.95;% ergibt Werte zwischen Quantisierungen --> nicht zulässig
                    obj.s.q= floor(-obj.s.q*0.95/obj.dq)*obj.dq;
                    disp(['q nach Umschaltung:',num2str(obj.s.q)]);
                end
            elseif (obj.s.dX < 0) % for negative change
                obj.s.sigma = - obj.dq / obj.s.dX; % calculate time until next internal event
                if obj.se
                    disp(['q vor Umschaltung:',num2str(obj.s.q)]);
                    
                end
                obj.s.q = obj.s.q - obj.dq; % substract a quantum from quantized state
                if obj.se
                    %obj.s.q=- obj.s.q*0.95;
                    obj.s.q= floor(-obj.s.q*0.95/obj.dq)*obj.dq;
                    disp(['q nach Umschaltung:',num2str(obj.s.q)]);
                end
            else
            obj.s.sigma = inf;
            end
            obj.s.traj=[obj.s.traj;obj.tnext, obj.s.X,2]; % add q/t-pair to q-trajectorie
            obj.s.qtraj=[obj.s.qtraj;obj.tnext, obj.s.q]; % add q/t-pair to q-trajectorie
            obj.se=0; %reset state event
            end
               
        %% discrete output function
        % calculates from states s the ouptputs y
        function obj = lambdafun(obj) 
            global DEBUG
            if DEBUG == 1
                disp(['lambdafun of ',obj.name,' called']);
            end
            if (obj.s.dX == 0) %if there is no change at the moment
                if obj.se
                    %obj.y.p1 = - obj.s.q*0.95;
                    obj.y.p1= floor(-obj.s.q*0.95/obj.dq)*obj.dq;
                  % obj.y.p2 = - obj.s.q*0.95;
                   obj.y.p2= floor(-obj.s.q*0.95/obj.dq)*obj.dq;
                    %obj.y.p3 = - obj.s.q*0.95;
                     obj.y.p3= floor(-obj.s.q*0.95/obj.dq)*obj.dq;
                else
                    obj.y.p1 = obj.s.q; %copy actual quantized state to output-port
                    obj.y.p2 = obj.s.q; %copy actual quantized state to output-port
                    obj.y.p3 = obj.s.q; %copy actual quantized state to output-port
                end
            else
                if obj.se
                    %obj.y.p1 = - obj.s.q*0.95 + obj.dq * obj.s.dX / abs(obj.s.dX); % add or substract a quantum and copy value to output-port
                    obj.y.p1 = floor(-obj.s.q*0.95/obj.dq)*obj.dq + obj.dq * obj.s.dX / abs(obj.s.dX);
                   %obj.y.p2 = - obj.s.q*0.95 + obj.dq * obj.s.dX / abs(obj.s.dX); % add or substract a quantum and copy value to output-port
                    obj.y.p2 = floor(-obj.s.q*0.95/obj.dq)*obj.dq + obj.dq * obj.s.dX / abs(obj.s.dX);
                    %obj.y.p3 = - obj.s.q*0.95 + obj.dq * obj.s.dX / abs(obj.s.dX); % add or substract a quantum and copy value to output-port
                    obj.y.p3 = floor(-obj.s.q*0.95/obj.dq)*obj.dq + obj.dq * obj.s.dX / abs(obj.s.dX);
                else           
                    obj.y.p1 = obj.s.q + obj.dq * obj.s.dX / abs(obj.s.dX); % add or substract a quantum and copy value to output-port
                    obj.y.p2 = obj.s.q + obj.dq * obj.s.dX / abs(obj.s.dX);
                    obj.y.p3 = obj.s.q + obj.dq * obj.s.dX / abs(obj.s.dX);
                end
            end 
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
                %dieses gehört in die messages --> SPÄTER
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

