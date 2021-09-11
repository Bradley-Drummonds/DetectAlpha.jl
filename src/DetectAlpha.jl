module DetectAlpha

@enum DecayType α β γ n
# Write your package code here.
struct Radiation
    particle::Bool
    type::DecayType
    energy::Float32
    Radiation() = new(true,α,6.5)
end

export Radiation,DecayType,α,β 
end
