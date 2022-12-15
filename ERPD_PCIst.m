%%%
%%% AUTHOR:         Matias Cavelli
%%% CONTACT:        cavelligonca@wisc.edu;  mcavelli@fmed.edu.uy;
%%% AFFILIATIONS:
%%%     1 - Departament of Psychiatry, Center for Sleep and Consciousness,
%%%         University of Wisconsin–Madison, USA.
%%%     2 - Universidad de la Republica (UdelaR), Departamento de
%%%         Fisiologia, Facultad de Medicina, Montevideo, Uruguay.
%%% VERSION:        December 2022
%%%
%%% Necessary Functions: PCIst; dimensionality_reduction; replace_bad_channels
%% 
%close all
clear all
clc
tic

%% load the data and define parameters 

load('ERPD_imec1_Sevo_lf.mat');
RCh = 293; % reference channel 
Cx_list = (295:375); % list of cortical channels 
ntrials = (1:83); % maximum number of trials shared by the 3 states
depth = (1:1:384); %channels from the tip of the probe

%% Replace bad channels 

ERPD = ERPD(:,:,ntrials);
list_ch = [288];% list of bad channels from the tip of the neuropixel probe 
jump_list = [1]; %replace by +- the first (1), second (2) or X neighboring channles 
ERPD = replace_bad_channels(ERPD,list_ch,jump_list);% function

%% 
figure()
t = tiledlayout(1,3);
set(gcf,'Position',[50 50 800 300]) %,'BackgroundColor',[0, 0, 0]

%% plot ERP

MERP = mean (ERPD,3);
nexttile (1)
contourf(ttime,depth', MERP,100,'linestyle','none','LineWidth',0.01,'edgecolor','none')%,'linestyle','none'
title ('All channels ERP')
ylabel('Channels from tip')
xlabel('Time (sec)')
set(gca, 'FontName', 'Times New Roman','FontSize',12)
xlim ([-0.2 0.8])
caxis ([-150 150])
colormap (jet)
line([0, 0], ylim, 'Color', 'k','LineStyle','--','LineWidth', 1); 

%% rereferencing to WM

ERP = ERPD;
for i = 1:size(ERP,1)
   for j = 1:size(ERP,3) 
       TT = ERPD(i,:,j) - ERPD(RCh,:,j);% select the stim + the channel
       ERP(i,:,j) = TT;
   end
end

%% ERP cortical plot. butterfly style

nexttile (2)

MERP = mean (ERP,3);
MERP = MERP(Cx_list,:);
for i = 1:2:size(MERP(:,:),1)
    plot(ttime,MERP(i,:)','Color',[0, 0, 0, 0.1])
    hold on
end 
title ('Cortical ERP') 
xlabel('Time (sec)')
ylabel('\muV')  
set(gca, 'FontName', 'Times New Roman','FontSize',12)
xlim ([-0.2 0.8])
line([0, 0], ylim, 'Color', 'k','LineStyle','--','LineWidth', 1); 

%% PCIst and PC

times = ttime.*1000;
par=struct('baseline',[-800 -100],'response',[10 800],'k',1.2,'min_snr',1.6,'max_var',99,'l',1,'nsteps',100,'tau',2);
[pci,dNST,parameters] = PCIst(MERP, times, par);
[signal,eigenv]=dimensionality_reduction(MERP,times,par);

%% Z-scored the PC

indsbase=(times>=parameters.baseline(1) & times<=parameters.baseline(2)); % baseline index

PCZs = nan(size(signal));
for i = 1: size(signal,1)
    MBL = mean(signal(i,indsbase),2);
    SBL = std(signal(i,indsbase),1,2);
    ZScore = (signal(i,:) - MBL)./ (SBL);
    PCZs(i,:) = ZScore;
end

nPC = numel(dNST); % number of PC
nST = mean(dNST); % mean ST value

%% plot PC and PCIst

nexttile (3)

plot(ttime,PCZs','LineWidth',1)
title (['PCIst = ',num2str(pci)])
xlabel('Time (sec)')
ylabel('Z-Score') 
set(gca, 'FontName', 'Times New Roman','FontSize',12)
xlim ([-0.2 0.8])
legend('PC1','PC2','eStim')%,'Location','eastoutside'
legend('Boxoff')
line([0, 0], ylim, 'Color', 'k','LineStyle','--','LineWidth', 1); % 'LineWidth', 2

%%
toc