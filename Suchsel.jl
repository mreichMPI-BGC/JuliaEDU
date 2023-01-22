using CairoMakie
using Chain

function makeSuchsel2(words::Vector{String})
    n = max(length(words), maximum(length.(words))) + 2
    matr = fill( ' ', n , n)
    m_empty = trues(n, n)
    c = vec(CartesianIndices(matr)) |> collect
    for w in words
        inserted = false
        direction = rand([CartesianIndex(1,0), CartesianIndex(1,-1), CartesianIndex(0,-1)])
        ntry=0
        while !inserted && ntry < 1e6
            pos=rand(c)
            for i in 1:length(w)
                if (pos in c) && m_empty[pos]
                  matr[pos] = w[i]
                  m_empty[pos] = false
                  pos += direction
                else
                    for j in 1:(i-1) 
                        pos -= direction
                        matr[pos] = ' '
                        m_empty[pos] = true
                    end
                    break
                end
                i == length(w) && (inserted=true)
            end
            ntry += 1
        end
       println(w, ": ",  ntry) 
    end
    idx_empty = findall(m_empty)
    matr[idx_empty] = rand('A':'Z' |> collect, length(idx_empty))
    (matr, .!m_empty)
end

function makeSuchsel(words::Vector{String})
    n = max(length(words), maximum(length.(words))) + 7
    matr = fill( ' ', n , n)
    m_empty = trues(n, n)
    c = vec(CartesianIndices(matr)) |> collect
    for w in words
        println(w)
        inserted = false
        while !inserted
            direction = rand([CartesianIndex(1,0), CartesianIndex(1,-1), CartesianIndex(0,-1)])
            pos = rand(c)
            inserted = insertWord!(w, matr, pos, direction)
        end 
        
    end
    m_empty = matr .== ' '
    idx_empty = findall(m_empty)
    matr[idx_empty] = rand('A':'Z' |> collect, length(idx_empty))
    (matr, .!m_empty)
end

function insertWord!(word::String, matr::Matrix{Char}, pos::CartesianIndex, direction::CartesianIndex)
    c = vec(CartesianIndices(matr)) |> collect
    len=length(word)
    inserted = false
       
            for i in 1:len
                if (pos in c) && matr[pos]==' '
                  matr[pos] = word[i]
                  pos += direction
                else
                    for j in 1:(i-1) 
                        pos -= direction
                        matr[pos] = ' '
                    end
                    inserted = false
                    break
                end
                i == len && (inserted=true)
            end
    return inserted
end

function plotLetterMatrix(matr; solution=nothing)
    nr, nc = size(matr)
    isnothing(solution) && (solution = fill(false, nr,nc))
    fig = Figure()
    ax = Axis(fig[1,1])
    hidedecorations!(ax)  # hides ticks, grid and lables
    hidespines!(ax)  #
    for idx in CartesianIndices(matr)
        text!(ax,  string(matr[idx]), position = Tuple(idx), 
        color= solution[idx] ? :red : :black,
        align = (:center, :center))
    end
    fig
end

struct PairWithCoord
    valuePair::Pair
    coordPair::Pair
end

function arrangePairsinMat2(pairs::Any; size=Tuple{Int, Int})

    cInd = CartesianIndices(size) |> vec |> collect

    allPairsinMat = map(pairs) do p
        idx = sample(1:length(cInd), 2, replace=false)
        coordPair = cInd[idx[1]] => cInd[idx[2]]
        deleteat!(cInd, sort(idx))
        return PairWithCoord(p, coordPair)
    end

    return allPairsinMat

end


function plot!( ax, p::PairWithCoord; linkthem=false, jitter=0.3, sizeFac=1)
    hidedecorations!(ax)  # hides ticks, grid and lables
    hidespines!(ax)  #

    pnt1 = Tuple(p.coordPair |> first) .+ Tuple(rand(-jitter..jitter, 2))
    pnt2 = Tuple(p.coordPair |> last) .+ Tuple(rand(-jitter..jitter, 2))

    len1 = length(p.valuePair |> first)
    len2 = length(p.valuePair |> last)

    linkthem && lines!([pnt1, pnt2], color=:black)

    scatter!(pnt1, marker=:circle, markersize=sizeFac * Vec2f(15+17len1,30), color=:white, strokewidth=1)
    scatter!(pnt2, marker=:circle, markersize=sizeFac * Vec2f(15+17len2,30), color=:white, strokewidth=1)
    text!(ax, string(p.valuePair |> first), position=pnt1, align=(0.5,0.5), fontsize=12sizeFac)
    text!(ax, string(p.valuePair |> last), position=pnt2,  align=(0.5,0.5), fontsize=12sizeFac)

end

function plot(ps::AbstractArray{PairWithCoord}; kwargs...) 
    fig = Figure()
    ax = Axis(fig[1,1])
    foreach(ps) do p
        plot!(ax, p; kwargs...)
    end
    fig
end

function randExercise(openrandSet=collect(1:10), operator=+)

    o1, o2 = rand(openrandSet, 2)
    solution = operator(o1, o2)
    exercise = "$o1 $operator $o2" => "$solution"
    return exercise

end


prs = [x => x for x in sample(100:1000, 12, replace=false)]
##OR
#prs = [Char(x) => Char(x) for x in sample(9824:9854, 12, replace=false)] ## Funny Unicode chars
## OR
prs = [randExercise() for x in 1:12] ## Random math exercise
prm = arrangePairsinMat2(prs, size=(6,6))
fig = plot(prm;sizeFac=1.6) # puzzle
save("Task.pdf", fig)

fig= plot(prm;sizeFac=1.4, linkthem=true) # solution
save("Solution.pdf", fig)



##
words=["JANUAR", "FEBRUAR", "MAERZ", "APRIL", "MAI", "JUNI", "JULI", "AUGUST", "SEPTEMBER",
"OKTOBER", "NOVEMBER", "DEZEMBER"]
words = ["MONTAG", "DIENSTAG", "MITTWOCH", "DONNERSTAG", "FREITAG", "SAMSTAG", "SONNTAG"]

words = uppercase.(["Gips", "Rubin", "Diamant", "Smaragd", "Saphir", "Wismut"])
suchsel, solution = makeSuchsel(words)
fig = plotLetterMatrix(suchsel)
fig_with_solution = plotLetterMatrix(suchsel, solution=solution)

save("Steine.pdf", fig)
save("SteineLoesung.pdf", fig_with_solution)