module Projekt.Core.Matrix
{-
  ( Matrix (..), genDiagM
  -- tests
  , isQuadraticM, isValidM
  -- getter
  , atM, getNumRowsM, getNumColsM, (!|), (!-)
  -- operations
  , swapRowsM, swapColsM, (<|>), (<-->), transposeM
  -- linear algebra
  , triangularM, detM
  )
 -}
  where
import Data.List
import Data.Array
import Data.Array.IArray (amap)

import Projekt.Core.ShowTex
import Debug.Trace

--------------------------------------------------------------------------------
--  Data Definition

data Matrix a = M {unM :: Array (Int, Int) a} | Mdiag a

--------------------------------------------------------------------------------
--  Basics

getAllIdxs n m = concat [[(i,j) | i <- [1..n]] | j <- [1..m]]
getAllIdxsExcept n m idxs = [idx | idx <- getAllIdxs n m
                                 , idx `notElem` idxs]
fillList ls n m = ls ++ [(idx,0) | idx <- getAllIdxsExcept n m idxs]
  where idxs = map fst ls


isQuadraticM :: Matrix a -> Bool
sQuadraticM (Mdiag a) = True
isQuadraticM (M m) = uncurry (==) b
  where b = snd $ bounds m

genDiagM :: (Num a) => a -> Int -> Matrix a
genDiagM x n = M $ array ((1,1),(n,n)) $ fillList [((i,i),x) | i <- [1..n]] n n


--------------------------------------------------------------------------------
--  Instanzen

instance Show a => Show (Matrix a) where
  show (Mdiag a) = "diag(" ++ show a ++ "…" ++ show a ++ ")"
  show (M m)     = unlines [concatMap (++ " ") [show (m!(i,j))
                                                | j <- [1..(snd b)]]
                             | i <- [1..(fst b)]]
    where b = snd $ bounds m

{-
instance (ShowTex a,Eq a) => ShowTex (Matrix a) where
  showTex (M [])    = ""
  showTex (M [[]])  = ""
  showTex (Mdiag a) = "[" ++ showTex a ++ "]"
  showTex (M m)     = "\\begin{pmatrix}" ++ showTex' m ++ "\\end{pmatrix}"
    where showTex'         = concatMap ((++ "\\\\") . showTex'')
          showTex'' (x:xs) = (showTex x ++) $ concatMap (('&':) . showTex) xs
 -}

instance (Eq a, Num a) => Eq (Matrix a) where
  Mdiag x == m = genDiagM x (getNumRowsM m) == m
  m == Mdiag x = m == genDiagM x (getNumRowsM m)
  M a == M b   = a == b

instance (Num a, Eq a) => Num (Matrix a) where
  x + y         = addM x y
  x * y         = multM x y
  fromInteger i = Mdiag (fromInteger i)
  abs _         = error "Prelude.Num.abs: inappropriate abstraction"
  signum _      = error "Prelude.Num.signum: inappropriate abstraction"
  negate        = negateM

addM :: (Num a) => Matrix a -> Matrix a -> Matrix a
addM (Mdiag x) (Mdiag y) = Mdiag (x+y)
addM (Mdiag x) m         = addM m (genDiagM x (getNumRowsM m))
addM m         (Mdiag y) = addM m (genDiagM y (getNumRowsM m))
addM (M x)     (M y)     | test      = M $ array (bounds x)
    [(idx,x!idx + y!idx) | idx <- indices x]
                         | otherwise = error "not the same Dimensions"
  where test      = bounds x == bounds y

negateM :: (Num a) => Matrix a -> Matrix a
negateM (Mdiag x) = Mdiag $ negate x
negateM (M m)     = M $ amap negate m

multM :: (Num a) => Matrix a -> Matrix a -> Matrix a
multM (Mdiag x) (Mdiag y) = Mdiag (x*y)
multM (Mdiag x) m         = multM m (genDiagM x (getNumRowsM m))
multM  m        (Mdiag x) = multM m (genDiagM x (getNumRowsM m))
multM (M m)     (M n)     | k' == l    = M $ array ((1,1),(k,l'))
    [((i,j), sum [m!(i,k) * n!(k,j) | k <- [1..l]]) | i <- [1..k] , j <- [1..l']]
                          | otherwise = error "not the same Dimensions"
  where ((_,_),(k,l))   = bounds m
        ((_,_),(k',l')) = bounds n


{-
-- 'concat' matrices horizontally
(<|>) :: Matrix a -> Matrix a -> Matrix a
(<|>) (M m1) (M m2) | test      = M [ m1 !! i ++ m2 !! i | i <- [0..(n-1)] ]
                    | otherwise = error "not same row count"
  where test = getNumRowsM (M m1) == getNumRowsM (M m2)
        n    = getNumRowsM (M m1)

-- 'concat' matrices vertically
(<-->) :: Matrix a -> Matrix a -> Matrix a
(<-->) (M m1) (M m2) | test      = M $ m1 ++ m2
                   | otherwise = error "not same column count"
  where
    test = getNumColsM (M m1) == getNumColsM (M m2)
 -}

--------------------------------------------------------------------------------
--  Getter

atM :: Matrix a -> Int -> Int -> a
atM (M m) row col = m!(row,col)

getNumRowsM :: Matrix a -> Int
getNumRowsM (M m) = fst $ snd $ bounds m

getNumColsM :: Matrix a -> Int
getNumColsM (M m) = snd $ snd $ bounds m

{-
-- get column
(!|) :: Matrix a -> Int -> [a]
(!|) (M m) n  = [m !! i !! n | i <- [0..r-1]]
  where r = getNumRowsM $ M m

-- get row
(!-) :: Matrix a -> Int -> [a]
(M m) !- n  = m !! n

-- get rows
(!!-) :: Matrix a -> [Int] -> Matrix a
(M m) !!- ns  = M [m !! i | i <- ns]

-- get columns
(!!|) :: Matrix a -> [Int] -> Matrix a
(!!|) (M m) ns  = M [[m !! i !! j | j <- ns] | i <- [0..r-1]]
  where r = getNumRowsM $ M m
-}

--------------------------------------------------------------------------------
--  Funktionen auf Matrizen

-- |Transponiere eine Matrix
transposeM :: Matrix a -> Matrix a
transposeM (Mdiag a) = Mdiag a
transposeM (M m)     = M $ ixmap (bounds m) (\(x,y) -> (y,x)) m

{-
-- |Vertausche zwei Zeilen einer Matrix
swapRowsM :: Matrix a -> Int -> Int -> Matrix a
swapRowsM m r1 r2 = M $ swapItems (unM m) r1 r2

-- |Vertausche zwei Spalten einer Matrix
swapColsM :: Matrix a -> Int -> Int -> Matrix a
swapColsM m r1 r2 = M $ map (\x -> swapItems x r1 r2) $ unM m

swapItems :: [a] -> Int -> Int -> [a]
swapItems ls r1 r2 = [get k x | (x,k) <- zip ls [0..]]
    where get k x | k == r1 = ls !! r1
                  | k == r1 = ls !! r2
                  | otherwise = x

triangularM :: (Eq a, Fractional a) => Matrix a -> Matrix a
triangularM (Mdiag m) = Mdiag m
triangularM (M m)     = M $ triangular' 0 m
  where triangular' n [] = []
        triangular' n m' = row : triangular' (n+1) rows'
          where (row:rows) = pivotAndSwap n m'
                rows'      = map eval rows
                eval rs    | (rs !! n) == 0 = rs
                           | otherwise     = zipWith (-) (map (*c) rs) row
                  where c = (row !! n) / (rs !! n)

        pivotAndSwap :: (Eq a, Num a) => Int -> [[a]] -> [[a]]
        pivotAndSwap n (row:rows)
          | (row !! n) /= 0
            || null rows
            || all (==True) (map (all (==0)) rows) = row:rows
          | otherwise                            = pivotAndSwap n (rows ++ [row])

{-fulltriangularM :: (Eq a, Fractional a) => Matrix a -> Matrix a-}
{-fulltriangularM  = backtrackM . triangularM-}

-- backtrack an upper triangular Matrix a
{-backtrackM :: (Eq a, Fractional a) => Matrix a -> Matrix a-}
{-backtrackM (M m)  = M $ backtrack' m-}
  {-where backtrack' [] = []-}
        {-backtrack' as = (backtrack' (init $ eval as)) ++ (last eval as)-}
          {-where eval as = undefined -- | f == Nothing   =  as-}
                        {-| otherwise     =  undefined map (zipWith (-) $ map (/f) l) as-}
              {-where l = last as-}
                {-f = find (/=0) l-}

detM :: (Eq a, Fractional a) => Matrix a -> a
detM (Mdiag 0) = 0
detM (Mdiag 1) = 1
detM (Mdiag _) = error "Not enougth information given"
detM m         | isQuadraticM m =
                  product [atM (triangularM m) i i | i <- [0..(getNumRowsM m -1)]]
               | otherwise      = error "Matrix not quadratic"

{-invM :: (Eq a, Fractional a) => Matrix a -> Matrix a-}
  {-invM m | !isQuadraticM m  = error "Matrix not quadratic"-}
         {-| -}

{-
-- |Berechne die Determinante ohne nutzen von Fractional a
altDetM :: (Eq a) => Matrix a -> a
altDetM = undefined
 -}
 -}
