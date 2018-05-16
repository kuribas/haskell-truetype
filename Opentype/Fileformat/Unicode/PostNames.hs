module Opentype.Fileformat.Unicode.PostNames
  (CodePoint, codepointName, hasDescriptiveName, nameToCodepoint,
   postscriptIndex, postscriptName, postscriptNames)
where
import qualified Data.Map.Strict as M
import qualified Data.HashMap.Strict as HM
import Text.Printf
import Data.Tuple (swap)
import Data.List (isPrefixOf, foldl')
import qualified Data.Vector as V
import Data.Char

type CodePoint = Int

-- | Standard name for this codepoint.  Will be a descriptive name if
-- one is available, otherwise uni<hex-codepoint>.
codepointName :: CodePoint -> String
codepointName cp =
  case M.lookup cp codeMap of
    Just n -> n
    Nothing
      | cp > 0xffff -> printf "u%06x" cp
      | otherwise -> printf "uni%04x" cp

hasDescriptiveName :: CodePoint -> Bool
hasDescriptiveName cp = M.member cp codeMap

nameToCodepoint :: String -> Maybe CodePoint
nameToCodepoint name
  | name == ".notdef" ||
    name == ".null" = Just 0
  | "uni" `isPrefixOf` name =
      let hexNum = takeWhile isHexDigit $ drop 3 name
      in if length hexNum == 4
      then Just $ foldl' (\t d -> t*16 + fromIntegral (digitToInt d)) 0 hexNum
      else def
  | "u" `isPrefixOf` name =
      let hexNum = takeWhile isHexDigit $ drop 1 name
          nDigits = length hexNum
      in if nDigits >= 4 && nDigits <= 6
      then Just $ foldl' (\t d -> t*16 + fromIntegral (digitToInt d)) 0 hexNum
      else def
  | otherwise = def 
  where
    def = HM.lookup (takeWhile isAlpha name) nameMap

nameMap :: HM.HashMap String CodePoint
nameMap = HM.fromList $ map swap aglfn

codeMap :: M.Map CodePoint String
codeMap = M.fromList aglfn

-- | index of the string in the list of standard postscript names, if any.
postscriptIndex :: String -> Maybe Int
postscriptIndex n = HM.lookup n postscriptIndexMap

-- | standard postscript name at index, if any.
postscriptName :: Int -> Maybe String
postscriptName i
  | i < 0 || i >= V.length postscriptNames = Nothing
  | otherwise = Just $ postscriptNames V.! i

postscriptIndexMap :: HM.HashMap String Int
postscriptIndexMap =
  HM.fromList $
  zip (V.toList postscriptNames) [1..]
                  
aglfn :: [(CodePoint, String)]
aglfn = [(0x0041,"A"),
         (0x00C6,"AE"),
         (0x01FC,"AEacute"),
         (0x00C1,"Aacute"),
         (0x0102,"Abreve"),
         (0x00C2,"Acircumflex"),
         (0x00C4,"Adieresis"),
         (0x00C0,"Agrave"),
         (0x0391,"Alpha"),
         (0x0386,"Alphatonos"),
         (0x0100,"Amacron"),
         (0x0104,"Aogonek"),
         (0x00C5,"Aring"),
         (0x01FA,"Aringacute"),
         (0x00C3,"Atilde"),
         (0x0042,"B"),
         (0x0392,"Beta"),
         (0x0043,"C"),
         (0x0106,"Cacute"),
         (0x010C,"Ccaron"),
         (0x00C7,"Ccedilla"),
         (0x0108,"Ccircumflex"),
         (0x010A,"Cdotaccent"),
         (0x03A7,"Chi"),
         (0x0044,"D"),
         (0x010E,"Dcaron"),
         (0x0110,"Dcroat"),
         (0x2206,"Delta"),
         (0x0045,"E"),
         (0x00C9,"Eacute"),
         (0x0114,"Ebreve"),
         (0x011A,"Ecaron"),
         (0x00CA,"Ecircumflex"),
         (0x00CB,"Edieresis"),
         (0x0116,"Edotaccent"),
         (0x00C8,"Egrave"),
         (0x0112,"Emacron"),
         (0x014A,"Eng"),
         (0x0118,"Eogonek"),
         (0x0395,"Epsilon"),
         (0x0388,"Epsilontonos"),
         (0x0397,"Eta"),
         (0x0389,"Etatonos"),
         (0x00D0,"Eth"),
         (0x20AC,"Euro"),
         (0x0046,"F"),
         (0x0047,"G"),
         (0x0393,"Gamma"),
         (0x011E,"Gbreve"),
         (0x01E6,"Gcaron"),
         (0x011C,"Gcircumflex"),
         (0x0120,"Gdotaccent"),
         (0x0048,"H"),
         (0x25CF,"H18533"),
         (0x25AA,"H18543"),
         (0x25AB,"H18551"),
         (0x25A1,"H22073"),
         (0x0126,"Hbar"),
         (0x0124,"Hcircumflex"),
         (0x0049,"I"),
         (0x0132,"IJ"),
         (0x00CD,"Iacute"),
         (0x012C,"Ibreve"),
         (0x00CE,"Icircumflex"),
         (0x00CF,"Idieresis"),
         (0x0130,"Idotaccent"),
         (0x2111,"Ifraktur"),
         (0x00CC,"Igrave"),
         (0x012A,"Imacron"),
         (0x012E,"Iogonek"),
         (0x0399,"Iota"),
         (0x03AA,"Iotadieresis"),
         (0x038A,"Iotatonos"),
         (0x0128,"Itilde"),
         (0x004A,"J"),
         (0x0134,"Jcircumflex"),
         (0x004B,"K"),
         (0x039A,"Kappa"),
         (0x004C,"L"),
         (0x0139,"Lacute"),
         (0x039B,"Lambda"),
         (0x013D,"Lcaron"),
         (0x013F,"Ldot"),
         (0x0141,"Lslash"),
         (0x004D,"M"),
         (0x039C,"Mu"),
         (0x004E,"N"),
         (0x0143,"Nacute"),
         (0x0147,"Ncaron"),
         (0x00D1,"Ntilde"),
         (0x039D,"Nu"),
         (0x004F,"O"),
         (0x0152,"OE"),
         (0x00D3,"Oacute"),
         (0x014E,"Obreve"),
         (0x00D4,"Ocircumflex"),
         (0x00D6,"Odieresis"),
         (0x00D2,"Ograve"),
         (0x01A0,"Ohorn"),
         (0x0150,"Ohungarumlaut"),
         (0x014C,"Omacron"),
         (0x2126,"Omega"),
         (0x038F,"Omegatonos"),
         (0x039F,"Omicron"),
         (0x038C,"Omicrontonos"),
         (0x00D8,"Oslash"),
         (0x01FE,"Oslashacute"),
         (0x00D5,"Otilde"),
         (0x0050,"P"),
         (0x03A6,"Phi"),
         (0x03A0,"Pi"),
         (0x03A8,"Psi"),
         (0x0051,"Q"),
         (0x0052,"R"),
         (0x0154,"Racute"),
         (0x0158,"Rcaron"),
         (0x211C,"Rfraktur"),
         (0x03A1,"Rho"),
         (0x0053,"S"),
         (0x250C,"SF010000"),
         (0x2514,"SF020000"),
         (0x2510,"SF030000"),
         (0x2518,"SF040000"),
         (0x253C,"SF050000"),
         (0x252C,"SF060000"),
         (0x2534,"SF070000"),
         (0x251C,"SF080000"),
         (0x2524,"SF090000"),
         (0x2500,"SF100000"),
         (0x2502,"SF110000"),
         (0x2561,"SF190000"),
         (0x2562,"SF200000"),
         (0x2556,"SF210000"),
         (0x2555,"SF220000"),
         (0x2563,"SF230000"),
         (0x2551,"SF240000"),
         (0x2557,"SF250000"),
         (0x255D,"SF260000"),
         (0x255C,"SF270000"),
         (0x255B,"SF280000"),
         (0x255E,"SF360000"),
         (0x255F,"SF370000"),
         (0x255A,"SF380000"),
         (0x2554,"SF390000"),
         (0x2569,"SF400000"),
         (0x2566,"SF410000"),
         (0x2560,"SF420000"),
         (0x2550,"SF430000"),
         (0x256C,"SF440000"),
         (0x2567,"SF450000"),
         (0x2568,"SF460000"),
         (0x2564,"SF470000"),
         (0x2565,"SF480000"),
         (0x2559,"SF490000"),
         (0x2558,"SF500000"),
         (0x2552,"SF510000"),
         (0x2553,"SF520000"),
         (0x256B,"SF530000"),
         (0x256A,"SF540000"),
         (0x015A,"Sacute"),
         (0x0160,"Scaron"),
         (0x015E,"Scedilla"),
         (0x015C,"Scircumflex"),
         (0x03A3,"Sigma"),
         (0x0054,"T"),
         (0x03A4,"Tau"),
         (0x0166,"Tbar"),
         (0x0164,"Tcaron"),
         (0x0398,"Theta"),
         (0x00DE,"Thorn"),
         (0x0055,"U"),
         (0x00DA,"Uacute"),
         (0x016C,"Ubreve"),
         (0x00DB,"Ucircumflex"),
         (0x00DC,"Udieresis"),
         (0x00D9,"Ugrave"),
         (0x01AF,"Uhorn"),
         (0x0170,"Uhungarumlaut"),
         (0x016A,"Umacron"),
         (0x0172,"Uogonek"),
         (0x03A5,"Upsilon"),
         (0x03D2,"Upsilon1"),
         (0x03AB,"Upsilondieresis"),
         (0x038E,"Upsilontonos"),
         (0x016E,"Uring"),
         (0x0168,"Utilde"),
         (0x0056,"V"),
         (0x0057,"W"),
         (0x1E82,"Wacute"),
         (0x0174,"Wcircumflex"),
         (0x1E84,"Wdieresis"),
         (0x1E80,"Wgrave"),
         (0x0058,"X"),
         (0x039E,"Xi"),
         (0x0059,"Y"),
         (0x00DD,"Yacute"),
         (0x0176,"Ycircumflex"),
         (0x0178,"Ydieresis"),
         (0x1EF2,"Ygrave"),
         (0x005A,"Z"),
         (0x0179,"Zacute"),
         (0x017D,"Zcaron"),
         (0x017B,"Zdotaccent"),
         (0x0396,"Zeta"),
         (0x0061,"a"),
         (0x00E1,"aacute"),
         (0x0103,"abreve"),
         (0x00E2,"acircumflex"),
         (0x00B4,"acute"),
         (0x0301,"acutecomb"),
         (0x00E4,"adieresis"),
         (0x00E6,"ae"),
         (0x01FD,"aeacute"),
         (0x00E0,"agrave"),
         (0x2135,"aleph"),
         (0x03B1,"alpha"),
         (0x03AC,"alphatonos"),
         (0x0101,"amacron"),
         (0x0026,"ampersand"),
         (0x2220,"angle"),
         (0x2329,"angleleft"),
         (0x232A,"angleright"),
         (0x0387,"anoteleia"),
         (0x0105,"aogonek"),
         (0x2248,"approxequal"),
         (0x00E5,"aring"),
         (0x01FB,"aringacute"),
         (0x2194,"arrowboth"),
         (0x21D4,"arrowdblboth"),
         (0x21D3,"arrowdbldown"),
         (0x21D0,"arrowdblleft"),
         (0x21D2,"arrowdblright"),
         (0x21D1,"arrowdblup"),
         (0x2193,"arrowdown"),
         (0x2190,"arrowleft"),
         (0x2192,"arrowright"),
         (0x2191,"arrowup"),
         (0x2195,"arrowupdn"),
         (0x21A8,"arrowupdnbse"),
         (0x005E,"asciicircum"),
         (0x007E,"asciitilde"),
         (0x002A,"asterisk"),
         (0x2217,"asteriskmath"),
         (0x0040,"at"),
         (0x00E3,"atilde"),
         (0x0062,"b"),
         (0x005C,"backslash"),
         (0x007C,"bar"),
         (0x03B2,"beta"),
         (0x2588,"block"),
         (0x007B,"braceleft"),
         (0x007D,"braceright"),
         (0x005B,"bracketleft"),
         (0x005D,"bracketright"),
         (0x02D8,"breve"),
         (0x00A6,"brokenbar"),
         (0x2022,"bullet"),
         (0x0063,"c"),
         (0x0107,"cacute"),
         (0x02C7,"caron"),
         (0x21B5,"carriagereturn"),
         (0x010D,"ccaron"),
         (0x00E7,"ccedilla"),
         (0x0109,"ccircumflex"),
         (0x010B,"cdotaccent"),
         (0x00B8,"cedilla"),
         (0x00A2,"cent"),
         (0x03C7,"chi"),
         (0x25CB,"circle"),
         (0x2297,"circlemultiply"),
         (0x2295,"circleplus"),
         (0x02C6,"circumflex"),
         (0x2663,"club"),
         (0x003A,"colon"),
         (0x20A1,"colonmonetary"),
         (0x002C,"comma"),
         (0x2245,"congruent"),
         (0x00A9,"copyright"),
         (0x00A4,"currency"),
         (0x0064,"d"),
         (0x2020,"dagger"),
         (0x2021,"daggerdbl"),
         (0x010F,"dcaron"),
         (0x0111,"dcroat"),
         (0x00B0,"degree"),
         (0x03B4,"delta"),
         (0x2666,"diamond"),
         (0x00A8,"dieresis"),
         (0x0385,"dieresistonos"),
         (0x00F7,"divide"),
         (0x2593,"dkshade"),
         (0x2584,"dnblock"),
         (0x0024,"dollar"),
         (0x20AB,"dong"),
         (0x02D9,"dotaccent"),
         (0x0323,"dotbelowcomb"),
         (0x0131,"dotlessi"),
         (0x22C5,"dotmath"),
         (0x0065,"e"),
         (0x00E9,"eacute"),
         (0x0115,"ebreve"),
         (0x011B,"ecaron"),
         (0x00EA,"ecircumflex"),
         (0x00EB,"edieresis"),
         (0x0117,"edotaccent"),
         (0x00E8,"egrave"),
         (0x0038,"eight"),
         (0x2208,"element"),
         (0x2026,"ellipsis"),
         (0x0113,"emacron"),
         (0x2014,"emdash"),
         (0x2205,"emptyset"),
         (0x2013,"endash"),
         (0x014B,"eng"),
         (0x0119,"eogonek"),
         (0x03B5,"epsilon"),
         (0x03AD,"epsilontonos"),
         (0x003D,"equal"),
         (0x2261,"equivalence"),
         (0x212E,"estimated"),
         (0x03B7,"eta"),
         (0x03AE,"etatonos"),
         (0x00F0,"eth"),
         (0x0021,"exclam"),
         (0x203C,"exclamdbl"),
         (0x00A1,"exclamdown"),
         (0x2203,"existential"),
         (0x0066,"f"),
         (0x2640,"female"),
         (0x2012,"figuredash"),
         (0x25A0,"filledbox"),
         (0x25AC,"filledrect"),
         (0x0035,"five"),
         (0x215D,"fiveeighths"),
         (0x0192,"florin"),
         (0x0034,"four"),
         (0x2044,"fraction"),
         (0x20A3,"franc"),
         (0x0067,"g"),
         (0x03B3,"gamma"),
         (0x011F,"gbreve"),
         (0x01E7,"gcaron"),
         (0x011D,"gcircumflex"),
         (0x0121,"gdotaccent"),
         (0x00DF,"germandbls"),
         (0x2207,"gradient"),
         (0x0060,"grave"),
         (0x0300,"gravecomb"),
         (0x003E,"greater"),
         (0x2265,"greaterequal"),
         (0x00AB,"guillemotleft"),
         (0x00BB,"guillemotright"),
         (0x2039,"guilsinglleft"),
         (0x203A,"guilsinglright"),
         (0x0068,"h"),
         (0x0127,"hbar"),
         (0x0125,"hcircumflex"),
         (0x2665,"heart"),
         (0x0309,"hookabovecomb"),
         (0x2302,"house"),
         (0x02DD,"hungarumlaut"),
         (0x002D,"hyphen"),
         (0x0069,"i"),
         (0x00ED,"iacute"),
         (0x012D,"ibreve"),
         (0x00EE,"icircumflex"),
         (0x00EF,"idieresis"),
         (0x00EC,"igrave"),
         (0x0133,"ij"),
         (0x012B,"imacron"),
         (0x221E,"infinity"),
         (0x222B,"integral"),
         (0x2321,"integralbt"),
         (0x2320,"integraltp"),
         (0x2229,"intersection"),
         (0x25D8,"invbullet"),
         (0x25D9,"invcircle"),
         (0x263B,"invsmileface"),
         (0x012F,"iogonek"),
         (0x03B9,"iota"),
         (0x03CA,"iotadieresis"),
         (0x0390,"iotadieresistonos"),
         (0x03AF,"iotatonos"),
         (0x0129,"itilde"),
         (0x006A,"j"),
         (0x0135,"jcircumflex"),
         (0x006B,"k"),
         (0x03BA,"kappa"),
         (0x0138,"kgreenlandic"),
         (0x006C,"l"),
         (0x013A,"lacute"),
         (0x03BB,"lambda"),
         (0x013E,"lcaron"),
         (0x0140,"ldot"),
         (0x003C,"less"),
         (0x2264,"lessequal"),
         (0x258C,"lfblock"),
         (0x20A4,"lira"),
         (0x2227,"logicaland"),
         (0x00AC,"logicalnot"),
         (0x2228,"logicalor"),
         (0x017F,"longs"),
         (0x25CA,"lozenge"),
         (0x0142,"lslash"),
         (0x2591,"ltshade"),
         (0x006D,"m"),
         (0x00AF,"macron"),
         (0x2642,"male"),
         (0x2212,"minus"),
         (0x2032,"minute"),
         (0x00B5,"mu"),
         (0x00D7,"multiply"),
         (0x266A,"musicalnote"),
         (0x266B,"musicalnotedbl"),
         (0x006E,"n"),
         (0x0144,"nacute"),
         (0x0149,"napostrophe"),
         (0x0148,"ncaron"),
         (0x0039,"nine"),
         (0x2209,"notelement"),
         (0x2260,"notequal"),
         (0x2284,"notsubset"),
         (0x00F1,"ntilde"),
         (0x03BD,"nu"),
         (0x0023,"numbersign"),
         (0x006F,"o"),
         (0x00F3,"oacute"),
         (0x014F,"obreve"),
         (0x00F4,"ocircumflex"),
         (0x00F6,"odieresis"),
         (0x0153,"oe"),
         (0x02DB,"ogonek"),
         (0x00F2,"ograve"),
         (0x01A1,"ohorn"),
         (0x0151,"ohungarumlaut"),
         (0x014D,"omacron"),
         (0x03C9,"omega"),
         (0x03D6,"omega1"),
         (0x03CE,"omegatonos"),
         (0x03BF,"omicron"),
         (0x03CC,"omicrontonos"),
         (0x0031,"one"),
         (0x2024,"onedotenleader"),
         (0x215B,"oneeighth"),
         (0x00BD,"onehalf"),
         (0x00BC,"onequarter"),
         (0x2153,"onethird"),
         (0x25E6,"openbullet"),
         (0x00AA,"ordfeminine"),
         (0x00BA,"ordmasculine"),
         (0x221F,"orthogonal"),
         (0x00F8,"oslash"),
         (0x01FF,"oslashacute"),
         (0x00F5,"otilde"),
         (0x0070,"p"),
         (0x00B6,"paragraph"),
         (0x0028,"parenleft"),
         (0x0029,"parenright"),
         (0x2202,"partialdiff"),
         (0x0025,"percent"),
         (0x002E,"period"),
         (0x00B7,"periodcentered"),
         (0x22A5,"perpendicular"),
         (0x2030,"perthousand"),
         (0x20A7,"peseta"),
         (0x03C6,"phi"),
         (0x03D5,"phi1"),
         (0x03C0,"pi"),
         (0x002B,"plus"),
         (0x00B1,"plusminus"),
         (0x211E,"prescription"),
         (0x220F,"product"),
         (0x2282,"propersubset"),
         (0x2283,"propersuperset"),
         (0x221D,"proportional"),
         (0x03C8,"psi"),
         (0x0071,"q"),
         (0x003F,"question"),
         (0x00BF,"questiondown"),
         (0x0022,"quotedbl"),
         (0x201E,"quotedblbase"),
         (0x201C,"quotedblleft"),
         (0x201D,"quotedblright"),
         (0x2018,"quoteleft"),
         (0x201B,"quotereversed"),
         (0x2019,"quoteright"),
         (0x201A,"quotesinglbase"),
         (0x0027,"quotesingle"),
         (0x0072,"r"),
         (0x0155,"racute"),
         (0x221A,"radical"),
         (0x0159,"rcaron"),
         (0x2286,"reflexsubset"),
         (0x2287,"reflexsuperset"),
         (0x00AE,"registered"),
         (0x2310,"revlogicalnot"),
         (0x03C1,"rho"),
         (0x02DA,"ring"),
         (0x2590,"rtblock"),
         (0x0073,"s"),
         (0x015B,"sacute"),
         (0x0161,"scaron"),
         (0x015F,"scedilla"),
         (0x015D,"scircumflex"),
         (0x2033,"second"),
         (0x00A7,"section"),
         (0x003B,"semicolon"),
         (0x0037,"seven"),
         (0x215E,"seveneighths"),
         (0x2592,"shade"),
         (0x03C3,"sigma"),
         (0x03C2,"sigma1"),
         (0x223C,"similar"),
         (0x0036,"six"),
         (0x002F,"slash"),
         (0x263A,"smileface"),
         (0x0020,"space"),
         (0x2660,"spade"),
         (0x00A3,"sterling"),
         (0x220B,"suchthat"),
         (0x2211,"summation"),
         (0x263C,"sun"),
         (0x0074,"t"),
         (0x03C4,"tau"),
         (0x0167,"tbar"),
         (0x0165,"tcaron"),
         (0x2234,"therefore"),
         (0x03B8,"theta"),
         (0x03D1,"theta1"),
         (0x00FE,"thorn"),
         (0x0033,"three"),
         (0x215C,"threeeighths"),
         (0x00BE,"threequarters"),
         (0x02DC,"tilde"),
         (0x0303,"tildecomb"),
         (0x0384,"tonos"),
         (0x2122,"trademark"),
         (0x25BC,"triagdn"),
         (0x25C4,"triaglf"),
         (0x25BA,"triagrt"),
         (0x25B2,"triagup"),
         (0x0032,"two"),
         (0x2025,"twodotenleader"),
         (0x2154,"twothirds"),
         (0x0075,"u"),
         (0x00FA,"uacute"),
         (0x016D,"ubreve"),
         (0x00FB,"ucircumflex"),
         (0x00FC,"udieresis"),
         (0x00F9,"ugrave"),
         (0x01B0,"uhorn"),
         (0x0171,"uhungarumlaut"),
         (0x016B,"umacron"),
         (0x005F,"underscore"),
         (0x2017,"underscoredbl"),
         (0x222A,"union"),
         (0x2200,"universal"),
         (0x0173,"uogonek"),
         (0x2580,"upblock"),
         (0x03C5,"upsilon"),
         (0x03CB,"upsilondieresis"),
         (0x03B0,"upsilondieresistonos"),
         (0x03CD,"upsilontonos"),
         (0x016F,"uring"),
         (0x0169,"utilde"),
         (0x0076,"v"),
         (0x0077,"w"),
         (0x1E83,"wacute"),
         (0x0175,"wcircumflex"),
         (0x1E85,"wdieresis"),
         (0x2118,"weierstrass"),
         (0x1E81,"wgrave"),
         (0x0078,"x"),
         (0x03BE,"xi"),
         (0x0079,"y"),
         (0x00FD,"yacute"),
         (0x0177,"ycircumflex"),
         (0x00FF,"ydieresis"),
         (0x00A5,"yen"),
         (0x1EF3,"ygrave"),
         (0x007A,"z"),
         (0x017A,"zacute"),
         (0x017E,"zcaron"),
         (0x017C,"zdotaccent"),
         (0x0030,"zero"),
         (0x03B6,"zeta")]

-- | vector of standard postscript names.
postscriptNames :: V.Vector String
postscriptNames =
  V.fromList
  [".notdef",
   ".null",
   "nonmarkingreturn",
   "space",
   "exclam",
   "quotedbl",
   "numbersign",
   "dollar",
   "percent",
   "ampersand",
   "quotesingle",
   "parenleft",
   "parenright",
   "asterisk",
   "plus",
   "comma",
   "hyphen",
   "period",
   "slash",
   "zero",
   "one",
   "two",
   "three",
   "four",
   "five",
   "six",
   "seven",
   "eight",
   "nine",
   "colon",
   "semicolon",
   "less",
   "equal",
   "greater",
   "question",
   "at",
   "A",
   "B",
   "C",
   "D",
   "E",
   "F",
   "G",
   "H",
   "I",
   "J",
   "K",
   "L",
   "M",
   "N",
   "O",
   "P",
   "Q",
   "R",
   "S",
   "T",
   "U",
   "V",
   "W",
   "X",
   "Y",
   "Z",
   "bracketleft",
   "backslash",
   "bracketright",
   "asciicircum",
   "underscore",
   "grave",
   "a",
   "b",
   "c",
   "d",
   "e",
   "f",
   "g",
   "h",
   "i",
   "j",
   "k",
   "l",
   "m",
   "n",
   "o",
   "p",
   "q",
   "r",
   "s",
   "t",
   "u",
   "v",
   "w",
   "x",
   "y",
   "z",
   "braceleft",
   "bar",
   "braceright",
   "asciitilde",
   "Adieresis",
   "Aring",
   "Ccedilla",
   "Eacute",
   "Ntilde",
   "Odieresis",
   "Udieresis",
   "aacute",
   "agrave",
   "acircumflex",
   "adieresis",
   "atilde",
   "aring",
   "ccedilla",
   "eacute",
   "egrave",
   "ecircumflex",
   "edieresis",
   "iacute",
   "igrave",
   "icircumflex",
   "idieresis",
   "ntilde",
   "oacute",
   "ograve",
   "ocircumflex",
   "odieresis",
   "otilde",
   "uacute",
   "ugrave",
   "ucircumflex",
   "udieresis",
   "dagger",
   "degree",
   "cent",
   "sterling",
   "section",
   "bullet",
   "paragraph",
   "germandbls",
   "registered",
   "copyright",
   "trademark",
   "acute",
   "dieresis",
   "notequal",
   "AE",
   "Oslash",
   "infinity",
   "plusminus",
   "lessequal",
   "greaterequal",
   "yen",
   "mu",
   "partialdiff",
   "summation",
   "product",
   "pi",
   "integral",
   "ordfeminine",
   "ordmasculine",
   "Omega",
   "ae",
   "oslash",
   "questiondown",
   "exclamdown",
   "logicalnot",
   "radical",
   "florin",
   "approxequal",
   "Delta",
   "guillemotleft",
   "guillemotright",
   "ellipsis",
   "nonbreakingspace",
   "Agrave",
   "Atilde",
   "Otilde",
   "OE",
   "oe",
   "endash",
   "emdash",
   "quotedblleft",
   "quotedblright",
   "quoteleft",
   "quoteright",
   "divide",
   "lozenge",
   "ydieresis",
   "Ydieresis",
   "fraction",
   "currency",
   "guilsinglleft",
   "guilsinglright",
   "fi",
   "fl",
   "daggerdbl",
   "periodcentered",
   "quotesinglbase",
   "quotedblbase",
   "perthousand",
   "Acircumflex",
   "Ecircumflex",
   "Aacute",
   "Edieresis",
   "Egrave",
   "Iacute",
   "Icircumflex",
   "Idieresis",
   "Igrave",
   "Oacute",
   "Ocircumflex",
   "apple",
   "Ograve",
   "Uacute",
   "Ucircumflex",
   "Ugrave",
   "dotlessi",
   "circumflex",
   "tilde",
   "macron",
   "breve",
   "dotaccent",
   "ring",
   "cedilla",
   "hungarumlaut",
   "ogonek",
   "caron",
   "Lslash",
   "lslash",
   "Scaron",
   "scaron",
   "Zcaron",
   "zcaron",
   "brokenbar",
   "Eth",
   "eth",
   "Yacute",
   "yacute",
   "Thorn",
   "thorn",
   "minus",
   "multiply",
   "onesuperior",
   "twosuperior",
   "threesuperior",
   "onehalf",
   "onequarter",
   "threequarters",
   "franc",
   "Gbreve",
   "gbreve",
   "Idotaccent",
   "Scedilla",
   "scedilla",
   "Cacute",
   "cacute",
   "Ccaron",
   "ccaron",
   "dcroat"]
