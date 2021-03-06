%% Setup the example TTD match

clear tracer
time=0:0.1:100;
gamma=25; delta=50;
    
    a1 = sqrt ( gamma^3 ./ (4*pi*delta^2.*time.^3) );
    a2 = -gamma*(time-gamma).^2./(4*delta^2*time);
    G = a1 .* exp( a2 );
    G( time==0 ) = 0;


truettd=inverse_gaussian_waugh([gamma delta],time);
clf
plot(time,truettd)
tracer.source(1,:)=exp(0.005*time); % Exponential tracer
tracer.source(2,:)=0.02*time; % Linear tracer
tracer.time=time;

conc(1)=trapz(time,fliplr(tracer.source(1,:)).*truettd);
conc(2)=trapz(time,fliplr(tracer.source(2,:)).*truettd);
fprintf('True TTD: GAMMA=%d DELTA=%d\n',gamma,delta)
%% See if we can get a reasonable answer for one tracer

tracsource.atmconc=tracer.source(1,:);
tracsource.time=time';

options = { ...
    'constraint','fixed', ...
    'x0',10, ...
    'lowerbound',0.1, ...
    'upperbound',100, ...
    'pecval',0.5 ...
    };
tic;
[meanage width error]=match1dTTD(conc(1)*1.0,1.0,tracsource,100, options{:});
disp('Single Tracer: Fixed Peclet Number')
fprintf('Mean Age: %3.2f Width: %3.2f Error: %5.5e\n',meanage,width,error)
toc;

options = { ...
    'constraint','peclet', ...
    'x0',[10 10], ...
    'lowerbound',[0.1 0.1], ...
    'upperbound',[100 100], ...
    'minpec',0.1, ...
    'maxpec',5 ...    
    };
tic;
[meanage width error]=match1dTTD(conc(1)*1.0,1.0,tracsource,100, options{:});
disp('Single Tracer: Constrained Peclet Numbe')
fprintf('Mean Age: %3.2f Width: %3.2f Error: %5.5e\n',meanage,width,error)
toc;

%% Two tracers
tracsource.atmconc=tracer.source;
tracsource.time=time';
% 
options = { ...
    'constraint','fixed', ...
    'x0',10, ...
    'lowerbound',0.1, ...
    'upperbound',100, ...
    'pecval',0.5 ...
    };

tic;
[meanage width error]=match1dTTD([conc(1) conc(2)]*1.0,1.0,tracsource,100,options{:});
disp('Dual Tracer: Fixed Peclet Number')
fprintf('Mean Age: %3.2f Width: %3.2f Error: %5.5e\n',meanage,width,error)
toc;

options = { ...
    'constraint','peclet', ...
    'x0',[10 10], ...
    'lowerbound',[0.1 0.1], ...
    'upperbound',[100 100], ...
    'minpec',0.1, ...
    'maxpec',10 ...    
    };

tic;
[meanage width error]=match1dTTD([conc(1) conc(2)]*1.0,1.0,tracsource,100,options{:});
disp('Dual Tracer: Constrained Peclet Number')
fprintf('Mean Age: %3.2f Width: %3.2f Error: %5.5e\n',meanage,width,error)
toc;