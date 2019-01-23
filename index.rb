infile = File.open("ctrl.csv", "r")

class Tree #クラスTreeを定義
	attr_accessor :num, :x, :y, :spp, :dbh01, :dbh04, :hgt #インスタンス変数を読み書きするためのアクセサメソッドを定義
	def initialize( line ) #オブジェクト作成時必ず実行される処理.()内をlineに読み込む
		buf = line.chop.split(",")#lineの最後の文字を消し(chop),","を区切り文字とした配列をbufに読み込み
		
		@num = buf[0].to_i#配列の1列目を整数型に変換して@numに格納。@numはインスタンス変数
		@x   = buf[1].to_f#浮動小数点型。後は同上
		@y   = buf[2].to_f
		@spp = buf[3]
		@dbh01=buf[4].to_f
		@dbh04=buf[5].to_f
		@hgt = buf[6].to_f
	end

	def dgrw#dgrwは成長量
		@dbh04-@dbh01
	end
end

def sq (_flt)
	return _flt * _flt
end
def dist( tree_a, tree_b )
	return Math::sqrt(sq(tree_a.x - tree_b.x) + sq(tree_a.y - tree_b.y))#木aと木bの距離。sqは上で定義されている
end


def edge_effect( a, x, y )#エッジ効果は林縁部にかかる効果
	if  y > x	# yがxより大きかったらxとyを入れ替えるためのif　よって常にx>y
		_tmp = x
		x = y
		y = _tmp
	end

	#####################
	if( x >a && y >a )
		return 1.0
	else
		if( x > a && y < a )
			return( Math::PI*sq(a) - sq(a)*Math::acos(y/a) + y*Math::sqrt( sq(a)-sq(y) ) ) / (sq(a)*Math::PI)
		else
			if( x*y < a * a )
				return ( Math::PI*sq(a)/4 + x*y+ x*Math::sqrt( sq(a)-sq(x) )/2 + y*Math::sqrt( sq(a) -sq(y) )/2 + sq(a)*Math::asin(x/a)/2 + sq(a)*Math::asin(y/a)/2 ) / ( sq(a) * Math::PI )
			else
				return ( sq(a) * Math::PI - sq(a)*Math::acos(x/a) + x*Math::sqrt( sq(a)-sq(x) ) -sq(a)*Math::acos(y/a) + y*Math::sqrt( sq(a) -sq(y) ) )/ (sq(a) * Math::PI )
			end
		end
	end
end

############## read file
trees = Array.new#treesを配列として定義
infile.each do |line|#1行目で読み込んだinfileの1行目だけ取り除いてTreeに入れ込む処理？
	if line =~/^#/
	else
		trees.push( Tree.new(line) )
	end
end

############### Calculate

print "#Num, x, y, spp, dbh01, dbh04, hgt, crd1, crd2, crd3, crd4, crd5, crd6, crd7, crd8, crd9\n"

trees.each do |target|
	print target.num, ","
	print target.x, ","
	print target.y, ","
	print target.spp, ","
	print target.dbh01, ","
	print target.dbh04, ","
	print target.hgt, ","
			edge_x = ( target.x > 50 )? 100-target.x: target.x#座標が50以上なら100-50にして端からの距離に
		edge_y = ( target.y > 25 )? 50-target.y : target.y#同上
		[1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0].each do |lim_dist|#9回作業を繰り返す
		efct = 0.0
		trees.each do | obj |#treesのデータがobjに格納された上で以下の処理を繰り返す
			if obj.num != target.num#obj.num≠target.numberならば･･･
				_dist =dist(target, obj)#targetとobjの距離を_distで返す
				if _dist < lim_dist && _dist > 0.0#もしtargetとobjectの距離が0~9なら(lim_distより)
					efct += obj.dbh04 / _dist#efct=対象木のdbh/対象木までの距離の合計！合計だよ！！！
				end
			end
		end
		 




		print  efct/edge_effect( lim_dist, edge_x, edge_y)
        if lim_dist != 9.0
			print ","
		else
			print "\n"
		end
		
	
	end
end