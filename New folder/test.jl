using PkgTemplates

t = Template(;
    user="bmyksvoll",
    authors=["your-name"],
    plugins=[
        License(name="MIT"),
        Git(),
        GitHubActions(),
    ],
)


t("EquinorCommodityQuant.jl")