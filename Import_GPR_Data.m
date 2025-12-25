%% Exemplary code for loading and visualization of modeled GPR reflection data

% Author: Philipp Koyan, Universitaet Potsdam, 2019.

% load the data
filename ='GPR_Data.h5';

% GPR data
gprData = h5read(filename,'/gprData');

% sampling interval in ns
dt = h5readatt(filename,'/','dt');

% time vector in ns
t = h5read(filename,'/tvec');

% gpr max version
vrs = h5readatt(filename,'/','gprMax');

% nominal center frequency in MHz
fc =  h5readatt(filename,'/','centre_freq');

% disretization of input model 
res = h5readatt(filename,'/','model discretization');

% number of profiles
nprofiles = h5readatt(filename,'/','nprofiles');

% number of samples per trace
nsamples = h5readatt(filename,'/','nsamples');

% total number of traces
ntraces = h5readatt(filename,'/','ntraces');

% geometry
x = h5read(filename,'/xvec');
y = h5read(filename,'/yvec');
% source-receiver-offset
xoff = h5readatt(filename,'/','xoff');


disp(['unprocessed GPR data with nominal center frequency of '...
    num2str(fc) ' MHz' char(10) ...
    'modeled using gprMax version ' vrs char(10) ...
    'across our porosity model (fresh-water saturated sediments) with a model discretization of ' ...
     num2str(res) ' m' char(10) 'consisting of ' num2str(nprofiles) ...
    ' profiles (''B-Scans'') with ' ...
    num2str(numel(x)) ' traces(''A-Scans'') each;' char(10) ...
    'inline trace spacing: ' num2str(x(2)-x(1))...
    ' m, crossline trace spacing: ' num2str(y(2)-y(1))...
    ' m, source-receiver-offset: ' num2str(xoff) ' m'])

%% Visualization: GPR data 
% x-t-(inline|profile)-slices

f1=figure('NumberTitle','off','Name','GPR inline|profile slices');
set(f1,'Color',[1 1 1],'Menubar','none','Units','centimeters','Position',[1 1 40 20]);
movegui(f1,'center')

for ii=1:nprofiles
    dat2show=squeeze(gprData(:,:,ii));
    imagesc(x,t,dat2show);
    colormap gray
    caxis([-0.1 0.1])
    title(['GPR profile slice at y = ' num2str(y(ii)) ' m'])
    h = colorbar; 
    h.YLabel.String = 'Amplitude';
    xlabel('x in m')
    ylabel('t in ns')
    pbaspect([1 (0.085*max(t)/2)/(x(end)-x(1)) 1])
    set(gca,'FontSize',16)
    pause(.5)
end

% x-y-(time)-slices

f1=figure('NumberTitle','off','Name','GPR time slices');
set(f1,'Color',[1 1 1],'Menubar','none','Units','centimeters','Position',[1 1 40 20]);
movegui(f1,'center')

for ii=find(t>25,1,'first'):10:numel(t)
    dat2show=squeeze(gprData(ii,:,:))';
    imagesc(x,y,dat2show);
    colormap gray
    caxis([-0.1 0.1])
    title(['GPR time slice at t = ' num2str(round(t(ii),1)) ' ns'])
    h = colorbar; 
    h.YLabel.String = 'Amplitude';
    xlabel('x in m')
    ylabel('y in m')    
    axis xy
    axis image
    set(gca,'FontSize',16)
    pause(.5)
end