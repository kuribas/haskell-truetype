module Opentype.Fileformat.Types where
import Data.Word
import Data.Int
import Data.Bits
import Data.Binary.Put
import Data.ByteString.Unsafe
import qualified Data.ByteString as Strict
import qualified Data.Map as M

-- | A ShortFrac is an 16 bit signed fixed number with a bias of
-- 14. This means it can represent numbers between 1.999 (0x7fff) and
-- -2.0 (0x8000). 1.0 is stored as 16384 (0x4000) and -1.0 is stored
-- as -16384 (0xc000).  Efficient numeric instances are provided.
newtype ShortFrac = ShortFrac Int16
  
-- | signed fixed-point number
type Fixed = Word32
-- | FWord describes a quantity in FUnits, the smallest
-- measurable distance in em space.
type FWord = Int16
-- | UFWord describes a quantity in FUnits, the smallest measurable
-- distance in em space.
type UFWord = Word16
-- | the glyph index in the glyph table
type GlyphID = Word16

data Platform =
  UnicodePlatform UnicodeEncoding |
  -- | /DEPRECATED/
  MacintoshPlatform Word16 |
  MicrosoftPlatform MicrosoftEncoding
  deriving (Ord, Eq, Show)

data MicrosoftEncoding =
  -- | Symbol
  MSSymbol |
  -- | Unicode BMP-only (UCS-2)
  MSUcs2 |
  -- | Shift-JIS
  ShiftJIS |
  -- | PRC
  PRC |
  -- | BigFive
  BigFive |
  -- | Johab
  Johab |
  -- Unicode UCS-4
  MSUcs4
  deriving (Show, Eq, Ord, Enum)

data UnicodeEncoding =
  -- | Default semantics
  UnicodeDefault |
  -- | Version 1.1 semantics
  UnicodeVersion1_1 |
  -- | ISO 10646 1993 semantics (deprecated)
  ISO_10646 |
  -- | Unicode 2.0 or later semantics (BMP only)
  UnicodeBmpOnly |
  -- | Unicode 2.0 or later semantics (non-BMP characters allowed)
  UnicodeNonBmp |
  -- | Unicode Variation Sequences
  UnicodeVariationSequences |
  -- | Full Unicode coverage (used with type 13.0 cmaps by OpenType)
  FullCoverage
  deriving (Show, Eq, Ord, Enum)
  
type WordMap a = M.Map Word32 a
-- return larged power of 2 <= i 
iLog2 :: Integral a => a -> a
iLog2 = iLog2' 0 where
  iLog2' base i
    | i > 0 = iLog2' (base+1) (i `quot` 2) 
    | otherwise = base-1

byteAt :: (Bits a, Num a) => a -> Int -> Bool
byteAt flag i = flag .&. 1 `shift` i /= 0
{-# SPECIALIZE byteAt :: Word8 -> Int -> Bool #-}
{-# SPECIALIZE byteAt :: Word16 -> Int -> Bool #-}

makeFlag :: [Bool] -> Word16
makeFlag l =
  fromIntegral $ sum $ zipWith (*) (iterate (*2) 1) $
  map fromEnum l

instance Num ShortFrac where
  (ShortFrac a) + (ShortFrac b) = ShortFrac $ a + b
  (ShortFrac a) - (ShortFrac b) = ShortFrac $ a - b
  (ShortFrac a) * (ShortFrac b) =
    ShortFrac $ fromIntegral (((fromIntegral a :: Int32) * (fromIntegral b :: Int32)) `shift` (-14))
  abs (ShortFrac a) = ShortFrac $ abs a
  fromInteger i = ShortFrac $ fromIntegral i `shift` 14
  signum (ShortFrac a) = fromIntegral $ signum a

instance Eq ShortFrac where
  (ShortFrac a) == (ShortFrac b) = a == b

instance Ord ShortFrac where
  compare (ShortFrac a) (ShortFrac b) = compare a b

instance Fractional ShortFrac where
  fromRational r =
    ShortFrac $ fromIntegral $ 
    floor ((r+2) * 0x4000) - (0x8000::Word16)
  (ShortFrac a) / (ShortFrac b) =
    ShortFrac $ fromIntegral $
    ((fromIntegral a :: Int32) `shift` 14) `quot` fromIntegral b

instance Show ShortFrac where
  show a = show (realToFrac a :: Float)

instance Real ShortFrac where
  toRational (ShortFrac a) =
    fromIntegral ((fromIntegral a::Word16) + 0x8000) / 0x4000 - 2

instance RealFrac ShortFrac where
  properFraction (ShortFrac a)
    | a < 0 && f /= 0 = (i+1, ShortFrac (-f))
    | otherwise = (i, ShortFrac f)
    where i = fromIntegral (((fromIntegral a :: Word16) + 0x8000) `shift` (-14)) - 2
          f = a .&. 0x3fff

putShortFrac :: ShortFrac -> Put
putShortFrac (ShortFrac a) = putInt16be a

putPf :: Platform -> Put
putPf (UnicodePlatform enc) = do
  putWord16be 0
  putWord16be $ case enc of
    UnicodeDefault -> 0
    UnicodeVersion1_1 -> 1
    ISO_10646 -> 2
    UnicodeBmpOnly -> 3
    UnicodeNonBmp -> 4
    UnicodeVariationSequences -> 5
    FullCoverage -> 10

putPf (MacintoshPlatform scriptcode) = do
  putWord16be 1
  putWord16be scriptcode
putPf (MicrosoftPlatform enc) = do
  putWord16be 3
  putWord16be $ case enc of
    MSSymbol -> 0
    MSUcs2 -> 1
    ShiftJIS -> 2
    PRC -> 3
    BigFive -> 4
    Johab -> 5
    MSUcs4 -> 6

toPf :: Word16 -> Word16 -> Either String Platform
toPf 0 enc = UnicodePlatform <$>
  case enc of
    0 -> Right UnicodeDefault
    1 -> Right UnicodeVersion1_1
    2 -> Right ISO_10646
    3 -> Right UnicodeBmpOnly
    4 -> Right UnicodeNonBmp
    5 -> Right UnicodeVariationSequences
    10 -> Right FullCoverage
    _ -> Left $ "unknown unicode encoding ID: " ++ show enc

toPf 1 enc = Right $ MacintoshPlatform enc

toPf 3 enc = MicrosoftPlatform <$>
  case enc of
    0 -> Right MSSymbol
    1 -> Right MSUcs2
    2 -> Right ShiftJIS
    3 -> Right PRC
    4 -> Right BigFive
    5 -> Right Johab
    6 -> Right MSUcs4
    _ -> Left $ "unknown microsoft encoding ID: " ++ show enc

toPf j _ = Left $ "unknown platformID " ++ show j

index16 :: Strict.ByteString -> Word16 -> Either String Word16
index16 bs i
  | Strict.length bs < fromIntegral ((i+1)*2) ||
    i < 0 = Left $ "Index " ++ show i ++ " out of Bounds"
  | otherwise = Right $ b1 * 256 + b2
  where
    b1, b2 :: Word16
    b1 = fromIntegral $ unsafeIndex bs (fromIntegral $ i*2)
    b2 = fromIntegral $ unsafeIndex bs (fromIntegral $ i*2 + 1)

index32 :: Strict.ByteString -> Word32 -> Either String Word32
index32 bs i
  | Strict.length bs < fromIntegral ((i+1)*4) ||
    i < 0 = Left $ "Index " ++ show i ++ " Out of Bounds"
  | otherwise = Right $ b1 `shift` 24 .|. b2 `shift` 16 .|. b3 `shift` 8 .|. b4
  where
    b1, b2, b3, b4 :: Word32
    b1 = fromIntegral $ unsafeIndex bs (fromIntegral $ i*4)
    b2 = fromIntegral $ unsafeIndex bs (fromIntegral $ i*4 + 1)
    b3 = fromIntegral $ unsafeIndex bs (fromIntegral $ i*4 + 2)
    b4 = fromIntegral $ unsafeIndex bs (fromIntegral $ i*4 + 3)

