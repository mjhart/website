{-# LANGUAGE OverloadedStrings #-}

--------------------------------------------------------------------------------

import Data.Monoid ((<>), mappend)
import Hakyll

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler
  match "css/*" $ do
    route idRoute
    compile compressCssCompiler
  match "about.md" $ do
    route $ setExtension "html"
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls
  match "projects.md" $ do
    route $ setExtension "html"
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" defaultContext
        >>= relativizeUrls
  match "posts/*" $ do
    route $ setExtension "html"
    compile $
      pandocCompiler
        >>= loadAndApplyTemplate "templates/post.html" postCtx
        >>= saveSnapshot "content"
        >>= loadAndApplyTemplate "templates/default.html" postCtx
        >>= relativizeUrls
  create ["archive.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts)
              <> constField "title" "Archives"
              <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls
  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let indexCtx =
            listField "posts" postCtx (return posts)
              <> constField "title" "Home"
              <> defaultContext
      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls
  match "templates/*" $ compile templateBodyCompiler
  create ["rss.xml"] $ do
    route idRoute
    compile $ do
      let feedCtx = postCtx `mappend` bodyField "description"
      posts <- loadAllSnapshots "posts/*" "content" >>= fmap (take 10) . recentFirst
      renderRss feedConfiguration feedCtx posts

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
  dateField "date" "%B %e, %Y"
    <> defaultContext

feedConfiguration :: FeedConfiguration
feedConfiguration =
  FeedConfiguration
    { feedTitle = "Matt Hart's Blog",
      feedDescription = "Thoughts on writing better software.",
      feedAuthorName = "Matt Hart",
      feedAuthorEmail = "matthart4@gmail.com",
      feedRoot = "https://mjhart.netlify.app"
    }
