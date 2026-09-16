# Ricoh driver PPD options

Reference for the options in Ricoh's macOS PPDs, generated from the vendor PPDs as installed under
`/Library/Printers/PPDs/Contents/Resources`. Defaults are the vendor defaults.

Every `*OpenGroup` and `*OpenUI`/`*JCLOpenUI` option: keyword, label, UI type, default, choices
(`keyword (label)`), and custom-value parameters from `*CustomX True` + `*ParamCustomX`.
Options with no `*OpenGroup` are listed under **General**, which is where libcups and the CUPS web UI put them.

Custom values are set as `-o Keyword=Custom.value` (one parameter) or `-o Keyword={Param=value ...}` (several).
Passcode and password values set as a queue default are stored in plain text in the world-readable queue PPD.

## Drivers

| PPD | NickName | PCFileName | Version | Groups | Options | Custom-value options |
|---|---|---|---|---|---|---|
| `RICOH IM C2000` | RICOH IM C2000 PS | RI3645E3.PPD | 1.3 | 11 | 84 | 23 |
| `RICOH IM C4500` | RICOH IM C4500 PS | RI3643E3.PPD | 1.2 | 11 | 88 | 23 |
| `RICOH MP C2004ex` | RICOH MP C2004ex PS | RI3625E3.PPD | 3.1 | 10 | 78 | 22 |
| `RICOH MP C3004ex` | RICOH MP C3004ex PS | RI3621E3.PPD | 3.1 | 10 | 79 | 22 |
| `RICOH MP C307` | RICOH MP C307 PS | RI3571E3.PPD | 3.1 | 11 | 76 | 23 |
| `RICOH MP C3504` | RICOH MP C3504 PS | RI3522E3.PPD | 3.1 | 10 | 78 | 22 |
| `RICOH MP 5055` | RICOH MP 5055 PS | RI1795E3.PPD | 3.1 | 11 | 76 | 20 |
| `RICOH M C251FW.ppd` | RICOH M C251FW PS | RICOH M C251FW.ppd | 1.01 | 8 | 31 | 1 |
| `RICOH SP 3710DN.ppd` | RICOH SP 3710DN | RICOH SP 3710DN.ppd | 1.02 | 1 | 6 | 0 |

## RICOH IM C2000 PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Lower Paper Tray), `2Cassette` (Lower Paper Trays) |  |
| `InnerTray2` | Internal Tray 2 | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ShiftTray` | Internal Shift Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ExternalTray` | External Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `Finisher` | Finisher | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `FinRUBICONC` (Finisher SR3250), `FinAMURCBK` (Finisher SR3270), `FinUYUNIB` (Finisher SR3300) |  |
| `RIPostScript` | PostScript | PickOne | `IRIPS` | `IRIPS` (PostScript Emulation), `Adobe` (Adobe PostScript) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3 (297 x 420 mm) (Full Bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 255–908; `Height` points 419–3572; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3 (297 x 420 mm) (Full Bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `ColorModel` | Color Mode | PickOne | `CMYK` | `CMYK` (Color), `Gray` (Black and White) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope`, `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2), `Shift` (Internal Shift Tray), `External` (External Tray), `FinRUBICONCShift` (Finisher SR3250 Shift Tray), `FinAMURCBKUpper` (Finisher SR3270 Upper Tray), `FinAMURCBKShift` (Finisher SR3270 Shift Tray), `FinAMURCBKBKLower` (Finisher SR3270 Booklet Tray), `FinUYUNIBShift` (Finisher SR3300 Shift Tray) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope` |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `RICollateKind` | Collate Type | PickOne | `Normal` | `Normal` (Collate), `RotateCollate` (Rotating Collate), `ShiftCollate` (Shift Collate) |  |
| `StapleLocation` | Staple | PickOne | `None` | `None` (Off), `StaplessUpperLeft` (Top left (stapleless)), `StaplessUpperRight` (Top right (stapleless)), `UpperLeft` (Top left), `UpperRight` (Top right), `LeftW` (2 at left), `RightW` (2 at right), `UpperW` (2 at top), `CenterW` (2 at center) |  |
| `RIPunch` | Punch | PickOne | `None` | `None` (Off), `Left2` (2 at left), `Left3` (3 at left), `Left4` (4 at left), `Right2` (2 at right), `Right3` (3 at right), `Right4` (4 at right), `Upper2` (2 at top), `Upper3` (3 at top), `Upper4` (4 at top) |  |
| `RIFoldType` | Fold Type | PickOne | `None` | `None` (Off), `OutsideTwofold` (Half Fold - Print Outside (Finisher Booklet Tray)) |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom), `OpenToLeftNoneRed` (Open to Left/Top (Full Size)), `OpenToRightNoneRed` (Open to Right/Bottom (Full Size)) |  |
| `RIBookletPageSize` | Booklet - Paper Size | PickOne | `Default` | `Default` (Printer Default), `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RPSBitsPerPixel` | Gradation | PickOne | `2BitsPerPixel` | `2BitsPerPixel` (Standard), `1BitsPerPixel` (Fast), `4BitsPerPixel` (Fine) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Off), `3rhit` (Toner Saving) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |
| `RPSRGBcorrect` | Color Setting | PickOne | `DetailBright` | `None` (Off), `DetailNormal` (Fine), `DetailBright` (Super Fine) |  |
| `RPSColorRendDict` | Color Profile | PickOne | `Auto` | `Auto`, `AutoBright` (Auto (Brighter)), `AutoDeep` (Auto (Darker)), `Photograph` (Photographic), `PhotographBright` (Photographic (Brighter)), `PhotographDeep` (Photographic (Darker)), `Business` (Presentation), `BusinessBright` (Presentation (Brighter)), `BusinessDeep` (Presentation (Darker)), `Colorimetric` (Solid Color), `ColorimetricBright` (Solid Color (Brighter)), `ColorimetricDeep` (Solid Color (Darker)), `POP` (POP Display), `User` (User Setting), `Clpsimulation1` (Soft), `Clpsimulation2` (Sharp), `Clpsimulation4` (Vivid), `Clpsimulation7` (Deep), `Clpsimulation` (CLP Simulation) |  |
| `Rcmyksimulation` | CMYK Simulation Profile | PickOne | `Off` | `Off`, `USOffsetPrint` (US OffsetPrint), `Euroscale`, `JapanColor` (JapanColor2001), `PANTONE` (PaletteColor), `Trans01` (Make Bluer) |  |
| `RPSBlackMode` | Gray Reproduction | PickOne | `gray` | `gray` (Black/Gray by K (Text/Line Art)), `1Color` (Black by K), `4Color` (CMY+K), `grayText` (Black/Gray by K (Text only)), `1ColorText` (Black by K (Text only)), `grayAll` (Black/Gray by K (Strong UCR)) |  |
| `RPSBlackOverPrint` | Black Over Print | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RPSColorSep` | Separate into CMYK | PickOne | `None` | `None` (Do not Separate), `Cyan`, `Magenta`, `Yellow`, `Black`, `Red` (Magenta and Yellow), `Green` (Cyan and Yellow), `Blue` (Cyan and Magenta), `KCyan` (Black and Cyan), `KMagenta` (Black and Magenta), `KYellow` (Black and Yellow) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `Default` | `Default` (Printer Default), `HelveticaB` (Helvetica Bold), `CourierB` (Courier Bold), `TimesB` (Times Bold), `NimbusSansB` (NimbusSans Bold), `NimbusMonoPSB` (NimbusMonoPS Bold), `NimbusRomanB` (NimbusRoman Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `Default` | `Default` (Printer Default), `NimbusSansBold` (NimbusSans-Bold), `NimbusMonoPSBold` (NimbusMonoPS-Bold), `NimbusRomanBold` (NimbusRoman-Bold), `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black`, `Cyan`, `Magenta` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |
| `RICyan` | Cyan ( -50 to 50 ) | PickOne | `0` | `0` | `Cyan` real -50–50 |
| `RIMagenta` | Magenta ( -50 to 50 ) | PickOne | `0` | `0` | `Magenta` real -50–50 |
| `RIYellow` | Yellow ( -50 to 50 ) | PickOne | `0` | `0` | `Yellow` real -50–50 |

### Background Numbering

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBackgroundNumbering` | Background Numbering | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIBNSize` | Size | PickOne | `Normal` | `Small`, `Normal`, `Large` |  |
| `RIBNDensity` | Density | PickOne | `Normal` | `Light`, `Normal`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIBNColor` | Color | PickOne | `Black` | `Yellow`, `Red`, `Cyan`, `Magenta`, `Green`, `Blue`, `Black` |  |
| `RIStartNumber` | Start Number (1 to 9999) | PickOne | `1` | `1` | `StartNumber` int 1–9999 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH IM C4500 PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Lower Paper Tray), `LCT` (Tray 3 (LCT)), `2Cassette` (Lower Paper Trays) |  |
| `LargeCapacityTray` | Large Capacity Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `InnerTray2` | Internal Tray 2 | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ShiftTray` | Internal Shift Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ExternalTray` | External Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `Finisher` | Finisher | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `FinRUBICONC` (Finisher SR3250), `FinVOLGAEBK` (Finisher SR3290), `FinVOLGAE` (Finisher SR3280), `FinAMURCBK` (Finisher SR3270), `FinAMURCHY` (Finisher SR3260) |  |
| `MultiFold` | Folding Unit | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `RIPostScript` | PostScript | PickOne | `IRIPS` | `IRIPS` (PostScript Emulation), `Adobe` (Adobe PostScript) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3 (297 x 420 mm) (Full Bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 255–908; `Height` points 419–3572; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3 (297 x 420 mm) (Full Bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `ColorModel` | Color Mode | PickOne | `CMYK` | `CMYK` (Color), `Gray` (Black and White) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope`, `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2), `Shift` (Internal Shift Tray), `External` (External Tray), `FinRUBICONCShift` (Finisher SR3250 Shift Tray), `FinVOLGAEBKUpper` (Finisher SR3290 Upper Tray), `FinVOLGAEBKShift` (Finisher SR3290 Shift Tray), `FinVOLGAEBKBKLower` (Finisher SR3290 Booklet Tray), `FinVOLGAEUpper` (Finisher SR3280 Upper Tray), `FinVOLGAEShift` (Finisher SR3280 Shift Tray), `FinAMURCBKUpper` (Finisher SR3270 Upper Tray), `FinAMURCBKShift` (Finisher SR3270 Shift Tray), `FinAMURCBKBKLower` (Finisher SR3270 Booklet Tray), `FinAMURCUpper` (Finisher SR3260 Upper Tray), `FinAMURCShift` (Finisher SR3260 Shift Tray), `FinDONAUProof` (Folding Unit Tray) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope` |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `RICollateKind` | Collate Type | PickOne | `Normal` | `Normal` (Collate), `RotateCollate` (Rotating Collate), `ShiftCollate` (Shift Collate) |  |
| `StapleLocation` | Staple | PickOne | `None` | `None` (Off), `StaplessUpperLeft` (Top left (stapleless)), `StaplessUpperRight` (Top right (stapleless)), `UpperLeft` (Top left), `UpperRight` (Top right), `LeftW` (2 at left), `RightW` (2 at right), `UpperW` (2 at top), `CenterW` (2 at center) |  |
| `RIPunch` | Punch | PickOne | `None` | `None` (Off), `Left2` (2 at left), `Left3` (3 at left), `Left4` (4 at left), `Right2` (2 at right), `Right3` (3 at right), `Right4` (4 at right), `Upper2` (2 at top), `Upper3` (3 at top), `Upper4` (4 at top) |  |
| `RIZfold` | Z-fold | PickOne | `None` | `None` (Off), `Bottom` (Bottom Fold), `Right` (Right Fold), `Left` (Left Fold) |  |
| `RIFoldType` | Fold Type | PickOne | `None` | `None` (Off), `Twofold` (Half Fold), `Threefold` (Letter Fold-in), `ThreefoldOut` (Letter Fold-out), `OutsideTwofold` (Half Fold - Print Outside (Finisher Booklet Tray)) |  |
| `OverlapFold` | Multi-sheet Fold | PickOne | `Off` | `Off`, `On` |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom), `OpenToLeftNoneRed` (Open to Left/Top (Full Size)), `OpenToRightNoneRed` (Open to Right/Bottom (Full Size)) |  |
| `RIBookletPageSize` | Booklet - Paper Size | PickOne | `Default` | `Default` (Printer Default), `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RPSBitsPerPixel` | Gradation | PickOne | `2BitsPerPixel` | `2BitsPerPixel` (Standard), `1BitsPerPixel` (Fast), `4BitsPerPixel` (Fine) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Off), `3rhit` (Toner Saving) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |
| `RPSRGBcorrect` | Color Setting | PickOne | `DetailBright` | `None` (Off), `DetailNormal` (Fine), `DetailBright` (Super Fine) |  |
| `RPSColorRendDict` | Color Profile | PickOne | `Auto` | `Auto`, `AutoBright` (Auto (Brighter)), `AutoDeep` (Auto (Darker)), `Photograph` (Photographic), `PhotographBright` (Photographic (Brighter)), `PhotographDeep` (Photographic (Darker)), `Business` (Presentation), `BusinessBright` (Presentation (Brighter)), `BusinessDeep` (Presentation (Darker)), `Colorimetric` (Solid Color), `ColorimetricBright` (Solid Color (Brighter)), `ColorimetricDeep` (Solid Color (Darker)), `POP` (POP Display), `User` (User Setting), `Clpsimulation1` (Soft), `Clpsimulation2` (Sharp), `Clpsimulation4` (Vivid), `Clpsimulation7` (Deep), `Clpsimulation` (CLP Simulation) |  |
| `Rcmyksimulation` | CMYK Simulation Profile | PickOne | `Off` | `Off`, `USOffsetPrint` (US OffsetPrint), `Euroscale`, `JapanColor` (JapanColor2001), `PANTONE` (PaletteColor), `Trans01` (Make Bluer) |  |
| `RPSBlackMode` | Gray Reproduction | PickOne | `gray` | `gray` (Black/Gray by K (Text/Line Art)), `1Color` (Black by K), `4Color` (CMY+K), `grayText` (Black/Gray by K (Text only)), `1ColorText` (Black by K (Text only)), `grayAll` (Black/Gray by K (Strong UCR)) |  |
| `RPSBlackOverPrint` | Black Over Print | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RPSColorSep` | Separate into CMYK | PickOne | `None` | `None` (Do not Separate), `Cyan`, `Magenta`, `Yellow`, `Black`, `Red` (Magenta and Yellow), `Green` (Cyan and Yellow), `Blue` (Cyan and Magenta), `KCyan` (Black and Cyan), `KMagenta` (Black and Magenta), `KYellow` (Black and Yellow) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `Default` | `Default` (Printer Default), `HelveticaB` (Helvetica Bold), `CourierB` (Courier Bold), `TimesB` (Times Bold), `NimbusSansB` (NimbusSans Bold), `NimbusMonoPSB` (NimbusMonoPS Bold), `NimbusRomanB` (NimbusRoman Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `Default` | `Default` (Printer Default), `NimbusSansBold` (NimbusSans-Bold), `NimbusMonoPSBold` (NimbusMonoPS-Bold), `NimbusRomanBold` (NimbusRoman-Bold), `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black`, `Cyan`, `Magenta` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |
| `RICyan` | Cyan ( -50 to 50 ) | PickOne | `0` | `0` | `Cyan` real -50–50 |
| `RIMagenta` | Magenta ( -50 to 50 ) | PickOne | `0` | `0` | `Magenta` real -50–50 |
| `RIYellow` | Yellow ( -50 to 50 ) | PickOne | `0` | `0` | `Yellow` real -50–50 |

### Background Numbering

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBackgroundNumbering` | Background Numbering | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIBNSize` | Size | PickOne | `Normal` | `Small`, `Normal`, `Large` |  |
| `RIBNDensity` | Density | PickOne | `Normal` | `Light`, `Normal`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIBNColor` | Color | PickOne | `Black` | `Yellow`, `Red`, `Cyan`, `Magenta`, `Green`, `Blue`, `Black` |  |
| `RIStartNumber` | Start Number (1 to 9999) | PickOne | `1` | `1` | `StartNumber` int 1–9999 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH MP C2004ex PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Lower Paper Tray), `2Cassette` (Lower Paper Trays) |  |
| `InnerTray2` | Internal Tray 2 | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ShiftTray` | Internal Shift Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ExternalTray` | External Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `Finisher` | Finisher | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `FinRUBICONB` (Finisher SR3130), `FinAMURBBK` (Finisher SR3220), `FinUYUNI` (Finisher SR3180) |  |
| `RIPostScript` | PostScript | PickOne | `IRIPS` | `IRIPS` (PostScript Emulation), `Adobe` (Adobe PostScript) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 255–908; `Height` points 419–3572; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `ColorModel` | Color Mode | PickOne | `CMYK` | `CMYK` (Color), `Gray` (Black and White) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope`, `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2), `Shift` (Internal Shift Tray), `External` (External Tray), `FinRUBICONBShift` (Finisher SR3130 Shift Tray), `FinAMURBBKUpper` (Finisher SR3220 Upper Tray), `FinAMURBBKShift` (Finisher SR3220 Shift Tray), `FinAMURBBKLower` (Finisher SR3220 Booklet Tray), `FinUYUNIShift` (Finisher SR3180 Shift Tray) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope` |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `RICollateKind` | Collate Type | PickOne | `Normal` | `Normal` (Collate), `RotateCollate` (Rotating Collate), `ShiftCollate` (Shift Collate) |  |
| `StapleLocation` | Staple | PickOne | `None` | `None` (Off), `StaplessUpperLeft` (Top left (stapleless)), `StaplessUpperRight` (Top right (stapleless)), `UpperLeft` (Top left), `UpperRight` (Top right), `LeftW` (2 at left), `RightW` (2 at right), `UpperW` (2 at top), `CenterW` (2 at center) |  |
| `RIPunch` | Punch | PickOne | `None` | `None` (Off), `Left2` (2 at left), `Left3` (3 at left), `Left4` (4 at left), `Right2` (2 at right), `Right3` (3 at right), `Right4` (4 at right), `Upper2` (2 at top), `Upper3` (3 at top), `Upper4` (4 at top) |  |
| `RIFoldType` | Fold Type | PickOne | `None` | `None` (Off), `OutsideTwofold` (Half Fold - Print Outside (Finisher Booklet Tray)) |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RPSBitsPerPixel` | Gradation | PickOne | `2BitsPerPixel` | `2BitsPerPixel` (Standard), `1BitsPerPixel` (Fast), `4BitsPerPixel` (Fine) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Off), `3rhit` (Toner Saving) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |
| `RPSRGBcorrect` | Color Setting | PickOne | `DetailBright` | `None` (Off), `DetailNormal` (Fine), `DetailBright` (Super Fine) |  |
| `RPSColorRendDict` | Color Profile | PickOne | `Auto` | `Auto`, `Photograph` (Photographic), `Business` (Presentation), `Colorimetric` (Solid Color), `POP` (POP Display), `User` (User Setting), `Clpsimulation1` (Soft), `Clpsimulation2` (Sharp), `Clpsimulation4` (Vivid), `Clpsimulation` (CLP Simulation) |  |
| `Rcmyksimulation` | CMYK Simulation Profile | PickOne | `Off` | `Off`, `USOffsetPrint` (US OffsetPrint), `Euroscale`, `JapanColor` (JapanColor2001), `PANTONE` (PaletteColor), `Trans01` (Make Bluer) |  |
| `RPSBlackMode` | Gray Reproduction | PickOne | `gray` | `gray` (Black/Gray by K (Text/Line Art)), `1Color` (Black by K), `4Color` (CMY+K), `grayText` (Black/Gray by K (Text only)), `1ColorText` (Black by K (Text only)), `grayAll` (Black/Gray by K (Strong UCR)) |  |
| `RPSBlackOverPrint` | Black Over Print | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RPSColorSep` | Separate into CMYK | PickOne | `None` | `None` (Do not Separate), `Cyan`, `Magenta`, `Yellow`, `Black`, `Red` (Magenta and Yellow), `Green` (Cyan and Yellow), `Blue` (Cyan and Magenta), `KCyan` (Black and Cyan), `KMagenta` (Black and Magenta), `KYellow` (Black and Yellow) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `Default` | `Default` (Printer Default), `HelveticaB` (Helvetica Bold), `CourierB` (Courier Bold), `TimesB` (Times Bold), `NimbusSansB` (NimbusSans Bold), `NimbusMonoPSB` (NimbusMonoPS Bold), `NimbusRomanB` (NimbusRoman Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `Default` | `Default` (Printer Default), `NimbusSansBold` (NimbusSans-Bold), `NimbusMonoPSBold` (NimbusMonoPS-Bold), `NimbusRomanBold` (NimbusRoman-Bold), `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black`, `Cyan`, `Magenta` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |
| `RICyan` | Cyan ( -50 to 50 ) | PickOne | `0` | `0` | `Cyan` real -50–50 |
| `RIMagenta` | Magenta ( -50 to 50 ) | PickOne | `0` | `0` | `Magenta` real -50–50 |
| `RIYellow` | Yellow ( -50 to 50 ) | PickOne | `0` | `0` | `Yellow` real -50–50 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH MP C3004ex PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Lower Paper Tray), `LCT` (Tray 3 (LCT)), `2Cassette` (Lower Paper Trays) |  |
| `LargeCapacityTray` | Large Capacity Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `InnerTray2` | Internal Tray 2 | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ShiftTray` | Internal Shift Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ExternalTray` | External Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `Finisher` | Finisher | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `FinRUBICONB` (Finisher SR3130), `FinAMURBBK` (Finisher SR3220), `FinAMURHY` (Finisher SR3210), `FinUYUNI` (Finisher SR3180) |  |
| `RIPostScript` | PostScript | PickOne | `IRIPS` | `IRIPS` (PostScript Emulation), `Adobe` (Adobe PostScript) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 255–908; `Height` points 419–3572; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `ColorModel` | Color Mode | PickOne | `CMYK` | `CMYK` (Color), `Gray` (Black and White) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope`, `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2), `Shift` (Internal Shift Tray), `External` (External Tray), `FinRUBICONBShift` (Finisher SR3130 Shift Tray), `FinAMURBBKUpper` (Finisher SR3220 Upper Tray), `FinAMURBBKShift` (Finisher SR3220 Shift Tray), `FinAMURBBKLower` (Finisher SR3220 Booklet Tray), `FinAMURHYUpper` (Finisher SR3210 Upper Tray), `FinAMURHYShift` (Finisher SR3210 Shift Tray), `FinUYUNIShift` (Finisher SR3180 Shift Tray) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope` |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `RICollateKind` | Collate Type | PickOne | `Normal` | `Normal` (Collate), `RotateCollate` (Rotating Collate), `ShiftCollate` (Shift Collate) |  |
| `StapleLocation` | Staple | PickOne | `None` | `None` (Off), `StaplessUpperLeft` (Top left (stapleless)), `StaplessUpperRight` (Top right (stapleless)), `UpperLeft` (Top left), `UpperRight` (Top right), `LeftW` (2 at left), `RightW` (2 at right), `UpperW` (2 at top), `CenterW` (2 at center) |  |
| `RIPunch` | Punch | PickOne | `None` | `None` (Off), `Left2` (2 at left), `Left3` (3 at left), `Left4` (4 at left), `Right2` (2 at right), `Right3` (3 at right), `Right4` (4 at right), `Upper2` (2 at top), `Upper3` (3 at top), `Upper4` (4 at top) |  |
| `RIFoldType` | Fold Type | PickOne | `None` | `None` (Off), `OutsideTwofold` (Half Fold - Print Outside (Finisher Booklet Tray)) |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RPSBitsPerPixel` | Gradation | PickOne | `2BitsPerPixel` | `2BitsPerPixel` (Standard), `1BitsPerPixel` (Fast), `4BitsPerPixel` (Fine) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Off), `3rhit` (Toner Saving) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |
| `RPSRGBcorrect` | Color Setting | PickOne | `DetailBright` | `None` (Off), `DetailNormal` (Fine), `DetailBright` (Super Fine) |  |
| `RPSColorRendDict` | Color Profile | PickOne | `Auto` | `Auto`, `Photograph` (Photographic), `Business` (Presentation), `Colorimetric` (Solid Color), `POP` (POP Display), `User` (User Setting), `Clpsimulation1` (Soft), `Clpsimulation2` (Sharp), `Clpsimulation4` (Vivid), `Clpsimulation` (CLP Simulation) |  |
| `Rcmyksimulation` | CMYK Simulation Profile | PickOne | `Off` | `Off`, `USOffsetPrint` (US OffsetPrint), `Euroscale`, `JapanColor` (JapanColor2001), `PANTONE` (PaletteColor), `Trans01` (Make Bluer) |  |
| `RPSBlackMode` | Gray Reproduction | PickOne | `gray` | `gray` (Black/Gray by K (Text/Line Art)), `1Color` (Black by K), `4Color` (CMY+K), `grayText` (Black/Gray by K (Text only)), `1ColorText` (Black by K (Text only)), `grayAll` (Black/Gray by K (Strong UCR)) |  |
| `RPSBlackOverPrint` | Black Over Print | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RPSColorSep` | Separate into CMYK | PickOne | `None` | `None` (Do not Separate), `Cyan`, `Magenta`, `Yellow`, `Black`, `Red` (Magenta and Yellow), `Green` (Cyan and Yellow), `Blue` (Cyan and Magenta), `KCyan` (Black and Cyan), `KMagenta` (Black and Magenta), `KYellow` (Black and Yellow) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `Default` | `Default` (Printer Default), `HelveticaB` (Helvetica Bold), `CourierB` (Courier Bold), `TimesB` (Times Bold), `NimbusSansB` (NimbusSans Bold), `NimbusMonoPSB` (NimbusMonoPS Bold), `NimbusRomanB` (NimbusRoman Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `Default` | `Default` (Printer Default), `NimbusSansBold` (NimbusSans-Bold), `NimbusMonoPSBold` (NimbusMonoPS-Bold), `NimbusRomanBold` (NimbusRoman-Bold), `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black`, `Cyan`, `Magenta` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |
| `RICyan` | Cyan ( -50 to 50 ) | PickOne | `0` | `0` | `Cyan` real -50–50 |
| `RIMagenta` | Magenta ( -50 to 50 ) | PickOne | `0` | `0` | `Magenta` real -50–50 |
| `RIYellow` | Yellow ( -50 to 50 ) | PickOne | `0` | `0` | `Yellow` real -50–50 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH MP C307 PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Tray 2), `2Cassette` (Tray 2 and 3) |  |
| `InnerTray2` | Upper Internal Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `RIPostScript` | PostScript | PickOne | `IRIPS` | `IRIPS` (PostScript Emulation), `Adobe` (Adobe PostScript) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGerman` (8.5 x 12), `FanFoldGermanLegal` (8.5 x 13), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGerman.FullBleed` (8.5 x 12 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 216–613; `Height` points 394–1701; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGerman` (8.5 x 12), `FanFoldGermanLegal` (8.5 x 13), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGerman.FullBleed` (8.5 x 12 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `ColorModel` | Color Mode | PickOne | `CMYK` | `CMYK` (Color), `Gray` (Black and White) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Coated`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 130 g/m2)), `Thick2` (Thick 2 (131 - 163 g/m2)), `Thick3` (Thick 3 (164 - 220 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `Envelope`, `WaterProof` (Waterproof), `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Coated`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 130 g/m2)), `Thick2` (Thick 2 (131 - 163 g/m2)), `Thick3` (Thick 3 (164 - 220 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `Envelope`, `WaterProof` (Waterproof) |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RPSBitsPerPixel` | Gradation | PickOne | `2BitsPerPixel` | `2BitsPerPixel` (Standard), `1BitsPerPixel` (Fast), `4BitsPerPixel` (Fine) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Off), `3rhit` (Toner Saving) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |
| `RPSRGBcorrect` | Color Setting | PickOne | `DetailBright` | `None` (Off), `DetailNormal` (Fine), `DetailBright` (Super Fine) |  |
| `RPSColorRendDict` | Color Profile | PickOne | `Auto` | `Auto`, `Photograph` (Photographic), `Business` (Presentation), `Colorimetric` (Solid Color), `POP` (POP Display), `User` (User Setting), `Clpsimulation1` (Soft), `Clpsimulation2` (Sharp), `Clpsimulation4` (Vivid), `Clpsimulation7` (Deep), `Clpsimulation` (CLP Simulation) |  |
| `Rcmyksimulation` | CMYK Simulation Profile | PickOne | `Off` | `Off`, `USOffsetPrint` (US OffsetPrint), `Euroscale`, `JapanColor` (JapanColor2001), `PANTONE` (PaletteColor), `Trans01` (Make Bluer) |  |
| `RPSBlackMode` | Gray Reproduction | PickOne | `gray` | `gray` (Black/Gray by K (Text/Line Art)), `1Color` (Black by K), `4Color` (CMY+K), `grayText` (Black/Gray by K (Text only)), `1ColorText` (Black by K (Text only)), `grayAll` (Black/Gray by K (Strong UCR)) |  |
| `RPSBlackOverPrint` | Black Over Print | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RPSColorSep` | Separate into CMYK | PickOne | `None` | `None` (Do not Separate), `Cyan`, `Magenta`, `Yellow`, `Black`, `Red` (Magenta and Yellow), `Green` (Cyan and Yellow), `Blue` (Cyan and Magenta), `KCyan` (Black and Cyan), `KMagenta` (Black and Magenta), `KYellow` (Black and Yellow) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `Default` | `Default` (Printer Default), `HelveticaB` (Helvetica Bold), `CourierB` (Courier Bold), `TimesB` (Times Bold), `NimbusSansB` (NimbusSans Bold), `NimbusMonoPSB` (NimbusMonoPS Bold), `NimbusRomanB` (NimbusRoman Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `Default` | `Default` (Printer Default), `NimbusSansBold` (NimbusSans-Bold), `NimbusMonoPSBold` (NimbusMonoPS-Bold), `NimbusRomanBold` (NimbusRoman-Bold), `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black`, `Cyan`, `Magenta` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |
| `RICyan` | Cyan ( -50 to 50 ) | PickOne | `0` | `0` | `Cyan` real -50–50 |
| `RIMagenta` | Magenta ( -50 to 50 ) | PickOne | `0` | `0` | `Magenta` real -50–50 |
| `RIYellow` | Yellow ( -50 to 50 ) | PickOne | `0` | `0` | `Yellow` real -50–50 |

### Background Numbering

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBackgroundNumbering` | Background Numbering | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIBNSize` | Size | PickOne | `Normal` | `Small`, `Normal`, `Large` |  |
| `RIBNDensity` | Density | PickOne | `Normal` | `Light`, `Normal`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIBNColor` | Color | PickOne | `Black` | `Yellow`, `Red`, `Cyan`, `Magenta`, `Green`, `Blue`, `Black` |  |
| `RIStartNumber` | Start Number (1 to 9999) | PickOne | `1` | `1` | `StartNumber` int 1–9999 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH MP C3504 PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Lower Paper Tray), `LCT` (Tray 3 (LCT)), `2Cassette` (Lower Paper Trays) |  |
| `LargeCapacityTray` | Large Capacity Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `InnerTray2` | Internal Tray 2 | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ShiftTray` | Internal Shift Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ExternalTray` | External Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `Finisher` | Finisher | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `FinRUBICONB` (Finisher SR3130), `FinAMURBBK` (Finisher SR3220), `FinAMURHY` (Finisher SR3210), `FinUYUNI` (Finisher SR3180) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 255–908; `Height` points 419–3572; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `SRA3` (SRA3 (320 x 450 mm)), `SRA4` (SRA4 (225 x 320 mm)), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `SRA3.FullBleed` (SRA3 (320 x 450 mm) (Full Bleed)), `SRA4.FullBleed` (SRA4 (225 x 320 mm) (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `ColorModel` | Color Mode | PickOne | `CMYK` | `CMYK` (Color), `Gray` (Black and White) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope`, `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2), `Shift` (Internal Shift Tray), `External` (External Tray), `FinRUBICONBShift` (Finisher SR3130 Shift Tray), `FinAMURBBKUpper` (Finisher SR3220 Upper Tray), `FinAMURBBKShift` (Finisher SR3220 Shift Tray), `FinAMURBBKLower` (Finisher SR3220 Booklet Tray), `FinAMURHYUpper` (Finisher SR3210 Upper Tray), `FinAMURHYShift` (Finisher SR3210 Shift Tray), `FinUYUNIShift` (Finisher SR3180 Shift Tray) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `GlossCoated` (Coated (Glossy)), `MatCoated` (Coated (Matte)), `Envelope` |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `RICollateKind` | Collate Type | PickOne | `Normal` | `Normal` (Collate), `RotateCollate` (Rotating Collate), `ShiftCollate` (Shift Collate) |  |
| `StapleLocation` | Staple | PickOne | `None` | `None` (Off), `StaplessUpperLeft` (Top left (stapleless)), `StaplessUpperRight` (Top right (stapleless)), `UpperLeft` (Top left), `UpperRight` (Top right), `LeftW` (2 at left), `RightW` (2 at right), `UpperW` (2 at top), `CenterW` (2 at center) |  |
| `RIPunch` | Punch | PickOne | `None` | `None` (Off), `Left2` (2 at left), `Left3` (3 at left), `Left4` (4 at left), `Right2` (2 at right), `Right3` (3 at right), `Right4` (4 at right), `Upper2` (2 at top), `Upper3` (3 at top), `Upper4` (4 at top) |  |
| `RIFoldType` | Fold Type | PickOne | `None` | `None` (Off), `OutsideTwofold` (Half Fold - Print Outside (Finisher Booklet Tray)) |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RPSBitsPerPixel` | Gradation | PickOne | `2BitsPerPixel` | `2BitsPerPixel` (Standard), `1BitsPerPixel` (Fast), `4BitsPerPixel` (Fine) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Off), `3rhit` (Toner Saving) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |
| `RPSRGBcorrect` | Color Setting | PickOne | `DetailBright` | `None` (Off), `DetailNormal` (Fine), `DetailBright` (Super Fine) |  |
| `RPSColorRendDict` | Color Profile | PickOne | `Auto` | `Auto`, `Photograph` (Photographic), `Business` (Presentation), `Colorimetric` (Solid Color), `POP` (POP Display), `User` (User Setting), `Clpsimulation1` (Soft), `Clpsimulation2` (Sharp), `Clpsimulation4` (Vivid), `Clpsimulation` (CLP Simulation) |  |
| `Rcmyksimulation` | CMYK Simulation Profile | PickOne | `Off` | `Off`, `USOffsetPrint` (US OffsetPrint), `Euroscale`, `JapanColor` (JapanColor2001), `PANTONE` (PaletteColor), `Trans01` (Make Bluer) |  |
| `RPSBlackMode` | Gray Reproduction | PickOne | `gray` | `gray` (Black/Gray by K (Text/Line Art)), `1Color` (Black by K), `4Color` (CMY+K), `grayText` (Black/Gray by K (Text only)), `1ColorText` (Black by K (Text only)), `grayAll` (Black/Gray by K (Strong UCR)) |  |
| `RPSBlackOverPrint` | Black Over Print | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RPSColorSep` | Separate into CMYK | PickOne | `None` | `None` (Do not Separate), `Cyan`, `Magenta`, `Yellow`, `Black`, `Red` (Magenta and Yellow), `Green` (Cyan and Yellow), `Blue` (Cyan and Magenta), `KCyan` (Black and Cyan), `KMagenta` (Black and Magenta), `KYellow` (Black and Yellow) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `HelveticaB` | `CourierB` (Courier Bold), `TimesB` (Times Bold), `HelveticaB` (Helvetica Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `ArialMT` | `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black`, `Cyan`, `Magenta` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |
| `RICyan` | Cyan ( -50 to 50 ) | PickOne | `0` | `0` | `Cyan` real -50–50 |
| `RIMagenta` | Magenta ( -50 to 50 ) | PickOne | `0` | `0` | `Magenta` real -50–50 |
| `RIYellow` | Yellow ( -50 to 50 ) | PickOne | `0` | `0` | `Yellow` real -50–50 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH MP 5055 PS

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `OptionTray` | Option Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `1Cassette` (Single Tray), `LCT` (Tray 3 (LCT)), `2Cassette` (Lower Paper Trays) |  |
| `LargeCapacityTray` | Large Capacity Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `InnerTray2` | Internal Tray 2 | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ShiftTray` | Internal Shift Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `ExternalTray` | External Tray | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `Finisher` | Finisher | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `FinRUBICONB` (Finisher SR3130), `FinVOLGADBK` (Finisher SR3240), `FinVOLGAD` (Finisher SR3230), `FinAMURBBK` (Finisher SR3220), `FinAMURHY` (Finisher SR3210) |  |
| `MultiFold` | Folding Unit | PickOne | `NotInstalled` | `NotInstalled` (Not Installed), `Installed` |  |
| `RIPostScript` | PostScript | PickOne | `IRIPS` | `IRIPS` (PostScript Emulation), `Adobe` (Adobe PostScript) |  |

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | PageSize | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) | `Width` points 255–864; `Height` points 419–1701; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 1–1 |
| `PageRegion` | PageRegion | PickOne | `A4` | `A3` (A3 (297 x 420 mm)), `A4` (A4 (210 x 297 mm)), `A5` (A5 (148 x 210 mm)), `A6` (A6 (105 x 148 mm)), `B4` (B4 JIS (257 x 364 mm)), `B5` (B5 JIS (182 x 257 mm)), `B6` (B6 JIS (128 x 182 mm)), `Legal` (Legal (8.5 x 14)), `GovernmentLG` (8.25 x 14), `EngQuatro` (8 x 10), `Letter` (Letter (8.5 x 11)), `HalfLetter` (5.5 x 8.5), `F` (8 x 13), `Folio` (8.25 x 13), `FanFoldGermanLegal` (8.5 x 13), `11x17` (11 x 17), `12x18` (12 x 18), `11x15` (11 x 15), `10x14` (10 x 14), `Executive` (Executive (7.25 x 10.5)), `Env10` (Com10 Env. (4.125 x 9.5)), `EnvMonarch` (Monarch Env. (3.875 x 7.5)), `EnvC5` (C5 Env. (162 x 229 mm)), `EnvC6` (C6 Env. (114 x 162 mm)), `DLEnv` (DL Env. (110 x 220 mm)), `8Kai` (8K (267 x 390 mm)), `16Kai` (16K (195 x 267 mm)), `Oficio` (8.5 x 13.4), `A3.FullBleed` (A3  (297 x 420 mm) (Full bleed)), `A4.FullBleed` (A4 (210 x 297 mm) (Full Bleed)), `A5.FullBleed` (A5 (148 x 210 mm) (Full Bleed)), `A6.FullBleed` (A6 (105 x 148 mm) (Full Bleed)), `B4.FullBleed` (B4 (JIS) (257 x 364 mm) (Full Bleed)), `B5.FullBleed` (B5 (JIS) (182 x 257 mm) (Full Bleed)), `B6.FullBleed` (B6 (JIS) (128 x 182 mm) (Full Bleed)), `Legal.FullBleed` (Legal (8.5 x 14) (Full Bleed)), `GovernmentLG.FullBleed` (8.25 x 14 (Full Bleed)), `EngQuatro.FullBleed` (8 x 10 (Full Bleed)), `Letter.FullBleed` (Letter (8.5 x 11) (Full Bleed)), `HalfLetter.FullBleed` (5.5 x 8.5 (Full Bleed)), `F.FullBleed` (8 x 13 (Full Bleed)), `Folio.FullBleed` (8.25 x 13 (Full Bleed)), `FanFoldGermanLegal.FullBleed` (8.5 x 13 (Full Bleed)), `11x17.FullBleed` (11 x 17 (Full Bleed)), `12x18.FullBleed` (12 x 18 (Full Bleed)), `11x15.FullBleed` (11 x 15 (Full Bleed)), `10x14.FullBleed` (10 x 14 (Full Bleed)), `Executive.FullBleed` (Executive (7.25 x 10.5) (Full Bleed)), `Env10.FullBleed` (Com10 Env. (4.125 x 9.5) (Full Bleed)), `EnvMonarch.FullBleed` (Monarch Env. (3.875 x 7.5) (Full Bleed)), `EnvC5.FullBleed` (C5 Env. (162 x 229 mm) (Full Bleed)), `EnvC6.FullBleed` (C6 Env. (114 x 162 mm) (Full Bleed)), `DLEnv.FullBleed` (DL Env. (110 x 220 mm) (Full Bleed)), `8Kai.FullBleed` (8K (267 x 390 mm) (Full Bleed)), `16Kai.FullBleed` (16K (195 x 267 mm) (Full Bleed)), `Oficio.FullBleed` (8.5 x 13.4 (Full Bleed)) |  |
| `InputSlot` | InputSlot | PickOne | `1Tray` | `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long Edge), `DuplexTumble` (Short Edge) |  |
| `Collate` | Collate | PickOne | `False` | `False` (Off), `True` (On) |  |

### Basic

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPaperPolicy` | Fit to Paper | PickOne | `PromptUser` | `PromptUser` (Prompt User), `NearestSizeAdjust` (Nearest Size and Scale), `NearestSizeNoAdjust` (Nearest Size and Crop) |  |
| `RIRotateBy180` | Rotate by 180 degrees | PickOne | `Off` | `Off`, `On` |  |

### Paper

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `Envelope`, `None` |  |
| `OutputBin` | Destination | PickOne | `Default` | `Default` (Printer Default), `Standard` (Internal Tray 1), `Bin1` (Internal Tray 2), `Shift` (Internal Shift Tray), `External` (External Tray), `FinRUBICONBShift` (Finisher SR3130 Shift Tray), `FinVOLGADBKUpper` (Finisher SR3240 Upper Tray), `FinVOLGADBKShift` (Finisher SR3240 Shift Tray), `FinVOLGADBKLower` (Finisher SR3240 Booklet Tray), `FinVOLGADUpper` (Finisher SR3230 Upper Tray), `FinVOLGADShift` (Finisher SR3230 Shift Tray), `FinAMURBBKUpper` (Finisher SR3220 Upper Tray), `FinAMURBBKShift` (Finisher SR3220 Shift Tray), `FinAMURBBKLower` (Finisher SR3220 Booklet Tray), `FinAMURHYUpper` (Finisher SR3210 Upper Tray), `FinAMURHYShift` (Finisher SR3210 Shift Tray), `FinDONAUProof` (Folding Unit Tray) |  |
| `RIBannerPagePrint` | Banner Page | PickOne | `False` | `False` (Off), `True` (On) |  |
| `RIBannerPageInputSlot` | Banner Page Input Tray | PickOne | `Auto` | `Auto` (Auto Tray Select), `MultiTray` (Bypass Tray), `1Tray` (Tray 1), `2Tray` (Tray 2), `3Tray` (Tray 3), `4Tray` (Tray 4), `5Tray` (Large Capacity Tray) |  |
| `RIBannerPageMediaType` | Banner Page Paper Type | PickOne | `Auto` | `Auto` (Plain/Recycled), `Plain1` (Plain 1 (60 - 74 g/m2)), `Plain2` (Plain 2 (75 - 81 g/m2)), `Recycled`, `Special1` (Special 1), `Special2` (Special 2), `Special3` (Special 3), `Colored` (Color), `Letterhead`, `Preprinted`, `Labels`, `Bond`, `Cardstock`, `OHP` (Transparency), `Thick1` (Thick 1 (106 - 169 g/m2)), `Thick2` (Thick 2 (170 - 220 g/m2)), `Thick3` (Thick 3 (221 - 256 g/m2)), `Thick4` (Thick 4 (257 - 300 g/m2)), `Thin` (Thin (52 - 59 g/m2)), `Middlethick` (Middle Thick (82 - 105 g/m2)), `Envelope` |  |

### Finishing

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIOrientOvr` | Orientation Override | PickOne | `Off` | `Off`, `Landscape`, `Portrait` |  |
| `RICollateKind` | Collate Type | PickOne | `Normal` | `Normal` (Collate), `RotateCollate` (Rotating Collate), `ShiftCollate` (Shift Collate) |  |
| `StapleLocation` | Staple | PickOne | `None` | `None` (Off), `StaplessUpperLeft` (Top left (stapleless)), `StaplessUpperRight` (Top right (stapleless)), `UpperLeft` (Top left), `UpperRight` (Top right), `LeftW` (2 at left), `RightW` (2 at right), `UpperW` (2 at top), `CenterW` (2 at center) |  |
| `RIPunch` | Punch | PickOne | `None` | `None` (Off), `Left2` (2 at left), `Left3` (3 at left), `Left4` (4 at left), `Right2` (2 at right), `Right3` (3 at right), `Right4` (4 at right), `Upper2` (2 at top), `Upper3` (3 at top), `Upper4` (4 at top) |  |
| `RIZfold` | Z-fold | PickOne | `None` | `None` (Off), `Bottom` (Bottom Fold), `Right` (Right Fold), `Left` (Left Fold) |  |
| `RIFoldType` | Fold Type | PickOne | `None` | `None` (Off), `Twofold` (Half Fold), `Threefold` (Letter Fold-in), `ThreefoldOut` (Letter Fold-out), `OutsideTwofold` (Half Fold - Print Outside (Finisher Booklet Tray)) |  |
| `OverlapFold` | Multi-sheet Fold | PickOne | `Off` | `Off`, `On` |  |
| `Booklet` | Booklet | PickOne | `None` | `None` (Off), `OpenToLeft` (Open to Left/Top), `OpenToRight` (Open to Right/Bottom) |  |

### Print Quality

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` (600 dpi), `1200dpi` (1200 dpi) |  |
| `RIPrintMode` | Print Mode | PickOne | `0rhit` | `0rhit` (Through), `1rhit` (Edge Smoothing), `3rhit` (Toner Saving 1), `4rhit` (Toner Saving 2) |  |
| `Rimagesm` | Image Smoothing | PickOne | `Off` | `Off`, `On`, `Auto`, `90ppi` (Less than 90 ppi), `150ppi` (Less than 150 ppi), `200ppi` (Less than 200 ppi), `300ppi` (Less than 300 ppi) |  |
| `RPSDitherType` | Dithering | PickOne | `Auto` | `Auto`, `Photo` (Photographic), `Letter` (Text), `User` (User Setting), `Dispersion` (Reduce Missing Colors and Blurring) |  |

### Effects

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIWatermark` | Watermark | PickOne | `Off` | `Off`, `On` |  |
| `RIWMText` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `Copy` (COPY), `Copyright` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF), `TopSecret` (TOP SECRET) |  |
| `RIwmFont` | Watermark Font | PickOne | `Default` | `Default` (Printer Default), `HelveticaB` (Helvetica Bold), `CourierB` (Courier Bold), `TimesB` (Times Bold), `NimbusSansB` (NimbusSans Bold), `NimbusMonoPSB` (NimbusMonoPS Bold), `NimbusRomanB` (NimbusRoman Bold) |  |
| `RIwmAngle` | Watermark Angle | PickOne | `45Deg` | `180Deg` (180 Degrees), `135Deg` (135 Degrees), `90Deg` (90 Degrees), `45Deg` (45 Degrees), `0Deg` (0 Degrees), `M45Deg` (-45 Degrees), `M90Deg` (-90 Degrees), `M135Deg` (-135 Degrees), `M180Deg` (-180 Degrees) |  |
| `RIwmSize` | Watermark Size | PickOne | `36` | `24` (24 Point), `36` (36 Point), `48` (48 Point), `60` (60 Point), `72` (72 Point) |  |
| `RIwmTextStyle` | Watermark Style | PickOne | `Gray` | `Gray`, `Outline` (Outlined) |  |

### Job Log

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIUserId` | User ID | PickOne | `None` | `None` | `UserId` string 0–8 |
| `RIJobType` | Job Type | PickOne | `Normal` | `Normal` (Normal Print), `SamplePrint` (Sample Print), `LockedPrint` (Locked Print), `HoldPrint` (Hold Print), `StoredPrint` (Stored Print), `StoreandPrint` (Store and Print), `DocServer` (Document Server) |  |
| `RIFileName` | File Name | PickOne | `None` | `None` | `FileName` string 0–16 |
| `RIPassword` | Password | PickOne | `None` | `None` | `Password` passcode 4–8 |
| `RIEnableUserCode` | Enable User Code | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIUserCode` | User Code | PickOne | `None` | `None` | `UserCode` string 0–8 |
| `RIEnableSpecifyTime` | Set Print Time | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RITimeHour` | Hour (0 to 23) | PickOne | `0` | `0` | `TimeHour` int 0–23 |
| `RITimeMin` | Minute (0 to 59) | PickOne | `0` | `0` | `TimeMin` int 0–59 |
| `RIFolderNumber` | Folder Number | PickOne | `0` | `0` | `FolderNumber` int 0–200 |
| `RIFolderPassword` | Folder Password | PickOne | `None` | `None` | `FolderPassword` passcode 4–8 |

### Unauthorized Copy Prevention

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIPreventionType` | Prevention Type | PickOne | `Off` | `Off`, `PreventionCopyPattern` (Unauthorized Copy Prevention for Pattern), `CopyGuard` (Data Security for Copying) |  |
| `RITypeText` | Text Type | PickOne | `UserText` | `UserText` (User Text), `LoginUserName` (Login User Name), `JobName` (Job Name), `JobTime` (Date & Time), `LoginUserNameJobName` (Login User Name + Job Name), `LoginUserNameJobTime` (Login User Name + Date & Time), `JobNameTime` (Job Name + Date & Time), `LoginUserNameJobNameTime` (Login User Name + Job Name + Date & Time) |  |
| `RIText` | Enter User Text | PickOne | `Copy` | `Copy` (COPY) | `Text` string 0–64 |
| `RIFont` | Font | PickOne | `Default` | `Default` (Printer Default), `NimbusSansBold` (NimbusSans-Bold), `NimbusMonoPSBold` (NimbusMonoPS-Bold), `NimbusRomanBold` (NimbusRoman-Bold), `AlbertusMT`, `AlbertusMTItalic` (AlbertusMT-Italic), `AlbertusMTLight` (AlbertusMT-Light), `AntiqueOliveBold` (AntiqueOlive-Bold), `AntiqueOliveCompact` (AntiqueOlive-Compact), `AntiqueOliveItalic` (AntiqueOlive-Italic), `AntiqueOliveRoman` (AntiqueOlive-Roman), `AppleChancery` (Apple-Chancery), `ArialMT`, `ArialBoldMT` (Arial-BoldMT), `ArialBoldItalicMT` (Arial-BoldItalicMT), `ArialItalicMT` (Arial-ItalicMT), `AvantGardeBook` (AvantGarde-Book), `AvantGardeBookOblique` (AvantGarde-BookOblique), `AvantGardeDemi` (AvantGarde-Demi), `AvantGardeDemiOblique` (AvantGarde-DemiOblique), `Bodoni`, `BodoniBold` (Bodoni-Bold), `BodoniBoldItalic` (Bodoni-BoldItalic), `BodoniItalic` (Bodoni-Italic), `BodoniPoster` (Bodoni-Poster), `BodoniPosterCompressed` (Bodoni-PosterCompressed), `BookmanDemi` (Bookman-Demi), `BookmanDemiItalic` (Bookman-DemiItalic), `BookmanLight` (Bookman-Light), `BookmanLightItalic` (Bookman-LightItalic), `Carta`, `Chicago`, `ClarendonBold` (Clarendon-Bold), `ClarendonLight` (Clarendon-Light), `Clarendon`, `CooperBlackItalic` (CooperBlack-Italic), `CooperBlack`, `CopperplateThirtyThreeBC` (Copperplate-ThirtyThreeBC), `CopperplateThirtyTwoBC` (Copperplate-ThirtyTwoBC), `CoronetRegular` (Coronet-Regular), `CourierBold` (Courier-Bold), `CourierBoldOblique` (Courier-BoldOblique), `CourierOblique` (Courier-Oblique), `Courier`, `EurostileBold` (Eurostile-Bold), `EurostileBoldExtendedTwo` (Eurostile-BoldExtendedTwo), `EurostileExtendedTwo` (Eurostile-ExtendedTwo), `Eurostile`, `Geneva`, `GillSans`, `GillSansBold` (GillSans-Bold), `GillSansBoldCondensed` (GillSans-BoldCondensed), `GillSansBoldItalic` (GillSans-BoldItalic), `GillSansCondensed` (GillSans-Condensed), `GillSansExtraBold` (GillSans-ExtraBold), `GillSansItalic` (GillSans-Italic), `GillSansLight` (GillSans-Light), `GillSansLightItalic` (GillSans-LightItalic), `Goudy`, `GoudyBold` (Goudy-Bold), `GoudyBoldItalic` (Goudy-BoldItalic), `GoudyExtraBold` (Goudy-ExtraBold), `GoudyItalic` (Goudy-Italic), `Helvetica`, `HelveticaBold` (Helvetica-Bold), `HelveticaBoldOblique` (Helvetica-BoldOblique), `HelveticaCondensedBold` (Helvetica-Condensed-Bold), `HelveticaCondensedBoldObl` (Helvetica-Condensed-BoldObl), `HelveticaCondensedOblique` (Helvetica-Condensed-Oblique), `HelveticaCondensed` (Helvetica-Condensed), `HelveticaNarrowBold` (Helvetica-Narrow-Bold), `HelveticaNarrowBoldOblique` (Helvetica-Narrow-BoldOblique), `HelveticaNarrowOblique` (Helvetica-Narrow-Oblique), `HelveticaNarrow` (Helvetica-Narrow), `HelveticaOblique` (Helvetica-Oblique), `HoeflerTextBlack` (HoeflerText-Black), `HoeflerTextBlackItalic` (HoeflerText-BlackItalic), `HoeflerTextItalic` (HoeflerText-Italic), `HoeflerTextOrnaments` (HoeflerText-Ornaments), `HoeflerTextRegular` (HoeflerText-Regular), `JoannaMT`, `JoannaMTBold` (JoannaMT-Bold), `JoannaMTBoldItalic` (JoannaMT-BoldItalic), `JoannaMTItalic` (JoannaMT-Italic), `LetterGothic`, `LetterGothicBold` (LetterGothic-Bold), `LetterGothicBoldSlanted` (LetterGothic-BoldSlanted), `LetterGothicSlanted` (LetterGothic-Slanted), `LubalinGraphBook` (LubalinGraph-Book), `LubalinGraphBookOblique` (LubalinGraph-BookOblique), `LubalinGraphDemi` (LubalinGraph-Demi), `LubalinGraphDemiOblique` (LubalinGraph-DemiOblique), `Marigold`, `MonaLisaRecut` (MonaLisa-Recut), `Monaco`, `NewCenturySchlbkBold` (NewCenturySchlbk-Bold), `NewCenturySchlbkBoldItalic` (NewCenturySchlbk-BoldItalic), `NewCenturySchlbkItalic` (NewCenturySchlbk-Italic), `NewCenturySchlbkRoman` (NewCenturySchlbk-Roman), `NewYork`, `OptimaBold` (Optima-Bold), `OptimaBoldItalic` (Optima-BoldItalic), `OptimaItalic` (Optima-Italic), `Optima`, `Oxford`, `PalatinoBold` (Palatino-Bold), `PalatinoBoldItalic` (Palatino-BoldItalic), `PalatinoItalic` (Palatino-Italic), `PalatinoRoman` (Palatino-Roman), `StempelGaramondBold` (StempelGaramond-Bold), `StempelGaramondBoldItalic` (StempelGaramond-BoldItalic), `StempelGaramondItalic` (StempelGaramond-Italic), `StempelGaramondRoman` (StempelGaramond-Roman), `Symbol`, `Tekton`, `TimesBold` (Times-Bold), `TimesBoldItalic` (Times-BoldItalic), `TimesItalic` (Times-Italic), `TimesRoman` (Times-Roman), `TimesNewRomanPSBoldItalicMT` (TimesNewRomanPS-BoldItalicMT), `TimesNewRomanPSBoldMT` (TimesNewRomanPS-BoldMT), `TimesNewRomanPSItalicMT` (TimesNewRomanPS-ItalicMT), `TimesNewRomanPSMT`, `Univers`, `UniversBold` (Univers-Bold), `UniversBoldExt` (Univers-BoldExt), `UniversBoldExtObl` (Univers-BoldExtObl), `UniversBoldOblique` (Univers-BoldOblique), `UniversCondensed` (Univers-Condensed), `UniversCondensedBold` (Univers-CondensedBold), `UniversCondensedBoldOblique` (Univers-CondensedBoldOblique), `UniversCondensedOblique` (Univers-CondensedOblique), `UniversExtended` (Univers-Extended), `UniversExtendedObl` (Univers-ExtendedObl), `UniversLight` (Univers-Light), `UniversLightOblique` (Univers-LightOblique), `UniversOblique` (Univers-Oblique), `WingdingsRegular` (Wingdings-Regular), `ZapfChanceryMediumItalic` (ZapfChancery-MediumItalic), `ZapfDingbats` |  |
| `RISize` | Size | PickOne | `70` | `70` | `Size` int 50–300 |
| `RIAngel` | Angle | PickOne | `30` | `30` | `Angel` int 0–359 |
| `RIEffects` | Text/Pattern Effects | PickOne | `Normal` | `Normal` (Text and Background), `ReversePatterns` (Reverse Patterns (Text/Background)), `BackgroundOnly` (Background Only), `TextOnly` (Text Only) |  |
| `RIRepeat` | Repeat | PickOne | `Off` | `Off`, `Repeat` (On), `RepeatandRotateCarriageReturn` (On (Rotate 180 Degrees at Carriage Return)) |  |
| `RILineSpace` | Line Space | PickOne | `70` | `70` | `LineSpace` int 50–300 |
| `RIPosition` | Position | PickOne | `Center` | `Center`, `TopLeft` (Top Left), `TopCenter` (Top Center), `TopRight` (Top Right), `BottomLeft` (Bottom Left), `BottomCenter` (Bottom Center), `BottomRight` (Bottom Right) |  |
| `RIColor` | Color | PickOne | `Black` | `Black` |  |
| `RIDensity` | Density | PickOne | `Medium` | `VeryLight` (Very Light), `Light`, `Medium`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIMaskType` | Mask Type | PickOne | `None` | `None`, `WaveCrest` (Type 1), `Mesh` (Type 2), `Lattice1` (Type 3), `Lattice2` (Type 4), `InterlockingCircles` (Type 5), `Shokkoh` (Type 6), `Matsukawabishi` (Type 7), `Scale` (Type 8), `Higaki` (Type 9), `Hexagonal` (Type 10) |  |

### Color Balance Details

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBrightness` | Brightness ( -50 to 50 ) | PickOne | `0` | `0` | `Brightness` real -50–50 |
| `RIContrast` | Contrast ( -50 to 50 ) | PickOne | `0` | `0` | `Contrast` real -50–50 |
| `RIBlack` | Black ( -50 to 50 ) | PickOne | `0` | `0` | `Black` real -50–50 |

### Background Numbering

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIBackgroundNumbering` | Background Numbering | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIBNSize` | Size | PickOne | `Normal` | `Small`, `Normal`, `Large` |  |
| `RIBNDensity` | Density | PickOne | `Normal` | `Light`, `Normal`, `Dark`, `VeryDark` (Very Dark) |  |
| `RIBNColor` | Color | PickOne | `Black` | `Black` |  |
| `RIStartNumber` | Start Number (1 to 9999) | PickOne | `1` | `1` | `StartNumber` int 1–9999 |

### User Authentication

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `RIEnableUserAuth` | User Authentication | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthLoginUserNameType` | Login User Name | PickOne | `DefinedUserID` | `DefinedUserID` (Defined User ID), `LoginUserName` (Mac Login Name) |  |
| `RIAuthLoginUserNameText` | Enter Login User Name | PickOne | `None` | `None` | `AuthLoginUserNameText` string 0–128 |
| `RIAuthLoginPassword` | Login Password | PickOne | `None` | `None` | `AuthLoginPassword` password 0–128 |
| `RIAuthEnableEncryption` | Driver Encryption Key | Boolean | `False` | `False` (Off), `True` (On) |  |
| `RIAuthEncryptionKey` | Driver Encryption Key | PickOne | `None` | `None` | `AuthEncryptionKey` password 0–32 |

## RICOH M C251FW PS

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | Media Size | PickOne | `A4` | `A4`, `JISB5` (B5 (JIS)), `A5`, `JISB6` (B6 (JIS)), `A6`, `Legal`, `Letter`, `HLT` (5.5" x 8.5"), `Executive`, `8x13` (8" x 13"), `8_25x13` (8.25" x 13"), `8_5x13` (8.5" x 13"), `4_125x9_5` (Com10 Env.), `3_875x7_5` (Monarch Env.), `DLEnv` (DL Env.), `C6Env` (C6 Env.), `C5Env` (C5 Env.), `Kai16` (16K), `A5L` (A5 (210 x 148mm)), `8_5x13_4` (8.5" x 13.4"), `8_5x13_6` (8.5" x 13.6") | `Width` points 255.119995117188–612.280029296875; `Height` points 419.529998779297–1009.130004882812; `WidthOffset` points 0–0; `HeightOffset` points 0–0; `Orientation` int 0–0 |
| `PageRegion` | Media Size | PickOne | `A4` | `A4`, `JISB5` (B5 (JIS)), `A5`, `JISB6` (B6 (JIS)), `A6`, `Legal`, `Letter`, `HLT` (5.5" x 8.5"), `Executive`, `8x13` (8" x 13"), `8_25x13` (8.25" x 13"), `8_5x13` (8.5" x 13"), `4_125x9_5` (Com10 Env.), `3_875x7_5` (Monarch Env.), `DLEnv` (DL Env.), `C6Env` (C6 Env.), `C5Env` (C5 Env.), `Kai16` (16K), `A5L` (A5 (210 x 148mm)), `8_5x13_4` (8.5" x 13.4"), `8_5x13_6` (8.5" x 13.6") |  |
| `InputSlot` | Input Tray | PickOne | `Tray1` | `Manual` (Bypass Tray), `Tray1` (Tray 1), `Tray2` (Tray 2) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (One sided), `DuplexNoTumble` (Left Side Binding), `DuplexTumble` (Top Side Binding) |  |

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Option1` | Total Memory | PickOne | `Mem256` | `Mem256` (256MB) |  |
| `Option2` | Tray 2 | PickOne | `False` | `False` (Not Installed), `True` (Installed) |  |

### Paper Type

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `MediaType` | Media Type | PickOne | `PlainRecycled` | `Thinner` (Thin (60 to 65 g/m2)), `Thin` (Plain 1 (66 to 74 g/m2)), `Thin2` (Plain 2 (75 to 81 g/m2)), `Plain` (Middle Thick (82 to 90 g/m2)), `PlainP` (Thick 1 (91 to 105 g/m2)), `Recycle` (Recycled), `PlainRecycled` (Plain 1/Plain 2/Middle Thick/Recycled), `Color`, `Letterhead`, `PrePrint` (Preprinted), `PrePunch` (Prepunched), `Labels`, `Bond`, `Cardstock`, `Thick` (Thick 2 (106 to 163 g/m2)), `Envelope` |  |

### Imaging

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `HQPrintMode` | Print Quality | Boolean | `661` | `661` (Standard), `662` (High Quality), `664` (Best Quality) |  |
| `HQColorRendering` | Color Profile | PickOne | `TEXT` | `OFF` (Off), `PRESENTATION` (Presentation), `TEXT` (Solid Color), `PHOTOGRAPHIC` (Photographic), `POPDISPLAY` (POP Display) |  |
| `HQColorSimul` | CMYK Simulation Profile | PickOne | `OFF` | `OFF` (Off), `USSWOP` (US OffsetPrint), `EUROSCALE` (Euroscale), `PALETTE` (PaletteColor) |  |
| `HQBlackTextOverprint` | Black Over Print | PickOne | `Text` | `Off`, `Text` (On) |  |

### Dithering

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `HQScreenMode` | Dithering | PickOne | `Auto` | `Auto` (Automatic), `Photographic`, `Text` |  |

### Toner

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `HQColorMode` | Color/ Black and White | PickOne | `COLOR` | `COLOR` (Color), `BW` (Black and White) |  |
| `HQGrayMode` | Gray Reproduction | PickOne | `Black` | `Black` (Black by K), `Color` (CMY+K) |  |
| `HQTonerSave` | Economy Color | PickOne | `OFF` | `OFF` (Off), `ON` (On) |  |
| `HQBlankPage` | Print Blank Pages | PickOne | `On` | `Off`, `On` |  |
| `HQCyan` | Cyan | PickOne | `On` | `Off`, `On` |  |
| `HQMagenta` | Magenta | PickOne | `On` | `Off`, `On` |  |
| `HQYellow` | Yellow | PickOne | `On` | `Off`, `On` |  |
| `HQBlack` | Black | PickOne | `On` | `Off`, `On` |  |

### Cover

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `HQFrontCoverPrint` | Front Cover | PickOne | `OFF` | `OFF` (Off), `BLANK` (Leave Blank), `SIMPLEXCOPY` (One Side), `DUPLEXCOPY` (Both Sides) |  |
| `HQFrontCoverPaperSource` | Front Cover Input | PickOne | `TRAY1` | `TRAY4Man` (Bypass Tray), `TRAY1` (Tray 1), `TRAY2` (Tray 2) |  |

### Watermark Text

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `HQwtrmrkType` | Watermark Type | PickOne | `Outline` | `Outline` (Outlined), `Solid`, `Transparent` (Transparent Text) |  |
| `HQwtrmrkString` | Watermark Text | PickOne | `Confidential` | `Confidential` (CONFIDENTIAL), `TopSecret` (TOP SECRET), `Copy` (COPY), `Draft` (DRAFT), `Final` (FINAL), `FileCopy` (FILE COPY), `Proof` (PROOF) |  |
| `HQwtrmrkFontSize` | Watermark Font Size (points) | PickOne | `pt60` | `pt6` (6), `pt18` (18), `pt30` (30), `pt60` (60), `pt90` (90), `pt120` (120), `pt150` (150), `pt180` (180), `pt200` (200), `pt300` (300) |  |
| `HQwtrmrkFontName` | Watermark Font Typeface | PickOne | `Helvetica` | `Arial-BoldItalic`, `Arial-Bold`, `Arial-Italic`, `Arial`, `Courier`, `Courier-Bold`, `Courier-BoldOblique`, `Courier-Oblique`, `Helvetica`, `Helvetica-Bold`, `Helvetica-BoldOblique`, `Helvetica-Oblique`, `Times-Bold`, `Times-BoldItalic`, `Times-Italic`, `Times-Roman` |  |
| `HQwtrmrkShading` | Watermark Font Shading | PickOne | `Shading20` | `Shading5` (5%), `Shading10` (10%), `Shading20` (20%), `Shading30` (30%), `Shading40` (40%), `Shading50` (50%), `Shading60` (60%), `Shading70` (70%), `Shading80` (80%), `Shading90` (90%), `Shading100` (100%) |  |

### Watermark Location

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `HQwtrmrkLocationX` | Watermark Position (Horizontal) | PickOne | `CenterX0` | `Left50` (Left (-50)), `Left40` (Left (-40)), `Left30` (Left (-30)), `Left20` (Left (-20)), `Left10` (Left (-10)), `CenterX0` (Center (0)), `Right10` (Right (+10)), `Right20` (Right (+20)), `Right30` (Right (+30)), `Right40` (Right (+40)), `Right50` (Right (+50)) |  |
| `HQwtrmrkLocationY` | Watermark Position (Vertical) | PickOne | `CenterY0` | `Bottom50` (Bottom (-50)), `Bottom40` (Bottom (-40)), `Bottom30` (Bottom (-30)), `Bottom20` (Bottom (-20)), `Bottom10` (Bottom (-10)), `CenterY0` (Center (0)), `Top10` (Top (+10)), `Top20` (Top (+20)), `Top30` (Top (+30)), `Top40` (Top (+40)), `Top50` (Top (+50)) |  |
| `HQwtrmrkAngle` | Watermark Angle | PickOne | `Deg45` | `Degm90` (Vertical (-90 degrees)), `Degm75` (Diagonal (-75 degrees)), `Degm60` (Diagonal (-60 degrees)), `Degm45` (Diagonal (-45 degrees)), `Degm30` (Diagonal (-30 degrees)), `Degm15` (Diagonal (-15 degrees)), `Deg0` (Horizontal (0 degrees)), `Deg15` (Diagonal (15 degrees)), `Deg30` (Diagonal (30 degrees)), `Deg45` (Diagonal (45 degrees)), `Deg60` (Diagonal (60 degrees)), `Deg75` (Diagonal (75 degrees)), `Deg90` (Vertical (90 degrees)) |  |
| `HQwtrmrkMode` | Watermark | PickOne | `None` | `None` (Off), `FirstPage` (First Page Only), `AllPage` (All Pages) |  |

## RICOH SP 3710DN

### General

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `PageSize` | Media Size | PickOne | `Letter` | `A4` (A4 (210 x 297 mm)), `Letter` (Letter (8.5" x 11")), `A5` (A5 (148 x 210 mm)), `Legal` (Legal (8.5" x 14")), `Env10` (Com10 (104.8 x 241.3 mm)), `EnvMonarch` (Monarch (98.4 x 190.5 mm)), `EnvDL` (DL Env (110 x 220 mm)), `EnvC5` (C5 Env (162 x 229 mm)) |  |
| `PageRegion` | Media Size | PickOne | `Letter` | `A4` (A4 (210 x 297 mm)), `Letter` (Letter (8.5" x 11")), `A5` (A5 (148 x 210 mm)), `Legal` (Legal (8.5" x 14")), `Env10` (Com10 (104.8 x 241.3 mm)), `EnvMonarch` (Monarch (98.4 x 190.5 mm)), `EnvDL` (DL Env (110 x 220 mm)), `EnvC5` (C5 Env (162 x 229 mm)) |  |
| `Resolution` | Resolution | PickOne | `600dpi` | `600dpi` |  |
| `InputSlot` | Input Tray | PickOne | `AutoSelect` | `AutoSelect` (Auto Tray Select), `Manual` (Bypass Tray), `Tray1` (Tray 1), `Tray2` (Tray 2) |  |
| `Duplex` | Duplex | PickOne | `DuplexNoTumble` | `None` (Off), `DuplexNoTumble` (Long-Edge Binding), `DuplexTumble` (Short-Edge Binding) |  |

### Installable Options

| Keyword | Label | UI type | Default | Choices | Custom value |
|---|---|---|---|---|---|
| `Option1` | Tray 2 | PickOne | `False` | `False` (Not Set), `True` (Set) |  |

