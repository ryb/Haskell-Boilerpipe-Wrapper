module Text.HTML.Boilerpipe (boilerpipe, boilerpipeFromJarPath) where

import Data.ByteString (ByteString)
import System.Cmd
import System.Process
import System.Exit
import System.FilePath
import System.IO
import System.IO.Temp
import System.UUID.V4
import Paths_Boilerpipe
import qualified Data.ByteString as BS
import qualified System.IO.Strict as Strict

boilerpipeFromJarPath :: FilePath -> ByteString -> IO (Maybe ByteString)
boilerpipeFromJarPath boilerpipePath txt = do
    withSystemTempDirectory "boilerpipe" $ \tempDirPath -> do
        inPath <- fmap ((tempDirPath </>) . show) uuid
        outPath <- fmap ((tempDirPath </>) . show) uuid
        withFile inPath WriteMode $ \h -> do
            BS.hPutStr h txt
        r <- rawSystem "java" ["-jar", boilerpipePath, inPath, outPath]
        case r of
            ExitSuccess -> withFile outPath ReadMode $ \h -> do
                t <- BS.hGetContents h
                return $ Just t
            ExitFailure _ -> return Nothing

boilerpipe :: ByteString -> IO (Maybe ByteString)
boilerpipe txt = do
    defaultJarPath <- getDataFileName
        "boilerpipe-core/dist/boilerpipe-1.2-dev.jar"
    boilerpipeFromJarPath defaultJarPath txt
