module Statistics

export SerializablePatient
mutable struct SerializablePatient
    Greal::Array{Float64,1}
    SerializablePatient() = new()
end

end