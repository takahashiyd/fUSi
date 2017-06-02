
function [J, L, BW] = PlayfUsiROI(FileName, dt, LimDepth, LimLateral, scale, flagplot)
% play fUSi image sequence as movies for selected region
%Select a region of interest (ROI) and press enter

%Input
%FileName = file and address
%dt = interval between frames in seconds
%LimDepth = limits of imaging depth
%LimLateral = limits of image lateral
%scale = scaling the limits of color code
% flagplot = 1 if you want to see the plots and movies

%Output
%J = filtered images
%L = filtered image with mask
%BW = mask

%DYT 05 19 2017

%e.g.
%ad = cd;PlayfUsiROI([ad(1:end-4) 'Data\051817\fus\sagittal_172224_fus'], 0.5, [1 9], [0 9], 0.1, 1)


if nargin < 5
    scale = 0.1;
    flagplot = 0;
end

if nargin < 5
    flagplot = 0;
end



load(FileName)
Depth = [1:size(I,1)]/size(I,1)*(LimDepth(2)-LimDepth(1));
Lateral = [1:size(I,2)]/size(I,2)*(LimLateral(2)-LimLateral(1));

MaxT = max(max(max(I)));
MinT = min(min(min(I)));

figure
colormap(hot)
imagesc(Depth, Lateral, I(:,:,1), scale*[MinT MaxT])
BW = roipoly;
H = fspecial('unsharp');
%H = fspecial('gaussian');
J = NaN(size(I));
L = NaN(size(I));

title('Filtering')
for n = 1:size(I,3)
    J(:,:,n) = roifilt2(H,I(:,:,n),BW);
end



nMaxT = max(max(max(J)));
nMinT = min(min(min(J)));
nMedT = median(median(median(J)));

for n = 1:size(I,3)
    L(:,:,n) = J(:,:,n).*BW;
end
L(L == 0) = NaN;


if flagplot == 1
    figure
    colormap(hot)
    
    
    subplot(2,3,[5 6])
    plot(time, squeeze(nanmean(nanmean(L,1),2)), 'b')
    axis tight
    
    
    for n = 1:size(I,3)
        subplot(2,3,1)
        imagesc(Depth, Lateral, I(:,:,n), scale*[nMinT nMaxT])
        xlabel('Lateral (mm)')
        ylabel('Depth (mm)')
        title(['T = ' num2str(time(n))])
        
        subplot(2,3,2)
        imagesc(Depth, Lateral, J(:,:,n), scale*[nMinT nMaxT])
        xlabel('Lateral (mm)')
        ylabel('Depth (mm)')
        
        subplot(2,3,3)
        imagesc(Depth, Lateral, L(:,:,n), scale*[nMinT nMaxT])
        xlabel('Lateral (mm)')
        ylabel('Depth (mm)')
        
        subplot(2,3,4)
        plot(time(max(1,n-100):n), squeeze(nanmean(nanmean(L(:,:,max(1,n-100):n),1),2)))
        
        subplot(2,3,[5 6])
        hold on
        vline(time(n), 'r')
        
        pause(0.1*dt)
    end
end