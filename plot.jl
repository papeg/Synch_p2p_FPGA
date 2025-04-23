using DataFrames
using CSV
using CairoMakie

df = CSV.read("results.csv", DataFrame)

fig = Figure(size=(1280, 800))

xticks = 2 .^ range(5, 16)

ax = Axis(fig[1, 1], xlabel="Cores", ylabel="MFLOPs", xscale=log2, xticks = (xticks, string.(xticks)), ytickformat = "{:}", title = "Synch_p2p")

data = []

for df_group in groupby(df, "Communication")
    push!(data, lines!(ax, df_group[!, "Ranks"], df_group[!, "MFlops_per_s"], label="$(first(df_group[!, "Communication"]))"))
end

Legend(fig[1, 2], [d for d in data], [d.label for d in data])

save("plot.pdf", fig)
