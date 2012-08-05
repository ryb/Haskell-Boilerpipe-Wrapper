module Text.HTML.Boilerpipe (boilerpipe, boilerpipeFromJarPath) where

import System.Cmd
import System.Exit
import System.FilePath
import System.IO
import System.IO.Temp
import System.UUID.V4
import Paths_Boilerpipe
import qualified System.IO.Strict as Strict

boilerpipeFromJarPath :: FilePath -> String -> IO (Maybe String)
boilerpipeFromJarPath boilerpipePath txt = do
    withSystemTempDirectory "boilerpipe" $ \tempDirPath -> do
        inPath <- fmap ((tempDirPath </>) . show) uuid
        outPath <- fmap ((tempDirPath </>) . show) uuid
        withFile inPath WriteMode $ \h -> do
            hSetEncoding h utf8
            hPutStr h txt
        r <- rawSystem "java" ["-jar", boilerpipePath, inPath, outPath]
        case r of
            ExitSuccess -> withFile outPath ReadMode $ \h -> do
                hSetEncoding h utf8
                t <- Strict.hGetContents h
                return $ Just t
            ExitFailure _ -> return Nothing

boilerpipe :: String -> IO (Maybe String)
boilerpipe txt = do
    defaultJarPath <- getDataFileName
        "boilerpipe-core/dist/boilerpipe-1.1-dev.jar"
    boilerpipeFromJarPath defaultJarPath txt
