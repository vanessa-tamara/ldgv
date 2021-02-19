module ArithmeticSpec (spec) where
import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)

import Parsing
import qualified Tokens as T
import qualified Grammar as G
import Syntax
import Kinds

spec :: Spec
spec = 
  describe "LDGV parser arithmetic tests" $ do
    it "parses an addition" $ do
      parse "val f (m:Int) (n:Int) = m + n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Add (Var "m") (Var "n"))
         Nothing]

    it "parses a subtraction" $ do
      parse "val f (m:Int) (n:Int) = m - n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Sub (Var "m") (Var "n"))
         Nothing]

    it "parses a negation" $ do
      parse "val f (m:Int) (n:Int) = - n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Neg (Var "n"))
         Nothing]

    it "parses a negation with multiplication" $ do
      parse "val f (m:Int) (n:Int) = - 2 * n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Neg (Math $ Mul (Lit $ LNat 2) (Var "n")))
         Nothing]

    it "parses a negation with subtraction" $ do
      parse "val f (m:Int) (n:Int) = - 2 - n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Sub (Math $ Neg (Lit $ LNat 2)) (Var "n"))
         Nothing]

    it "parses a double negation" $ do
      parse "val f (m:Int) (n:Int) = - - n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Neg (Math $ Neg (Var "n")))
         Nothing]

    it "parses precedence of multiplication left over subtraction" $ do
      parse "val f (m:Int) (n:Int) = m - 2 * n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Sub (Var "m") (Math $ Mul (Lit $ LNat 2) (Var "n")))
         Nothing]

    it "parses precedence of multiplication right over subtraction" $ do
      parse "val f (m:Int) (n:Int) = m * 2 - n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)]
         (Math $ Sub (Math $ Mul (Var "m") (Lit $ LNat 2)) (Var "n"))
         Nothing]

    it "parses a division" $ do
      parse "val f (m:Int) (n:Int) = m / n" `shouldBe`
        [DFun "f" [(MMany,"m",TInt),(MMany,"n",TInt)] (Math $ Div (Var "m") (Var "n")) Nothing]
