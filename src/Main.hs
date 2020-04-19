module Main where

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

import Discord
import Discord.Types
import Discord.Requests as DR
import System.Environment (getEnv)

import ProcessMessage (processMsg)

cmdPrefix :: T.Text
cmdPrefix = T.pack "dm "

main :: IO ()
main = botMain

-- | The main function that initializes the bot
botMain :: IO ()
botMain = do
  tokenStr <- getEnv "DISCORD_BOT_TOKEN"
  let token = T.pack tokenStr
  t <- runDiscord $ def 
    { discordToken = token
    , discordOnStart = handlerOnReady
    , discordOnEnd = putStrLn "Bot shut down"
    , discordOnEvent = handlerOnEvent
    , discordOnLog = \txt -> TIO.putStrLn txt
    }
  TIO.putStrLn t

handlerOnReady :: DiscordHandle -> IO ()
handlerOnReady dis = do
  Right user <- restCall dis DR.GetCurrentUser
  TIO.putStrLn $ (T.pack "Noglobot Haskell.\nLogged on as ") <> userName user
  pure ()

handlerOnEvent :: DiscordHandle -> Event -> IO ()
handlerOnEvent dis event = case event of 
  MessageCreate m -> onMessageCreate dis m
  _ -> pure ()

onMessageCreate :: DiscordHandle -> Message -> IO ()
onMessageCreate dis m = 
  if userIsBot (messageAuthor m) then pure () 
  else processMsg (dis, m) cmdPrefix