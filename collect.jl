using DataFrames
using CSV

function find_latest(to_find)
    latest_file = ""
    latest_job_id = 0
    for file in readdir(".")
        if isfile(file)
            if occursin(to_find, file) && occursin(".out", file) 
                for match in eachmatch(r"(\d+)\.out$", file)
                    display(match.match)
                    job_id = parse(Int, split(match.match, ".")[1])
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
for comm in [["mpi1", "mpirma", "mpishm"];["mpiomp_" * string(Int(i)) for i in logrange(1, 128, 8)]]
    for problem_size in [49152]
        for n in 2 .^ range(5, 16)
            to_find = join([comm, n, problem_size, problem_size], "_")
            file = find_latest(to_find)
            if file == ""
                println(" ", to_find, " not found")
                continue
            end
            output = read(file, String)
            validates = occursin("Solution validates", output)
            splitted = split(output)
            found = findfirst(v -> v == "(MFlops/s):", splitted)
            mflops_per_s = if found == nothing
                0.0
            else
                parse(Float64, splitted[found + 1])
            end
            push!(df,(
                Communication = comm,
                Ranks = n,
                MFlops_per_s = mflops_per_s,
                Validates = validates,
           ))
        end
    end
end

display(df)
CSV.write("results.csv", df)
