
classdef qss2 < atomic
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
    % x        //type: structure    //set of inport/input value pairs
    % y        //type: structure    //set of outport/output value pairs
    % c_states //array             //set of ports and continuous states 
    % c_x      //type: structure   //set of ports and continuous inputs
    % c_y      //type: structure   //set of continuous outputs
    % mealy    //type: bool        //1 if it is of Mealy type, 0 if it
    %                                is of Moore type
    % s        //type: structure    //set of states
    % elapsed  //type: float        //time elapsed since last 
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
    % dq //type: float //quantum --> accuracy=quantization level of QSS2-Integrator  
    % se //type: bool  //state event marker
    %
    % in states s for integrator:   s.sigma --> time advance variable
    %                               s.X --> State value, initialize it with
    %                               startvalue
    %                               s.dx --> actual rate of change
    %                               s.mdx --> actual slope of s.dx
    %                               s.q --> quantized variable
    %                               s.mq --> slope of s.q
    %                               s.traj --> trajectory of X/t pairs for
    %                               display
    %                               s.dxtraj --> trajectory of dx/t pairs
    %                               for display
    %                               s.qtraj --> trajectory of q/t pairs for
    %                               display
    %                               s.mqtraj --> trajectory of mq/t pairs
    %                               for display
    properties (Access = public)
         % insert new properties here
         dq = 0.001 % quantum --> accuracy=quantization level of QSS2-Integrator 
         se=0; %marks, if state event
    end
    methods
        %% constructor method
        function obj = qss2(name,x,y,s,elapsed,dq) %  name,x,y,c_states,c_x,c_y,s,elapsed required
            % or have to be initiated before constructor of superclass is called
            % pure discrete model, therefore c_states,c_x,c_y are empty!!!
            c_states = [];
            c_x = [];
            c_y = [];
            obj = obj@atomic(name,x,y,c_states,c_x,c_y,s,elapsed);
                        
            if nargin==9
                % define and set the continuous state variables
                obj.mealy = 1; % model is of Mealy type --> continuous outputs depend on inputs AND internal states 
                obj.output_length = 1; % the function lamda_c returns 1 element
            elseif nargin==6
                obj.dq = dq;
                disp(dq);
                pause
                disp('atomic model of class qss2 successfully generated');
            else
                disp('mistake at constructor method for class qss2');
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
            %obj = deltaextfun(deltaintfun(obj),gt); % if external and internal event at the same time, execute internal event
            obj = deltaextfun(obj,gt);
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
             obj.s.X = obj.s.X + obj.s.dx * obj.elapsed + obj.s.mdx/2*obj.elapsed*obj.elapsed; % calculate actual state from state before this event and rate of change until now
             %disp([num2str(obj.s.dx),' is s.dx']);
             %disp([num2str(obj.elapsed),' is elapsed']);
             %disp([num2str(obj.s.mdx),' is s.mdx']);
             %disp([num2str(obj.s.X),' is new X']);
             %disp(obj.x);
             obj.s.dx = obj.x.p1; % copy input value
             obj.s.mdx = obj.x.p2; % copy input slope
             
             if obj.s.sigma ~= 0
                 obj.s.q = obj.s.q + obj.s.mq * obj.elapsed;% set new quantized state
                 a = obj.s.mdx/2;
                 b = obj.s.dx - obj.s.mq;
                 c = obj.s.X - obj.s.q + obj.dq;
                 obj.s.sigma = inf;
                 if a == 0
                     if b ~= 0
                         s = -c/b;
                         if s>0
                             obj.s.sigma = s;
                         end
                         c = obj.s.X - obj.s.q - obj.dq;
                         s = -c/b;
                         if (s>0) && (s<obj.s.sigma)
                             obj.s.sigma = s;
                         end
                     end
                 else
                     if isreal(sqrt(b*b-4*a*c))
                        s = (-b + sqrt(b*b-4*a*c))/2/a;
                        if (s>0) && (s<obj.s.sigma)
                            obj.s.sigma = s;
                        end
                        s = (-b - sqrt(b*b-4*a*c))/2/a;
                        if (s>0) && (s<obj.s.sigma)
                             obj.s.sigma = s;
                        end
                     end
                     c = obj.s.X - obj.s.q - obj.dq;
                     if isreal(sqrt(b*b-4*a*c))
                        s = (-b + sqrt(b*b-4*a*c))/2/a;
                        if (s>0) && (s<obj.s.sigma)
                             obj.s.sigma = s;
                        end
                        s = (-b - sqrt(b*b-4*a*c))/2/a;
                        if (s>0) && (s<obj.s.sigma)
                            obj.s.sigma = s;
                        end
                     end
                         
                     end
             end   
              
             %disp(obj.s.traj);
             %disp('external, X is:');
             %disp(obj.s.X);
             obj.s.traj=[obj.s.traj;gt, obj.s.X]; % add X/t-pair to X-trajectory
             obj.s.dxtraj=[obj.s.dxtraj;gt, obj.s.dx]; % add dx/t-pair to dx-trajectory
             obj.s.qtraj=[obj.s.qtraj;gt, obj.s.q]; % add q/t-pair to q-trajectory
             obj.s.mqtraj=[obj.s.mqtraj;gt, obj.s.mq]; % add q/t-pair to q-trajectory
            
                       
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
            obj.s.X = obj.s.X + obj.s.dx*obj.s.sigma+obj.s.mdx/2*obj.s.sigma*obj.s.sigma; % calculate actual state
            obj.s.q = obj.s.X; % copy to quantized state
            obj.s.dx = obj.s.dx + obj.s.mdx * obj.s.sigma;
            obj.s.mq = obj.s.dx;
            if obj.s.mdx == 0
                obj.s.sigma = inf;
            else
                obj.s.sigma = sqrt(2*obj.dq/abs(obj.s.mdx));
                if ~isreal(obj.s.sigma)
                    disp(' not real in int. trans. func.');
                    keyboard;
                end
            end
            
            obj.s.traj=[obj.s.traj;obj.tnext, obj.s.X]; % add X/t-pair to X-trajectory
            %disp(obj.s.traj);
            %disp('internal');
            obj.s.dxtraj=[obj.s.dxtraj;obj.tnext, obj.s.dx]; % add dx/t-pair to dx-trajectory
            obj.s.qtraj=[obj.s.qtraj;obj.tnext, obj.s.q]; % add q/t-pair to q-trajectory
            obj.s.mqtraj=[obj.s.mqtraj;obj.tnext, obj.s.mq]; % add q/t-pair to q-trajectory
            
            end
               
        %% discrete output function
        % calculates from states s the ouptputs y
        function obj = lambdafun(obj) 
            global DEBUG
            if DEBUG == 1
                disp(['lambdafun of ',obj.name,' called']);
            end
                    obj.y.p1 = obj.s.X + obj.s.dx*obj.s.sigma + obj.s.mdx/2*obj.s.sigma*obj.s.sigma; % output of quantized variable
                    obj.y.p2 = obj.s.dx + obj.s.mdx * obj.s.sigma;
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

