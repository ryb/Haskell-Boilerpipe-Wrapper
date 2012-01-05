module Text.HTML.Boilerpipe (boilerpipe, boilerpipeFromJarPath) where

import System.Cmd
import System.Exit
import System.IO
import System.IO.Temp
import Paths_Boilerpipe
import qualified System.IO.Strict as Strict

boilerpipeFromJarPath :: FilePath -> String -> IO (Maybe String)
boilerpipeFromJarPath boilerpipePath txt = do
    withSystemTempFile "htmlinput.txt" $ \inPath inHandle -> do
        withSystemTempFile "textoutput.txt" $ \outPath outHandle -> do
            hSetEncoding inHandle utf8
            hSetEncoding outHandle utf8
            hPutStr inHandle txt
            r <- rawSystem "java" ["-jar", boilerpipePath, inPath, outPath]
            case r of
                ExitSuccess -> Strict.hGetContents outHandle >>=
                    \t -> return $ Just t
                ExitFailure _ -> return Nothing

boilerpipe :: String -> IO (Maybe String)
boilerpipe txt = do
    defaultJarPath <- getDataFileName
        "boilerpipe-core/dist/boilerpipe-1.1-dev.jar"
    boilerpipeFromJarPath defaultJarPath txt