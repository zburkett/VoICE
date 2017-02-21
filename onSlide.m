function onSlide(Sld,ev,hPan)
    % slider value
    offset = get(Sld,'Value');

    % update panel position
    p = get(hPan, 'Position');  % panel current position
    set(hPan, 'Position',[p(1) -offset p(3) p(4)])
end