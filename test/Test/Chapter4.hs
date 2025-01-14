{-# OPTIONS_GHC -Wno-type-defaults #-}

{-# LANGUAGE TypeApplications #-}

module Test.Chapter4
    ( chapter4
    ) where

import Test.Hspec (Spec, describe, it, shouldBe)

import Chapter4


chapter4 :: Spec
chapter4 = describe "Chapter4" $ do
    chapter4normal
    chapter4advanced

chapter4normal :: Spec
chapter4normal = describe "Chapter4Normal" $ do
    describe "Task2: Functor for Secret" $ do
        let trap = Trap "it's a trap"
        it "doesn't affect trap" $
            fmap @(Secret String) @Bool not trap `shouldBe` trap
        it "change reward, same type" $
            fmap @(Secret String) @Bool not (Reward False) `shouldBe` Reward True
        it "change reward, other type" $
            fmap @(Secret String) @Int even (Reward 5) `shouldBe` Reward False
        it "change reward, other type" $
            fmap @(Secret String) @Int even (Reward 4) `shouldBe` Reward True
    describe "Task3: Functor for List" $ do
        let list = Cons 1 $ Cons 2 Empty
        it "f <$> empty" $
            fmap @List @Int (+1) Empty `shouldBe` Empty
        it "change content, same type" $
            fmap @List @Int (+1) list `shouldBe` (Cons 2 $ Cons 3 Empty)
        it "change content, other type" $
            fmap @List @Int even list `shouldBe` (Cons False $ Cons True Empty)
        it "identity law" $
            fmap id list `shouldBe` list
        it "composition law" $
            fmap ((*2) .  (+1)) list `shouldBe` (fmap (*2) . fmap (+1)) list
    describe "Task4: Applicative for Secret" $ do
        let trap :: Secret String Int
            trap = Trap "it's a trap"
        it "pure int" $
            pure @(Secret String) "x" `shouldBe` Reward "x"
        it "pure bool" $
            pure @(Secret String) False `shouldBe` Reward False
        it "trap <*> reward" $
            Trap "it's a trap" <*> Reward 42 `shouldBe` trap
        it "trap <*> trap" $
            Trap "it's a trap" <*> Trap "42" `shouldBe` trap
        it "reward <*> trap" $
            Reward not <*> Trap 42 `shouldBe` Trap 42
        it "reward <*> reward - same type" $
            Reward not <*> Reward True `shouldBe` (Reward False :: Secret String Bool)
        it "reward <*> reward" $
            Reward odd <*> Reward 42 `shouldBe` (Reward False :: Secret String Bool)
    describe "Task5: Applicative for List" $ do
        let list = Cons 1 $ Cons 2 Empty
        it "pure int" $
            pure @List @Int 42 `shouldBe` Cons 42 Empty
        it "pure bool" $
            pure @List @Bool False `shouldBe` Cons False Empty
        it "empty <*> nonempty" $
            Empty <*> list `shouldBe` (Empty :: List Int)
        it "nonempty <*> empty" $
            Cons (+1) Empty <*> Empty `shouldBe` Empty
        it "nonempty <*> nonempty" $
            Cons (+1) (Cons (*2) Empty) <*> list `shouldBe` (Cons 2 $ Cons 3 $ Cons 2 $ Cons 4 Empty)
    describe "Task6: Monad for Secret" $ do
        it "Trap" $ (Trap "aaar" >>= halfSecret) `shouldBe` Trap "aaar"
        it "Reward even" $ (Reward 42 >>= halfSecret) `shouldBe` Reward 21
        it "Reward odd" $ (Reward 11 >>= halfSecret) `shouldBe` Trap "it's a trap"

chapter4advanced :: Spec
chapter4advanced = describe "Chapter4Advanced" $
    describe "Task 8*: Before the Final Boss" $ do
        it "Nothing - Nothing" $ andM Nothing Nothing `shouldBe` Nothing
        it "Nothing - Just" $ andM Nothing (Just True) `shouldBe` Nothing
        it "Just True - Nothing" $ andM (Just True) Nothing `shouldBe` Nothing
        it "Just False - Nothing" $ andM (Just False) Nothing `shouldBe` Just False
        it "Just - Just : False" $ andM (Just True) (Just False) `shouldBe` Just False
        it "Just - Just : True" $ andM (Just True) (Just True) `shouldBe` Just True

halfSecret :: Int -> Secret String Int
halfSecret n
    | even n = Reward (div n 2)
    | otherwise = Trap "it's a trap"
