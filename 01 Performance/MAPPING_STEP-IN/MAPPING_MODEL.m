
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   19/03/2018
%   LUCIEN VIALA
%   AERO MAPPING KRIGGING MODEL
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc

%%  VARIABLES

dace_path = './99 ANALYSIS_SOFTWARE/DACE';


source_data_path = './01 Performance/MAPPING_STEP-IN/DATA';
DATA_RAW_in = 'MFE19_FINAL_MAPPING_STEPIN_19032018.csv' ;

AERO_CLASS_PATH = './01 Performance/MAPPING_STEP-IN/MODELS';
AERO_CLASS_OUT  = 'MFE19_FINAL_MAPPING_STEP_IN_LOWSLIP';

rho_ref = 1.1845;
v_ref = 16;


%%  EXTRACT DATA

Data_Table = readtable(fullfile(source_data_path , DATA_RAW_in));
Data_Table(:,1) = [];

%%  DACEFIT

Data_IN = {'FrontRideHeightChange' , 'RearRideHeightChange' , ... 
    'Wheel_Angle' , 'SideSlip' , 'Roll'};
Sub_OUT = {'DownforceFW','DownforceUT','DownforceRW'};

regr = @regpoly2;
corr = @corrgauss;
theta_0 = 10;
lob = [1e-1]; upb = [20];

[CLA_dmodel , ~]  = dacefit(Data_Table{:,Data_IN} , Data_Table ... 
    {:,'CLA_Mean'} , regr , corr , theta_0 , lob , upb);
[CDA_dmodel , ~]  = dacefit(Data_Table{:,Data_IN} , Data_Table ...
    {:,'CDA_Mean'} , regr , corr , theta_0 , lob , upb);
[ABAL_dmodel , ~] = dacefit(Data_Table{:,Data_IN} , Data_Table ... 
    {:,'A___Front_Aero_Balance'} , regr , corr , theta_0 ,lob , upb);

Aero = Aero(CLA_dmodel , CDA_dmodel ,  ABAL_dmodel);

for ii = 1:length(Sub_OUT)
    eval(['[Aero.subModels.' Sub_OUT{ii} ' , ~] = dacefit(Data_Table{:,Data_IN} , Data_Table{:,{''' Sub_OUT{ii} '''}}/(0.5*rho_ref*v_ref^2) , regr , corr , theta_0 ,lob , upb);'])
end
Aero.Cl
%% PACKAGE AERO_MODEL

save(fullfile(AERO_CLASS_PATH , AERO_CLASS_OUT) , 'Aero');
