function h = imagescp(varargin)
%IMAGESCP Display image with scaled colors
%   IMAGESCP(...) is the same as IMAGE(...) except the data is scaled
%   to use the full colormap and plotted using PCOLOR.
%
%   IMAGESCP(...,CLIM) where CLIM = [CLOW CHIGH] can specify the
%   scaling.
%
%   See also IMSHOW, IMAGE, IMAGESC, PCOLOR, COLORBAR, IMREAD, IMWRITE.

% Created by Léa Strobino.
% Copyright 2017 hepia. All rights reserved.

[a,args,nargs] = axescheck(varargin{:});
clim = [];
if nargs < 3
  c = args{1};
  x = .5:size(c,2)+.5;
  y = .5:size(c,1)+.5;
  if nargs > 1
    clim = args{2};
  end
else
  x = args{1};
  y = args{2};
  c = args{3};
  if nargs > 3
    clim = args{4};
  end
  d = (x(end)-x(1))/(size(c,2)-1);
  x = [x(1)-d/2 (.5:size(c,2))*d+x(1)];
  d = (y(end)-y(1))/(size(c,1)-1);
  y = [y(1)-d/2 (.5:size(c,1))*d+y(1)];
end
c(end+1,:) = 0;
c(:,end+1) = 0;
a = newplot(a);
h_ = surface(x,y,zeros(size(c)),c,...
  'Parent',a,...
  'FaceColor','flat','EdgeColor','none',...
  'AlignVertexCenters','on');
if ~ishold(a)
  set(a,...
    'Box','on','Layer','Top','View',[0 90],...
    'XDir','normal','YDir','reverse','ZDir','normal',...
    'XLim',[min(x) max(x)],'YLim',[min(y) max(y)],'Zlim',[-1 1]);
end
if ~isempty(clim),
  set(a,'CLim',clim)
elseif ~ishold(a),
  set(a,'CLimMode','auto')
end
if nargout
  h = h_;
end
