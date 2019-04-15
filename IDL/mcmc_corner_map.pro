Function Get_Data

np = 10000
chain = {a:RandomN(seed, np), b:RandomN(seed, np), c:RandomN(seed, np), d:RandomN(seed, np)}

Return, chain

END


PRO MCMC_Corner_Map

chain = Get_Data()

keys = ["a", "b", "c", "d"]


nbins = 10
pos = [0.15, 0.1, 0.99, 0.99]
hspace = 0.01
vspace = 0.01
width  = (pos[2] - pos[0] - (N_Elements(keys) - 1) * hspace) / N_Elements(keys)
height = (pos[3] - pos[1] - (N_Elements(keys) - 1) * vspace) / N_Elements(keys)

Set_Plot, "PS"
Device, FileName = "mcmc.ps", /Color, XSize = 10, YSize = 10
Device, Decomposed = 0
LOadCT, 16

!P.CharSize = 0.75

FOR i = 0, N_Elements(keys) - 1 DO BEGIN
FOR j = 0, N_Elements(keys) - 1, 1 DO BEGIN
    
    IF i + j GT N_Elements(keys) - 1 THEN CONTINUE
    
    itag_x = Where(StrUpCase(Tag_Names(chain)) EQ StrUpCase(keys[i]))
    itag_y = Where(StrUpCase(Tag_Names(chain)) EQ StrUpCase(keys[N_Elements(keys) - 1 - j]))

    rect = [pos[0] + i * (width + hspace), pos[1] + j * (height + vspace), pos[0] + i * (width + hspace) + width, pos[1] + j * (height + vspace) + height]
    x = chain.(itag_x)
    y = chain.(itag_y)
    
    IF i + j EQ N_Elements(keys) - 1 THEN BEGIN
        h = Histogram(x, NBins = nbins)
        h = Float(h) / Max(h)
        d = (Max(x) - Min(x)) / nbins
        xx = Replicate(0.0, 2 * nbins)
        xl = Min(x) + d * Findgen(nbins)
        xr = Min(x) + d * Findgen(nbins) + d
        xx[0:*:2] = xl
        xx[1:*:2] = xr
        xx = [[Min(x)], xx, [Max(x)]]
        yy = Replicate(0.0, 2 * nbins)
        yy[0:*:2] = h
        yy[1:*:2] = h
        yy = [[0], yy, [0]]
        
        cgPlot, xx, yy, Position = rect, /NoErase, XRange = [Min(xx), Max(xx)], YRange = [0, Max(yy) * 1.1], XStyle = 1, YStyle = 1, $
                XTickS = 2, XTickV = [-3, 0, 3], XTickName = Replicate(" ", 3), XMinor = 5, $
                YtickS = 4, YTickV = 0.25 * Findgen(5), YTickName = Replicate(" ", 5), YMinor = 5
                
        IF i EQ 0 THEN BEGIN
            cgPlot, xx, yy, Position = rect, /NoErase, XRange = [Min(xx), Max(xx)], YRange = [0, Max(yy) * 1.1], XStyle = 1, YStyle = 1, $
                    XTickS = 2, XTickV = [-3, 0, 3], XTickName = Replicate(" ", 3), XMinor = 5, $
                    YTickS = 4, YTickV = 0.25 * Findgen(5), YMinor = 5
        ENDIF
        
        IF j EQ 0 THEN BEGIN
            cgPlot, xx, yy, Position = rect, /NoErase, XRange = [Min(xx), Max(xx)], YRange = [0, Max(yy) * 1.1], XStyle = 1, YStyle = 1, $
                    XTickS = 2, XTickV = [-3, 0, 3], XTitle = keys[i], XMinor = 5, $
                    YtickS = 4, YTickV = 0.25 * Findgen(5), YTickName = Replicate(" ", 5), YMinor = 5
                    
        ENDIF
    ENDIF
    
    IF i + j LT N_Elements(keys) - 1 THEN BEGIN
        density = Hist_2D(x, y, Bin1 = (Max(x)-Min(x))/25.0, Bin2 = (Max(y)-Min(y))/25.0)
        density = BytSCL(density)
        cgImage, density, Position = rect, /NoErase, XRange = [Min(x), Max(x)], YRange = [Min(y), Max(y)]
        
        cgPlot, x, y, /NoData, Position = rect, /NoErase, XRange = [Min(x), Max(x)], YRange = [Min(y), Max(y)], XStyle = 1, YStyle = 1, $
                XTickS = 2, XTickV = [-3, 0, 3], XTickName = Replicate(" ", 3), XMinor = 5, $
                YTickS = 2, YTickV = [-3, 0, 3], YTickName = Replicate(" ", 3), YMinor = 5
                
        IF i EQ 0 THEN BEGIN
            cgPlot, x, y, /NoData, Position = rect, /NoErase, XRange = [Min(x), Max(x)], YRange = [Min(y), Max(y)], XStyle = 1, YStyle = 1, $
                    XTickS = 2, XTickV = [-3, 0, 3], XTickName = Replicate(" ", 3), XMinor = 5, $
                    YTickS = 2, YTickV = [-3, 0, 3], YMinor = 5, YTitle = keys[N_Elements(keys) - 1 - j]
        ENDIF
        
        IF j EQ 0 THEN BEGIN
            cgPlot, x, y, /NoData, Position = rect, /NoErase, XRange = [Min(x), Max(x)], YRange = [Min(y), Max(y)], XStyle = 1, YStyle = 1, $
                    XTickS = 2, XTickV = [-3, 0, 3], XMinor = 5, XTitle = keys[i], $
                    YTickS = 2, YTickV = [-3, 0, 3], YTickName = Replicate(" ", 3), YMinor = 5
        ENDIF
        
        
    ENDIF

ENDFOR
ENDFOR

Device, /Close_File

END
