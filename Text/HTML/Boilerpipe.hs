module Text.HTML.Boilerpipe (boilerpipe, boilerpipeFromJarPath) where

import Codec.Text.IConv
import Data.ByteString.Lazy.UTF8 (fromString, toString)
import System.Cmd
import System.Exit
import System.IO
import System.IO.Temp
import Paths_Boilerpipe
import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BL

toUtf8 = toString . convert "LATIN1" "UTF-8" . toLazyByteString

toLazyByteString bs = BL.fromChunks [bs]
toStrictByteString bs = BS.concat $ BL.toChunks bs

boilerpipeFromJarPath :: FilePath -> String -> IO (Maybe String)
boilerpipeFromJarPath boilerpipePath txt = do
    withSystemTempFile "htmlinput.txt" $ \inPath inHandle -> do
        withSystemTempFile "textoutput.txt" $ \outPath outHandle -> do
            hSetEncoding inHandle utf8
            hSetEncoding outHandle latin1
            hPutStr inHandle txt
            r <- rawSystem "java" ["-jar", boilerpipePath, inPath, outPath]
            case r of
                ExitSuccess -> BS.hGetContents outHandle >>=
                    \t -> return $ Just $ toUtf8 t
                ExitFailure _ -> return Nothing

boilerpipe :: String -> IO (Maybe String)
boilerpipe txt = do
    defaultJarPath <- getDataFileName
        "boilerpipe-core/dist/boilerpipe-1.1-dev.jar"
    boilerpipeFromJarPath defaultJarPath txt