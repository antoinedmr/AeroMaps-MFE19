%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   AERO MODEL PLOTTING
%--------------------------------------------------------------------------
% VAR CONVENTION: 
%    FRH (delta), RRH (delta), STEER (UP +ve), SLIP (UP+ve), ROLL (FWD +ve)
% OUTPUT CONVENTION:
%    Cl - Cd - Abal - DownforceFW - DownforceUT - DownforceRW
%--------------------------------------------------------------------------
% 19/03/2018
% LUCIEN VIALA, ANTOINE DEMEIRE
% 2017, McGill Formula Electric
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%close all
clc

%% OPTIONS

n_plot = 2; %   - 1: X-Y PLot , 2: Contour
b_save = 0; %   - 0: do not save , 1: save

export_dir = ('/Users/antoinedemeire/Desktop/01 MCGILL/FSAE/E19/99_PERFORMANCE/11 Performance/MAPPING_STEP-IN/EXPORTS/4_CORNER_EXIT');

var_sweep  = {'FRH' , 'RRH'};
var_bounds = {[-30/1000 0/1000] , [-20/1000 10/1000]};
var_out    = 'Cl';

var_BSL = [ 0/1000 0/1000 deg2rad(10) deg2rad(1.5) deg2rad(-0.75) ];

%%  VARIABLES

dace_path = '/Users/antoinedemeire/Desktop/DESIGN BINDER/2018/MFE19/99 ANALYSIS_SOFTWARE/DACE';
source_data_path = '/Users/antoinedemeire/Desktop/01 MCGILL/FSAE/E19/99_PERFORMANCE/11 Performance/MAPPING_STEP-IN/DATA';

AERO_CLASS_PATH = '/Users/antoinedemeire/Desktop/01 MCGILL/FSAE/E19/99_PERFORMANCE/11 Performance/MAPPING_STEP-IN/MODELS';
AERO_CLASS_IN  = 'MFE19_FINAL_MAPPING_STEP_IN.mat';clc

%%  INITIALIZE

addpath(genpath(dace_path));
addpath(genpath('/Users/antoinedemeire/Desktop/DESIGN BINDER/2018/MFE19/99 ANALYSIS_SOFTWARE/AERO_CLASSES'));

load(fullfile(AERO_CLASS_PATH , AERO_CLASS_IN));

%%  PLOTTING

var_in  = {'FRH' , 'RRH' , 'Steer' , 'Slip' , 'Roll'};
x_var_id = find(strcmp(var_sweep{1} , var_in) == 1);
y_var_id = find(strcmp(var_sweep{2} , var_in) == 1);

x_var = linspace(var_bounds{1}(1) , var_bounds{1}(2) , 61);     %   CHANGE FOR NUMBER OF POINTS PLOTTED
y_var = linspace(var_bounds{2}(1) , var_bounds{2}(2) , 41);     %   CHANGE FOR NUMBER OF POINTS PLOTTED

if any(strcmp({'Cl' , 'Cd' , 'Abal'} , var_out))
    dmodel = Aero.(var_out);
else
    dmodel = Aero.subModels.(var_out);
end

% X-Y PLOT
if n_plot == 1
    Model_in  = [ones(100,1)*var_BSL(1) ones(100,1)*var_BSL(2) ones(100,1)*var_BSL(3) ...
        ones(100,1)*var_BSL(4) ones(100,1)*var_BSL(5)];
    
    Model_in(: , x_var_id) = x_var;
    
    Model_out = predictor(Model_in , dmodel);
    
    figure();
    plot(x_var , Model_out)
    xlabel(var_sweep(1))
    ylabel(var_out)
    
    title([var_out ' vs. ' var_sweep{1}]);
    export_name = ['XY_' , var_sweep{1} , '_' , var_out , '.png'];
    
% CONTOUR PLOT
elseif n_plot == 2
    
    [XX , YY] = meshgrid(x_var , y_var);
    
    Model_in  = [ones(length(XX(:)),1)*var_BSL(1) ones(length(XX(:)),1)*var_BSL(2) ones(length(XX(:)),1)*var_BSL(3) ...
        ones(length(XX(:)),1)*var_BSL(4) ones(length(XX(:)),1)*var_BSL(5)];
    
    Model_in(: , x_var_id) = XX(:);
    Model_in(: , y_var_id) = YY(:);
    
    Model_out = predictor(Model_in , dmodel);
    
    Model_out = reshape(Model_out , size(XX,1) , size(XX,2));
    
    figure();
    [C ,h] = contourf(XX , YY , Model_out);
    clabel(C , h);
    
    xlabel(var_sweep{1});
    ylabel(var_sweep{2});
    
    title([var_out ' vs. ' var_sweep{1} ' and ' var_sweep{2}]);
    
    export_name = ['CONTOUR_' , var_sweep{1} , '_' , var_sweep{2} , '_' , var_out , '.png'];
end
%%  OUTPUT

if b_save
   print(fullfile(export_dir , export_name) , '-dpng' , '-r600'); 
end

v
