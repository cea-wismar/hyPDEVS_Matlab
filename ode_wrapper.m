%   varargout = ODE_WRAPPER(gt,y,flag,...
%				   moore_objs, moore_soff_len, moore_eoff_len, ...
%				   mealy_objs, mealy_soff_len, mealy_eoff_len);
%   For providing a closed representation of continuous model parts to ODE solver within
%   MatlabDEVS Tbx following the wrapper concept. Acts as model function and as event function at
%   the same time.
%
%   Is provided as p-code.
%


function varargout = ode_wrapper(gt,y,flag,...
				   moore_objs, moore_soff_len, moore_eoff_len, ...
				   mealy_objs, mealy_soff_len, mealy_eoff_len);
               %asubs,gstat_length,gstat_offset)
  % t     ....   time
  % q     ....   (global) state vector
  % flag  ....   distinguish between call of derivations or event testing

  % moore ... nicht sprungfaehig --> output depends just on state
  % mealy ... sprungfaehig --> output depends on input AND state

  % Anmerkung: Der __direkte__ Zugriff auf die atomaren Komponenten
  %            ist die guenstigste Loesung bzgl. Laufzeit. Die
  %            Berechnung von 'f' und 'lambda_c' der einzelnen
  %            Simulationsobjekte nach dem hierarchischen Prinzip
  %            bringt keinerlei Vorteile, weil es auch bei dieser
  %            Variante nicht moeglich ist, die von odexx detektierten
  %            Ereignisse den entsprechenden Simulationsobjekten
  %            direkt zuzuordnen (z.B. bei Rueckkehr von 'f') und die
  %            diskreten Zustaende zu veraendern. Erst __nachdem__
  %            odexx abgebrochen ist (termination event), ist
  %            feststellbar wo das Ereignis aufgetreten ist.
  % flag == 1 --> return the derivations
  % flag == 0 --> return event conditions
  if flag == 1
      % execute all continuous output functions
      x=[];
      x_total=[];                       % to collect all outputs
      for idx=1:length(moore_objs)      % first output functions of moore objects
          soff = moore_soff_len(1,idx); % state offset for this object
          len = moore_soff_len(2,idx);  % number/length of continuous state variables
          x = lambda_c(moore_objs{idx},gt,y(soff+1:soff+len));% get the vector of outputs
          x_total(soff+1 : soff + len, 1) = x; % sort to overall output vector
      end
      
      x_local=[];% to temporally store input for specific mealy object
      for idx=1:length(mealy_objs)% then output functions of mealy objects
          %disp('mealy_input_offset: ');
          ioff = mealy_objs{idx}.input_offset;
          for iidx = 1:length (ioff)
            if ioff(iidx) == 0%if there is no coupling at this port?????????
                x_local(iidx) = 0;%then there is no value
            else
                x_local(iidx) = x_total(ioff(iidx));% copy the input-value from 
                                                    % collected outputs
            end	
          end
          soff = mealy_soff_len(1,idx);
          len = mealy_soff_len(2,idx);
          x = lambda_c(mealy_objs{idx},gt,y(soff+1:soff+len),x_local);
          x_total(soff+1 : soff + len, 1) = x;
      end
      
      
      
      % execute rate of change functions (f)
      dy_total = []; % collect all derivatives
      x_local = [];
      for idx = 1:length(moore_objs)% first of moore objects
           %disp('moore_input_offset: ');
            ioff = moore_objs{idx}.input_offset;
            for iidx = 1:length (ioff)
                if ioff(iidx) == 0
                    x_local(iidx) = 0;
                else
                    x_local(iidx) = x_total (ioff(iidx));
                end
            end
            soff = moore_soff_len (1, idx);
            len  = moore_soff_len (2, idx);
            dy =  f (moore_objs{idx}, gt, x_local, y(soff+1 : soff + len));
            dy_total (soff+1 : soff + len, 1) = dy;
      end

      for idx = 1:length(mealy_objs)% then for mealy objects
          %disp('mealy_input_offset: ');
            ioff = mealy_objs{idx}.input_offset;
            for iidx = 1:length (ioff)
                if ioff(iidx) == 0
                    x_local(iidx) = 0;
                else
                x_local(iidx) = x_total(ioff(iidx));
                end           
            end
            soff = mealy_soff_len(1, idx);
            len  = mealy_soff_len(2, idx);
            dy =  f(mealy_objs{idx}, gt, x_local, y(soff+1 : soff + len));
            dy_total(soff+1 : soff + len, 1) = dy;
      end
      varargout{1} = dy_total;

    
  elseif flag == 0
      %disp('event function called');
      %for i=1:length(asubs)
         % if i==1
          %  ret=cse(asubs{i},gt,y(gstat_offset(i)+1:gstat_offset(i)+gstat_length(i)));
           % value=ret(1);
           %isterminal=ret(2);
            %direction=ret(3);
          %else            
            %ret=cse(asubs{i},gt,y(gstat_offset(i)+1:gstat_offset(i)+gstat_length(i)));
            %value=[value;ret(1)];
            %isterminal=[isterminal;ret(2)];
            %direction=[direction;ret(3)];             
          %end
      %varargout{1}=value;
      %varargout{2}=isterminal;
      %varargout{3}=direction;
      
      
      value_total = [];
      dir_total = [];
      is_terminal_total = [];
      % check state events
      for idx = 1:length (moore_objs)
            eoff = moore_eoff_len (1, idx);
            elen = moore_eoff_len (2, idx);
            soff = moore_soff_len (1, idx);
            slen = moore_soff_len (2, idx);
            if moore_objs{idx}.num_c_state_events >0
                ret = cse(moore_objs{idx}, gt, y(soff+1 : soff + slen));
                value_total(eoff+1 : eoff + elen) = ret(:,1);
                is_terminal_total(eoff+1 : eoff + elen) = ret(:,2);
                dir_total(eoff+1 : eoff + elen) = ret(:,3);
            end
      end
      for idx = 1:length (mealy_objs)
            eoff = mealy_eoff_len (1, idx);
            elen = mealy_eoff_len (2, idx);
            soff = mealy_soff_len (1, idx);
            slen = mealy_soff_len (2, idx);
            if mealy_objs{idx}.num_c_state_events > 0
                ret = cse(mealy_objs{idx}, gt, y(soff+1 : soff + slen));
                value_total(eoff+1 : eoff + elen) = ret(:,1);
                is_terminal_total(eoff+1 : eoff + elen) = ret(:,2);
                dir_total(eoff+1 : eoff + elen) = ret(:,3);
            end
      end
      varargout{1} = value_total';
      varargout{2} = is_terminal_total';
      varargout{3} = dir_total';  % direction 1=positive, -1=negative, 0=don't care
  end
      
  
  
  
  
  
end