module Projekt.Algorithmen.SFreeFactorization
  (sff
  ) where
import Projekt.Core.FiniteFields
import Projekt.Core.Polynomials

{-
 - from: http://en.wikipedia.org/wiki/Factorization_of_polynomials_over_finite_fields

  Algorithm: SFF (Square-Free Factorization)
  Input: A monic polynomial f in Fq[x]
  Output: Square-free factorization of f

  i←1; R ← 1; g ← f′;
  if g ≠ 0 then {
     c ← gcd(f, g);
     w ← f/c;
     while w ≠ 1 do {
         y ← gcd(w, c); z ← w/y;
         R ← R·z^i; i ← i+1;
         w ← y; c ← c/y }
     if c ≠ 1 then {
         c ← c^1/p;
         Output(R·SFF(c)^p) }
     else Output(R)
  else {
     f ← f^1/p;
     Output(SFF(f)^p) }
  end
 -}
sff :: FiniteField a => Polynom a -> [Polynom a]
sff f = undefined

sff' :: (FiniteField a, Num a, Fractional a) => Polynom a -> [(Int,Polynom a)]
sff' f = undefined

shiftTupple i (n,x) = (n+i,x)
shiftTupples i = map (shiftTupple i)

pThPower :: FiniteField a => [Polynom a] -> [Polynom a]
pThPower = undefined

pThRoot :: FiniteField a => Polynom a -> Polynom a
pThRoot = charRootP

{-
sff' :: (FiniteField a, Num a, Fractional a) => Polynom a -> [(Int,Polynom a)]
sff' f = undefined
  where df = deriveP f
        loop c r w i | w  /= 1    = loop (fst $ divP c y)
                                        (shiftP i r)
                                        y
                                        (i+1)
                     | otherwise = (r,c)
          where y = ggTP w c
        c          = ggTP f df
        (r',c')    = loop c (P[1]) (fst $ divP f c) 1
 -}

{-
sff' f | df == 0    = pThPower $ sff (pThRoot f)
       | c == 1     = undefined
       | otherwise = undefined
  where df = deriveP f
        c  = ggTP f df -- Hier fehlt noch der Durchgang durch die While Schleife
        w  = fst $ divP f c
 -}

-- |simmuliert das '^p', indem in das Array manipuliert wird
spreadByP :: Mod a => [a] -> [a]
spreadByP = undefined
{-
spreadByP []     = []
spreadByP (m:ms) = m : [0|i<-[1..(modulus m - 1)]] ++ spreadByP ms
 -}

{-
 - Beispiel in F3[x]:
 -      f = X¹¹+2x⁹+2x⁸+x⁶+x⁵+2x³+2x²+1
 -        = (x+1)(x²+1)³(x+2)⁴
 -}
f=P[1::F3,0,2,2,0,1,1,0,2,2,0,1]
sqf=[P[1::F3,1]
    ,P[1::F3,0,1]
    ,P[]
    ,P[2::F3,1]]

testSFF = sff f == sqf
