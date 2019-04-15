PRO My_ShowFont
Compile_OPT IDL2, Hidden
!Quiet = 1

width  = 16    ;--page width
height = 7     ;--page height
pos0   = [0.005, 0.015, 0.995, 0.870]    ;--zone for the plot, nothing outside this region
space  = 0.005    ;--spacing between subplot
vshift = 0.02     ;--vertical shift for the chars
xlen   = (pos0[2] - pos0[0] -  2. * space) / 3.    ;--length of each subplot
pos0   = [pos0[0], pos0[1], pos0[0] + xlen, pos0[3]]    ;--position for the first subplot
box    = [[pos0[0], pos0[0], pos0[2], pos0[2], pos0[0]], $
          [pos0[1], pos0[3], pos0[3], pos0[1], pos0[1]]]
dx = (pos0[2] - pos0[0]) / 17.
dx = (pos0[2] - pos0[0] - 1.2 * dx) / 16.
dy = (pos0[3] - pos0[1]) / 15.
dy = (pos0[3] - pos0[1] - 0.8 * dy) / 14
ytxt = [pos0[0] + Indgen(15) * dy, pos0[3]] & ytxt = Reverse(ytxt)
ytxt =  ytxt[1 : 15] + vshift
xtxt = [pos0[2] - Indgen(17) * dx, pos0[0]] & xtxt = Reverse(xtxt)
xtxt = (xtxt[1 : 17] + xtxt[0 : 16]) / 2.
font     =        [-1,                1,          0]
HTD      = '!6' + ['Hershey Vector [-1]', 'TrueType [1]', 'Device [0]'] + '!X'
fontnum  = [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,16, 17, 18, 19, 20]
PRE      = '!6' + StrTrim(fontnum, 2) + '!I !N-!I !N'
fontname = [['Simplex Roman',  'Helvetica',             'Helvetica'],                     $    ;--3
            ['Simplex Greek',  'Helvetica Bold',        'Helvetica Bold'],                $    ;--4
            ['Duplex Roman',   'Helvetica Italic',      'Helvetica Narrow'],              $    ;--5
            ['Complex Roman',  'Helvetica Bold Italic', 'Helvetica Narrow Bold Oblique'], $    ;--6
            ['Complex Greek',  'Times',                 'Times Roman'],                   $    ;--7
            ['Complex Italic', 'Times Italic',          'Times Bold Italic'],             $    ;--8
            ['Math',           'Symbol',                'Symbol'],                        $    ;--9
            ['Special',        'DejaVuSans',            'Zapf Dingbats'],                 $    ;--10
            ['Gothic English', 'Courier',               'Courier'],                       $    ;--11
            ['Simplex Script', 'Courier Italic',        'Courier Oblique'],               $    ;--12
            ['Complex Script', 'Courier Bold',          'Palatino'],                      $    ;--13
            ['Gothic Italian', 'Courier Bold Italic',   'Palatino Italic'],               $    ;--14
            ['Gothic German',  'Times Bold',            'Palatino Bold'],                 $    ;--15
            ['Cyrillic',       'Times Bold Italic',     'Palatino Bold Italic'],          $    ;--16
            ['Triplex Roman',  'Helvetica*',            'Avant Garde Book'],              $    ;--17
            ['Triplex Italic', 'Helvetica*',            'New Century Schoolbook'],        $    ;--18
            ['None',           'Helvetica*',            'New Century Schoolbook Bold'],   $    ;--29
            ['Miscellaneous',  'Helvetica*',            'Undefined Used Font']]                ;--20
Set_Plot, 'PS'
pdf = ''
For ifont = 0, N_Elements(fontnum) - 1 Do Begin
    filename = 'Fonts' + StrTrim(fontnum[ifont], 2)
    Device, FileName = filename + '.eps', /Color, Bits_Per_Pixel = 8, XSize = width, YSize = height
    Erase
    For i = 0, 3 - 1 Do Begin
        CgPlotS, box[*, 0] + (xlen + space) * i, box[*, 1], /Normal, Color = CgColor('Black')
        XYouts, (pos0[0] + pos0[2]) / 2. + (xlen + space) * i, pos0[3] + dy * 1.25, HTD[i], $
                /Normal, Alignment = 0.5, CharSize = 1, CharThick = 2, Font = -1, Color = CgColor('Black')
        XYouts, (pos0[0] + pos0[2]) / 2. + (xlen + space) * i, pos0[3] + dy * 0.3, PRE[ifont] + fontname[i, ifont] + '!X', $
                /Normal, Alignment = 0.5, CharSize = 0.75, CharThick = 1, Font = -1, Color = CgColor('Royal Blue')
        For ix = 1, 16 Do Begin
            CgPlotS, [pos0[2] - dx * ix, pos0[2] - dx * ix] + (xlen + space) * i, $
                     [pos0[1], pos0[3]], $
                     /Normal, Color = CgColor('Gray')
        EndFor
        For iy = 1, 14 Do Begin
            CgPlotS, [pos0[0], pos0[2]] + (xlen + space) * i, $
                     [pos0[1] + dy * iy, pos0[1] + dy * iy], $
                     /Normal, Color = CgColor('Gray')
        EndFor
        XYouts, xtxt[0] + (xlen + space) * i, ytxt[0], 'code', /Normal, $
                Alignment = 0.5, CharSize = 0.4, CharThick = 1, Font = -1, Color = CgColor('Black')
        XYouts, xtxt[1 : 16] + (xlen + space) * i, ytxt[0], StrTrim(Indgen(16), 2), /Normal, $
                Alignment = 0.5, CharSize = 0.4, CharThick = 1, Font = -1, Color = CgColor('Black')
        XYouts, xtxt[0] + (xlen + space) * i, ytxt[1 : 14], StrTrim(Indgen(14) * 16 + 32, 2), /Normal, $
                Alignment = 0.5, CharSize = 0.4, CharThick = 1, Font = -1, Color = CgColor('Black')
        If fontnum[ifont] EQ 19 AND i EQ 0 Then Continue
        If fontnum[ifont] EQ 20 AND i EQ 2 Then Continue
        For ic = 1, 14 Do Begin
        For jc = 1, 16 Do Begin
            char = String(Byte((ic - 1) * 16 + 32 + (jc - 1)))
            If char EQ '!' Then char = '!!'
            XYouts, xtxt[jc] + (xlen + space) * i, ytxt[ic], '!' + StrTrim(fontnum[ifont], 2) + char + '!X', /Normal, $
                    Alignment = 0.5, CharSize = 0.75, CharThick = 1, Font = font[i], Color = CgColor('Blue')
        EndFor
        EndFor
    EndFor
    Device, /Close_File
    ; convert EPS to PDF
    cmd = "epstopdf " + filename + '.eps'
    Spawn, cmd
    pdf = pdf + ' ' + filename + '.pdf'
EndFor
; combine to a sinle PDF file
cmd = 'pdftk ' + pdf + ' output ' + 'Fonts.pdf'
Spawn, cmd
; delete single EPS and PDF files
Spawn, "rm *.eps"
Spawn, "rm " + pdf
END
