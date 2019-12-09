classdef Aero
    
    properties
       
        Cl
        Cd
        Abal
        subModels = struct();
        
    end
    
    methods
       
        function this = Aero(Cl , Cd , Abal)
        
            this.Cl = Cl;
            this.Cd = Cd;
            this.Abal = Abal;
            
        end
        
    end
    
end