using DetectAlpha
using Documenter

DocMeta.setdocmeta!(DetectAlpha, :DocTestSetup, :(using DetectAlpha); recursive=true)

makedocs(;
    modules=[DetectAlpha],
    authors="Brad D",
    repo="https://github.com/Bradley-Drummonds/DetectAlpha.jl/blob/{commit}{path}#{line}",
    sitename="DetectAlpha.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Bradley-Drummonds.github.io/DetectAlpha.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Bradley-Drummonds/DetectAlpha.jl",
)
