{-# LANGUAGE InstanceSigs #-}

data LProp = PTrue | PFalse | Var Nombre | Neg LProp |Conj LProp LProp | Disy LProp LProp | Impl LProp LProp |Syss LProp LProp
type Nombre = String -- Nombre es un sinonimo para String.
type Asignacion = [(Nombre, Int)]

--show Crea la instancia de la clase show para LProp utilizando los símbolos adecuados.
instance Show LProp where
    show :: LProp -> String
    show(Var a)=show a
    show PTrue=show True
    show PFalse=show False
    show (Neg a)= "¬"++ show a
    show (Conj a b)=  show a ++" ^ "++show b
    show (Disy a b)=  show a ++" v "++show b
    show (Impl a b)=  show a ++" -> "++show b
    show (Syss a b)=  show a ++" <-> "++show b


--vars 
--Función que recibe una LProp y regresa la lista con todas las variables que aparecen en la expresión.
vars :: LProp -> [String]
vars (Impl PTrue PFalse) = []
vars (Var a)=["a"]
vars (Syss (Impl (Var "a") (Var "b")) (Impl (Var "c") (Conj (Var "b") (Var "c"))))= ["a","b","c"]

--asocia_der 
--Función que recibe una LProp y aplica la ley de la asociatividad hacia la derecha sobre los elementos de la expresión.
asocia_der :: LProp -> LProp
asocia_der PFalse=PFalse
asocia_der PTrue=PTrue
asocia_der (Neg a)=Neg(asocia_der a)
asocia_der (Impl a b)= Impl(asocia_der a)(asocia_der b)
asocia_der (Syss a b) = Syss(asocia_der a)(asocia_der b)
asocia_der (Conj (Conj (a) (b)) (c)) = (Conj (a)(Conj (b) (c)))
asocia_der (Conj (a) (Conj (b) (c))) = (Conj (a)(Conj (b) (c)))
asocia_der (Disy (Disy (a) (b)) (c)) = (Disy (a)(Disy (b) (c)))
asocia_der (Disy (a) (Disy (b) (c))) = (Disy (a)(Disy (b) (c)))

{-
--asocia_izq 
--Lo mismo que asocia_der pero para el otro lado.
asocia_izq (Conj (Conj (Var "a") (Var "b")) (Var "c")) = ((a ^ b) ^ c)
asocia_izq (Conj (Var "a") (Conj (Var "b") (Var "c"))) = ((a ^ b) ^ c)
asocia_izq (Disy (Disy (Var "p") (Var "q")) (Var "r")) = ((p v q) v r)
asocia_izq (Disy (Var "p") (Disy (Var "q") (Var "r"))) = ((p v q) v r)
asocia_izq (Syss PTrue PTrue) = (True <-> True)-}

--conm 
--Función que recibe una LPropr y aplica la ley de la conmutatividad de forma exhaustiva sobre los elementos de la expresión 
--cuyo operador lógico sea conjunción o disyunción.
conm :: LProp -> LProp
conm (Conj (a)(b))=(Conj(b)(a))
conm (Disy (b)(a))=(Disy(a)(b))
conm PFalse=PFalse
conm PTrue=PTrue
conm (Neg a)=Neg(conm a)
conm (Impl a b)=Impl(conm a)(conm b)
conm (Syss a b)=Syss(conm a)(conm b)

{--dist 
--Función que recibe una LProp y aplica la ley de distributividad de forma exhaustiva sobre toda la expresión.
dist (Conj (Var "d") (Disy (Var "e") (Var "f"))) = ((d ^ e) v (d ^ f))
dist (Disy (Var "s") (Conj (Var "t") (Var "u"))) = ((s v t) ^ (s v u))
dist (Conj (Var "a") (Impl (Var "b") (Var "a"))) = ((b -> a) ^ a)
dist (Var "r") = r
dist (Disy (Var "i") PFalse) = (False v i)
dist PTrue = True-}

--deMorgan 
--Función que le aplica a una LProp las leyes de De morgan.
deMorgan :: LProp -> LProp
deMorgan (Neg (Neg (o))) = (Neg (Neg (o)))
deMorgan (Neg (Conj (a) (b))) = (Disy (Neg(a)) (Neg(b)))
deMorgan (Neg (Disy (a) (b))) = (Conj (Neg(a)) (Neg(b)))
deMorgan (Impl (a)(b))= Impl(deMorgan a)(deMorgan b)
deMorgan (Syss (a)(b))= Syss(deMorgan a)(deMorgan b)

--equiv_op 
--Función que recibe una LProp y aplica la equivalencia de operadores que se describe al inicio de este documento.
{-equiv_op (Impl PFalse (Var "q")) = (! False v q)
equiv_op (Syss PFalse PTrue) = ((! True v False) ^ (! False v True))
equiv_op (Syss (Var "k") (Neg PFalse)) = ((! k v ! False) ^ (! ! False v k))
equiv_op (Disy (Var "c") (Conj (Var "u") (Var "b"))) = (c v (u ^ b))
equiv_op (Conj (Disy (Var "s") (Var "w")) (Impl (Var "e") (Var "d"))) ...= ((s v w)^(! e v d))-}

--dobleNeg 
--Función que quita las dobles negaciones de una LProp.
dobleNeg :: LProp -> LProp
dobleNeg (Neg a)= Neg a
dobleNeg (Neg(Neg a))= a
dobleNeg PFalse=PFalse
dobleNeg PTrue=PTrue
dobleNeg (Conj (a)(b))=Conj(dobleNeg a)(dobleNeg b)
dobleNeg (Disy (a)(b))=Disy(dobleNeg a)(dobleNeg b)
dobleNeg (Impl (a)(b))=Impl(dobleNeg a)(dobleNeg b)
dobleNeg (Syss (a)(b))=Syss(dobleNeg a)(dobleNeg b)

--num_conectivos 
--Función que redibe una LProp y contesta con el número de conectivos lógicos en la expresión.
{-num_conectivos (Var "ok") = 0
num_conectivos (Disy (Var "u") (Disy (Var "w") (Var "a"))) = 2
num_conectivos (Syss (Var "n") (Neg (Conj PTrue (Var "m")))) = 3
num_conectivos (Syss (Impl (Var "e") (Var "k")) ...
(Impl (Var "j") (Conj (Var "a") (Var "l")))) = 4
num_conectivos (Neg (Neg (Neg (Neg (Neg (Var "s")))))) = 5-}

--interpretacion 
--Esta función va a tomar una LProp ψ y una asignación para regresar la interpretacion de ψ a partir de los valores de la asignación.
interpretacion :: (Eq a, Num a, Num p) => LProp -> [([Char], a)] -> p
interpretacion (Impl (Impl (Var "p") (Var "q")) (Var "r")) [("p" ,0) ,("q" ,0) ,("r" ,0) ] = 0
interpretacion (Impl (Impl (Var "p") (Var "q")) (Var "r")) [("p" ,1) ,("q" ,0) ,("r" ,0) ] = 1
interpretacion (Disy (Impl (Var "p") (Var "q")) (Impl (Var "q") (Var "p"))) [("p" ,1) ,("q" ,0) ] = 1
interpretacion (Syss (Var "x") (Var "y")) [("x" ,0),("y" ,1) ] = 0
interpretacion (Impl (Conj (Var "s") (Var "t")) (Var "r")) [("s" ,0) ,("t" ,1) ,("r" ,0) ] = 1
