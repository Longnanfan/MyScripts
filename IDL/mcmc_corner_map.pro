Function Get_Data

np = 10000
chain = {a:RandomN(seed, np), b:RandomN(seed, np), c:RandomN(seed, np), d:RandomN(seed, np)}

Return, chain

END




FUNCTION Get_Contour, density, percentile = percentile

; 这里的 percentile 要按照从大到小的顺序

IF N_Elements(percentile) EQ 0 THEN percentile = [0.84, 0.50, 0.16]
percentile = 1 - percentile
temp_ = density[Sort(density)]
tempC = Total(temp_, /Cumulative)
inds = Value_Locate(tempC, percentile)
vals = temp_[inds]
Return, vals
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
        ;--------------------------------------------------------------------v
        xbinsize = (Max(x)-Min(x))/25.0
        ybinsize = (Max(y)-Min(y))/25.0
        density = Hist_2D(x, y, Bin1 = xbinsize, Bin2 = ybinsize) / Double(N_Elements(x))
        ;--------------------------------------------------------------------^
        
        cgImage, BytSCL(density), Position = rect, /NoErase, XRange = [Min(x), Max(x)], YRange = [Min(y), Max(y)]
        
        ;--------------------------------------------------------------------v
        cgContour, density, Position = rect, /NoErase, XStyle = 1+4, YStyle = 1+4, Levels = Get_Contour(density, percentile = [0.84, 0.50, 0.16]), $
                   Label = 0, C_Colors = cgColor("Red")
        ;--------------------------------------------------------------------^
        
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
