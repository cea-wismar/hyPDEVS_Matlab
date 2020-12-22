function Check(obj)
%   ALGORITHM: 
%   >>check if size of Zid is >n x 4<
%   >>foreach row in Zid          
%       >>checks: if left component name is element of Da or Dc
%           >>checks: if specified output port is available
%       >>checks: if right component name is element of Da or Dc
%           >>checks: if specified input port is available
%       >>checks: if component(s) are self loop output with input
%     end
%   >>checks: if all ports defined used -> warning
%   >>recursively call function with next layer    

% 
%  author:  Birger Freymann
%  version: 23.11.2015 16:00 Germany, University Wismar

    if size(obj.Zid,2) ~= 4
        error('Zid must be of size >n x 4< in coupled model %s',obj.name)
    end

    %common Error Message: 
    c_ERR = ['\nError in >ZID< line: %d of coupled model: %s \n',...
                 '%s: %s  -->  %s: %s \n \n'];           
    %specific Error Message: 
    s_ERR = {'component: %s not found in >Da< or >Dc<';
             'component: %s is self looping';
             'component: %s defines no port: %s'};
    %warnings     
    warn =   'warning: %-20s Port defined but unused\n';   
    
         
    %collect data to find unconnected port     
    comps = struct();
    for i = fieldnames(obj.components)'
        %comps.CompName.{x|y}.portname
        comps.(i{:}).x = obj.components.(i{1}).x;
        comps.(i{:}).y = obj.components.(i{1}).y;
    end    
    comps.parent.x = obj.x;
    comps.parent.y = obj.y;    
      
    
    for i = 1:size(obj.Zid,1)        %all lines of ZID        
        for j = 1:2                  %first left side than right side
            CmpN = obj.Zid{i,2*j-1}; %ComponentName 
            PrtN = obj.Zid{i,2*j};   %PortName 
            
            if j==1
                H_P1 = 'y'; 
                H_P2 = 'x';
            else                
                H_P1 = 'x'; 
                H_P2 = 'y';
            end 
            
            if any(strcmp(CmpN,[obj.Da,obj.Dc]))
                comps.(CmpN).(H_P1).(PrtN) = 'Port_used';
                PortNames = fieldnames(obj.components.(CmpN).(H_P1));
                if ~any(strcmp(PrtN,PortNames))
                    error([c_ERR,s_ERR{3}],...
                           i,obj.name,obj.Zid{i,:},CmpN,PrtN) %ERR 3
                end          
            elseif strcmp(CmpN,'parent')
                comps.(CmpN).(H_P2).(PrtN) = 'Port_used';
                PortNames = fieldnames(obj.(H_P2));
                if ~any(strcmp(PrtN,PortNames))               
                    error([c_ERR,s_ERR{3}],...
                           i,obj.name,obj.Zid{i,:},'parent',PrtN) %ERR 3
                end
            else            
                error([c_ERR,s_ERR{1}],...
                       i,obj.name,obj.Zid{i,:},CmpN) %ERR 1
            end        
        end 
        
        %SELF LOOPING          
        if ~strcmp(CmpN,'parent') && strcmp(obj.Zid{i,1},CmpN) 
            error([c_ERR,s_ERR{2}],...
                   i,obj.name,obj.Zid{i,:},CmpN) %ERR 2
        end
    end %end of forloop
    
    
    fprintf(1,'\ncheck of: %-20s \n',obj.name);    
    %show warning if port is not used but defined in model
    warningsFound = false;
    for i = fieldnames(comps)'
        %check Inputs
        if isempty(comps.(i{:}).x)
            continue
        else
            for j = fieldnames(comps.(i{:}).x)'
                if isempty(comps.(i{:}).x.(j{:}))
                    fprintf(2,warn,[i{:},'.x.',j{:}]);
                    warningsFound = true;
                end
            end
        end 
        %check Outputs
        if isempty(comps.(i{:}).y)
            continue
        else
            for j = fieldnames(comps.(i{:}).y)'
                if isempty(comps.(i{:}).y.(j{:}))
                    fprintf(2,warn,[i{:},'.y.',j{:}]);
                    warningsFound = true;
                end
            end
        end         
    end
        
    if warningsFound        
        fprintf(1,'  result: [WARNING]\n');
    else
        fprintf(1,'  result: [OK]\n');
    end
    
    %RECUSION 
    %deep search - one layer down    
    for i = obj.Dc
        Check(obj.components.(i{:}))
    end    
end