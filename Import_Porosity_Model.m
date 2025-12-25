%% Exemplary code for loading and visualization of porosity model

% Author: Philipp Koyan, Universitaet Potsdam, 2019.

% load the data
filename = 'Porosity_Model.h5';

% model discretization
res = h5readatt(filename,'/','mod_res');

% porosity model
porosity = h5read(filename,'/porosity');

% geometry
x = h5read(filename,'/xvec');
y = h5read(filename,'/yvec');
z = h5read(filename,'/zvec');

% colormap
pcmap = h5read(filename,'/pcmap');

disp(['Model discretization: ' num2str(res) ' m'])

%% Visualization of Porosity model
% The electrical subsurface properties can be calculated using Eqs. 1&2 given
% in the associated article and visualized in the same manner as follows

% x-z-(profile)-slices
f1=figure('NumberTitle','off','Name','x-z Porosity slice');
set(f1,'Color',[1 1 1],'Menubar','none','Units','centimeters','Position',[1 1 40 20]);
movegui(f1,'center')

for ii = 1:80:numel(y)
    dat2show = squeeze(porosity(:,:,ii));
    imagesc(x,z,dat2show);
    axis image
    colormap(pcmap)
    cb = colorbar;
    cb.Label.String = 'Porosity \Phi';
    caxis([min(porosity(:)) max(porosity(:))])
    xlabel('x in m')
    ylabel('z in m')
    title(['x-z slice at y = ' num2str(y(ii)) ' m'])
    set(gca,'FontSize',16)

    drawnow
    pause(1)
end

% x-y-(depth)-slices
f1=figure('NumberTitle','off','Name','x-y Porosity slice');
set(f1,'Color',[1 1 1],'Menubar','none','Units','centimeters','Position',[1 1 40 20]);
movegui(f1,'center')

for ii = 20:10:numel(z)
    dat2show = squeeze(porosity(ii,:,:));
    imagesc(x,y,dat2show');
    axis image xy
    colormap(pcmap)
    cb = colorbar;
    cb.Label.String = 'Porosity \Phi';
    cb.TickLength = 0; 
    caxis([min(porosity(:)) max(porosity(:))])
    xlabel('x in m')
    ylabel('y in m')
    title(['x-y slice at z = ' num2str(z(ii)) ' m'])
    set(gca,'FontSize',16)

    drawnow
    pause(1)
end
