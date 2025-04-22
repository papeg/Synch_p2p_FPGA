using DataFrames
using CSV

function find_latest(comm, num_ranks)
    latest_file = ""
    latest_job_id = 0
    for file in readdir(".")
        if isfile(file)
            if occursin(comm, file) && occursin("_" * string(num_ranks) * "-", file) && occursin(".out", file) 
                for match in eachmatch(r"\d+", file)
                    job_id = parse(Int, match.match)
                    if job_id > latest_job_id
                        latest_file = file
                        latest_job_id = job_id
                    end
                end
            end
        end
    end
    return latest_file
end

df = DataFrame(Communication = String[], Ranks = Int[], MFlops_per_s = Float64[], Validates = Bool[])
for comm in ["mpi1", "mpiomp", "mpirma", "mpishm"]
    for n in 2 .^ range(5, 16)
        file = find_latest(comm, n)
        if file == ""
            println(n, " ", comm, " found")
            continue
        end
        output = read(file, String)
        validates = occursin("Solution validates", output)
        splitted = split(output)
        mflops_per_s = parse(Float64, splitted[findfirst(v -> v == "(MFlops/s):", splitted) + 1])
        push!(df,(
            Communication = comm,
            Ranks = n,
            MFlops_per_s = mflops_per_s,
            Validates = validates,
       ))
    end
end

display(df)
CSV.write("results.csv", df)
