
%=========Mouse callback===========
function []=get_pnts(src, e ,m_spec_deriv ,sound_bird, x_length , y_length ,h , h_t , fs , m_AM, m_FM ,m_Entropy , m_amplitude ,m_Freq,  m_PitchGoodness , m_Pitch  )
global x quit_index2 axis_x1 axis_x2 axis_y1 axis_y2 cutoff
  curr_point=get(gcf,'CurrentPoint');
  curr_position=get(gcf,'Position');
  figure(h);
  curr_axis=axis;
  ScreenSize=get(0,'ScreenSize');
  if length(x)==2
       x=[];
%       hold off
%       imagesc(m_spec_deriv);  colormap(bone); set(gca,'YDir','normal'); caxis([-cutoff cutoff])
%       axis(curr_axis);
%       axis off
           figure(h);
            h_line = findobj(gca,'Type','line');
            for k=1:length(h_line)
                xdata=get(h_line(k),'XData');
                if length(xdata)==2
                    delete(h_line(k));
                end
            end
  
   elseif length(x)==0
      x(1)=(curr_point(1)-0.00*curr_position(3))./(curr_position(3)-0.00*curr_position(3))*x_length+curr_axis(1)-1;
      m_const=1;
      if x(1)>0 & x(1)<size(m_spec_deriv,2)
       hold on
       plot([x(1)*m_const x(1)*m_const],[0 y_length],'r')
      end
   elseif length(x)==1
      x(2)=(curr_point(1)-0.00*curr_position(3))./(curr_position(3)-0.00*curr_position(3)) *x_length+curr_axis(1)-1;
      m_const=1;
        quit_index2=1;
         hold on
      if x(2)>0 & x(2)<size(m_spec_deriv,2)
         plot([x(2)*m_const x(2)*m_const],[0 y_length],'b')
         uiresume(h)
         [x]=sort(round([x(1),x(2)]));
         gui_image([],[],h,h_t,m_spec_deriv,sound_bird,[], x , fs , m_AM, m_FM ,m_Entropy , m_amplitude ,m_Freq,  m_PitchGoodness , m_Pitch  , x_length,y_length);
      end
   else
       error(['To many mouse clicks']);
  end
  
   
return
