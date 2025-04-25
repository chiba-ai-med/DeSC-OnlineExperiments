# 引数の取得
outfile = ARGS[1]
nrows = parse(Int, ARGS[2])

# Setting
ncols = 7581  # 列数

open(outfile, "w") do io
    for i in 1:nrows
        nz = rand(1:2)  # 非ゼロ要素数（1〜2個）
        cols = rand(1:ncols, nz)  # ランダムな列番号
        for col in cols
            println(io, "$i $col")  # 行番号と列番号のみを書き出す
        end
    end
end