{-# LANGUAGE DeriveDataTypeable, ScopedTypeVariables #-}

module Main where

import           System.Console.CmdArgs
import           System.FilePath
import qualified Control.Exception      as CE
import           Data.Maybe
import           Control.Monad

data Args = Args {
  data_path  :: FilePath,
  output    :: FilePath
} deriving (Eq, Show, Typeable, Data)

defaultArgs :: Args
defaultArgs = Args {
  data_path = "Data"
  &= typDir
  &= help "Input data directory. If a file called CURRENT_DATA exists in the directory, the contents of that file will be appended to the path. Default: Data"
  ,
  output = "Entry.csv"
  &= typFile
  &= help "Output data file. Default: Entry.csv"
}

main :: IO ()
main = do
  Args {data_path = dataPathArg,
        output = entryFile} <- cmdArgs $ defaultArgs
    &= program "hpn"
    &= summary "hpn v0.1"
  
  putStrLn $! "dataPathArg: " ++ dataPathArg
  putStrLn $! "entryFile: " ++ entryFile
  
  dataPath <- realDataPath dataPathArg
  putStrLn $! "dataPath: " ++ dataPath
  
  where realDataPath path = do
          dataPath <- getDataPath path
          return $! path </> fromMaybe "" dataPath
        getDataPath path = CE.catch (Just `liftM` (readFile $! path </> "CURRENT_DATA"))
                                    (\(_ :: IOError) -> return Nothing)