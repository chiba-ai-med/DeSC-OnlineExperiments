using SparseArrays
using MatrixMarket

# 引数の取得
outfile = ARGS[1]
nrows = parse(Int, ARGS[2])

# Setting
ncols = 7581  # 列数
I = Int[]
J = Int[]
V = Int[]

for i in 1:nrows
    nz = rand(1:2)  # 非ゼロ要素数
    cols = rand(1:ncols, nz)  # 列位置をランダムに選ぶ
    vals = ones(Int, nz)  # 値は0～1の一様乱数

    append!(I, fill(i, nz))
    append!(J, cols)
    append!(V, vals)
end

# Output
S = sparse(I, J, V, nrows, ncols)
mmwrite(outfile, S)
