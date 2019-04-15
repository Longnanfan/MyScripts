PRO Get_Data, picture, np = np, write = write
Compile_OPT IDL2, Hidden
!Quiet = 1
;- This procedure is intended to get coordinates of the data points in a literature figure.
;- Currently work for linear coordinates only.
;- There is a png file along with this procedure for a test purpose.
Print, StrJoin(Replicate('-', 80), '')
If N_Elements(picture) EQ 0 Then Begin
    picture = ''
    Read, picture, Prompt = 'Choose a picture for processing : '
EndIf
If not File_Test(picture) Then Begin
    Print, 'Input picture does not exist, the test picture along with this procedure will be used !!!!'
    picture = 'm4.png'
EndIf
Print, 'Processing on picture : "' + picture + '"'
ok = Query_PNG(picture, info)
image = Read_PNG(picture)
width  = info.Dimensions[0]
height = info.Dimensions[1]
Print, StrJoin(Replicate('-', 80), '')
Print, 'The raw size of the picture : [' + StrJoin(StrTrim(String([width, height], Format = '(I)'), 2), ', ') + ']'
asp    = Double(width) / Double(height)
Print, 'ASPECT Width/Height : ' + StrTrim(String(asp, Format = '(F10.6)'), 2)
If asp Ge 1.0 Then Begin    ;- if width > height, then set width = 1000, and keep aspect
    width  = 1000
    height = Fix(width / asp)
EndIf Else Begin            ;- if height > width, then set height = 800, and keep aspect
    height = 800
    width  = Fix(height * asp)
EndElse
Print, 'The display size for the image : [' + StrJoin(StrTrim(String([width, height], Format = '(I)'), 2), ', ') + ']'
Print, StrJoin(Replicate('-', 80), '')
image = congrid(image, 3, width, height)

xpos = 0
ypos = 0
Window, 1, XSize = width, YSize = height, XPos = xpos, YPos = ypos, Title = 'Display the Image'
xpos      = width + xpos + 20
ypos      = ypos
zoom_size = 300
Window, 2, XSize = zoom_size, YSize = zoom_size, XPos = xpos, YPos = ypos, Title = 'Zoom'

WSet, 1
CgImage, image, True = 1, Position = [0, 0, 1.0, 1.0], /Normal
Print, 'Get the PIXEL-coord of the Left-Bottom and Top-Right corners : '
xpix = [1.0, 1.0]
ypix = [1.0, 1.0]
For i = 0, 1 Do Begin
    !Mouse.Button = 0
    Repeat Begin
        Wset, 1
        Cursor, x0, y0, /Change, /Device
        If !Mouse.Button Eq 4 Then Return
        box = [x0 - 20, x0 + 20, y0 - 20, y0 + 20]
        box[0] = 0 > box[0]
        box[1] = width - 1 < box[1]
        box[2] = 0 > box[2]
        box[3] = height - 1 < box[3]
        zoom  = image[*, box[0] : box[1], box[2] : box[3]]
        Wset, 2
        CgPlot, x0, y0, Position = [0.08, 0.08, 0.92, 0.92], /Normal, /NoData, XStyle = 1 + 4, YStyle = 1 + 4, $
                XRange = [box[0], box[1]], YRange = [box[2], box[3]]
        CgImage, zoom, True = 1, /NoErase, Position = [0.08, 0.08, 0.92, 0.92]
        CgPlot, x0, y0, Position = [0.08, 0.08, 0.92, 0.92], /Normal, /OverPlot, Psym = 1, SymSize = 2, Color = CgColor('Green')
    EndRep Until (!Mouse.Button Eq 1)
    xpix[i] = x0
    ypix[i] = y0
    Cursor, x0, y0, /Change, /Device
EndFor
corners = ['[Left-Bottom]', '[Top-Right]  ']
For i = 0, 1 Do Begin
    Print, 'PIXEL-coord ' + corners[i] + ' : [' + StrTrim(String(xpix[i], Format = '(I)'), 2) + ', ' + StrTrim(String(ypix[i], Format = '(I)'), 2) + ']'
EndFor
Print, 'Set the DATA-coord of the Left-Bottom and Top-Right corners : '
If picture EQ 'm4.png' Then Begin
    xdata = [0.5, 3.5]
    ydata = [0.9, 1.4]
EndIf Else Begin
    xdata0 = 1.0
    Read, xdata0, Prompt = 'Enter X-coord [DATA] of Left-Bottom corner : '
    xdata = [xdata0]
    Read, xdata0, Prompt = 'Enter X-coord [DATA] of Top-Right corner   : '
    xdata = [xdata, xdata0]
    ydata0 = 1.0
    Read, ydata0, Prompt = 'Enter Y-coord [DATA] of Left-Bottom corner : '
    ydata = [ydata0]
    Read, ydata0, Prompt = 'Enter Y-coord [DATA] of Top-Right corner   : '
    ydata = [ydata, ydata0]
EndElse
corners = ['[Left-Bottom]', '[Top-Right]  ']
For i = 0, 1 Do Begin
    Print, 'DATA-coord ' + corners[i]  + ' : [' + StrTrim(String(xdata[i], Format = '(F10.1)'), 2) + ', ' + StrTrim(String(ydata[i], Format = '(F10.1)'), 2) + ']'
EndFor
Print, StrJoin(Replicate('-', 80), '')
Print, '              Data-Coordinate    ====>     Pixel-Coordinate'
Print, 'Left-Bottom : [' + StrJoin(StrTrim(String([xdata[0], ydata[0]], Format = '(F10.4)'), 2), ', ') + ']' + '             ' + $
                     '[' + StrJoin(StrTrim([xpix[0],  ypix[0]], 2), ', ') + ']'
Print, '  Right-Top : [' + StrJoin(StrTrim(String([xdata[1], ydata[1]], Format = '(F10.4)'), 2), ', ') + ']' + '             ' + $
                     '[' + StrJoin(StrTrim([xpix[1],  ypix[1]], 2), ', ') + ']'
xscale = (xdata[1] - xdata[0]) / (xpix[1] - xpix[0])
yscale = (ydata[1] - ydata[0]) / (ypix[1] - ypix[0])
Print, StrJoin(Replicate('-', 80), '')
Print, 'The Scale-Factor from pixel-number to data is : '
Print, '          ' + 'xscale = ' + StrTrim(String(xscale, Format = '(F10.6)'), 2) + ',  ' + $
                      'yscale = ' + StrTrim(String(yscale, Format = '(F10.6)'), 2)

If N_Elements(np) EQ 0 Then Begin
    Read, np, Prompt = 'Enter the Number of Points to be retrieved : '
EndIf
Print, 'Retrieve ' + StrTrim(String(np, Format = '(I)'), 2) + ' points from the picture.'
x_retrieve = Replicate(1.0D, np)  ;- may write out to a local file
y_retrieve = Replicate(1.0D, np)  ;- may write out to a local file
Print, StrJoin(Replicate('-', 80), '')
Print, 'Retrieved Data Points : '
For i = 0, np - 1 Do Begin
    !Mouse.Button = 0
    Repeat Begin
        Wset, 1
        Cursor, x0, y0, /Change, /Device
        If !Mouse.Button Eq 4 Then Return
        box = [x0 - 20, x0 + 20, y0 - 20, y0 + 20]
        box[0] = 0 > box[0]
        box[1] = width - 1 < box[1]
        box[2] = 0 > box[2]
        box[3] = height -1 < box[3]
        zoom = image[*, box[0] : box[1], box[2] : box[3]]
        Wset, 2
        CgPlot, x0, y0, Position = [0.08, 0.08, 0.92, 0.92], /Normal, /NoData, XStyle = 1 + 4, YStyle = 1 + 4, $
                XRange = [box[0], box[1]], YRange = [box[2], box[3]]
        CgImage, zoom, True = 1, /NoErase, Position = [0.08, 0.08, 0.92, 0.92]
        CgPlot, x0, y0, Position = [0.08, 0.08, 0.92, 0.92], /Normal, /OverPlot, Psym = 1, SymSize = 2, Color = CgColor('Green')
        x = (x0 - xpix[0]) * xscale + xdata[0]
        y = (y0 - ypix[0]) * yscale + ydata[0]
        XYouts, 0.1, 0.1, '[' + StrTrim(String(x, Format = '(F10.4)'), 2) + ', ' + $
                                StrTrim(String(y, Format = '(F10.4)'), 2) + ']', $
                                /Normal, Color = CgColor('Red'), CharSize = 2, CharThick = 2, Font = -1
    EndRep Until (!Mouse.Button Eq 1)
    x_retrieve[i] = x
    y_retrieve[i] = y
    Print, '          ' + '[' + StrJoin(StrTrim(String([x, y], Format = '(F10.4)'), 2), ', ') + ']'
    Cursor, x0, y0, /Change, /Device
EndFor
If KeyWord_Set(write) Then Begin
    file = File_BaseName(picture, 'png') + ".dat"
    Free_Lun, 1
    OpenW, 1, file
    PrintF, 1, "X", "Y", Format = "(A10, 2X, A10)"
    PrintF, 1, [Transpose(x_retrieve), Transpose(y_retrieve)], Format = "(F10.6, 2X, F10.6)"
    Free_Lun, 1
EndIf
Print, '=============== Done ==============='
END
