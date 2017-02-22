function []=sam(file,fs)

%SAM – Sound Analysis, based on Matlab, presents spectral derivatives and
%features of sound – see user manual.
%[]=sam(file,fs)
% Written by Sigal Saar


global figure_table

if nargin==0
bgcolor=[0.8 0.8 1];

    figure_table=[];

    h_t=figure;
    position=[0.745 0.1 0.255 0.3 ;
          0.745 0.4 0.255 0.3 ;
          0.745 0.65 0.255 0.3 ; ];
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

else
    if ischar(file(1))
        [file fs]=wavread(file);
        file=file(:,1);
    else
        
        if nargin<2
            fs=44100;
        end
    end
    Call_spectrum_derivative(file,fs);
end
    