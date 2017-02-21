function []=Spectral_derivatives(file,fs)

% []=Spectral_derivatives(file,fs)
% written by Sigal Saar
global figure_table

if nargin==0
bgcolor=[0.8 0.8 1];

    figure_table=[];

    h_t=figure;
    position=[0.745 0.1 0.255 0.26 ;
          0.745 0.4 0.255 0.26 ;
          0.745 0.7 0.255 0.26 ; ];
    set(gcf,'Units','normalized',...
    'position', position(2,:),...
    'Name',['Feature table'],...
    'NumberTitle','off',...
    'doublebuffer','on',...
    'HandleVisibility','on',...
    'MenuBar','none',...
   'Renderer', 'openGL',...
    'Color',bgcolor);
   gui_image([],[],[],h_t,[],[],[],[],[],[],[],[],[],[],[],[],[],[]);

end
if nargin<2
    fs=44100;
end
if nargin>0
    if nargin<2
        fs=44100;
    end
    Call_spectrum_derivative(file,fs);
end
    