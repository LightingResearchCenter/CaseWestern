function hc = phasorplot(varargin)
% phasor plot plots phasors passed as magnitude and angle (angle in hours)
% The function requires at least 2 arguments, and the arguments that can be
% passed are:
% argument 1: magnitude
% argument 2: angle
% argument 3: radius of the outer circle/plot (1 by default)
% argument 4: number of circles (4 by default)
% argument 5: number of spokes (6 by default)
% argument 6: where the circle labels sit with respect to the axis vertically ('top' by default)
% argument 7: where the circle labels sit with respect to the axis horizontally ('left' by default)
% argument 8: pass a zero if you don't want heads on your arrows, and pass the size of the heads you want if not (e.g., .1)
% argument 9: pass a zero if you want the circles labelled on the positive y axis, a one if you want them on the negative x axis, a two if you want them on the negative y axis, and a 3 if you want them on the positive x axis
% argument 10: the distance from the plot you want the spoke labels (0 by default)
% 
% Thus, to plot a magnitude of .5 and an angle of 3 hours on a plot with radius 1, 3 rings, 12 spokes, small arrowheads, and labels on the -x-axis, you could use:
% phasorplot(.5, 3, 1, 3, 12, 'top', 'left', .05, 1, 0)
% 
% Using H = phasorplot(...) will let you use H as a normal plot handle so
% that you can change the line widths, line colors, etc.

[cax,args,nargs] = axescheck(varargin{:});

%set the default arguments as needed
switch(nargs)
    case 2
        args{3} = 1;
        args{4} = 4;
        args{5} = 6;
        args{6} = 'top';
        args{7} = 'left';
        args{8} = 0;
        args{9} = 0;
        args{10} = 0;
        
    case 3
        args{4} = 4;
        args{5} = 6;
        args{6} = 'top';
        args{7} = 'left';
        args{8} = 0;
        args{9} = 0;
        args{10} = 0;
        
    case 4
        args{5} = 6;
        args{6} = 'top';
        args{7} = 'left';
        args{8} = 0;
        args{9} = 0;
        args{10} = 0;
        
    case 5
        args{6} = 'top';
        args{7} = 'left';
        args{8} = 0;
        args{9} = 0;
        args{10} = 0;
        
    case 6
        args{7} = 'left';
        args{8} = 0;
        args{9} = 0;
        args{10} = 0;
        
    case 7
        args{8} = 0;
        args{9} = 0;
        args{10} = 0;
        
    case 8
        args{9} = 0;
        args{10} = 0;
        
    case 9
        args{10} = 0;
        
end

%convert to cartestian
mag = args{1};
args{1} = mag.*cos(args{2}.*pi/12);
args{2} = mag.*sin(args{2}.*pi/12);

%set arrow head sizes
xx = [0 1 (1 - args{8}) 1 (1 - args{8})].';
yy = [0 0 args{8} 0 -args{8}].';


arrow = xx + yy.*sqrt(-1);

if nargs == 2
    x = args{1};
    y = args{2};
    if ischar(y)
        s = y;
        y = imag(x); x = real(x);
    else
        s = [];
    end
elseif nargs == 1
    x = args{1}; 
    s = [];
    y = imag(x); x = real(x);
else
    x = args{1};
    y = args{2};
    if ischar(y)
        s = y;
        y = imag(x); x = real(x);
    else
        s = [];
    end
end

x = x(:);
y = y(:);
if length(x) ~= length(y)
    error('MATLAB:compass:LengthMismatch','X and Y must be same length.');
end

z = (x + y.*sqrt(-1)).';
a = arrow * z;

% Create plot
cax = newplot(cax);

next = lower(get(cax,'NextPlot'));
isholdon = ishold(cax);
[th,r] = cart2pol(real(a),imag(a));

if isempty(s),
    h = polarhour2(cax,th,r,args{3},args{4},args{5},args{6},args{7},...
        args{8},args{9},args{10});
%     co = get(cax,'colororder');
%     set(h,'color',co(1,:))
    set(h,'color','k');
else
    h = polarhour2(cax,th,r,s);
    set(h,'color','k');
end
if ~isholdon, set(cax,'NextPlot',next); end

if nargout == 1
    hc = h;
end


function hpol = polarhour2(varargin)
% Parse possible Axes input
[cax,args,nargs] = axescheck(varargin{:});
% error(nargchk(1,3,nargs,'struct'));

theta = args{1};
rho = args{2};

if ischar(rho)
    line_style = rho;
    rho = theta;
    [mr,nr] = size(rho);
    if mr == 1
        theta = 1:nr;
    else
        th = (1:mr)';
        theta = th(:,ones(1,nr));
    end
else
    line_style = 'auto';
end

if ischar(theta) || ischar(rho)
    error('MATLAB:polar:InvalidInputType', 'Input arguments must be numeric.');
end
if ~isequal(size(theta),size(rho))
    error('MATLAB:polar:InvalidInput', 'THETA and RHO must be the same size.');
end

% get hold state
cax = newplot(cax);

next = lower(get(cax,'NextPlot'));
hold_state = ishold(cax);

% get x-axis text color so grid is in same color
% tc = get(cax,'xcolor');
tc = [0.5 0.5 0.5];
ls = get(cax,'gridlinestyle');

% Hold on to current Text defaults, reset them to the
% Axes' font attributes so tick marks use them.
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data')

% only do grids if hold is off
if ~hold_state

% make a radial grid
    hold(cax,'on');
% ensure that Inf values don't enter into the limit calculation.
    arho = abs(rho(:));
    maxrho = max(arho(arho ~= Inf));
    hhh=line([-maxrho -maxrho maxrho maxrho],[-maxrho maxrho maxrho -maxrho],'parent',cax);
    set(cax,'dataaspectratio',[1 1 1],'plotboxaspectratiomode','auto')
    v = [get(cax,'xlim') get(cax,'ylim')];
    ticks = sum(get(cax,'ytick')>=0);
    delete(hhh);
% check radial limits and ticks
    rmin = 0; rmax = v(4); rticks = max(ticks-1,2);
    if rticks > 5   % see if we can reduce the number
        if rem(rticks,2) == 0
            rticks = rticks/2;
        elseif rem(rticks,3) == 0
            rticks = rticks/3;
        end
    end
    
    if(nargs > 2)
        rmax = args{3};
        rticks = args{4};
    end

% define a circle
    th = 0:pi/50:2*pi;
    xunit = cos(th);
    yunit = sin(th);
% now really force points on x/y axes to lie on them exactly
    inds = 1:(length(th)-1)/4:length(th);
    xunit(inds(2:2:4)) = zeros(2,1);
    yunit(inds(1:2:5)) = zeros(3,1);
% plot background if necessary
    if ~ischar(get(cax,'color')),
       patch('xdata',xunit*rmax,'ydata',yunit*rmax, ...
             'edgecolor',tc,'facecolor',get(cax,'color'),...
             'handlevisibility','off','parent',cax);
    end

% draw radial circles
    c82 = cos(82*pi/180);
    s82 = sin(82*pi/180);
    rinc = (rmax-rmin)/rticks;
    
    if(nargs > 5)
        vert = args{6};
        hor = args{7};
    else
        vert = 'top';
        hor = 'left';
    end
    
    for i=(rmin+rinc):rinc:rmax
        hhh = line(xunit*i,yunit*i,'linestyle',ls,'color',tc,'linewidth',1,...
                   'handlevisibility','off','parent',cax);
        if(nargs > 8)
            if(args{9} == 0)
                text(-.1,(i+rinc/20)*s82 + .02, ...
                    ['  ' num2str(i)],'verticalalignment',vert, 'horizontalalignment', hor,...
                    'handlevisibility','off','parent',cax)
            elseif(args{9} == 1)
                text(-(i+rinc/20)*s82 - .02, -.01,...
                    ['  ' num2str(i)],'verticalalignment',vert, 'horizontalalignment', hor,...
                    'handlevisibility','off','parent',cax)
            elseif(args{9} == 2)
                text(-.1,-(i+rinc/20)*s82 + .02, ...
                    ['  ' num2str(i)],'verticalalignment',vert, 'horizontalalignment', hor,...
                    'handlevisibility','off','parent',cax)
            else
                text((i+rinc/20)*s82 - .1, -.01,...
                    ['  ' num2str(i)],'verticalalignment',vert, 'horizontalalignment', hor,...
                    'handlevisibility','off','parent',cax)
                
            end
        end
    end
    set(hhh,'linestyle','-') % Make outer circle solid

% plot spokes
    th = (1:6)*2*pi/12;
    if(nargs > 4)
        th = (1:args{5})*2*(6/args{5})*pi/12;
        spoke_factor = 6/args{5};
    else
        spoke_factor = 1;
    end
    cst = cos(th); snt = sin(th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    line(rmax*cs,rmax*sn,'linestyle',ls,'color',tc,'linewidth',1,...
         'handlevisibility','off','parent',cax)

% annotate spokes in degrees
    rt = 1.1*rmax;
    if(nargs > 9)
        rt = (1.1 + args{10}) * rmax;
    end
    for i = 1:length(th)
        text(rt*cst(i),rt*snt(i),strcat(int2str(spoke_factor*i*2),' h'),...
             'horizontalalignment','center',...
             'handlevisibility','off','parent',cax);
        if i == length(th)
            loc = int2str(0);
        else
            loc = int2str(-12+spoke_factor*i*2);
        end
        text(-rt*cst(i),-rt*snt(i),strcat(loc,' h'),'horizontalalignment','center',...
             'handlevisibility','off','parent',cax)
    end

% set view to 2-D
    view(cax,2);
% set axis limits
    axis(cax,rmax*[-1 1 -1.15 1.15]);
end

% Reset defaults.
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits',fUnits );

% transform data to Cartesian coordinates.
xx = rho.*cos(theta);
yy = rho.*sin(theta);

% plot data on top of grid
if strcmp(line_style,'auto')
    q = plot(xx,yy,'LineWidth',2,'parent',cax);
else
    q = plot(xx,yy,line_style,'LineWidth',2,'parent',cax);
end

if nargout == 1
    hpol = q;
end

if ~hold_state
    set(cax,'dataaspectratio',[1 1 1]), axis(cax,'off'); set(cax,'NextPlot',next);
end
set(get(cax,'xlabel'),'visible','on')
set(get(cax,'ylabel'),'visible','on')

if ~isempty(q) && ~isdeployed
    makemcode('RegisterHandle',cax,'IgnoreHandle',q,'FunctionName','polar');
end