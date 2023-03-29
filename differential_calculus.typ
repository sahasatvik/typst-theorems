#import "theorems.typ": *

// Define theorem environments

#let theorem = thmbox(
  "theorem",
  "Theorem",
  fill: rgb("#e8e8f8")
)
#let lemma = thmbox(
  "theorem",            // Lemmas use the same counter as Theorems
  "Lemma",
  fill: rgb("#efe6ff")
)
#let corollary = thmbox(
  "corollary",
  "Corollary",
  base: "theorem",      // Corollaries are 'attached' to Theorems
  fill: rgb("#f8e8e8")
)

#let definition = thmbox(
  "definition",         // Definitions use their own counter
  "Definition",
  fill: rgb("#e8f8e8")
)

#let exercise = thmbox(
  "exercise",
  "Exercise",
  stroke: rgb("#ffaaaa") + 1pt,
  base: none,           // Unattached: count globally
).with(numbering: "I")  // Use Roman numerals

// Examples and remarks are not numbered
#let example = thmplain("example", "Example").with(numbering: none)
#let remark = thmplain(
  "remark",
  "Remark",
  inset: 0em
).with(numbering: none)

// Proofs are attached to theorems, although they are not numbered
#let proof = thmplain(
  "proof",
  "Proof",
  base: "theorem",
  bodyfmt: body => [
    #body #h(1fr) $square$    // Insert QED symbol
  ]
).with(numbering: none)

#let solution = thmplain(
  "solution",
  "Solution",
  base: "exercise",
  inset: 0em,
).with(numbering: none)


// Template

#let project(title: "", authors: (), body) = {
  set document(author: authors, title: title)
  set text(font: "Linux Libertine", lang: "en")
  set heading(numbering: "1.1.", )
  set par(justify: true)

  show heading: it => [
    #v(1em)
    #it
  ]

  align(center)[
    #block(text(weight: 700, 1.75em, title))
    #v(2em)
  ]

  outline(fill: none, indent: true)

  body
}

// Shorthand for vectors
#let va = $bold(a)$
#let vb = $bold(b)$
#let vx = $bold(x)$
#let vy = $bold(y)$
#let vz = $bold(z)$
#let vv = $bold(v)$
#let vw = $bold(w)$
#let ve = $bold(e)$

// Mapping arrow
#let mapsto = $arrow.r.bar$

// Operators
#let grad = (x) => $nabla #x$
#let ip = (x, y) => $angle.l #x, #y angle.r$
#let pp = (x, y) => $(diff #x) / (diff #y)$
#let dd = (x, y) => $(d #x) / (d #y)$
#let Df = $D f$
#let Dg = $D g$
#let DT = $D T$


// Document starts here

#show: project.with(
  title: "Notes on Differential Calculus"
)

= Differentiability

#definition[
    Let $f : (a, b) -> RR^n$, and let $f_i = pi_i compose  f$ be its
    components. Then, $f$ is differentiable at $t_0  in  (a, b)$ if the
    following limit exists. $ 
        f'(t_0) =  lim _(h -> 0)  frac(f(t_0 + h) - f(t_0), h)  .
    $
    #remark[
        The vector $f'(t_0)$ represents the tangent to the curve $f$ at the
        point $f(t_0)$. The full tangent line is the parametric curve $f(t) +
        f'(t_0)(t - t_0)$.
    ]
]

#definition[
    Let $U  subset.eq  RR^n$ be open, and let $f: U -> RR^m$. Then, $f$ is
    differentiable at $x  in  U$ if there exists a linear transformation $
    lambda : RR^n -> RR^m$ such that $ 
         lim _(h -> 0)   frac(f(x + h) - f(x) -  lambda  h,  norm(h))  = 0.
    $ The derivative of $f$ at $x$ is denoted by $lambda  = Df(x)$.
    #remark[
        In a neighbourhood of $x$, we may approximate $ 
            f(x + h)  approx  f(x) + Df(x)(h).
        $
    ]
    #remark[
        The statement that this quantity goes to zero means that each of the
        $m$ components must also go to zero. For each of these limits, there
        are $n$ axes along which we can let $h -> 0$. As a result, we obtain
        $m times n$ limits, which allow us to identify the $m times n$
        components of the matrix representing the linear transformation
        $lambda$ (in the standard basis). These are the partial derivatives of
        $f$, and the matrix of $lambda$ is the Jacobian matrix of $f$
        evaluated at $x$.
    ]
]

#example[
    Let $T: RR^n -> RR^m$ be a linear map. By choosing $ lambda = T$, we see
    that $T$ is differentiable everywhere, with $DT(x) = T$ for every choice
    of $x  in  RR^n$. This is made obvious by the fact that the best linear
    approximation of a linear map at some point is the map itself; indeed, the
    'approximation' is exact.
]

#lemma[
    If $f: RR^n -> RR^m$ is differentiable at $x  in  RR^n$, with derivative
    $Df(x)$, then
        + $f$ is continuous at $x$.
        + The linear transformation $Df(x)$ is unique.
]
#proof[
    We prove the second part. Suppose that $lambda$, $mu$ satisfy the
    requirements for $Df(x)$; it can be shown that $ lim _(h -> 0) ( lambda  -
    mu )h \/  norm(h)  = 0$. Now, if $ lambda  v  !=   mu  v$ for some
    non-zero vector $v  in  RR^n$, then $ 
         lambda  v -  mu  v =   frac(lambda (t v) - mu(t v), norm(t v))
         dot.c norm(v) -> 0,
    $ a contradiction.
]

= Chain rule

#exercise[
    Let $T: RR^n -> RR^m$ be a linear transformation. Then, there exists $M
    > 0$ such that for all $ vx   in  RR^n$, we have $ 
         norm(T vx )   <=  M norm( vx ) .
    $
    #solution[
        Set $ vv _i = T( ve _i)$ where $ ve _i$ are the standard unit basis
        vectors of $RR^n$. Then, $ 
             norm(T vx )
             =   norm( sum _(i) x_i vv _i)
             <=  sum _(i) norm(x_i vv _i) 
             <=  max  norm( vv _i)   sum _i |x_i|.
        $  Since each $|x_i|  <=   norm( vx ) $, set $M = n max  norm( vv _i)
        $ and write $ 
             norm(T vx )
             <=  max  norm( vv _i)  sum _i |x_i|
             <=  max  norm( vv _i)  dot.c  n norm( vx )
             = M norm( vx ) .
        $
    ]
]
#theorem(name: "Chain Rule")[
    Let $f: RR^n -> RR^m$, $g: RR^m -> RR^k$ where $f$ is differentiable at $a
    in  RR^n$ and $g$ is differentiable at $f(a)  in  RR^m$.  Then, $g compose
    f$ is differentiable, with $D(g compose  f)(a) = Dg(f(a))  compose Df(a)$.
    Note that this means that the Jacobian matrices simply multiply.
]
#proof[
    Set $b = f(a)  in  RR^m$, $ lambda  = Df(a)$, $ mu  = Dg(f(a))$. Define 
    $
         phi : RR^n -> RR^m, quad   phi (x) &= f(x) - f(a) -  lambda (x
        - a), \
         psi : RR^m -> RR^k, quad   psi (y) &= g(y) - g(b) -  mu (y - b).
    $
    We claim that $ 
         lim _(x -> a) frac(g compose  f(x) - g compose  f(a) -  mu  compose   lambda (x
        - a),  norm(x - a) ) = 0.
    $  Write the numerator as $ 
        g compose  f(x) - g compose  f(a) -  mu  compose   lambda (x - a) =  psi (f(x)) +
         mu ( phi (x)).
    $  Note that $ 
         lim _(x -> a)   frac( phi (x),  norm(x - a)  )  = 0, quad
         lim _(y -> b)   frac( psi (y),  norm(y - b)  )  = 0.
    $  Thus, find $M > 0$ such that $ norm( mu ( phi (x)))   <= 
     norm( phi (x)) $ for all $x  in  RR^n$, hence $ 
         lim _(x -> a)   frac( norm( mu ( phi (x))) ,  norm(x - a)  )   <=
         lim _{x -> a}   frac(M norm( phi (x)) ,  norm(x - a)  )  = 0.
    $  Now write $ 
         lim _(f(x) -> b)   frac( psi (f(x)),  norm(f(x)  - b) )  = 0, 
    $  hence for any $ epsilon  > 0$, there is a neighbourhood of $b$ on which $ 
         norm( psi (f(x)))   <=   epsilon   norm(f(x) - b)  =  epsilon 
         norm( phi (x) +  lambda (x - a)) .
    $  Apply the triangle inequality and find $M' > 0$ such that $ 
         norm( psi (f(x)))   <= 
         epsilon  norm( phi (x))  +  epsilon  M' norm(x - a) .
    $  Thus, $ 
         lim _(x -> a)   frac( norm( psi (f(x))) ,  norm(x - a)  )   <= 
         lim _(x -> a)   frac( epsilon  norm( phi (x)) ,  norm(x - a)  )  +  epsilon 
        M' =  epsilon  M'.
    $  Since $ epsilon  > 0$ was arbitrary, this limit is zero, completing the proof.
] 


= Partial derivatives

#definition[
    Let $U  subset.eq  RR^n$ be open, and let $f: U -> RR$. The partial
    derivative of $f$ with respect to the coordinate $x_j$ at some $a  in  U$
    is defined by the following limit, if it exists. $ 
         pp(f, x_j) (a) =  lim _(h -> 0)   frac(f(a + h ve_j) - f(a), h)  .
    $  
]
#lemma[
    If $f: U -> RR$ is differentiable at a point $a  in  RR^n$, then $ 
        Df(a)(x_1,  dots , x_n) = x_1 \, pp(f, x_1) (a) +  dots  + x_n
        \, pp(f, x_n) (a).
    $  
]
#example[
    Consider $ 
        f: RR^2 -> RR,  quad  (x, y)  mapsto  cases(
             (x y) \/ (x^2 + y^2)\, & " if "  (x, y)  !=  (0, 0),
            0\, & " if "  (x, y) = (0, 0).
        )
    $  Note that $f$ is not differentiable at $(0, 0)$; it is not even continuous
    there. However, both partial derivatives of $f$ exist at $(0, 0)$.
]

#lemma[
    If $f: RR^n -> RR^m$ is differentiable at $a  in  RR^n$, then the matrix
    representation of $Df(a)$ in the standard basis is given by $ 
        [Df(a)] = [ pp(f_i, x_j) (a)]_(i j).
    $  
]

#lemma[
    Let $f: RR^n -> RR^m$ be differentiable at $a  in  RR^n$, and let $g: RR^m
    -> RR^k$ be differentiable at $f(a)  in  RR^m$. Then, the matrix
    representation of $D(g compose  f)(a)$ in the standard basis is the
    product $ 
        [D(g compose  f)(a)] = [Dg(f(a))][Df(a)] = [ sum _( ell  = 1)^m
         pp(g_i, y_ ell )  pp(f_ ell , x_j) ]_(i j).
    $  In other words, $ 
         pp(, x_j) (g compose  f)_i(a) =  sum _( ell  = 1)^m  pp(g_i, y_ ell ) (f(a))
         pp(f_ ell , x_j) (a).
    $  
]

#example[
    Let $f: RR^2-> RR$ be differentiable, and let $ Gamma (f) = {(x, y, f(x,
    y)): x, y  in  RR}$ be the graph of $f$. Now, let $gamma : [-1, 1] ->
    Gamma (f)$ be a differentiable curve, represented by $ 
         gamma (t) = (g(t), h(t), f(g(t), h(t))).
    $  Then, we can compute the derivative $ 
         gamma '(a) = (g'(a), h'(a), lr(g'(a) pp(f, x)  + h'(a) pp(f, y) 
            \|)_((g(a), h(a))))
    $  
]

#exercise[
    Consider the inner product map, $ ip( dot.c ,  dot.c ) : RR^n  times RR^n
    -> RR$. What is its derivative?
    #solution[
        We treat the inner product as a map $g: RR^(2n) -> RR$, which acts
        as $ 
             ip( vx ,  vy )  colon.eq g(x_1,  dots , x_n, y_1,  dots , y_n) = x_1y_1 +
             dots  + x_n y_n.
        $  Now, note that $ 
             pp(g, x_i)  = y_i,  quad   pp(g, y_i)  = x_i.
        $  Thus, $
            Dg( va ,  vb )( vx ,  vy ) &=  sum _(i = 1)^n x_i  pp(g, x_i) ( va ,  vb ) +
             sum _(i = 1)^n y_i  pp(g, y_i) ( va ,  vb ) \
            &=  sum _(i = 1)^n x_i b_i +  sum _(i = 1)^n y_i a_i \
            &=  ip( vx ,  vb )  +  ip( vy ,  va ) .
        $
        In other words, the matrix representation of the derivative of the inner
        product map at the point $( va ,  vb )$ is given by $[ vb^top
         va^top]$.
    ]
]

#exercise[
    Let $gamma : RR -> RR^n$ be a differentiable curve. What is the
    derivative of the real map $t  mapsto   norm( gamma (t)) ^2$?
    #solution[
        We write this map as $t  mapsto   ip( gamma (t),  gamma (t)) $. Consider the
        scheme $
            RR -> RR^(2n) -> RR, quad
            t  mapsto  mat(
                 gamma (t) ;  gamma (t)
            )  mapsto   ip( gamma (t),  gamma (t)) .
        $  Pick a point $t in  RR$, whence the derivative of the map at $t$ is $ 
            mat(
                 gamma (t)^top ,  gamma (t)^top
            ) mat(
                 gamma '(t) ;  gamma '(t)
            ) = 2 ip( gamma (t),  gamma '(t)) .
        $
    ]
    #remark[
        Consider the surface $S^(n - 1)  subset  RR^n$, and pick an arbitrary
        differentiable curve $gamma : RR -> S^(n - 1)$. Now, the tangent
        vector $gamma '(t)$ is tangent to the sphere $S^(n - 1)$ at any point
        $gamma (t)$. We claim that this tangent drawn at $ gamma (t)$ is always
        perpendicular to the position vector $ gamma (t)$. This is made trivial by
        our exercise: the map $t  mapsto   norm( gamma (t)) ^2 = 1$ is a constant
        map since $gamma$ is a curve on the unit sphere. This means that it has
        zero derivative, forcing $ ip( gamma (t),  gamma '(t))  = 0$.
    ]
]

== Directional derivatives

#definition[
    Let $U  subset.eq  RR^n$ be open, and let $f: U -> RR$. The directional
    derivative of $f$ along a direction $ vv   in  RR^n$ at a point $a  in  U$ is
    defined by the following limit, if it exists. $ 
         nabla _v f(a) =  lim _(h -> 0)   frac(f(a + h vv ) - f(a), h)  .
    $  
]

#example[
    Consider $ 
        f: RR^2 -> RR,  quad  (x, y)  mapsto  cases(
            x^3\/(x^2 + y^2)\, & " if "  (x, y)  !=  (0, 0),
            0\, & " if "  (x, y) = (0, 0).
        )
    $  Note that $f$ is not differentiable at $(0, 0)$. However, all
    directional derivatives derivatives of $f$ exist at $(0, 0)$. Indeed,
    consider a direction $( cos  theta , sin theta )$, and examine the limit
    $ 
         lim_(t -> 0)   frac(1, t)  [f(t cos  theta , t sin theta ) - f(0,
        0)] =  cos ^3 theta .
    $  
]

#definition[
    Let $f: RR^n -> RR$ be differentiable. The gradient of $f$ is defined
    as the map $ 
         grad(f) : RR^n -> RR^n,  quad  x  mapsto 
        [ pp(f, x_i) (x)]_i.
    $  
    #remark[
        The gradient at a point $x  in  RR^n$ is thought of as a vector. In
        contrast, the derivative is thought of as a linear transformation.
        Otherwise, we see that $ grad(f) (x) = [Df(x)]$.
    ]
]

#definition[
    Let $C^1(RR^n)$ be the set of real-valued differentiable functions on $RR^n$.
    Fix a point $a  in  RR^n$, then fix a tangent vector $v  in  RR^n$. Then, the
    map $ 
         nabla _v: C^1(RR^n) -> RR,  quad  f mapsto  Df(a)(v)
    $  is a linear functional. The quantity $ nabla _v f$ is called the
    directional derivative of $f$ in the direction $v$ at the point $a$.
    #remark[
        We can represent $ nabla _v$ as the operator $ 
             nabla _v ( dot.c ) = D( dot.c )(a)(v) =  sum _i v_i  lr(pp(, x_i)\|)_a =
            v dot.c   nabla  ( dot.c ).
        $ 
    ]
]

#lemma[
    The directional derivatives $ nabla _v$ form a vector space called the tangent
    space, attached to the point $a  in  RR^n$. This can be identified with the
    vector space $RR^n$ by the natural map $ nabla _v  mapsto  v$. The standard
    basis can be informally denoted by the vectors $ 
         nabla_( ve _1) colon.eq  pp(, x_1) ,  quad dots quad,  nabla _( ve _n) colon.eq  pp(, x_n) .
    $  
]


== Differentiation on manifolds \*

#definition[
    A homeomorphism is a continuous, bijective map whose inverse is also continuous.
]

#lemma[
    Let $f: RR^n -> RR$ be continuous. Denote the graph of $f$ as $ 
         Gamma (f) = \{(x, f(x)): x  in  RR^n\}.
    $  Then, $ Gamma (f)$ is a smooth manifold.
]
#proof[
    Consider the homeomorphism $ 
         phi :  Gamma (f) -> RR^n,  quad  (x, f(x))  mapsto  x.
    $  This is clearly bijective, continuous (restriction of a projection map),
    with a continuous inverse (from the continuity of $f$). Call this
    homeomorphism $phi$ a coordinate map on $Gamma (f)$.
]

#definition[
    Let $f: M -> RR$ where $M$ is a smooth manifold, with a coordinate map
    $phi : M -> RR^n$. We say that $f$ is differentiable at a point $a
     in  M$ if $f compose   phi ^(-1): RR^n -> RR$ is differentiable at
    $ phi (a)$.
]

#definition[
    Let $f: M -> RR$ where $M$ is a smooth manifold, let $ phi : M
    -> RR^n$ be a coordinate map, and let $a  in  M$. Let $gamma : RR -> M$
    be a curve such that $ gamma (0) = a$, and further let $gamma$ be
    differentiable in the sense that $phi  compose   gamma : RR -> RR^n$ is
    differentiable. The directional derivative of $f$ at $a$ along $gamma$ is
    defined as $ 
         dd(, t)  f( gamma (t)) \|_ (t = 0) =  lim _(h -> 0) lr(frac(f( gamma (t +
        h)) - f( gamma (t)), h) \|)_ (t = 0).
    $  Note that we are taking the derivative of $f compose   gamma : RR -> RR$
    in the conventional sense.
]

#lemma[
    Let $ gamma _1$ and $gamma _2$ be two curves in $M$ such that $gamma_1(0) =
     gamma _2(0) = a$, and $ 
         dd(, t) lr( phi  compose  gamma _1(t) \|)_ (t = 0) 
         = dd(, t)  lr( phi  compose  gamma _2(t)  \|)_ (t = 0).
    $  In other words, $gamma _1$ and $ gamma _2$ pass through the same point $a$
    at $t = 0$, and have the same velocities there. Then, the directional
    derivatives of $f$ at $a$ along $gamma _1$ and $ gamma _2$ are the same.
]

#definition[
    Let $M$ be a smooth manifold, and let $a  in  M$. Consider the following
    equivalence relation on the set of all curves $gamma$ in $M$ such that
    $gamma (0) = a$. $ 
         gamma_1 tilde.op gamma_2  quad arrow.r.double.long quad
         dd(, t) lr( phi  compose gamma _1(t)  \|)_ (t = 0) 
         = dd(, t) lr( phi  compose   gamma _2(t) \|)_ (t = 0).
    $ Each resultant equivalence class of curves is called a tangent vector at
    $a  in  M$. Note that all these curves in a particular equivalence class pass
    through $a$ with the same velocity vector.

    The collection of all such tangent vectors, i.e. the space of all curves
    through $a$ modulo the equivalence relation which identifies curves with the
    same velocity vector through $a$, is called the tangent space to $M$ at $a$,
    denoted $T_a M$.

    #remark[
        Each tangent vector $v in  T_a M$ acts on a differentiable function
        $f: M -> RR$ yielding a (well-defined) directional derivative at
        $a$. $ 
            v: C^1(M) -> RR,  quad  f mapsto   dd(, t) 
            lr(f( gamma _v(t)) \|)_ (t = 0).
        $ 
        Thus, the tangent space represents all the directions in which taking a
        derivative of $f$ makes sense.
    ]
    #remark[
        The tangent space $T_a M$ is a vector space. Upon fixing $f$, the map
        $Df(a): T_a M -> RR$, $v  mapsto  v f(a)$ is a linear functional on
        the tangent space.
    ]
    #remark[
        Given a tangent vector $v  in  T_a M$, it can be identified with its
        corresponding velocity vector in $RR^n$. Thus, the tangent space $T_a M$
        can be identified with the geometric tangent plane drawn to the manifold
        $M$ at the point $a$.
    ]
]


= Mean value theorem
Consider a differentiable function $f: RR^n -> RR$, and fix $a  in  RR^n$.
Define the functions $ 
    g_i: RR -> RR,  quad  g_i(x) = f(a_1,  dots , a_(i - 1), x, a_(i + 1),
     dots , a_n).
$  Then, each $g_i$ is differentiable, with $ 
    g_i'(x) =  pp(f, x_i) (a_1,  dots , a_(i - 1), x, a_(i + 1),  dots , a_n).
$  By applying the Mean Value Theorem on some interval $[c, d]$, we can find
$ alpha  in  (c, d)$ such that $g_i(d) - g_i(c) = g_i'( alpha )(d - c)$. In other
words,
$ 
    f( dots , d,  dots ) - f( dots , c,  dots ) =  pp(f, x_i) ( dots ,  alpha ,  dots )(d
    - c).
$

#theorem[
    Let $f: RR^n -> RR^m$ and $a  in  RR^n$. Then, $f$ is differentiable at
    $a$ if all the partial derivatives $diff  f\/diff  x_j$ exist in a
    neighbourhood of $a$ and are continuous at $a$.
]
#proof[
    Without loss of generality, let $m = 1$. We claim that $ 
         lim _(h -> 0)     frac(1,  norm(h)  )  norm(f(a + h) - f(a) -  sum _(i = 0) ^n
         pp(f, x_i) (a)h_i) = 0.
    $  Examine $
        f(a + h) - f(a) &= f(a_1 + h_1,  dots , a_n + h_n) - f(a_1,  dots ,
        a_n) \
        &= f(a_1 + h_1,  dots , a_n + h_n) - f(a_1 + h_1,  dots , a_(n - 1) +
        h_(n - 1), a_n) + \
        &   quad  f(a_1 + h_1,  dots , a_(n - 1) + h_(n - 1), a_n) - f(a_1 + h_1,
         dots , a_(n - 1), a_n) + \
        &   quad   dots.h  \
        &   quad  f(a_1 + h_1, a_2,  dots , a_n) - f(a_1,  dots , a_n) \
        &=  pp(f, x_n) (c_n)h_n +  dots  +  pp(f, x_1) (c_1)h_1.
    $
    The last step follows from the Mean Value Theorem. As $h -> 0$, each $c_i
    -> a$. Thus, $
          frac(1,  norm(h))  norm(f(a + h) - f(a) -  sum _(i = 0)^n
         pp(f, x_i) (a)h_i) 
        &=   frac(1,  norm(h))  norm( sum _(i = 0) ^n (pp(f, x_i)(c_i) -
         pp(f, x_i) (a))h_i) \
        & <=   sum _(i = 0)^n | pp(f, x_i) (c_i) -  pp(f, x_i) (a) |
          frac(|h_i|,  norm(h)  )  \
        & <=   sum _(i = 0)^n | pp(f, x_i) (c_i) -  pp(f, x_i) (a) |.
    $
    Taking the limit $h -> 0$, observe that $(diff  f\/diff  x_i) (c_i) ->
    (diff  f \/ diff  x_i) (a)$ by the continuity of the partial derivatives,
    completing the proof.
]

#corollary[
    All polynomial functions on $RR^n$ are differentiable.
]

#theorem[
    Let $f: RR^n -> RR$ be differentiable with continuous partial
    derivatives, and let $a  in  RR^n$ be a point of local maximum. Then, $Df(a) =
    0$.
]
#proof[
    We need only show that each $ 
         pp(f, x_i) (a) = 0.
    $  This must be true, since $a$ is also a local maximum of each of the
    restrictions $g_i$ as defined earlier.
]

= Inverse and implicit function theorems
#theorem(name: [Inverse function theorem])[
    Let $f: RR^n -> RR^n$ be continuously differentiable on a neighbourhood
    of $a  in  RR^n$, and let $"det" (Df(a))  !=  0$. Then, there exist neighbourhoods
    $U$ of $a$ and $W$ of $f(a)$ such that the restriction $f: U -> W$ is
    invertible. Furthermore, $f^(-1)$ is continuous on $U$ and differentiable on
    $U$.
]

#lemma[
    Consider a continuously differentiable function $f: RR^n -> RR$, and
    let $M$ denote the surface defined by the zero set of $f$. Then, $M$ can be
    represented as the graph of a differentiable function $h: RR^(n - 1) ->
    RR$ at those points where $Df  !=  0$.
]
#proof[
    Without loss of generality, suppose that $diff  f \/ diff  x_n  !=  0$
    at some point $a  in  M$. It can be shown that the map $ 
        F: RR^n -> RR^n ,  quad  x  mapsto  (x_1, x_2,  dots , x_(n - 1),
        f(x))
    $  is invertible in a neighbourhood $W$ of $a$, with a continuous and
    differentiable inverse of the form
    $ 
        G: RR^n -> RR^n,  quad  u  mapsto  (u_1, u_2,  dots , u_(n - 1),
        g(u)).
    $
    Since $F compose G$ must be the identity map on $W$, we demand $ 
        (x_1, x_2,  dots , x_(n - 1), f(x_1, x_2,  dots , x_(n - 1), g(x))) = (x_1,
        x_2,  dots , x_(n - 1), x_n).
    $  Thus, the zero set of $f$ in this neighbourhood of $a$ satisfies $x_n =
    0$, hence $ 
        f(x_1, x_2,  dots , x_(n - 1), g(x_1, x_2,  dots , x_(n - 1), 0)) = 0.
    $  In other words, the part of the surface $M$ in the neighbourhood of $a$ is
    precisely the set of points $ 
        (x_1, x_2,  dots , x_(n - 1), g(x_1, x_2,  dots , x_(n - 1), 0)).
    $  Simply set $ 
        h: RR^(n - 1) -> RR,  quad  x  mapsto  g(x_1, x_2,  dots , x_(n - 1),
        0),
    $  whence the surface $M$ is locally represented by the graph of $h$.
]

#block(inset: 1em)[
#remark()[
    Note that by using $ 
        f(x_1,  dots , x_(n - 1), h(x_1,  dots , x_(n - 1))) = 0
    $  on the surface, we can use the chain rule to conclude that for all $1  <= 
    i < n$, we have $ 
         pp(f, x_i) (a) +  pp(f, x_n) (a) pp(h, x_i) (a_1,  dots , a_(n - 1)) = 0.
    $  
]
]

#theorem(name: [Implicit function theorem])[
    Let $f: RR^n times RR^m -> RR^m$ be continuously differentiable in an open
    set containing $(a, b)$, with $f(a, b) = 0$. Let $"det" (diff  f^j \/ diff
    x_(n + k) (a, b))  !=  0$. Then, there exists an open set $U  subset RR^n$
    containing $a$, an open set $V  subset  RR^m$ containing $b$, and a
    differentiable function $g: U -> V$ such that $f(x, g(x)) = 0$.

    #remark[
        The condition on the determinant can be rephrased as
        $"rank" Df(a, b) = m$.
    ]
]

#theorem[
    Let $f: RR^n -> RR$ be continuously differentiable, and let $M$ be the
    surface defined by its zero set. Furthermore, let $ grad(f) (a)  !=  0$ for
    some $a  in  M$; thus, $M$ can be locally represented by a graph on $RR^(n
    - 1)$. Then, $ grad(f) (a)$ is normal to the tangent vectors drawn at $a$
    to $M$; in fact, the perpendicular space of $ grad(f) (a)$ is precisely
    the tangent space $T_a M$.
]
#proof[
    Consider a tangent vector drawn at $a$ to $M$, represented by the
    differentiable curve $gamma : RR -> M$, $ gamma (0) = a$; note that
    we use the identification $gamma '(0) = v  in  RR^n$. Then, calculate $ 
         dd(, t) lr(f( gamma (t))  \|)_ (t = 0) = Df( gamma (0))( gamma '(0))
         = Df(a)(v).
    $  On the other hand, we have $f( gamma (t)) = 0$ identically. Thus, $ 
        v dot.c   grad(f) (a) = Df(a)(v) = 0
    $ as claimed.
]

= Taylor's theorem

#theorem(name: "Clairaut")[
    Let $f: RR^n -> RR$ have continuous second order partial derivatives.
    Then, $ 
          frac(diff ^2 f, diff  x_i diff  x_j)   = frac(diff ^2
        f, diff  x_j diff  x_i).
    $
]

#theorem(name: "Taylor")[
    Let $f: RR^2 -> RR$ have continuous second order partial derivatives,
    and let $(x_0, y_0)  in  RR^2$. Then, there exists $ epsilon  > 0$ such that
    for all $norm((x - x_0, y - y_0))  <  epsilon$,
    $
        f(x, y)   =   &f(x_0, y_0) +  pp(f, x) (x - x_0) +  pp(f, y) (y - y_0) \
        & + space frac(1, 2)  frac(diff^2 f, diff x^2)(x - x_0)^2 + frac(1, 2)
        frac(diff^2 f, diff y^2)(y - y_0)^2 \
        & + space frac(diff ^2 f, diff  x diff  y)  (x - x_0)(y - x_0) + R(x,
        y),
    $
    where as $(x, y) -> (x_0, y_0)$, the remainder term vanishes as $ 
          frac(|R(x, y)|,  norm((x - x_0, y - y_0) ) ^2)  -> 0.
    $  All partial derivatives here are evaluated at $(x_0, y_0)$.
]
#proof[
    This follows from applying the Taylor's Theorem in one variable to the real
    function $g: RR -> RR$, $t  mapsto  f((1 - t)(x_0, y_0) + t(x, y))$.
]


= Critical points and extrema
#definition[
    We say that $a  in  RR^n$ is a critical point of $f: RR^n -> RR$ if all
    $diff  f \/ diff  x^j = 0$ there.
]

#lemma[
    All points of extrema of a differentiable function are critical points.
]
#proof[
    We already know that $Df(a) = 0$ where $a$ is either a point of maximum or
    minimum.
]

#example[
    In order to find a point of extrema of a $C^2$-smooth function $f: RR^2
    -> RR$, we first identify a critical point $(x_0, y_0)$. Next, we must find
    a neighbourhood of $(x_0, y_0)$ which contains no other critical points -- to
    do this, apply Taylor's Theorem. Indeed, we see that $ 
        f(x, y) = f(x_0, y_0) + A(x - x_0)^2 + 2B(x - x_0)(y - y_0) + C(y -
        y_0)^2 + R_2.
    $  For non-degeneracy of solutions, we demand $A C - B^2  !=  0$, i.e. at
    $(x_0, y_0)$, we want $ 
        [  frac(diff ^2 f, diff  x diff  y)  ]^2  != 
          frac(diff ^2 f, diff  x^2)  
          frac(diff ^2 f, diff  y^2)  .
    $  

    If $A C - B^2 > 0$ and $diff ^2f \/ diff  x^2 > 0$, then we have found a
    point of minima; if $diff ^2 f \/ diff  x^2 < 0$, then we have found a
    point of maximum. If $A C - B^2 < 0$, then we have found a saddle point.
]

#example[
    Suppose that we wish to maximize the function $f: RR^2 -> RR$, given an
    equation of constraint $g = 0$, where $g: RR^2 -> RR$. Using the method
    of Lagrange multipliers, we look for solutions of the system $ 
        cases(
            grad(f) (x, y) +  lambda   grad(&g) (x, y) &= 0,
            &g(x, y) &= 0.
        )
    $
]
