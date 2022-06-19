""" model function for an isotope """
function alphamodel(x,var)
    μ = var[1]
    σ = var[2]
    τ = var[3]
    A = var[4]
    amp = A / 2τ 
    oneOverSqrt2 = 1.0 / √2 
    sigScaledByTau  = σ / τ  
    return @.  amp * exp((x - μ ) / τ + (sigScaledByTau^2) ) * erfc( oneOverSqrt2 * ((x - μ ) / σ  +  sigScaledByTau ))
end